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
    def parse(source, file = '(string)')
      # Legacy support
      if String === source
        warn 'this method is deprecated from the public API'
        buffer        = ::Parser::Source::Buffer.new(file)
        buffer.source = source
      else
        buffer = source
      end

      diagnostics.all_errors_are_fatal = true
      diagnostics.ignore_warnings      = true

      if RUBY_ENGINE == 'opal'
        diagnostics.consumer = ->(diag){}
      else
        diagnostics.consumer = lambda do |diagnostic|
          $stderr.puts(diagnostic.render)
        end
      end

      parsed = super(buffer)
      rewriten = rewrite(parsed)
      rewriten
    end

    def rewrite(node)
      Opal::Rewriter.new(node).process
    end
  end
end
