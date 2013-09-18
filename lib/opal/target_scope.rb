module Opal
  # Instances of TargetScope are used by the parser when a new scope is
  # being processed. It is used to keep track of used variables,
  # temp variables and ivars so they can be processed and output
  # along with the scope implementation.
  class TargetScope

    # Every scope can have a parent scope
    attr_accessor :parent

    # The class or module name if this scope is a class scope
    attr_accessor :name

    # The given block name for a def scope
    attr_accessor :block_name

    attr_reader :scope_name
    attr_reader :ivars

    attr_reader :type

    attr_accessor :defines_defn
    attr_accessor :defines_defs

    # One of - :class, :module, :top, :iter, :def
    attr_accessor :mid

    # true if singleton def, false otherwise
    attr_accessor :defs

    # used by modules to know what methods to donate to includees
    attr_reader :methods

    # uses parents super method
    attr_accessor :uses_super
    attr_accessor :uses_zuper

    attr_accessor :catch_return

    # @param [Symbol] type the scope type (:class, :module, :iter, :def, :top)
    # @param [Opal::Parser] parser a parser instance used to create this scope
    def initialize(type, parser)
      @parser  = parser
      @type    = type
      @locals  = []
      @temps   = []
      @args    = []
      @ivars   = []
      @parent  = nil
      @queue   = []
      @unique  = "a"
      @while_stack = []

      @defines_defs = false
      @defines_defn = false

      @methods  = []

      @uses_block = false

      # used by classes to store all ivars used in direct def methods
      @proto_ivars = []
    end

    # Returns true if this scope is a class/module body scope
    def class_scope?
      @type == :class or @type == :module
    end

    # Returns true if this is strictly a class scope
    def class?
      @type == :class
    end

    # True if this is a module scope
    def module?
      @type == :module
    end

    def sclass?
      @type == :sclass
    end

    # Returns true if this is a top scope (main file body)
    def top?
      @type == :top
    end

    # True if a block/iter scope
    def iter?
      @type == :iter
    end

    def def?
      @type == :def
    end

    # Is this a normal def method directly inside a class? This is
    # used for optimizing ivars as we can set them to nil in the
    # class body
    def def_in_class?
      !@defs && @type == :def && @parent && @parent.class?
    end

    # Inside a class or module scope, the javascript variable name returned
    # by this function points to the classes' prototype. This is the target
    # to where methods are actually added inside a class body.
    def proto
      "def"
    end

    # A scope donates its methods if it is a module, or the core Object
    # class. Modules donate their methods to classes or objects they are
    # included in. Object donates methods to bridged classes whose native
    # prototypes do not actually inherit from Opal.Object.prototype.
    def should_donate?
      @type == :module or @name.to_s == 'Object'
    end

    ##
    # Vars to use inside each scope
    def to_vars
      vars = @temps.dup
      vars.push(*@locals.map { |l| "#{l} = nil" })
      current_self = @parser.current_self

      iv = ivars.map do |ivar|
        "if (#{current_self}#{ivar} == null) #{current_self}#{ivar} = nil;\n"
      end

      indent = @parser.parser_indent
      res = vars.empty? ? '' : "var #{vars.join ', '};"
      str = ivars.empty? ? res : "#{res}\n#{indent}#{iv.join indent}"

      if class? and !@proto_ivars.empty?
        #raise "FIXME to_vars"
        pvars = @proto_ivars.map { |i| "#{proto}#{i}"}.join(' = ')
        result = "%s\n%s%s = nil;" % [str, indent, pvars]
      else
        result = str
      end

      f(result)
    end

    def f(code, sexp = nil)
      @parser.f code
    end

    # Generates code for this module to donate methods
    def to_donate_methods
      if should_donate? and !@methods.empty?
        f("%s;$opal.donate(#{@name}, [%s]);" % [@parser.parser_indent, @methods.map(&:inspect).join(', ')])
      else
        f("")
      end
    end

    def add_ivar(ivar)
      if def_in_class?
        @parent.add_proto_ivar ivar
      else
        @ivars << ivar unless @ivars.include? ivar
      end
    end

    def add_proto_ivar(ivar)
      @proto_ivars << ivar unless @proto_ivars.include? ivar
    end

    def add_arg(arg)
      @args << arg unless @args.include? arg
      arg
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

    def add_temp(*tmps)
      @temps.push(*tmps)
    end

    def has_temp?(tmp)
      @temps.include? tmp
    end

    def new_temp
      return @queue.pop unless @queue.empty?

      tmp = next_temp
      @temps << tmp
      tmp
    end

    def next_temp
      tmp = "$#{@unique}"
      @unique = @unique.succ
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
        identify!
      end
    end

    def identify!
      return @identity if @identity

      @identity = @parser.unique_temp
      @parent.add_temp @identity if @parent

      @identity
    end

    def identity
      @identity
    end

    def find_parent_def
      scope = self
      while scope = scope.parent
        if scope.def?
          return scope
        end
      end

      nil
    end

    def get_super_chain
      chain, scope, defn, mid = [], self, 'null', 'null'

      while scope
        if scope.type == :iter
          chain << scope.identify!
          scope = scope.parent if scope.parent

        elsif scope.type == :def
          defn = scope.identify!
          mid  = "'$#{scope.mid}'"
          break

        else
          break
        end
      end

      [chain, defn, mid]
    end

    def uses_block?
      @uses_block
    end
  end
end

