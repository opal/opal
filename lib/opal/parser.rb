require 'ast'
require 'parser/ruby23'

module Opal
  class ::Parser::AST::Node
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
  end

  class Parser < ::Parser::Ruby23
    def parse(source, file = '(string)')
      buffer        = ::Parser::Source::Buffer.new(file)
      buffer.source = source
      ast           = super(buffer)
      ast
    end
  end
end
