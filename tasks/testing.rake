require_relative './testing/mspec_special_calls'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

module Testing
  extend self

  def stubs
    %w[
      mspec/helpers/tmp
      mspec/helpers/environment
      mspec/guards/block_device
      mspec/guards/endian
    ]
  end

  def specs(env = ENV)
    excepting = []
    rubyspecs = File.read('spec/rubyspecs').lines.reject do |l|
      l.strip!
      l.start_with?('#') || l.empty? || (l.start_with?('!') && excepting.push(l.sub('!', 'spec/') + '.rb'))
    end.flat_map do |path|
      path = "spec/#{path}"
      File.directory?(path) ? Dir[path+'/*.rb'] : "#{path}.rb"
    end - excepting

    filters = Dir['spec/filters/**/*.rb']
    shared = Dir['spec/{opal,lib/parser}/**/*_spec.rb'] + ['spec/lib/lexer_spec.rb']

    specs = []
    add_specs = ->(name, new_specs) { p [new_specs.size, name]; specs + new_specs}

    specs = add_specs.(:filters, filters)
    pattern = env['PATTERN']
    whitelist_pattern = !!env['RUBYSPECS']

    if pattern
      custom = Dir[pattern]
      custom &= rubyspecs if whitelist_pattern
      specs = add_specs.(:custom, custom)
    elsif env['SUITE'] == 'opal'
      specs = add_specs.(:shared, shared)
    elsif env['SUITE'] == 'rubyspec'
      specs = add_specs.(:rubyspecs, rubyspecs)
    else
      warn 'Please provide at lease one of the following ENV vars:'
      warn 'PATTERN # e.g. env PATTERN="spec/rubyspec/core/numeric/**_spec.rb"'
      warn 'SUITE   # can be either SUITE=opal or SUITE=rubyspec'
      exit 1
    end
  end

  def write_file(filename, specs, bm_filepath = nil)
    requires = specs.map{|s| "require '#{s.sub(/^spec\//,'')}'"}

    if bm_filepath
      enter_benchmarking_mode = "OSpecRunner.main.bm!(#{Integer(ENV['BM'])}, '#{bm_filepath}')"
    end

    File.write filename, <<-RUBY
      require 'spec_helper'
      #{enter_benchmarking_mode}
      #{requires.join("\n    ")}
      OSpecRunner.main.did_finish
    RUBY
  end

  def bm_filepath
    mkdir_p 'tmp/bench'
    index = 0
    begin
      index += 1
      bm_filepath = "tmp/bench/Spec#{index}"
    end while File.exist?(bm_filepath)
  end
end

pattern_usage = <<-DESC
Use PATTERN and env var to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the rubyspecs filters will still apply)
  env PATTERN="spec/rubyspec/core/module/class_variable*_spec.rb" rake mspec_node
  env PATTERN="spec/rubyspec/core/numeric/**_spec.rb" rake mspec_node
DESC

%w[rubyspec opal].each do |suite|
  desc "Run the MSpec/#{suite} test suite on Phantom.js" + pattern_usage
  task :"mspec_#{suite}_phantom" do
    filename = File.expand_path('tmp/mspec_phantom.rb')
    runner   = "#{__dir__}/testing/phantomjs1-sprockets.js"
    port     = 9999
    url      = "http://localhost:#{port}/"

    mkdir_p File.dirname(filename)
    Testing.write_file filename, Testing.specs('SUITE' => suite)

    Testing.stubs.each {|s| ::Opal::Processor.stub_file s }

    Opal::Config.arity_check_enabled = true
    Opal::Config.freezing_stubs_enabled = false
    Opal::Config.tainting_stubs_enabled = false
    Opal::Config.dynamic_require_severity = :error

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

  desc "Run the MSpec test suite on Node.js" + pattern_usage
  task :"mspec_#{suite}_node" do
    include_paths = '-Ispec -Ilib'

    filename = 'tmp/mspec_node.rb'
    js_filename = 'tmp/mspec_node.js'
    mkdir_p File.dirname(filename)
    bm_filepath = Testing.bm_filepath if ENV['BM']
    Testing.write_file filename, Testing.specs('SUITE' => suite), bm_filepath

    stubs = Testing.stubs.map{|s| "-s#{s}"}.join(' ')

    sh "ruby -rbundler/setup -r#{__dir__}/testing/mspec_special_calls "\
       "bin/opal -gmspec #{include_paths} #{stubs} -rnodejs/io -rnodejs/kernel -Dwarning -A #{filename} -c > #{js_filename}"
    sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"

    if bm_filepath
      puts "Benchmark results have been written to #{bm_filepath}"
      puts "To view the results, run bundle exec rake bench:report"
    end
  end
end

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

task :cruby_tests do
  if ENV.key? 'FILES'
    files = Dir[ENV['FILES'] || 'test/test_*.rb']
    include_paths = '-Itest -I. -Itmp -Ilib'
  else
    include_paths = '-Itest/cruby/test -Itest'
    test_dir = Pathname("#{__dir__}/../test/cruby/test")
    files = %w[
      benchmark/test_benchmark.rb
      ruby/test_call.rb
      opal/test_keyword.rb
    ].flat_map do |path|
      if path.end_with?('.rb')
        path
      else
        glob = test_dir.join(path+"/test_*.rb").to_s
        size = test_dir.to_s.size
        Dir[glob].map { |file| file[size+1..-1] }
      end
    end
  end
  include_paths << ' -Ivendored-minitest'

  requires = files.map{|f| "require '#{f}'"}
  filename = 'tmp/cruby_tests.rb'
  js_filename = 'tmp/cruby_tests.js'
  mkdir_p File.dirname(filename)
  File.write filename, requires.join("\n")

  stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"

  puts "== Running: #{files.join ", "}"

  sh "ruby -rbundler/setup "\
     "bin/opal #{include_paths} #{stubs} -rnodejs -ropal-parser -Dwarning -A #{filename} -c > #{js_filename}"
  sh "NODE_PATH=stdlib/nodejs/node_modules node #{js_filename}"
end

task :mspec    => [:mspec_rubyspec_node, :mspec_rubyspec_phantom, :mspec_opal_node, :mspec_opal_phantom]
task :minitest => [:cruby_tests]
task :test_all => [:rspec, :mspec, :minitest]


if (current_suite = ENV['SUITE'])
  # Legacy tasks, only if ENV['SUITE'] is set
  desc "Deprecated: use mspec_rubyspec_phantom or mspec_opal_phantom instead"
  task :mspec_phantom => :"mspec_#{current_suite}_phantom"

  desc "Deprecated: use mspec_rubyspec_node or mspec_opal_node instead"
  task :mspec_node    => :"mspec_#{current_suite}_node"
else
  task :mspec_phantom => [:mspec_opal_phantom, :mspec_rubyspec_phantom]
  task :mspec_node => [:mspec_opal_node, :mspec_rubyspec_node]
end
