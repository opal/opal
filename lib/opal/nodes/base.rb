require 'opal/nodes/helpers'

module Opal
  module Nodes
    class Base
      include Helpers

      def self.handlers
        @handlers ||= {}
      end

      def self.handle(*types)
        types.each do |type|
          Base.handlers[type] = self
        end
      end

      def self.children(*names)
        names.each_with_index do |name, idx|
          define_method(name) do
            @sexp[idx + 1]
          end
        end
      end

      attr_reader :compiler, :type

      def initialize(sexp, level, compiler)
        @sexp = sexp
        @type = sexp.type
        @level = level
        @compiler = compiler
      end

      def children
        @sexp[1..-1]
      end

      def compile_to_fragments
        return @fragments if defined?(@fragments)

        @fragments = []
        self.compile
        @fragments
      end

      def compile
        raise "Not Implemented"
      end

      def push(*strs)
        strs.each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments << str
        end
      end

      def unshift(*strs)
        strs.reverse.each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments.unshift str
        end
      end

      def wrap(pre, post)
        unshift pre
        push post
      end

      def fragment(str)
        Opal::Fragment.new str, @sexp
      end

      def error(msg)
        @compiler.error msg
      end

      def scope
        @compiler.scope
      end

      def s(*args)
        @compiler.s(*args)
      end

      def expr?
        @level == :expr
      end

      def recv?
        @level == :recv
      end

      def stmt?
        @level == :stmt
      end

      def process(sexp, level = :expr)
        @compiler.process sexp, level
      end

      def expr(sexp)
        @compiler.process sexp, :expr
      end

      def recv(sexp)
        @compiler.process sexp, :recv
      end

      def stmt(sexp)
        @compiler.process sexp, :stmt
      end

      def expr_or_nil(sexp)
        sexp ? expr(sexp) : "nil"
      end

      def add_local(name)
        scope.add_scope_local name.to_sym
      end

      def add_ivar(name)
        scope.add_scope_ivar name
      end

      def add_gvar(name)
        scope.add_scope_gvar name
      end

      def add_temp(temp)
        scope.add_scope_temp temp
      end

      def helper(name)
        @compiler.helper name
      end

      def with_temp(&block)
        @compiler.with_temp(&block)
      end

      def in_while?
        @compiler.in_while?
      end

      def while_loop
        @compiler.instance_variable_get(:@while_loop)
      end
    end
  end
end
