# frozen_string_literal: true

require 'opal/ast/builder'
require 'opal/rewriter'
require 'opal/parser/patch'

if RUBY_ENGINE != 'opal'
  begin
    require 'c_lexer'
  rescue LoadError
    $stderr.puts 'Failed to load CLexer, using pure Ruby lexer'
  end
end

module Opal
  module Source
    class Buffer < Parser::Source::Buffer
      def self.recognize_encoding(string)
        super || Encoding::UTF_8
      end
    end
  end

  module Parser
    module OpalDefaults
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.diagnostics_consumer = ->(diagnostic) {
          $stderr.puts(diagnostic.render)
        }
      end

      module ClassMethods
        attr_accessor :diagnostics_consumer

        def default_parser
          parser = super

          parser.diagnostics.all_errors_are_fatal = true
          parser.diagnostics.ignore_warnings      = false

          parser.diagnostics.consumer =
            if RUBY_ENGINE == 'opal'
              ->(diag) {}
            else
              diagnostics_consumer
            end

          parser
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

    class WithRubyLexer < ::Parser::Ruby25
      include OpalDefaults
    end

    if defined?(::Parser::Ruby25WithCLexer)
      class WithCLexer < ::Parser::Ruby25WithCLexer
        include OpalDefaults
      end
    end

    def self.default_parser_class
      if defined?(WithCLexer)
        WithCLexer
      else
        WithRubyLexer
      end
    end

    def self.default_parser
      default_parser_class.default_parser
    end
  end
end
