# frozen_string_literal: true

module Opal
  module Nodes
    class NodeWithArgs < ScopeNode
      # Shortcuts for the simplest kinds of methods
      Shortcut = Struct.new(:name, :for, :when, :transform) do
        def match?(node)
          node.instance_exec(&self.when)
        end

        def compile(node)
          node.helper name
          node.instance_exec(&transform)
        end
      end

      @shortcuts = []
      @shortcuts_for = {}
      def self.define_shortcut(name, **kwargs, &block)
        kwargs[:for] ||= :def
        @shortcuts << Shortcut.new(name, kwargs[:for], kwargs[:when], block)
      end

      def self.shortcuts_for(node_type)
        @shortcuts_for[node_type] ||=
          @shortcuts.select do |shortcut|
            [node_type, :*].include? shortcut.for
          end
      end

      def compile_body_or_shortcut
        # The shortcuts don't check arity. If we want to check arity,
        # we can't use them.
        return compile_body if compiler.arity_check?

        node_type = is_a?(DefNode) ? :def : :iter

        NodeWithArgs.shortcuts_for(node_type).each do |shortcut|
          if shortcut.match?(self)
            if ENV['OPAL_DEBUG_SHORTCUTS']
              node_desc = node_type == :def ? "def #{mid}" : "iter"
              warn "* shortcut #{shortcut.name} used for #{node_desc}"
            end

            return shortcut.compile(self)
          end
        end

        compile_body
      end

      # Shortcut definitions
      # --------------------

      # def a; self; end
      define_shortcut :return_self, when: -> { stmts.type == :self } do
        push '$return_self'
      end

      def simple_value?(node = stmts)
        %i[true false nil int float str sym].include?(node.type)
      end

      # def a; 123; end
      define_shortcut :return_val, for: :*, when: -> { simple_value? } do
        push '$return_val(', expr(stmts), ')'
      end

      # def a; @x; end
      define_shortcut :return_ivar, when: -> { stmts.type == :ivar } do
        name = stmts.children.first.to_s[1..-1].to_sym
        push '$return_ivar(', expr(stmts.updated(:sym, [name])), ')'
      end

      # def a; @x = 5; end
      define_shortcut :assign_ivar, when: -> {
        stmts.type == :ivasgn &&
          inline_args.children.length == 1 &&
          inline_args.children.last.type == :arg &&
          stmts.children.last.type == :lvar &&
          stmts.children.last.children.last == inline_args.children.last.children.last
      } do
        name = stmts.children.first.to_s[1..-1].to_sym
        name = expr(stmts.updated(:sym, [name]))
        push '$assign_ivar(', name, ')'
      end

      # def a(x); @x = x; end
      define_shortcut :assign_ivar_val, when: -> {
        stmts.type == :ivasgn &&
          simple_value?(stmts.children.last)
      } do
        name = stmts.children.first.to_s[1..-1].to_sym
        name = expr(stmts.updated(:sym, [name]))
        push '$assign_ivar_val(', name, ', ', expr(stmts.children.last), ')'
      end

      # each { test }
      define_shortcut :return_iter_call, for: :iter, when: -> {
        stmts.type == :send &&
          stmts.children.length == 2 &&
          [nil, s(:self)].include?(stmts.children.first)
      } do
        compiler.method_calls << stmts.children.last
        name = expr(stmts.updated(:sym, ["$#{stmts.children.last}"]))
        push '$return_iter_call(', name, ')'
      end

      # def a; other; end
      define_shortcut :return_call, for: :def, when: -> {
        stmts.type == :send &&
          stmts.children.length == 2 &&
          [nil, s(:self)].include?(stmts.children.first)
      } do
        compiler.method_calls << stmts.children.last
        name = expr(stmts.updated(:sym, ["$#{stmts.children.last}"]))
        push '$return_call(', name, ')'
      end

      # def a; @x.other; end
      define_shortcut :return_ivar_call, when: -> {
        stmts.type == :send &&
          stmts.children.length == 2 &&
          stmts.children.first.type == :ivar
      } do
        compiler.method_calls << stmts.children.last
        ivar_name = stmts.children.first.children.first.to_s[1..-1].to_sym
        ivar_name = expr(stmts.children.first.updated(:sym, [ivar_name]))
        call_name = expr(stmts.updated(:sym, ["$#{stmts.children.last}"]))
        push '$return_ivar_call(', ivar_name, ',', call_name, ')'
      end
    end
  end
end
