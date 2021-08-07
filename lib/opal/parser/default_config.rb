# frozen_string_literal: true

module Opal
  module Parser
    module DefaultConfig
      module ClassMethods
        attr_accessor :diagnostics_consumer

        def default_parser
          parser = super
          parser.diagnostics.all_errors_are_fatal = true
          parser.diagnostics.ignore_warnings      = false
          parser.diagnostics.consumer             = diagnostics_consumer
          parser
        end
      end

      def self.included(klass)
        klass.extend(ClassMethods)
        klass.diagnostics_consumer = ->(diagnostic) do
          if RUBY_ENGINE != 'opal'
            $stderr.puts(diagnostic.render)
          end
        end
      end

      def initialize(*)
        super(Opal::AST::Builder.new)
      end

      def parse(source_buffer)
        parsed = super
        rewriten = rewrite(parsed)
        rewriten
      end

      def rewrite(node)
        Opal::Rewriter.new(node).process
      end
    end

    class << self
      def default_parser
        DEFAULT_PARSER_CLASS.default_parser
      end
    end
  end
end
