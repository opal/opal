# frozen_string_literal: true

require 'set'
require 'pathname'
require 'opal/nodes/base'

module Opal
  module Nodes
    class CallNode < Base
      handle :send, :csend

      attr_reader :recvr, :meth, :arglist, :iter

      SPECIALS = {}

      # Operators that get optimized by compiler
      OPERATORS = { :+ => :plus, :- => :minus, :* => :times, :/ => :divide,
                    :< => :lt, :<= => :le, :> => :gt, :>= => :ge,
                    :| => nil, :& => nil, :^ => nil, :+@ => nil,
                    :-@ => nil, :~@ => nil, :!@ => nil, :length => nil,
                    :<< => nil, :>> => nil
                  }.freeze

      def self.add_special(name, options = {}, &handler)
        SPECIALS[name] ||= []
        SPECIALS[name] << [options, handler]
      end

      def initialize(*)
        super
        @recvr, @meth, *args = *@sexp

        *rest, last_arg = *args

        if last_arg && %i[iter block_pass].include?(last_arg.type)
          @iter = last_arg
          args = rest
        else
          @iter = nil
        end

        @arglist = s(:arglist, *args)
      end

      def compile
        # handle some methods specially
        # some special methods need to skip compilation, so we pass the default as a block
        handle_special do
          compiler.record_method_call meth

          with_wrapper do
            if using_eval?
              # if trying to access an lvar in eval or irb mode
              compile_eval_var
            elsif using_irb?
              # if trying to access an lvar in irb mode
              compile_irb_var
            else
              default_compile
            end
          end
        end
      end

      private

      def iter_has_break?
        return false unless iter

        iter.meta[:has_break]
      end

      # Opal has a runtime helper 'Opal.send_method_name' that assigns
      # provided block to a '$$p' property of the method body
      # and invokes a method using 'apply'.
      #
      # We have to compile a method call using this 'Opal.send_method_name' when a method:
      # 1. takes a splat
      # 2. takes a block
      #
      # Arguments that contain splat must be handled in a different way.
      # @see #compile_arguments
      #
      # When a method takes a block we have to calculate all arguments
      # **before** assigning '$$p' property (that stores a passed block)
      # to a method body. This is some kind of protection from method calls
      # like 'a(a {}) { 1 }'.
      def invoke_using_send?
        iter || splat? || call_is_writer_that_needs_handling?
      end

      def invoke_using_refinement?
        !scope.scope.collect_refinements_temps.empty?
      end

      # Is it a conditional send, ie. `foo&.bar`?
      def csend?
        @sexp.type == :csend
      end

      def default_compile
        if auto_await?
          push '(await '
          scope.await_encountered = true
        end

        push_closure(Closure::SEND) if iter_has_break?
        if invoke_using_refinement?
          compile_using_refined_send
        elsif invoke_using_send?
          compile_using_send
        else
          compile_simple_call_chain
        end
        pop_closure if iter_has_break?

        if auto_await?
          push ')'
        end
      end

      # Compiles method call using `Opal.send`
      #
      # @example
      #   a.b(c, &block)
      #
      #   Opal.send(a, 'b', [c], block)
      #
      def compile_using_send
        helper :send

        push dce_use(meth)

        push '$send('
        compile_receiver
        compile_method_name
        compile_arguments
        compile_block_pass
        push ')'
      end

      # Compiles method call using `Opal.refined_send`
      #
      # @example
      #   a.b(c, &block)
      #
      #   Opal.refined_send(a, 'b', [c], block, [[Opal.MyRefinements]])
      #
      def compile_using_refined_send
        helper :refined_send

        push dce_use(meth)

        push '$refined_send('
        compile_refinements
        compile_receiver
        compile_method_name
        compile_arguments
        compile_block_pass
        push ')'
      end

      def compile_receiver
        push @conditional_recvr || recv(receiver_sexp)
      end

      def compile_method_name
        push ", '#{meth}'"
      end

      def compile_arguments(skip_comma = false)
        push ', ' unless skip_comma

        if @with_writer_temp
          push @with_writer_temp
        elsif splat?
          push expr(arglist)
        elsif arglist.children.empty?
          push '[]'
        else
          push '[', expr(arglist), ']'
        end
      end

      def compile_block_pass
        if iter
          push ', ', expr(iter)
        end
      end

      def compile_refinements
        refinements = scope.collect_refinements_temps.map { |i| s(:js_tmp, i) }
        push expr(s(:array, *refinements)), ', '
      end

      def compile_simple_call_chain
        compile_receiver
        push dce_use(meth)
        push method_jsid, '(', expr(arglist), ')'
      end

      def splat?
        arglist.children.any? { |a| a.type == :splat }
      end

      def receiver_sexp
        recvr || s(:self)
      end

      def method_jsid
        mid_to_jsid meth.to_s
      end

      # Used to generate the code to use this sexp as an ivar var reference
      def compile_irb_var
        with_temp do |tmp|
          lvar = meth
          call = s(:send, s(:self), meth.intern, s(:arglist))
          ref = "(typeof #{lvar} !== 'undefined') ? #{lvar} : "
          push "((#{tmp} = Opal.irb_vars.#{lvar}) == null ? ", ref, expr(call), " : #{tmp})"
        end
      end

      def compile_eval_var
        push meth.to_s
      end

      # a variable reference in irb mode in top scope might be a var ref,
      # or it might be a method call
      def using_irb?
        @compiler.irb? && scope.top? && variable_like?
      end

      def using_eval?
        @compiler.eval? && scope.top? && @compiler.scope_variables.include?(meth)
      end

      def variable_like?
        arglist == s(:arglist) && recvr.nil? && iter.nil?
      end

      def sexp_with_arglist
        @sexp.updated(nil, [recvr, meth, arglist])
      end

      def auto_await?
        awaited_set = compiler.async_await

        awaited_set && awaited_set != true && awaited_set.match?(meth.to_s)
      end

      # Handle "special" method calls, e.g. require(). Subclasses can override
      # this method. If this method returns nil, then the method will continue
      # to be generated by CallNode.
      def handle_special(&compile_default)
        if SPECIALS.include? meth
          current_proc = compile_default
          SPECIALS[meth].reverse_each do |_options, handler|
            previous_proc = current_proc
            current_proc = proc do
              instance_exec(previous_proc, &handler)
            end
          end
          current_proc.call
        else
          yield # i.e. compile_default.call
        end
      end

      OPERATORS.each do |operator, name|
        add_special(operator.to_sym) do |compile_default|
          if invoke_using_refinement?
            compile_default.call
          elsif compiler.inline_operators?
            if @sexp.meta[:type]
              # We have inferred the types. Therefore, we can compile
              # the expression directly to JavaScript
              if @sexp.children.length == 2
                if /\A[a-z_]*\z/.match? operator.to_s
                  push recv(recvr), '.', operator.to_s
                else
                  push '(', operator.to_s[0], ' ', expr(recvr), ')'
                end
              elsif @sexp.children.length == 3
                # Boolean operators
                if %i[| &].include?(operator) && @sexp.meta[:type] == :bool
                  operator = operator.to_s * 2
                end

                if %i[<<].include?(operator) && @sexp.meta[:type] == :array
                  # Statements are those operations where we discard return value
                  if stmt?
                    push recv(recvr), '.push(', expr(arglist), ')'
                  else
                    compile_default.call
                  end
                elsif %i[<< >>].include?(operator) && @sexp.meta[:type] == :float
                  # <<, >> with negative right operand have different semantics
                  if [:int, :float].include?(@sexp.children[2].type) && 
                     @sexp.children[2].children[0] > 0
                    push '(', expr(recvr), ' ', operator.to_s, ' ', expr(arglist), ')'
                  else
                    compile_default.call
                  end
                else
                  push '(', expr(recvr), ' ', operator.to_s, ' ', expr(arglist), ')'
                end
              else
                compile_default.call
              end
            elsif name
              compiler.record_method_call operator

              helper :"rb_#{name}"

              push "$rb_#{name}(", expr(recvr), ', ', expr(arglist), ')'
            else
              compile_default.call
            end
          else
            compile_default.call
          end
        end
      end

      add_special :block_given? do
        push compiler.handle_block_given_call @sexp
      end

      # Refinements support
      add_special :using do |compile_default|
        if scope.accepts_using? && arglist.children.count == 1
          using_refinement(arglist.children.first)
        else
          compile_default.call
        end
      end

      def using_refinement(arg)
        prev, curr = *scope.refinements_temp
        if prev
          push "(#{curr} = #{prev}.slice(), #{curr}.push(", expr(arg), "), #{scope.self})"
        else
          push "(#{curr} = [", expr(arg), "], #{scope.self})"
        end
      end

      add_special :debugger do
        push fragment 'debugger'
      end

      add_special :lambda do |compile_default|
        scope.defines_lambda do
          compile_default.call
        end
      end

      add_special :__await__ do |compile_default|
        if compiler.async_await
          push fragment '(await ('
          push process(recvr)
          push fragment '))'
          scope.await_encountered = true
        else
          compile_default.call
        end
      end

      def push_nesting?
        recv = children.first

        children.size == 2 && (           # only receiver and method
          recv.nil? || (                  # and no receiver
            recv.type == :const &&        # or receiver
            recv.children.last == :Module # is Module
          )
        )
      end

      def with_wrapper(&block)
        if csend? && !@conditional_recvr
          handle_conditional_send do
            with_wrapper(&block)
          end
        elsif call_is_writer_that_needs_handling?
          handle_writer(&block)
        else
          yield
        end
      end

      def call_is_writer_that_needs_handling?
        (expr? || recv?) && (meth.to_s =~ /^\w+=$/ || meth == :[]=)
      end

      # Handle safe-operator calls: foo&.bar / foo&.bar ||= baz / ...
      def handle_conditional_send
        # temporary variable that stores method receiver
        receiver_temp = scope.new_temp
        push "#{receiver_temp} = ", expr(receiver_sexp)

        # execute the sexp only if the receiver isn't nil
        push ", (#{receiver_temp} === nil || #{receiver_temp} == null) ? nil : "
        @conditional_recvr = receiver_temp
        yield
        wrap '(', ')'
      end

      def handle_writer
        with_temp do |temp|
          push "(#{temp} = "
          compile_arguments(true)
          push ", "
          @with_writer_temp = temp
          yield
          @with_writer_temp = false
          push ", "
          push "#{temp}[#{temp}.length - 1])"
        end
      end
    end
  end
end
