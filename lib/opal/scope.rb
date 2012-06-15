module Opal
  class Parser
    class Scope
      attr_reader :locals
      attr_reader :temps
      attr_accessor :parent

      attr_accessor :name

      attr_accessor :block_name

      attr_reader :scope_name
      attr_reader :ivars

      attr_accessor :donates_methods

      attr_reader :type

      attr_accessor :defines_defn
      attr_accessor :defines_defs

      attr_accessor :mid

      # used by modules to know what methods to donate to includees
      attr_reader :methods

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

        @methods = []

        @uses_block = false
      end

      # Returns true if this scope is a class/module body scope
      def class_scope?
        @type == :class or @type == :module
      end

      ##
      # Vars to use inside each scope
      def to_vars
        vars = locals.map { |l| "#{l} = nil" }
        vars.push *temps

        iv = ivars.map do |ivar|
         "if (this#{ivar} == null) this#{ivar} = nil;\n"
        end

        indent = @parser.parser_indent
        res = vars.empty? ? '' : "var #{vars.join ', '};"
        ivars.empty? ? res : "#{res}\n#{indent}#{iv.join indent}"
      end

      # Generates code for this module to donate methods
      def to_donate_methods
        return "" if @methods.empty?

        "%s;this._donate([%s]);" %
          [@parser.parser_indent, @methods.map(&:inspect).join(', ')]
      end

      def add_ivar(ivar)
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

      def add_temp(*tmps)
        @temps.push *tmps
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
        @identity ||= @parser.unique_temp
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
            mid  = "'#{scope.mid}'"
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