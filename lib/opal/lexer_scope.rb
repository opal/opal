module Opal
  # LexerScope is used during lexing to keep track of local variables
  # created inside a scope. A lexer scope can be asked if it has a local
  # variable defined, and it can also check its parent scope if applicable.
  #
  # A LexerScope is created automatically as a new scope is entered during
  # the lexing stage.
  class LexerScope
    attr_reader :locals
    attr_accessor :parent

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
