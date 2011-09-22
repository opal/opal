require 'rake'
require 'rake/tasklib'

module Opal
  module Rake

    class BundleTask

      # The output file to bundle this package to. This should be a full
      # path including '.js' extension. This defaults to
      # name-version.js
      #
      # @return [String] full path to bundle package to.
      attr_accessor :out

      # The path to the package.yml file for the package to build. This
      # defaults to package.yml in the current directory.
      #
      # @return [String] path to package.yml
      attr_accessor :package

      # A hash of parser options passed to each compile stage. This
      # accepts various options such as `:method_missing`. See
      # [Parser] for more information.
      #
      # @return [Hash] hash of parser options
      attr_accessor :options

      def initialize(name = :bundle)
        @name    = name
        @options = {}
        @package = 'package.yml'

        yield self if block_given?

        define
      end

      def define
        desc "Bundle this package ready for a web browser"
        task(@name) do
          # lazy load rbp/bundle incase not installed yet - we dont want to
          # disrupt other take tasks.
          require 'opal/bundle'

          path = File.expand_path(@package || 'package.yml')
          raise "Cannot find package: `#{path}'" unless File.exists? path

          package = Rbp::Package.load_path path
          bundle  = Bundle.new package
          bundle.options = options
          code    = bundle.build

          File.open("#{package.name}-#{package.version}.js", 'w+') do |out|
            out.write code
          end
        end
      end
    end
  end
end

