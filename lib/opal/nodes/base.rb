# frozen_string_literal: true

require 'opal/nodes/helpers'
require 'opal/ast/matcher'

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
            @sexp.children[idx]
          end
        end
      end

      def self.truthy_optimize?
        false
      end

      def self.define_matcher(name, &block)
        define_method(name, &AST::Matcher.new(&block))
      end

      attr_reader :compiler, :type, :sexp

      def initialize(sexp, level, compiler)
        @sexp = sexp
        @type = sexp.type
        @level = level
        @compiler = compiler
        @compiler.top_scope ||= self
      end

      def children
        @sexp.children
      end

      def compile_to_fragments
        return @fragments if defined?(@fragments)

        @fragments = []
        compile
        @fragments
      end

      def compile
        raise 'Not Implemented'
      end

      def push(*strs)
        strs.each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments << str
        end
      end

      def unshift(*strs)
        strs.reverse_each do |str|
          str = fragment(str) if str.is_a?(String)
          @fragments.unshift str
        end
      end

      def wrap(pre, post)
        unshift pre
        push post
      end

      def fragment(str, loc: true)
        Opal::Fragment.new str, scope, loc && @sexp
      end

      def error(msg)
        @compiler.error msg
      end

      def scope
        @compiler.scope
      end

      def top_scope
        @compiler.top_scope
      end

      def s(type, *children)
        ::Opal::AST::Node.new(type, children, location: @sexp.loc)
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
        sexp ? expr(sexp) : 'nil'
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

      def has_rescue_else?
        scope.has_rescue_else?
      end

      def in_ensure(&block)
        scope.in_ensure(&block)
      end

      def in_ensure?
        scope.in_ensure?
      end

      def in_resbody(&block)
        scope.in_resbody(&block)
      end

      def in_resbody?
        scope.in_resbody?
      end

      def in_rescue(node, &block)
        scope.in_rescue(node, &block)
      end

      def class_variable_owner_nesting_level
        cvar_scope = scope
        nesting_level = 0

        while cvar_scope && !cvar_scope.class_scope?
          # Needs only `class << self`, `module`, and `class`
          # can increase nesting, but `class` & `module` are
          # covered by `class_scope?`.
          nesting_level += 1 if cvar_scope.sclass?

          cvar_scope = cvar_scope.parent
        end

        nesting_level
      end

      def class_variable_owner
        if scope
          "#{scope.nesting}[#{class_variable_owner_nesting_level}]"
        else
          'Opal.Object'
        end
      end

      def comments
        compiler.comments[@sexp.loc]
      end

      def source_location
        file = @sexp.loc.expression.source_buffer.name
        file = "<internal:#{file}>" if file.start_with?("corelib/")
        file = "<js:#{file}>" if file.end_with?(".js")
        line = @sexp.loc.line
        "['#{file}', #{line}]"
      end
    end
  end
end
