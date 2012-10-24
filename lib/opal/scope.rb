module Opal
  class Parser
    # Instances of Scope are used by the parser when a new scope is
    # being processed. It is used to keep track of used variables,
    # temp variables and ivars so they can be processed and output
    # along with the scope implementation.
    class Scope
      attr_accessor :parent

      attr_accessor :name

      attr_accessor :block_name

      attr_reader :scope_name
      attr_reader :ivars

      attr_reader :type

      attr_accessor :defines_defn
      attr_accessor :defines_defs

      attr_accessor :mid

      # true if singleton def, false otherwise
      attr_accessor :defs

      # used by modules to know what methods to donate to includees
      attr_reader :methods

      # singleton methods defined on classes/modules
      attr_reader :smethods

      # uses parents super method
      attr_accessor :uses_super

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
        @smethods = []

        @uses_block = false

        # used by classes to store all ivars used in direct def methods
        @proto_ivars = []
      end

      # Returns true if this scope is a class/module body scope
      def class_scope?
        @type == :class or @type == :module
      end

      def class?
        @type == :class
      end

      def module?
        @type == :module
      end

      def top?
        @type == :top
      end

      def iter?
        @type == :iter
      end

      # Is this a normal def method directly inside a class? This is
      # used for optimizing ivars as we can set them to nil in the
      # class body
      def def_in_class?
        !@defs && @type == :def && @parent && @parent.class?
      end

      def proto
        "#{ @name }_prototype"
      end
      
      def should_donate?
        @type == :module or @name.to_s == 'Object'
      end

      ##
      # Vars to use inside each scope
      def to_vars
        vars = @locals.map { |l| "#{l} = nil" }
        vars.push *@temps

        iv = ivars.map do |ivar|
         "if (this#{ivar} == null) this#{ivar} = nil;\n"
        end

        indent = @parser.parser_indent
        res = vars.empty? ? '' : "var #{vars.join ', '};"
        str = ivars.empty? ? res : "#{res}\n#{indent}#{iv.join indent}"

        if class? and !@proto_ivars.empty?
          pvars = @proto_ivars.map { |i| "#{proto}#{i}"}.join(' = ')
          "%s\n%s%s = nil;" % [str, indent, pvars]
        else
          str
        end
      end

      # Generates code for this module to donate methods
      def to_donate_methods
        out = ""

        if should_donate? and !@methods.empty?
        # unless @methods.empty?
          out += "%s;#{@name}._donate([%s]);" %
            [@parser.parser_indent, @methods.map(&:inspect).join(', ')]
        end

        unless @smethods.empty?
          out += "%s;#{@name}._sdonate([%s]);" %
            [@parser.parser_indent, @smethods.map(&:inspect).join(', ')]
        end

        out
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
        @temps.push *tmps
      end

      def has_temp?(tmp)
        @temps.include? tmp
      end

      def new_temp
        return @queue.pop unless @queue.empty?

        tmp = "__#{@unique}"
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
end