require 'rake'
require 'rake/tasklib'
require 'opal/bundle'

module Opal
  module Rake

    class BundleTask

      # The bundle name. For gems this will be the gem name, for
      # applications just use the app name.
      #
      # @return [String] bundle name
      attr_accessor :name

      # @return [String] the bundle version
      attr_accessor :version

      # The output file to bundle this package to. This should be a full
      # path including '.js' extension. This defaults to
      # name-version.js
      #
      # @return [String] full path to bundle package to.
      attr_accessor :out

      # A hash of parser options passed to each compile stage. This
      # accepts various options such as `:method_missing`. See
      # [Parser] for more information.
      #
      # @return [Hash] hash of parser options
      attr_accessor :options

      def initialize(task_name = :bundle)
        @name      = nil
        @version   = nil
        @task_name = task_name
        @options   = {}
        @package   = 'package.yml'

        yield self if block_given?

        define
      end

      def define
        desc "Bundle this package ready for a web browser"
        task(@task_name) do
          bundle  = Bundle.new

          bundle.name    = @name || File.basename(File.dirname)
          bundle.version = @version
          bundle.options = options

          path    = @name
          path   += "-#{@version}" if @version

          File.open("#{path}.js", 'w+') { |o| o.write(bundle.build) }
        end
      end
    end
  end
end

