# Remove when we drop support for 1.9.3
__dir__ = defined?(Kernel.__dir__) ? Kernel.__dir__ : File.dirname(File.realpath(__FILE__))

require "#{__dir__}/testing/mspec_special_calls"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

module MSpecSuite
  extend self

  def stubs
    %w[
      mspec/helpers/tmp
      mspec/helpers/environment
      mspec/guards/block_device
      mspec/guards/endian
      a_file
      lib/spec_helper
    ]
  end

  def specs(env = ENV)
    suite = env['SUITE']
    pattern = env['PATTERN']
    whitelist_pattern = !!env['RUBYSPECS']

    excepting = []
    rubyspecs = File.read('spec/ruby_specs').lines.reject do |l|
      l.strip!
      l.start_with?('#') || l.empty? || (l.start_with?('!') && excepting.push(l.sub('!', 'spec/') + '.rb'))
    end.flat_map do |path|
      path = "spec/#{path}"
      File.directory?(path) ? Dir[path+'/*.rb'] : "#{path}.rb"
    end - excepting

    opalspecs = Dir['spec/{opal,lib/parser}/**/*_spec.rb']
    userspecs = Dir[pattern] if pattern
    userspecs &= rubyspecs if whitelist_pattern

    opalspec_filters = Dir['spec/filters/**/*_opal.rb']

    if ENV['INVERT_RUNNING_MODE']
      # When we run an inverted test suite we should run only 'bugs'.
      # Unsupported features are not supported anyway
      rubyspec_filters = Dir['spec/filters/bugs/*.rb'] - opalspec_filters
    else
      rubyspec_filters = Dir['spec/filters/**/*.rb'] - opalspec_filters
    end

    specs = []
    add_specs = ->(name, new_specs) do
      puts "Adding #{new_specs.size.to_s.rjust(3)} files (#{name})"
      specs += new_specs
    end

    # Filters must be added first
    suite_filters = suite == 'opal' ? opalspec_filters : rubyspec_filters
    add_specs["#{suite} filters", suite_filters]

    if pattern
      add_specs["PATTERN=#{pattern}", userspecs]
    elsif suite == 'opal'
      add_specs['spec/opal', opalspecs]
    elsif suite == 'ruby'
      add_specs['spec/ruby', rubyspecs]
    else
      warn 'Please provide at lease one of the following environment variables:'
      warn 'PATTERN # e.g. PATTERN=spec/ruby/core/numeric/**_spec.rb'
      warn 'SUITE   # can be either SUITE=opal or SUITE=ruby'
      exit 1
    end

    specs
  end

  def write_file(filename, specs, bm_filepath = nil)
    requires = specs.map{|s| "require '#{s.sub(/^spec\//,'')}'"}

    if bm_filepath
      enter_benchmarking_mode = "OSpecRunner.main.bm!(#{Integer(ENV['BM'])}, '#{bm_filepath}')"
    end

    File.write filename, <<-RUBY
      require 'spec_helper'
      require 'opal/full'
      OSpecRunner.main.will_start
      #{enter_benchmarking_mode}
      #{requires.join("\n    ")}
      OSpecFilter.main.unused_filters_message(list: #{!!ENV['LIST_UNUSED_FILTERS']})
      OSpecRunner.main.did_finish
      exit MSpec.exit_code
    RUBY
  end

  def bm_filepath
    mkdir_p 'tmp/bench'
    index = 0
    begin
      index += 1
      filepath = "tmp/bench/Spec#{index}"
    end while File.exist?(filepath)
    filepath
  end
end

pattern_usage = <<-DESC
Use PATTERN environment variable to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the ruby_specs filters will still apply)
  bundle exec rake mspec_node PATTERN=spec/ruby/core/module/class_variable*_spec.rb
  bundle exec rake mspec_node PATTERN=spec/ruby/core/numeric/**_spec.rb
DESC

%w[ruby opal].each do |suite|
  desc "Run the MSpec/#{suite} test suite on Opal::Sprockets/phantomjs" + pattern_usage
  task :"mspec_#{suite}_sprockets_phantomjs" do
    filename = File.expand_path('tmp/mspec_sprockets_phantomjs.rb')
    runner   = "#{__dir__}/testing/sprockets-phantomjs.js"
    port     = 9999
    url      = "http://localhost:#{port}/"

    mkdir_p File.dirname(filename)
    MSpecSuite.write_file filename, MSpecSuite.specs(ENV.to_hash.merge 'SUITE' => suite)

    MSpecSuite.stubs.each {|s| ::Opal::Config.stubbed_files << s }

    Opal::Config.arity_check_enabled = true
    Opal::Config.freezing_stubs_enabled = true
    Opal::Config.tainting_stubs_enabled = false
    Opal::Config.dynamic_require_severity = :warning

    Opal.use_gem 'mspec'
    Opal.append_path 'spec'
    Opal.append_path 'lib'
    Opal.append_path File.dirname(filename)

    app = Opal::Server.new { |s| s.main = File.basename(filename) }
    server = Thread.new { Rack::Server.start(app: app, Port: port) }
    sleep 1

    begin
      sh 'phantomjs', runner, url
    ensure
      server.kill if server.alive?
    end
  end

  %w[nodejs phantomjs].each do |platform|
    desc "Run the MSpec test suite on Opal::Builder/#{platform}" + pattern_usage
    task :"mspec_#{suite}_#{platform}" do
      include_paths = '-Ispec -Ilib'

      filename = "tmp/mspec_#{platform}.rb"
      mkdir_p File.dirname(filename)
      bm_filepath = MSpecSuite.bm_filepath if ENV['BM']
      MSpecSuite.write_file filename, MSpecSuite.specs(ENV.to_hash.merge 'SUITE' => suite), bm_filepath

      stubs = MSpecSuite.stubs.map{|s| "-s#{s}"}.join(' ')

      sh "ruby -rbundler/setup -r#{__dir__}/testing/mspec_special_calls "\
         "bin/opal -gmspec -gast -gparser #{include_paths} #{stubs} -R#{platform} -Dwarning -A #{filename}"

      if bm_filepath
        puts "Benchmark results have been written to #{bm_filepath}"
        puts "To view the results, run bundle exec rake bench:report"
      end
    end
  end
end

task :mspec_phantomjs           => [:mspec_opal_phantomjs,           :mspec_ruby_phantomjs]
task :mspec_nodejs              => [:mspec_opal_nodejs,              :mspec_ruby_nodejs]
task :mspec_sprockets_phantomjs => [:mspec_opal_sprockets_phantomjs, :mspec_ruby_sprockets_phantomjs]

task :jshint do
  js_filename = 'tmp/jshint.js'
  mkdir_p 'tmp'

  if ENV['SUITE'] == 'core'
    sh "ruby -rbundler/setup bin/opal -ce '23' > #{js_filename}"
    sh "jshint --verbose #{js_filename}"
  elsif ENV['SUITE'] == 'stdlib'
    sh "rake dist"

    Dir["build/*.js"].each {|path|
      unless path =~ /(opal.*js)|.min.js/
        sh "jshint --verbose #{path}"
      end
    }
  else
    warn 'Please provide at lease one of the following ENV vars:'
    warn 'SUITE   # can be either SUITE=core or SUITE=stdlib'
    exit 1
  end
end


module MinitestSuite
  extend self

  def build_js_command(files, options = {})
    includes = options.fetch(:includes, [])
    js_filename = options.fetch(:js_filename, [])

    includes << 'vendored-minitest'
    include_paths = includes.map {|i| " -I#{i}"}.join

    requires = files.map{|f| "require '#{f}'"}
    rb_filename = js_filename.sub(/\.js$/, '.rb')
    mkdir_p File.dirname(rb_filename)
    File.write rb_filename, requires.join("\n")

    stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"

    "ruby -rbundler/setup bin/opal #{include_paths} #{stubs} -Dwarning -A #{rb_filename} -c > #{js_filename}"
  end
end

task :cruby_tests do
  if ENV.key? 'FILES'
    files = Dir[ENV['FILES']]
    includes = %w[test . tmp lib]
  else
    includes = %w[test test/cruby/test]
    files = %w[
      benchmark/test_benchmark.rb
      ruby/test_call.rb
      opal/test_keyword.rb
      base64/test_base64.rb
      opal/unsupported_and_bugs.rb
    ]
  end

  js_filename = 'tmp/cruby_tests.js'
  build_js_command = MinitestSuite.build_js_command(
    %w[
      opal/platform
      opal-parser
    ] + files,
    includes: includes,
    js_filename: js_filename,
  )
  sh build_js_command
  sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"
end

task :test_nodejs do
  js_filename = 'tmp/test_nodejs.js'
  build_js_command = MinitestSuite.build_js_command(
    %w[
      opal-parser.rb
      test_file.rb
    ],
    includes: %w[test/nodejs],
    js_filename: js_filename,
  )
  sh build_js_command
  sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"
end

task :mspec    => [:mspec_phantomjs, :mspec_nodejs, :mspec_sprockets_phantomjs]
task :minitest => [:cruby_tests, :test_nodejs]
task :test_all => [:rspec, :mspec, :minitest]

