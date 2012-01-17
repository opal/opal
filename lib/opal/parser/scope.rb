module Opal; class Parser
  class Scope
    attr_reader :locals
    attr_reader :temps
    attr_accessor :parent

    attr_accessor :name

    attr_reader :scope_name
    attr_reader :ivars

    attr_accessor :donates_methods

    attr_reader :type

    # used by modules to know what methods to donate to includees
    attr_reader :methods

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

      @methods = []

      @uses_block = false
      @catches_break = false
    end

    ##
    # Vars to use inside each scope
    def to_vars
      vars = []

      if @type == :class
        vars << '$const = this.$const'
        vars << 'def = this.$proto'
      elsif @type == :module
        vars << '$const = this.$const'
        vars << 'def = this.$proto'
      elsif @type == :sclass
        vars << '$const = this.$const'
      end

      locals.each { |l| vars << "#{l} = nil" }
      temps.each { |t| vars << t }

      iv = ivars.map do |ivar|
        "this#{ivar} == null && (this#{ivar} = nil);"
      end

      res = vars.empty? ? '' : "var #{vars.join ', '}; "
      "#{res}#{iv.join ''}"
    end

    # Generates code for this module to donate methods
    def to_donate_methods
      ";this.$donate([#{@methods.map { |m| m.inspect }.join ', '}]);"
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
      if @type == :iter && @parent
        @parent.uses_block!
      else
        @uses_block = true
      end
    end

    def uses_block?
      @uses_block
    end

    def catches_break!
      if @type == :iter && @parent
        @parent.catches_break!
      else
        @catches_break = true
      end
    end

    def catches_break?
      @catches_break
    end

    def mid=(mid)
      @mid = mid
    end

    def mid
      @mid
    end
  end

end; end
