require 'opal/ast/builder'
require 'opal/rewriter'

if RUBY_ENGINE == 'opal'
  class << Parser::Source::Buffer
    def recognize_encoding(s)
      Encoding::UTF_8
    end
  end
end

module Opal
  class Parser < ::Parser::Ruby23
    def initialize(*)
      super(Opal::AST::Builder.new)
    end

    def self.default_parser
      parser = super

      parser.diagnostics.all_errors_are_fatal = true
      parser.diagnostics.ignore_warnings      = true

      if RUBY_ENGINE == 'opal'
        parser.diagnostics.consumer = ->(diag){}
      else
        parser.diagnostics.consumer = lambda do |diagnostic|
          $stderr.puts(diagnostic.render)
        end
      end
      parser
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
