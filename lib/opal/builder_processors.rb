# frozen_string_literal: true

require 'opal/compiler'
require 'opal/erb'
require 'source_map'

module Opal
  module BuilderProcessors
    class Processor
      def initialize(source, filename, options = {})
        @source, @filename, @options = source, filename, options
        @requires = []
        @required_trees = []
      end
      attr_reader :source, :filename, :options, :requires, :required_trees

      def to_s
        source.to_s
      end

      class << self
        attr_reader :extensions

        def handles(*extensions)
          @extensions = extensions
          matches = extensions.join('|')
          matches = "(#{matches})" if extensions.size == 1
          @match_regexp = Regexp.new "\\.#{matches}#{REGEXP_END}"

          ::Opal::Builder.register_processor(self, extensions)
          nil
        end

        def match?(other)
          other.is_a?(String) && other.match(match_regexp)
        end

        def match_regexp
          @match_regexp || raise(NotImplementedError)
        end
      end

      def source_map
        @source_map ||= begin
          mappings = []
          source_file = "#{filename}.js"
          line = source.count("\n")
          column = source.scan("\n[^\n]*$").size
          offset = ::SourceMap::Offset.new(line, column)
          mappings << ::SourceMap::Mapping.new(source_file, offset, offset)

          # Ensure mappings isn't empty: https://github.com/maccman/sourcemap/issues/11
          unless mappings.any?
            zero_offset = ::SourceMap::Offset.new(0, 0)
            mappings = [::SourceMap::Mapping.new(source_file, zero_offset, zero_offset)]
          end

          ::SourceMap::Map.new(mappings)
        end
      end

      def mark_as_required(filename)
        "Opal.loaded([#{filename.to_s.inspect}]);"
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
          compiler = compiler_for(@source, file: @filename.gsub(/\.(rb|js|opal)#{REGEXP_END}/, ''))
          compiler.compile
          compiler
        end
      end

      def compiler_for(source, options = {})
        ::Opal::Compiler.new(source, @options.merge(options))
      end

      def requires
        compiled.requires
      end

      def required_trees
        compiled.required_trees.map do |tree|
          # Remove any leading ./ after joining to dirname
          File.join(File.dirname(@filename), tree).sub(%r{^(\./)*}, '')
        end
      end

      # Also catch a files with missing extensions and nil.
      def self.match?(other)
        super || File.extname(other.to_s) == ''
      end
    end

    class OpalERBProcessor < RubyProcessor
      handles :opalerb

      def initialize(*args)
        super
        @source = prepare(@source, @filename)
      end

      def requires
        ['erb'] + super
      end

      private

      def prepare(source, path)
        ::Opal::ERB::Compiler.new(source, path).prepared_source
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
