require 'opal/compiler'
require 'opal/erb'

module Opal
  module BuilderProcessors
    class Processor
      def initialize(source, filename, options = {})
        @source, @filename, @options = source, filename, options
        @requires = []
      end
      attr_reader :source, :filename, :options, :requires

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
        ''
      end
    end

    class JsProcessor < Processor
      def source
        @source.to_s
      end

      def self.match_regexp
        /\.js$/
      end
    end

    class RubyProcessor < Processor
      def source
        compiled.result
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
