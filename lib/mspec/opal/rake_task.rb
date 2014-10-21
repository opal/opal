require 'rack'
require 'webrick'
require 'mspec/opal/special_calls'

module MSpec
  module Opal
    DEFAULT_BASEDIR = 'spec'

    require 'rake'
    require 'rake/tasklib'
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(name, &task_block)
        namespace name do
          desc 'Run MSpec::Opal code examples' unless ::Rake.application.last_comment
          task :default do
            puts 'Starting MSpec Runner...'
            runner = Runner.new(&task_block)
            runner.run
          end

          desc 'Build specs to build/specs.js and build/specs.min.js'
          task :build do
            require 'opal/util'
            path = './build/specs.js'
            min_path = './build/specs.min.js'
            Environment.new.build_specs(path)
            min = ::Opal::Util.uglify File.read(path)
            File.open(min_path, 'w') { |f| f << min_path }
          end
        end

        task name => "#{name}:default"
      end
    end

    class Runner
      def initialize &block
        @app = RackApp.new(&block).to_app
        @port = 9999
      end

      attr_reader :app, :server
      attr_accessor :port

      def passed?
        @passed
      end

      def run
        start_server
        start_phantomjs

        exit 1 unless passed?
      rescue => e
        puts e.message
      ensure
        stop_server if server
      end

      def stop_server
        server.kill
      end

      require 'opal/util'
      class PhantomJS < ::Opal::Util::Command
        require 'shellwords'

        def initialize(runner, url)
          runner = runner.shellescape
          url    = url.shellescape
          super 'phantomjs', "#{runner} #{url}", '. Please install PhantomJS'
        end

        def run
          system "#{command} #{options}"
        end
      end

      def start_phantomjs
        runner  = File.expand_path('../sprockets.js', __FILE__).shellescape
        url     = "http://localhost:#{port}/".shellescape
        command = PhantomJS.new(runner, url)
        @passed = command.run
      end

      def start_server
        @server = Thread.new do
          Rack::Server.start(:app => app, :Port => port, :AccessLog => [],
            :Logger => WEBrick::Log.new("/dev/null"))
        end
      end
    end

    class Environment < ::Opal::Environment
      attr_reader :basedir, :pattern

      def initialize(basedir = nil, pattern = nil)
        ::Opal::Processor.arity_check_enabled = true
        ::Opal::Processor.dynamic_require_severity = :error

        @pattern = pattern
        @basedir = basedir = File.expand_path(basedir || DEFAULT_BASEDIR)

        ::Opal.append_path basedir
        ::Opal.use_gem 'mspec'

        stubs.each do |asset|
          ::Opal::Processor.stub_file asset
        end

        ENV['OPAL_SPEC'] ||= files_to_run(pattern).join(',')

        super()
      end

      def stubs
        # missing stdlib
        stubs = %w[fileutils iconv yaml]

        # use x-strings which generate bad javascript
        stubs << "mspec/helpers/tmp"
        stubs << "mspec/helpers/environment"
        stubs << "mspec/guards/block_device"
        stubs << "mspec/guards/endian"

        stubs
      end

      def specs
        @specs ||= self['mspec/opal/main'] || raise("Cannot find mspec/opal/main inside #{paths.inspect}")
      end

      def build_min file = "#{basedir}/build/specs.min.js"
        require 'opal/util'
        build ::Opal::Util.uglify(specs.to_s), file
      end

      def files
        @files ||= []
      end

      def add_files specs, tag = ''
        tag = "[#{tag}] "
        puts "#{tag}Adding #{specs.size} spec files..."
        specs = specs.flatten.map do |path|
          dirname = File.join([basedir, path])
          if File.directory? dirname
            rubyspec_paths_in_dir(dirname, path)
          else
            path
          end
        end.flatten
        files.concat specs
      end

      def paths_from_glob pattern
        Dir.glob(File.expand_path(pattern)).map do |s|
          s.sub(/^#{basedir}\//, '').sub(/\.rb$/, '')
        end
      end

      def rubyspec_paths_in_dir(dirname, path)
        Dir.entries(dirname).select do |spec|
          spec.end_with? '.rb'
        end.map do |spec|
          File.join path, spec
        end
      end

      def rubyspec_white_list
        File.read("#{basedir}/rubyspecs").split("\n").reject do |line|
          line.sub(/#.*/, '').strip.empty?
        end
      end

      def files_to_run(pattern=nil)
        # add any filters in spec/filters of specs we dont want to run
        add_files paths_from_glob("#{basedir}/filters/**/*.rb"), :filters

        if pattern
          # add custom opal specs from spec/
          add_files paths_from_glob(pattern) & rubyspec_white_list, :rubyspec_custom_pattern
          add_files paths_from_glob(pattern).grep(/(?!spec\/(corelib|stdlib)\/)/), :other_custom_pattern

        else
          # add opal specific specs
          add_files paths_from_glob("#{basedir}/opal/**/*_spec.rb"), 'opal/*'
          add_files paths_from_glob("#{basedir}/lib/{lexer_spec.rb,parser/**/*_spec.rb}"), 'lib/{lexer,parser}'

          # add any rubyspecs we want to run (defined in spec/rubyspecs)
          add_files rubyspec_white_list, :rubyspec_white_list
        end
      end

      def build_specs file = "#{basedir}/build/specs.js"
        code = specs.to_s
        FileUtils.mkdir_p File.dirname(file)
        puts "Building #{file}..."
        File.open(file, 'w+') { |o| o << code }
      end
    end

    class RackApp < Rack::Builder
      attr_accessor :pattern, :basedir

      def initialize
        self.pattern = nil
        self.basedir = DEFAULT_BASEDIR

        yield(self) if block_given?
        super()

        use Rack::ShowExceptions
        use Rack::ShowStatus
        use Index
        run environment
      end

      def environment
        @environment ||= Environment.new(basedir, pattern)
      end
    end

    class Index
      HTML = <<-HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8" />
          <title>Opal Specs</title>
        </head>
        <body>
          <script src="/mspec/opal/main.js"></script>
        </body>
      </html>
      HTML

      def initialize(app)
        @app = app
      end

      def call(env)
        if %w[/ /index.html].include? env['PATH_INFO']
          [200, { 'Content-Type' => 'text/html' }, [HTML]]
        else
          @app.call env
        end
      end
    end

  end
end
