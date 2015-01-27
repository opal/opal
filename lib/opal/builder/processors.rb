require 'opal/compiler'
require 'opal/erb'
require 'source_map'

module Opal
  module Processors
    # A [Processor] subclass is used to handled assets for a given extension,
    # by an [Opal::Builder] instance. Subclasses should generally override
    # the '#source' method which returns the compiled source for the asset
    # type:
    #
    #     class CoffeeScriptProcessor < Opal::Processors::Processor
    #       def source
    #         ::CoffeeScript.compile(@source)
    #       end
    #     end
    #
    # For [Builder] to be able to use a custom processor, it needs to be
    # registered with the required file extension:
    #
    #     Opal::Builder.register_processor '.coffee', CoffeeScriptProcessor
    #
    # Once registered, any `require` statements which resolve to the newly
    # defined extension will be required like any other asset in the final
    # compiled result.
    #
    class Processor
      # Create a new [Processor] or subclass.
      #
      # @params [String] source raw file content of asset to compile
      # @params [String] logical_path the module/require name of asset
      # @params [Hash] options any special compiler options for asset
      # @returns [Processor]
      #
      def initialize(source, logical_path, options = {})
        @source, @logical_path, @options = source, logical_path, options
        @requires = []
        @required_trees = []
      end

      # General compiler options.
      #
      # @returns [Hash]
      attr_reader :options

      # The logical path of an asset, which is used to require it at runtime.
      # This is *not* the same as an assets filename.
      #
      # @returns [String]
      attr_reader :logical_path

      # Returns the compiled source of this asset.
      #
      # @returns [String]
      attr_reader :source

      # Returns an array of logical_paths this asset depends on
      #
      # @returns [Array] array of strings
      attr_reader :requires

      # An array of tree required made by this asset. Generally only used
      # by ruby processors.
      #
      # @returns [Array] array of strings
      attr_reader :required_trees

      def to_s
        source.to_s
      end

      def source_map
        @source_map ||= begin
          mappings = []
          source_file = "#{logical_path}.js"
          line = source.count("\n")
          column = source.scan("\n[^\n]*$").size
          offset = ::SourceMap::Offset.new(line, column)
          mappings << ::SourceMap::Mapping.new(source_file, offset, offset)

          # Ensure mappings isn't empty: https://github.com/maccman/sourcemap/issues/11
          unless mappings.any?
            zero_offset = ::SourceMap::Offset.new(0,0)
            mappings = [::SourceMap::Mapping.new(source_file,zero_offset,zero_offset)]
          end

          ::SourceMap::Map.new(mappings)
        end
      end

      def mark_as_required(path)
        "Opal.mark_as_loaded(Opal.normalize_loadable_path(#{path.to_s.inspect}));"
      end
    end

    class JsProcessor < Processor
      def source
        @source.to_s + mark_as_required(logical_path)
      end
    end

    class RubyProcessor < Processor
      def source
        compiled.result
      end

      def source_map
        compiled.source_map.map
      end

      def compiled
        @compiled ||= begin
          compiler = compiler_for(@source, file: logical_path)
          compiler.compile
          compiler
        end
      end

      def compiler_for(source, options = {})
        compiler_class.new(source, @options.merge(options))
      end

      def requires
        compiled.requires
      end

      def required_trees
        compiled.required_trees
      end

      def compiler_class
        ::Opal::Compiler
      end
    end

    class OpalERBProcessor < RubyProcessor
      def initialize(*args)
        super
        @source = prepare(@source, logical_path)
      end

      def requires
        ['erb'] + super
      end

      private

      def erb_compiler_class
        ::Opal::ERB::Compiler
      end

      def prepare(source, path)
        erb_compiler = erb_compiler_class.new(source, path)
        erb_compiler.prepared_source
      end
    end

    class ERBProcessor < Processor
      def source
        result = ::ERB.new(@source.to_s).result
        "Opal.modules[#{logical_path.inspect}] = function() {#{result}};"
      end
    end
  end
end
