# frozen_string_literal: true

require 'set'
require 'pathname'
require 'opal/nodes/base'
require 'opal/rewriters/break_finder'

module Opal
  module Nodes
    class CallNode < Base
      handle :send

      attr_reader :recvr, :meth, :arglist, :iter

      SPECIALS = {}

      # Operators that get optimized by compiler
      OPERATORS = { :+ => :plus, :- => :minus, :* => :times, :/ => :divide,
                    :< => :lt, :<= => :le, :> => :gt, :>= => :ge }.freeze

      def self.add_special(name, options = {}, &handler)
        SPECIALS[name] = options
        define_method("handle_#{name}", &handler)
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
          compiler.method_calls << meth.to_sym if record_method?

          # if trying to access an lvar in eval or irb mode
          return compile_eval_var if using_eval?

          # if trying to access an lvar in irb mode
          return compile_irb_var if using_irb?

          default_compile
        end
      end

      private

      def iter_has_break?
        return false unless iter

        finder = Opal::Rewriters::BreakFinder.new
        finder.process(iter)
        finder.found_break?
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
        iter || splat?
      end

      def invoke_using_refinement?
        !scope.scope.collect_refinements_temps.empty?
      end

      def default_compile
        if auto_await?
          push 'await '
          scope.await_encountered = true
        end

        if invoke_using_refinement?
          compile_using_refined_send
        elsif invoke_using_send?
          compile_using_send
        else
          compile_simple_call_chain
        end

        compile_break_catcher
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

        push '$refined_send('
        compile_refinements
        compile_receiver
        compile_method_name
        compile_arguments
        compile_block_pass
        push ')'
      end

      def compile_receiver
        push recv(receiver_sexp)
      end

      def compile_method_name
        push ", '#{meth}'"
      end

      def compile_arguments
        push ', '

        if splat?
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

      def compile_break_catcher
        if iter_has_break?
          unshift 'return '
          unshift '(function(){var $brk = Opal.new_brk(); try {'
          line '} catch (err) { if (err === $brk) { return err.$v } else { throw err } }})()'
        end
      end

      def compile_simple_call_chain
        push recv(receiver_sexp), method_jsid, '(', expr(arglist), ')'
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

      def record_method?
        true
      end

      # Used to generate the code to use this sexp as an ivar var reference
      def compile_irb_var
        with_temp do |tmp|
          lvar = meth
          call = s(:send, s(:self), meth.intern, s(:arglist))
          push "((#{tmp} = Opal.irb_vars.#{lvar}) == null ? ", expr(call), " : #{tmp})"
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
          method = method("handle_#{meth}")
          method.arity == 1 ? method[compile_default] : method[]
        else
          yield # i.e. compile_default.call
        end
      end

      OPERATORS.each do |operator, name|
        add_special(operator.to_sym) do |compile_default|
          if compiler.inline_operators?
            compiler.method_calls << operator.to_sym if record_method?
            compiler.operator_helpers << operator.to_sym
            lhs, rhs = expr(recvr), expr(arglist)

            push fragment("$rb_#{name}(")
            push lhs
            push fragment(', ')
            push rhs
            push fragment(')')
          else
            compile_default.call
          end
        end
      end

      add_special :require do |compile_default|
        str = DependencyResolver.new(compiler, arglist.children[0]).resolve
        compiler.requires << str unless str.nil?
        compile_default.call
      end

      add_special :require_relative do
        arg = arglist.children[0]
        file = compiler.file
        if arg.type == :str
          dir = File.dirname(file)
          compiler.requires << Pathname(dir).join(arg.children[0]).cleanpath.to_s
        end
        push fragment("self.$require(#{file.inspect}+ '/../' + ")
        push process(arglist)
        push fragment(')')
      end

      add_special :autoload do
        unless scope.top?
          push recv(receiver_sexp), method_jsid, '(', expr(arglist.children[0]), ', '
          if arglist.children[1].type == :str && arglist.children[1].children[0] != ''
            str = DependencyResolver.new(compiler, arglist.children[1]).resolve
            if str.nil?
              warn "Warning: File '#{arglist.children[1].children[0]}' for autoload of constant '#{arglist.children[0].children[0]}' could not be found!"
            end
            push expr(arglist.children[1])
          else
            push expr(arglist.children[1])
          end
          push ')'
        end
      end

      add_special :require_tree do |compile_default|
        first_arg, *rest = *arglist.children
        if first_arg.type == :str
          relative_path = first_arg.children[0]
          compiler.required_trees << relative_path

          dir = File.dirname(compiler.file)
          full_path = Pathname(dir).join(relative_path).cleanpath.to_s
          full_path.force_encoding(relative_path.encoding)
          first_arg = first_arg.updated(nil, [full_path])
        end
        @arglist = arglist.updated(nil, [first_arg] + rest)
        compile_default.call
      end

      add_special :block_given? do
        push compiler.handle_block_given_call @sexp
      end

      add_special :__callee__ do
        if scope.def?
          push fragment scope.mid.to_s.inspect
        else
          push fragment 'nil'
        end
      end

      add_special :__method__ do
        if scope.def?
          push fragment scope.mid.to_s.inspect
        else
          push fragment 'nil'
        end
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
          push "(#{curr} = #{prev}.slice(), #{curr}.push(", expr(arg), '), self)'
        else
          push "(#{curr} = [", expr(arg), '], self)'
        end
      end

      add_special :debugger do
        push fragment 'debugger'
      end

      add_special :__OPAL_COMPILER_CONFIG__ do
        push fragment "Opal.hash({ arity_check: #{compiler.arity_check?} })"
      end

      add_special :lambda do |compile_default|
        scope.defines_lambda do
          compile_default.call
        end
      end

      add_special :nesting do |compile_default|
        push_nesting = push_nesting?
        push '(Opal.Module.$$nesting = $nesting, ' if push_nesting
        compile_default.call
        push ')' if push_nesting
      end

      add_special :constants do |compile_default|
        push_nesting = push_nesting?
        push '(Opal.Module.$$nesting = $nesting, ' if push_nesting
        compile_default.call
        push ')' if push_nesting
      end

      # This can be refactored in terms of binding, but it would 'corelib/binding'
      # to be required in existing code.
      add_special :eval do |compile_default|
        next compile_default.call if arglist.children.length != 1 || ![s(:self), nil].include?(recvr)

        temp = scope.new_temp
        scope_variables = scope.scope_locals.map(&:to_s).inspect
        push "(#{temp} = ", expr(arglist)
        push ", typeof Opal.compile === 'function' ? eval(Opal.compile(#{temp}"
        push ', {scope_variables: ', scope_variables
        push ", arity_check: #{compiler.arity_check?}, file: '(eval)', eval: true})) : "
        push "self.$eval(#{temp}))"
      end

      add_special :binding do
        push "Opal.Binding.$new("
        push "  function($code, $value) {"
        push "    if (typeof $value === 'undefined') {"
        push "      return eval($code);"
        push "    }"
        push "    else {"
        push "      return eval($code + ' = $value');"
        push "    }"
        push "  },"
        push "  ", scope.scope_locals.map(&:to_s).inspect, ","
        push "  self,"
        push "  ", source_location
        push ")"
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

      class DependencyResolver
        def initialize(compiler, sexp)
          @compiler = compiler
          @sexp = sexp
        end

        def resolve
          handle_part @sexp
        end

        def handle_part(sexp)
          type = sexp.type

          if type == :str
            return sexp.children[0]
          elsif type == :send
            recv, meth, *args = sexp.children

            parts = args.map { |s| handle_part s }

            if recv.is_a?(::Opal::AST::Node) && recv.type == :const && recv.children.last == :File
              if meth == :expand_path
                return expand_path(*parts)
              elsif meth == :join
                return expand_path parts.join('/')
              elsif meth == :dirname
                return expand_path parts[0].split('/')[0...-1].join('/')
              end
            end
          end

          msg = 'Cannot handle dynamic require'
          case @compiler.dynamic_require_severity
          when :error
            @compiler.error msg, @sexp.line
          when :warning
            @compiler.warning msg, @sexp.line
          end
        end

        def expand_path(path, base = '')
          "#{base}/#{path}".split('/').each_with_object([]) do |part, p|
            if part == ''
              # we had '//', so ignore
            elsif part == '..'
              p.pop
            else
              p << part
            end
          end.join '/'
        end
      end
    end
  end
end
