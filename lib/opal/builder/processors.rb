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

      # FIXME: remove this
      attr_accessor :mtime

      def initialize(source, filename, options = {})
        @source, @filename, @options = source, filename, options
        @requires = []
        @required_trees = []
      end
      attr_reader :source, :filename, :options, :requires, :required_trees

      def encode
        {
          'source'          => source,
          'requires'        => requires,
          'required_trees'  => required_trees,
          'mtime'           => mtime,
          'source_map'      => source_map.as_json
        }
      end

      def to_s
        source.to_s
      end

      def self.handles(*extensions)
        @extensions = extensions
        matches = extensions.join('|')
        matches = "(#{matches})" if extensions.size == 1

        @match_regexp = Regexp.new "\\.#{matches}$"
      end

      def self.extensions
        @extensions
      end

      def self.match? other
        (other.is_a?(String) and other.match(match_regexp))
      end

      def self.match_regexp
        @match_regexp or raise NotImplementedError
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
      handles :js

      def source
        @source.to_s + mark_as_required(@filename)
      end
    end

    class RubyProcessor < Processor
      handles :rb, :opal

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
    end

    class OpalERBProcessor < RubyProcessor
      handles :opalerb

      def initialize(*args)
        super
        @source = prepare(@source, @filename)
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

    class ERBProcessor < Processor
      handles :erb

      def source
        result = ::ERB.new(@source.to_s).result
        "Opal.modules[#{@filename.inspect}] = function() {#{result}};"
      end
    end
  end
end
