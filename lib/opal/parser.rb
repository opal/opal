# frozen_string_literal: true
require 'opal/ast/builder'
require 'opal/rewriter'

module Opal
  class Parser < ::Parser::Ruby23
    class << self
      attr_accessor :diagnostics_consumer

      def default_parser
        parser = super

        parser.diagnostics.all_errors_are_fatal = true
        parser.diagnostics.ignore_warnings      = false

        if RUBY_ENGINE == 'opal'
          parser.diagnostics.consumer = ->(diag){}
        else
          parser.diagnostics.consumer = diagnostics_consumer
        end

        parser
      end
    end

    self.diagnostics_consumer = ->(diagnostic) { $stderr.puts(diagnostic.render) }

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
end
