# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    class ScopeNode < Base

      # Every scope can have a parent scope
      attr_accessor :parent

      # The class or module name if this scope is a class scope
      attr_accessor :name

      # The given block name for a def scope
      attr_accessor :block_name

      attr_reader :scope_name
      attr_reader :locals
      attr_reader :ivars
      attr_reader :gvars

      attr_accessor :mid

      # true if singleton def, false otherwise
      attr_accessor :defs

      # used by modules to know what methods to donate to includees
      attr_reader :methods

      # uses parents super method
      attr_accessor :uses_super
      attr_accessor :uses_zuper

      attr_accessor :catch_return, :has_break

      attr_accessor :rescue_else_sexp

      def initialize(*)
        super

        @locals   = []
        @temps    = []
        @args     = []
        @ivars    = []
        @gvars    = []
        @parent   = nil
        @queue    = []
        @unique   = 'a'
        @while_stack = []
        @identity = nil
        @defs     = nil

        @methods = []

        @uses_block = false
        @in_ensure = false

        # used by classes to store all ivars used in direct def methods
        @proto_ivars = []
      end

      def in_scope(&block)
        indent do
          @parent = compiler.scope
          compiler.scope = self
          block.call self
          compiler.scope = @parent
        end
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
        @type == :def || @type == :defs
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

      ##
      # Vars to use inside each scope
      def to_vars
        vars = @temps.dup
        vars.push(*@locals.map { |l| "#{l} = nil" })

        iv = ivars.map do |ivar|
          "if (self#{ivar} == null) self#{ivar} = nil;\n"
        end

        gv = gvars.map do |gvar|
          "if ($gvars#{gvar} == null) $gvars#{gvar} = nil;\n"
        end

        indent = @compiler.parser_indent
        str  = vars.empty? ? '' : "var #{vars.join ', '};\n"
        str += "#{indent}#{iv.join indent}" unless ivars.empty?
        str += "#{indent}#{gv.join indent}" unless gvars.empty?

        if class? and !@proto_ivars.empty?
          #raise "FIXME to_vars"
          pvars = @proto_ivars.map { |i| "#{proto}#{i}"}.join(' = ')
          result = "%s\n%s%s = nil;" % [str, indent, pvars]
        else
          result = str
        end

        fragment(result)
      end

      def add_scope_ivar(ivar)
        if def_in_class?
          @parent.add_proto_ivar ivar
        else
          @ivars << ivar unless @ivars.include? ivar
        end
      end

      def add_scope_gvar(gvar)
        @gvars << gvar unless @gvars.include? gvar
      end

      def add_proto_ivar(ivar)
        @proto_ivars << ivar unless @proto_ivars.include? ivar
      end

      def add_arg(arg)
        @args << arg unless @args.include? arg
        arg
      end

      def add_scope_local(local)
        return if has_local? local

        @locals << local
      end

      def has_local?(local)
        return true if @locals.include? local or @args.include? local or @temps.include? local
        return @parent.has_local?(local) if @parent and @type == :iter
        false
      end

      def add_scope_temp(tmp)
        return if has_temp?(tmp)

        @temps.push(tmp)
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
        while true
          tmp = "$#{@unique}"
          @unique = @unique.succ
          unless has_local?(tmp)
            break
          end
        end
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

      def identify!(name = nil)
        return @identity if @identity

        # Parent scope is the defining module/class
        name ||= [(parent && (parent.name || parent.scope_name)), self.mid].compact.join('_')
        @identity = @compiler.unique_temp(name)
        @parent.add_scope_temp @identity if @parent

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

          elsif [:def, :defs].include?(scope.type)
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

      def has_rescue_else?
        !!rescue_else_sexp
      end

      def in_ensure
        return unless block_given?

        @in_ensure = true
        result = yield
        @in_ensure = false

        result
      end

      def in_ensure?
        !!@in_ensure
      end
    end
  end
end
