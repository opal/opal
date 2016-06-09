require 'ast'
require 'parser/ruby22'
require 'opal/rewriter'

::Parser::AST::Node.class_eval do
  attr_reader :meta

  alias_method :old_assign_properties, :assign_properties
  def assign_properties(properties)
    if meta = properties[:meta]
      meta = meta.dup if meta.frozen?
      @meta.merge!(meta)
    else
      @meta ||= {}
    end

    old_assign_properties(properties)
  end

  def line
    loc.line if loc
  end

  def column
    loc.column if loc
  end
end

::Parser::Builders::Default.class_eval do
  def string_value(token)
    token[0]
  end
end

if RUBY_ENGINE == 'opal'
  class << Parser::Source::Buffer
    def recognize_encoding(s)
      Encoding::UTF_8
    end
  end
end

module Opal
  class Parser < ::Parser::Ruby22
    def parse(source, file = '(string)')
      # Legacy support
      if String === source
        warn 'this method is deprecated from the public API'
        buffer        = ::Parser::Source::Buffer.new(file)
        buffer.source = source
      else
        buffer = source
      end

      if RUBY_ENGINE == 'opal'
        diagnostics.consumer = ->(diag){}
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
