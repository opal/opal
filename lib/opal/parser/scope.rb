module Opal; class Parser
  class Scope
    attr_reader :locals
    attr_reader :temps
    attr_accessor :parent

    attr_accessor :name

    attr_reader :scope_name
    attr_reader :ivars

    def initialize(type)
      @type    = type
      @locals  = []
      @temps   = []
      @args    = []
      @ivars   = []
      @parent  = nil
      @queue   = []
      @unique  = "a"
      @while_stack = []

      @uses_block = false
      @catches_break = false
    end

    def add_ivar ivar
      @ivars << ivar unless @ivars.include? ivar
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

      tmp = "_#{@unique}"
      @unique = @unique.succ
      @temps << tmp
      tmp
    end

    def queue_temp(name)
      @queue << name
    end

    def push_while
      info = {}
      @while_stack.push info
      info
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

    def catches_break!
      @catches_break = true
    end

    def catches_break?
      @catches_break
    end
  end

end; end

