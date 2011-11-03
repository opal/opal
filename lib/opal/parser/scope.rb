module Opal; class Parser
  class Scope
    attr_reader :locals
    attr_reader :temps
    attr_accessor :parent

    attr_accessor :name

    attr_reader :scope_name

    def initialize(type)
      @type    = type
      @locals  = []
      @temps   = []
      @args    = []
      @parent  = nil
      @queue   = []
      @unique  = "a"
      @while_stack = []

      @uses_block = false
    end

    def add_arg(arg)
      @args << arg unless @args.include? arg
    end

    def add_local(local)
      return if has_local? local

      @locals << local
    end

    def has_local?(local)
      return true if @locals.include? local or @args.include? local
      return @parent.has_local?(local) if @parent and @type == :iter

      false
    end

    def new_temp
      return @queue.pop unless @queue.empty?

      tmp = "$_#{@unique}"
      @unique = @unique.succ
      @temps << tmp

      tmp
    end

    def queue_temp(name)
      @queue << name
    end

    def push_while
      @while_stack.push({})
    end

    def pop_while
      @while_stack.pop
    end

    def in_while?
      !@while_stack.empty?
    end

    def uses_block!
      @uses_block = true
    end

    def uses_block?
      @uses_block
    end
  end

end; end

