module Opal
  # ParserScope is used during lexing to keep track of local variables
  # created inside a scope. A lexer scope can be asked if it has a local
  # variable defined, and it can also check its parent scope if applicable.
  class ParserScope
    attr_reader :locals
    attr_accessor :parent

    # Create new parse scope. Valid types are :block, :class, :module, :def.
    #
    # @param type [Symbol] scope type
    def initialize(type)
      @block  = type == :block
      @locals = []
      @parent = nil
    end

    def add_local(local)
      @locals << local
    end

    def has_local?(local)
      return true if @locals.include? local
      return @parent.has_local?(local) if @parent and @block
      false
    end
  end
end
