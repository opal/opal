# frozen_string_literal: true

module Opal
  module Nodes
    class NodeWithArgs < ScopeNode
      # Shortcuts for the simplest kinds of methods
      Shortcut = Struct.new(:name, :for, :when, :transform) do
        def match?(node)
          if self.when.is_a? AST::Matcher
            @matches = self.when.match(node.sexp, lambda_self: node)
          else
            node.instance_exec(&self.when)
          end
        end

        def compile(node)
          node.helper name unless name.to_s.start_with? '_'
          node.instance_exec(*(@matches || []), &transform)
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

      # Matcher helpers
      # ---------------
      class Matcher < AST::Matcher
        def not_setter_call_name
          ->(call_name) { not_setter?(call_name) }
        end

        def capture_single_arg
          s(:args, s(:arg, cap), :**)
        end

        def capture_simple_value
          cap { |i| simple_value? i }
        end
      end

      define_matcher :simple_value? do
        s(%i[true false nil int float str sym], :**)
      end

      def not_setter?(call_name)
        !call_name.to_s.end_with? '='
      end

      define_matcher :simple_value_access? do |arg|
        [
          s(:nil),
          s(:send,
            s(:lvar, arg), :[],
            s(%i[int sym str], :*)
          )
        ]
      end

      # Transformer helpers
      # -------------------

      def format_ivar_name(name, onto = stmts)
        expr(onto.updated(:sym, [name.to_s[1..-1].to_sym]))
      end

      def format_call_name(name, onto = stmts)
        compiler.method_calls << name
        expr(onto.updated(:sym, ["$#{name}"]))
      end

      # Shortcut definitions
      # --------------------

      # def a; self; end
      define_shortcut :return_self, when: -> { stmts.type == :self } do
        push '$return_self'
      end

      # def a; 123; end
      define_shortcut :return_val, for: :*, when: Matcher.new {
        s(:**,
          [
            capture_simple_value,
            s(:begin, # def a(*); 123; end
              s(:prepare_post_args, 0),
              s(:extract_restarg, :*, 0),
              capture_simple_value
            )
          ]
        )
      } do |val|
        push '$return_val(', expr(val), ')'
      end

      # def a; @x; end
      define_shortcut :return_ivar, when: -> { stmts.type == :ivar } do
        push '$return_ivar(', format_ivar_name(stmts.children.last), ')'
      end

      # def a; @x = 5; end
      define_shortcut :assign_ivar_pass, when: Matcher.new {
        s(:**,
          capture_single_arg,
          s(:ivasgn, cap, s(:lvar, cap_eq(0)))
        )
      } do |_, name|
        name = format_ivar_name(name)
        push '$assign_ivar_pass(', name, ')'
      end

      %i[iter def].each do |type|
        mark = "_iter" if type == :iter

        # def a; other; end
        define_shortcut :"return#{mark}_call", for: type, when: Matcher.new {
          s(:**,
            s(:send, [nil, s(:self)], cap(not_setter_call_name))
          )
        } do |call|
          call = format_call_name(call)
          self.self if type == :iter # Ensure self is passed as $$s
          push "$return#{mark}_call(", call, ")"
        end
      end

      # def a(b); self.x(b); end
      define_shortcut :return_iter_call_pass, for: :iter, when: Matcher.new {
        s(:**,
          capture_single_arg,
          s(:begin,
            s(:initialize_iter_arg, cap_eq(0)),
            s(:send,
              [nil, s(:self)],
              cap(not_setter_call_name),
              s(:lvar, cap_eq(0))
            )
          )
        )
      } do |_, call_name|
        call_name = format_call_name(call_name)
        self.self # Ensure self is passed as $$s
        push "$return_iter_call_pass(", call_name, ")"
      end

      # def a(b); self.x.other(b); end
      define_shortcut :return_call_call, when: Matcher.new {
        s(:**,
          s(:send,
            cap(s(:send,
              [nil, s(:self)],
              cap(not_setter_call_name),
            )
            ),
            cap(not_setter_call_name)
          )
        )
      } do |call1_name, call1, call2_name|
        call1_name = format_call_name(call1_name, call1)
        call2_name = format_call_name(call2_name)
        push '$return_call_call(', call1_name, ',', call2_name, ')'
      end

      # def a; @x.other; end
      define_shortcut :return_ivar_call, when: Matcher.new {
        s(:**,
          s(:send, cap(s(:ivar, cap)), cap)
        )
      } do |ivar_name, ivar, call_name|
        ivar_name = format_ivar_name(ivar_name, ivar)
        call_name = format_call_name(call_name)
        push '$return_ivar_call(', ivar_name, ',', call_name, ')'
      end

      # def a; @x.other(1,2,3); end
      define_shortcut :return_ivar_call_args, when: Matcher.new {
        s(:**,
          s(:send, cap(s(:ivar, cap)), cap,
            cap(:**) { |args| args.all? { |i| simple_value? i } }
          )
        )
      } do |ivar_name, ivar, call_name, args|
        ivar_name = format_ivar_name(ivar_name, ivar)
        call_name = format_call_name(call_name)
        push '$return_ivar_call_args(', ivar_name, ',', call_name
        args.each do |arg|
          push ',', expr(arg)
        end
        push ')'
      end

      # def a(b); @x.other(b); end
      define_shortcut :return_ivar_call_pass, when: Matcher.new {
        s(:**,
          capture_single_arg,
          s(:send, cap(s(:ivar, cap)),
            cap(not_setter_call_name),
            s(:lvar, cap_eq(0))
          )
        )
      } do |_, ivar_name, ivar, call_name|
        ivar_name = format_ivar_name(ivar_name, ivar)
        call_name = format_call_name(call_name)
        push '$return_ivar_call_pass(', ivar_name, ',', call_name, ')'
      end

      # This happens a lot in the parser:
      # def a(y); @x.other(y[1],y[2],nil,y[3]); end
      define_shortcut :return_ivar_call_access_args, when: Matcher.new {
        s(:**,
          capture_single_arg,
          s(:send, cap(s(:ivar, cap)), cap,
            cap(:**, pass_captures: 0) do |args, arg|
              args.all? { |i| simple_value_access?(i, arg) }
            end
          )
        )
      } do |_, ivar_name, ivar, call_name, args|
        ivar_name = format_ivar_name(ivar_name, ivar)
        call_name = format_call_name(call_name)
        push '$return_ivar_call_access_args(', ivar_name, ',', call_name
        args.each do |arg|
          push ',', expr(arg.type == :nil ? arg : arg.children[2])
        end
        push ')'
      end

      # def a; `self.toA()`; end
      define_shortcut :_xstr_to_direct, when: Matcher.new {
        s(:def, :*,
          s(:args),
          s(:xstr,
            s(:str, cap(/^self.[\w$]+\(\)$/))
          )
        )
      } do |xstr|
        push "#{self.self}.$$prototype.#{xstr.split('.').last.split('(').first}"
      end
    end
  end
end
