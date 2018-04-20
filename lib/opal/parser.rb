# frozen_string_literal: true

require 'opal/ast/builder'
require 'opal/rewriter'
require 'opal/parser/patch'

module Opal
  module Source
    class Buffer < Parser::Source::Buffer
      def self.recognize_encoding(string)
        super || Encoding::UTF_8
      end
    end
  end

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
      attr_accessor :default_parser_class

      def default_parser
        default_parser_class.default_parser
      end
    end
  end
end

require 'opal/parser/with_ruby_lexer'

if RUBY_ENGINE != 'opal'
  require 'opal/parser/with_c_lexer'
end

