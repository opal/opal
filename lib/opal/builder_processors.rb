require 'opal/compiler'
require 'opal/erb'
require 'source_map'

module Opal
  module BuilderProcessors
    DEFAULT_PROCESSORS = []

    class Processor
      def self.inherited(processor)
        DEFAULT_PROCESSORS << processor
      end

      def initialize(source, filename, options = {})
        @source, @filename, @options = source, filename, options
        @requires = []
        @required_trees = []
      end
      attr_reader :source, :filename, :options, :requires, :required_trees

      def to_s
        source.to_s
      end

      def self.match? other
        (other.is_a?(String) and other.match(match_regexp))
      end

      def self.match_regexp
        raise NotImplementedError
      end

      def source_map
        @source_map ||= begin
          mappings = []
          source_file = filename+'.js'
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

      def mark_as_required(filename)
        "Opal.mark_as_loaded(Opal.normalize_loadable_path(#{filename.to_s.inspect}));"
      end
    end

    class JsProcessor < Processor
      def source
        @source.to_s + mark_as_required(@filename)
      end

      def self.match_regexp
        /\.js$/
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
          compiler = compiler_for(@source, file: @filename)
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

      def self.match_regexp
        /\.(rb|opal)$/
      end
    end

    class ERBProcessor < RubyProcessor
      def initialize(*args)
        super
        @source = prepare(@source, @filename)
      end

      def self.match_regexp
        /\.opalerb$/
      end

      def requires
        ['erb']+super
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

  end
end
