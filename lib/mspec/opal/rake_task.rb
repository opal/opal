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
    class Environment < ::Opal::Environment
      attr_reader :basedir

      def initialize(basedir = '.')
        super
        @basedir = basedir = File.expand_path(basedir)
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

      def build code = specs.to_s, file = "#{basedir}/build/specs.js"
        FileUtils.mkdir_p File.dirname(file)
        puts "Building #{file}..."
        File.open(file, 'w+') { |o| o << code }
      end
    end

    class Builder
      attr_accessor :pattern, :basedir

      def initialize
        ::Opal::Processor.arity_check_enabled = true
        ::Opal::Processor.dynamic_require_severity = :ignore

        yield(self)

        ENV['OPAL_SPEC'] = files_to_run(pattern).join(',')

        build_specs

        _basedir = basedir
        server = fork do
          app = Rack::Builder.app do
            use Rack::ShowExceptions
            run Rack::Directory.new(_basedir)
          end

          Rack::Server.start(:app => app, :Port => 9999, :AccessLog => [],
            :Logger => WEBrick::Log.new("/dev/null"))
        end

        require 'shellwords'
        runner  = "#{basedir}/mspec/opal/sprockets.js".shellescape
        url     = "http://localhost:9999/index.html".shellescape
        command = %Q{phantomjs #{runner} #{url}}

        system command
        success = $?.success?

        exit 1 unless success

      rescue => e
        puts e.message
      ensure
        if server
          Process.kill(:SIGINT, server)
          Process.wait
        end
      end

      def files_to_run(pattern=nil)
        specs = []

        # add any filters in spec/filters of specs we dont want to run
        specs << Dir.glob("#{basedir}/filters/**/*.rb").map do |s|
          s.sub(/^#{basedir}\//, '').sub(/\.rb$/, '')
        end

        # add custom opal specs from spec/
        specs << Dir.glob(pattern) if pattern

        # add any rubyspecs we want to run (defined in spec/rubyspecs)
        specs.push File.read("#{basedir}/rubyspecs").split("\n").reject {|line|
          line.empty? || line.start_with?('#')
        }

        specs.flatten
      end

      def build_specs
        Environment.new(basedir).build
      end
    end

    require 'rake'
    require 'rake/tasklib'
    class RakeTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(name, &task_block)
        desc "Run MSpec::Opal code examples" unless ::Rake.application.last_comment
        task name do |_, task_args|
          Builder.new(&task_block)
        end
      end
    end
  end
end

