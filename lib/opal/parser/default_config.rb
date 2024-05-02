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

      def modify_ast(ast)
        ast ||= ::Opal::AST::Node.new(:nil)
        wrapped = ::Opal::AST::Node.new(:top, [ast])
        rewrite(wrapped)
      end

      def rewrite(node)
        Opal::Rewriter.new(node).process
      end
    end

    class << self
      def default_parser_class
        @default_parser_class ||= WithRubyLexer
      end

      def default_parser
        default_parser_class.default_parser
      end

      def use_prism
        require 'opal/parser/with_prism'
        @default_parser_class = WithPrism
      end
    end
  end
end
