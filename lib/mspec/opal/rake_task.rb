require 'opal/nodes'
class Opal::Nodes::CallNode
  # Rubyspec uses this call to load in language specific features at runtime.
  # We can't do this at runtime, so handle it during compilation
  add_special :language_version do
    if meth == :language_version and scope.top?
      lang_type = arglist[2][1]
      target = "rubyspec/language/versions/#{lang_type}_1.9"

      if File.exist?(target)
        compiler.requires << target
      end

      return fragment("nil")
    end

    nil
  end
end


require 'rack'
require 'webrick'
require 'opal-sprockets'
module MSpec
  module Opal
    DEFAULT_PATTERN = 'spec/opal/{parser,core,compiler,stdlib}/**/*_spec.rb'
    DEFAULT_BASEDIR = 'spec/opal'

    require 'rake'
    require 'rake/tasklib'
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(name, &task_block)
        namespace name do
          desc 'Run MSpec::Opal code examples' unless ::Rake.application.last_comment
          task :default do
            runner = Runner.new(&task_block)
            runner.run
          end

          desc 'Build specs to build/specs.js and build/specs.min.js'
          task :build do
            path = './build/specs.js'
            min_path = './build/specs.min.js'
            Environment.new.build_specs(path)
            min = ::Opal::Builder::Util.uglify File.read(path)
            File.open(min_path, 'w') { |f| f << min_path }
          end
        end

        task name => "#{name}:default"
      end
    end

    class Runner
      def initialize &block
        @app = RackApp.new(&block).app
        @port = 9999
      end

      attr_reader :app, :server_pid
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
        stop_server if server_pid
      end

      def stop_server
        Process.kill(:SIGINT, server_pid)
        Process.wait
      end

      def start_phantomjs
        require 'shellwords'
        runner  = File.expand_path('../sprockets.js', __FILE__).shellescape
        url     = "http://localhost:#{port}/".shellescape
        command = %Q{phantomjs #{runner} #{url}}

        @passed = system command
      end

      def start_server
        @server_pid = fork do
          Rack::Server.start(:app => app, :Port => port, :AccessLog => [],
            :Logger => WEBrick::Log.new("/dev/null"))
        end
      end
    end

    class Environment < ::Opal::Environment
      attr_reader :basedir, :pattern

      def initialize(basedir = nil, pattern = nil)
        ::Opal::Processor.arity_check_enabled = true
        ::Opal::Processor.dynamic_require_severity = :ignore
        super()
        @pattern = pattern || DEFAULT_PATTERN
        @basedir = basedir = File.expand_path(basedir || DEFAULT_BASEDIR)
        append_path basedir
        append_path "#{basedir}/rubyspec"
        use_gem 'mspec'

        stubs.each do |asset|
          ::Opal::Processor.stub_file asset
        end
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
        build uglify(specs.to_s), file
      end

      def files
        @files ||= []
      end

      def add_files specs
        files.concat specs.flatten
      end

      def paths_from_glob pattern
        Dir.glob(File.expand_path(pattern)).map do |s|
          s.sub(/^#{basedir}\//, '').sub(/\.rb$/, '')
        end
      end

      def rubyspec_paths
        File.read("#{basedir}/rubyspecs").split("\n").reject do |line|
          line.empty? || line.start_with?('#')
        end
      end

      def files_to_run(pattern=nil)
        # add any filters in spec/filters of specs we dont want to run
        add_files paths_from_glob("#{basedir}/filters/**/*.rb")

        # add custom opal specs from spec/
        add_files paths_from_glob(pattern) if pattern

        # add any rubyspecs we want to run (defined in spec/rubyspecs)
        add_files rubyspec_paths
      end

      def build_specs file = "#{basedir}/build/specs.js"
        ENV['OPAL_SPEC'] = files_to_run(pattern).join(',')
        code = specs.to_s
        FileUtils.mkdir_p File.dirname(file)
        puts "Building #{file}..."
        File.open(file, 'w+') { |o| o << code }
      end
    end

    class RackApp
      attr_accessor :pattern, :basedir
      attr_reader :app

      def initialize
        self.pattern = DEFAULT_PATTERN
        self.basedir = DEFAULT_BASEDIR

        yield(self) if block_given?

        @app = Rack::Builder.app environment do
          use Rack::ShowExceptions
          use Rack::ShowStatus
          use Index
        end
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
          <title>Opal Specs</title>
        </head>
        <body>
          <script src="/build/specs.js"></script>
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

