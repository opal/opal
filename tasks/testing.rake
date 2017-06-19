require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = 'spec/lib/**/*_spec.rb'
end

module Testing
  extend self

  def get_random_seed(env)
    random_seed = env['RANDOM_SEED'] ? env['RANDOM_SEED'] : rand(100_000)
    puts "export RANDOM_SEED=#{random_seed} # to re-use the same randomization"
    random_seed
  end

  module MSpec
    extend self

    def stubs
      %w[
        mspec/helpers/tmp
        mspec/helpers/environment
        mspec/guards/block_device
        mspec/guards/endian
        a_file
        lib/spec_helper
        mspec/commands/mspec-run
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

      specs = []
      add_specs = ->(name, new_specs) do
        puts "Adding #{new_specs.size.to_s.rjust(3)} files (#{name})"
        specs += new_specs
      end

      if pattern
        add_specs["PATTERN=#{pattern}", userspecs.sort]
      elsif suite == 'opal'
        add_specs['spec/opal', opalspecs.sort]
      elsif suite == 'ruby'
        add_specs['spec/ruby', rubyspecs.sort]
      else
        warn 'Please provide at lease one of the following environment variables:'
        warn 'PATTERN # e.g. PATTERN=spec/ruby/core/numeric/**_spec.rb'
        warn 'SUITE   # can be either SUITE=opal or SUITE=ruby'
        exit 1
      end

      specs
    end

    def filters(suite)
      opalspec_filters = Dir['spec/filters/**/*_opal.rb']

      if ENV['INVERT_RUNNING_MODE']
        # When we run an inverted test suite we should run only 'bugs'.
        # Unsupported features are not supported anyway
        rubyspec_filters = Dir['spec/filters/bugs/*.rb'] - opalspec_filters
      else
        rubyspec_filters = Dir['spec/filters/**/*.rb'] - opalspec_filters
      end

      suite == 'opal' ? opalspec_filters : rubyspec_filters
    end

    def write_file(filename, filters, specs, env)
      bm_filepath = env['BM_FILEPATH']

      [filters, specs].each do |files|
        files.map! { |s| "'#{s.sub(/^spec\//,'')}'" }
      end

      filter_requires = filters.map { |s| "require #{s}" }.join("\n")
      spec_requires = specs.map { |s| "requirable_spec_file #{s}" }.join("\n")
      spec_registration = specs.join(",\n  ")

      if bm_filepath
        enter_benchmarking_mode = "OpalBM.main.register(#{Integer(env['BM'])}, '#{bm_filepath}')"
      end

      random_seed = Testing.get_random_seed(env)

      env_data = env.map{ |k,v| "ENV[#{k.inspect}] = #{v.to_s.inspect}" unless v.nil? }.join("\n")

      File.write filename, <<-RUBY
        require 'opal/platform' # in node ENV is replaced
        #{env_data}

        require 'spec_helper'
        require 'opal/full'
        #{enter_benchmarking_mode}

        #{filter_requires}

        #{spec_requires}

        MSpec.register_files [
          #{spec_registration}
        ]

        srand(#{random_seed})
        MSpec.randomize(true)

        MSpec.process
        OSpecFilter.main.unused_filters_message(list: #{!!ENV['LIST_UNUSED_FILTERS']})
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

  module Minitest
    extend self

    def write_file(filename, files = [], env = {})
      env_data = env.map{ |k,v| "ENV[#{k.inspect}] = #{v.to_s.inspect}" unless v.nil? }.join("\n")
      requires = files.map{|f| "require '#{f}'"}
      mkdir_p File.dirname(filename)

      random_seed = Testing.get_random_seed(env)

      File.write filename, <<-RUBY
        require 'opal/platform' # in node ENV is replaced
        require 'opal-parser'
        #{env_data}
        srand(#{random_seed})

        #{requires.join("\n")}
      RUBY
    end
  end

  class SauceLabs
    include FileUtils

    def initialize(options = {})
      @host = options.fetch(:host, '127.0.0.1')
      @port = options.fetch(:port, '3000')
      @username = options.fetch(:username)
      @access_key = options.fetch(:access_key)
      @tunnel = options.fetch(:tunnel, nil)
    end
    attr_reader :host, :port, :username, :access_key, :tunnel

    def with_server
      cd 'examples/rack'
      system 'bundle install' or raise 'bundle install failed'
      begin
        server = Process.spawn "bundle exec rackup --host #{host} --port #{port}"
        puts 'Waiting for server…'
        sleep 0.1 until system "curl -s 'http://#{host}:#{port}/' > /dev/null"
        puts 'Server ready.'
        yield self
      ensure
        Process.kill(:TERM, server)
        Process.wait(server)
      end
    end

    def on_platform(options = {})
      browser = options.fetch(:browser)
      version = options.fetch(:version)
      platform = options.fetch(:platform, nil)
      device = options.fetch(:device, nil)

      puts "=============== Testing on browser: #{browser} v#{version} #{"(#{platform})" if platform}"
      require "selenium/webdriver"

      caps = {}
      caps[:platform]           = platform if platform
      caps[:browserName]        = browser if browser
      caps[:version]            = version if version
      caps[:device]             = device if device
      caps['tunnel-identifier'] = tunnel if tunnel

      driver = Selenium::WebDriver.for(
        :remote,
        url: "http://#{username}:#{access_key}@localhost:4445/wd/hub",
        desired_capabilities: caps
      )

      driver.get("http://#{host}:#{port}/")
      yield driver
      driver.quit
    end

    def test_title(driver)
      if (title = driver.title) == 'Bob is authenticated'
        puts "SUCCESS! title of webpage is: #{title}"
      else
        raise "FAILED! title of webpage is: #{title}"
      end
    end

    def run(**options)
      on_platform(**options) do |driver|
        test_title(driver)
      end
    end
  end

end


pattern_usage = <<-DESC
Use PATTERN environment variable to manually set the glob for specs:

  # Will run all specs matching the specified pattern.
  # (Note: the ruby_specs filters will still apply)
  bundle exec rake mspec_node PATTERN=spec/ruby/core/module/class_variable*_spec.rb
  bundle exec rake mspec_node PATTERN=spec/ruby/core/numeric/**_spec.rb
DESC

platforms = %w[nodejs server chrome]
mspec_suites = %w[ruby opal]
minitest_suites = %w[cruby]

platforms.each do |platform|
  mspec_suites.each do |suite|
    desc "Run the MSpec test suite on Opal::Builder/#{platform}" + pattern_usage
    task :"mspec_#{suite}_#{platform}" do
      filename = "tmp/mspec_#{platform}.rb"
      mkdir_p File.dirname(filename)
      bm_filepath = Testing::MSpec.bm_filepath if ENV['BM']
      specs_env = {
        'SUITE' => suite,
        'FORMATTER' => platform, # Use the current platform as the default formatter
        'BM_FILEPATH' => bm_filepath,
      }.merge(ENV.to_hash)

      Testing::MSpec.write_file filename, Testing::MSpec.filters(suite), Testing::MSpec.specs(specs_env), specs_env

      stubs = Testing::MSpec.stubs.map{|s| "-s#{s}"}.join(' ')

      sh "ruby -rbundler/setup -r#{__dir__}/testing/mspec_special_calls "\
         "bin/opal -gmspec -Ispec -Ilib #{stubs} -R#{platform} -Dwarning -A --enable-source-location #{filename}"

      if bm_filepath
        puts "Benchmark results have been written to #{bm_filepath}"
        puts "To view the results, run bundle exec rake bench:report"
      end
    end
  end

  minitest_suites.each do |suite|
    task :"minitest_#{suite}_#{platform}" do
      if ENV.key? 'FILES'
        files = Dir[ENV['FILES']]
        includes = "-Itmp"
      else
        includes = "-Itest/cruby/test"
        files = %w[
          benchmark/test_benchmark.rb
          ruby/test_call.rb
          opal/test_keyword.rb
          base64/test_base64.rb
          opal/unsupported_and_bugs.rb
        ]
      end

      filename = "tmp/minitest_#{suite}_#{platform}.rb"
      Testing::Minitest.write_file(filename, files, ENV)

      stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"
      includes = "-Itest -Ilib -Ivendored-minitest #{includes}"

      sh "ruby -rbundler/setup "\
         "bin/opal -ghike #{includes} #{stubs} -R#{platform} -Dwarning -A --enable-source-location #{filename}"
    end
  end
end

# The name ends with the platform, which is of course mandated in this case
task :minitest_node_nodejs do
  Opal.use_gem 'hike'

  platform = 'nodejs'
  suite = 'node'
  files = %w[
    nodejs
    opal-parser
    nodejs/test_file.rb
    nodejs/test_dir.rb
    nodejs/test_io.rb
    nodejs/test_opal_builder.rb
  ]

  filename = "tmp/minitest_node_nodejs.rb"
  Testing::Minitest.write_file(filename, files, ENV)

  stubs = "-soptparse -sio/console -stimeout -smutex_m -srubygems -stempfile -smonitor"
  includes = "-Itest -Ilib -Ivendored-minitest"

  sh "ruby -rbundler/setup "\
     "bin/opal -ghike #{includes} #{stubs} -R#{platform} -Dwarning -A --enable-source-location #{filename}"
end

desc 'Runs opal-rspec tests to augment unit testing/rubyspecs'
task :smoke_test do
  opal_rspec_dir = 'tmp/smoke_test_opal_rspec'
  # Travis caching might be creating this, manage the state idempotently
  unless File.exist?(File.join(opal_rspec_dir, '.git'))
    rm_rf opal_rspec_dir
    sh "git clone https://github.com/opal/opal-rspec.git #{opal_rspec_dir}"
  end
  # Don't want conflicts with opal-rspec's Gemfile
  gemfile_name = 'opal_rspec_smoketest.Gemfile'
  cp File.join('tasks/testing', gemfile_name), opal_rspec_dir
  Dir.chdir opal_rspec_dir do
    sh 'git checkout releases/0-6-stable'
    sh 'git pull'
    # RSpec source itself
    sh 'git submodule update --init'
    Bundler.with_clean_env do
      # Force new dependencies each time
      rm_rf "#{gemfile_name}.lock"
      with_gemfile = lambda {|command| sh "BUNDLE_GEMFILE=#{gemfile_name} RUNNER=node bundle #{command}"}
      with_gemfile['install']
      with_gemfile['exec rake rake_only']
    end
  end
end

task :browser_test do
  credentials = {
    username: ENV['SAUCE_USERNAME'] || warn('missing SAUCE_USERNAME env var'),
    access_key: ENV['SAUCE_ACCESS_KEY'] || warn('missing SAUCE_ACCESS_KEY env var'),
    tunnel: ENV['TRAVIS_JOB_NUMBER'],
  }

  # Exit if we're missing credentials.
  exit unless credentials[:username] && credentials[:access_key]

  Testing::SauceLabs.new(credentials).with_server do |session|
    session.run(browser: 'Internet Explorer', version: '9')
    session.run(browser: 'Internet Explorer', version: '10')
    session.run(browser: 'Internet Explorer', version: '11')
    # session.run(browser: 'Edge', version: '13') # something goes wrong
    session.run(browser: 'Firefox', version: '47')
    session.run(browser: 'Firefox', version: '48')
    # session.run(browser: 'Chrome', version: '52') # chrome webdriver is broken
    # session.run(browser: 'Chrome', version: '53') # chrome webdriver is broken
    session.run(browser: 'Safari', version: '8')
    session.run(browser: 'Safari', version: '9')
    session.run(browser: 'Safari', version: '10')
  end
end

platforms.each { |platform| task(:"mspec_#{platform}"    => mspec_suites.map    { |suite| :"mspec_#{suite}_#{platform}"    }) }
platforms.each { |platform| task(:"minitest_#{platform}" => minitest_suites.map { |suite| :"minitest_#{suite}_#{platform}" }) }

task :mspec    => [:mspec_nodejs]
task :minitest => [:minitest_nodejs, :minitest_node_nodejs]
task :test_all => [:rspec, :mspec, :minitest]

# deprecated, can be removed after 0.11
task(:cruby_tests) { warn "The task 'cruby_tests' has been renamed to 'minitest_cruby_nodejs'."; exit 1 }
task(:test_cruby)  { warn "The task 'test_cruby' has been renamed to 'minitest_cruby_nodejs'."; exit 1 }
task(:test_nodejs) { warn "The task 'test_nodejs' has been renamed to 'minitest_node_nodejs'."; exit 1 }

