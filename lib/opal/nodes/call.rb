require 'set'
require 'pathname'
require 'opal/nodes/base'
require 'opal/nodes/runtime_helpers'

module Opal
  module Nodes
    class CallNode < Base
      handle :call

      children :recvr, :meth, :arglist, :iter

      SPECIALS = {}

      # Operators that get optimized by compiler
      OPERATORS = { :+ => :plus, :- => :minus, :* => :times, :/ => :divide,
                    :< => :lt, :<= => :le, :> => :gt, :>= => :ge }

      def self.add_special(name, options = {}, &handler)
        SPECIALS[name] = options
        define_method("handle_#{name}", &handler)
      end

      def compile
        # handle some methods specially
        handle_special

        # some special methods need to skip compilation
        return unless compile_default?

        compiler.method_calls << meth.to_sym if record_method?

        # if trying to access an lvar in irb mode
        return compile_irb_var if using_irb?

        default_compile
      end

      def record_method?
        true
      end

      def default_compile

        mid = mid_to_jsid meth.to_s

        splat = arglist[1..-1].any? { |a| a.first == :splat }

        if Sexp === arglist.last and arglist.last.type == :block_pass
          block = arglist.pop
        elsif iter
          block = iter
        end

        blktmp  = scope.new_temp if block
        tmprecv = scope.new_temp if splat || blktmp

        # must do this after assigning temp variables
        block = expr(block) if block

        recv_code = recv(recv_sexp)
        call_recv = s(:js_tmp, tmprecv || recv_code)

        if blktmp and !splat
          arglist.insert 1, call_recv
        end

        args = expr(arglist)

        if tmprecv
          push "(#{tmprecv} = ", recv_code, ")#{mid}"
        else
          push recv_code, mid
        end

        if blktmp
          unshift "(#{blktmp} = "
          push ", #{blktmp}.$$p = ", block, ", #{blktmp})"
        end

        if splat
          push ".apply(", (tmprecv || recv_code), ", ", args, ")"
        elsif blktmp
          push ".call(", args, ")"
        else
          push "(", args, ")"
        end

        scope.queue_temp blktmp if blktmp
      end

      def recv_sexp
        recvr || s(:self)
      end

      def attr_assignment?
        @assignment ||= meth.to_s =~ /#{REGEXP_START}[\da-z]+\=#{REGEXP_END}/i
      end

      # Used to generate the code to use this sexp as an ivar var reference
      def compile_irb_var
        with_temp do |tmp|
          lvar = variable(meth)
          call = s(:call, s(:self), meth.intern, s(:arglist))
          push "((#{tmp} = Opal.irb_vars.#{lvar}) == null ? ", expr(call), " : #{tmp})"
        end
      end

      def compile_assignment
        with_temp do |args_tmp|
          with_temp do |recv_tmp|
            args = expr(arglist)
            mid = mid_to_jsid meth.to_s
            push "((#{args_tmp} = [", args, "]), "+
                 "#{recv_tmp} = ", recv(recv_sexp), ", ",
                 recv_tmp, mid, ".apply(#{recv_tmp}, #{args_tmp}), "+
                 "#{args_tmp}[#{args_tmp}.length-1])"
          end
        end
      end

      # a variable reference in irb mode in top scope might be a var ref,
      # or it might be a method call
      def using_irb?
        @compiler.irb? and scope.top? and arglist == s(:arglist) and recvr.nil? and iter.nil?
      end

      # Handle "special" method calls, e.g. require(). Subclasses can override
      # this method. If this method returns nil, then the method will continue
      # to be generated by CallNode.
      def handle_special
        @compile_default = true

        if SPECIALS.include? meth
          @compile_default = false
          __send__("handle_#{meth}")
        elsif RuntimeHelpers.compatible?(recvr, meth, arglist)
          @compile_default = false
          push(RuntimeHelpers.new(@sexp, @level, @compiler).compile)
        end
      end

      def compile_default!
        @compile_default = true
      end

      def compile_default?
        @compile_default
      end

      OPERATORS.each do |operator, name|
        add_special(operator.to_sym) do
          if compiler.inline_operators?
            compiler.operator_helpers << operator.to_sym
            lhs, rhs = expr(recvr), expr(arglist[1])

            push fragment("$rb_#{name}(")
            push lhs
            push fragment(", ")
            push rhs
            push fragment(")")
          else
            compile_default!
          end
        end
      end

      add_special :require do
        compile_default!
        str = DependencyResolver.new(compiler, arglist[1]).resolve
        compiler.requires << str unless str.nil?
        push fragment('')
      end

      add_special :require_relative do
        arg = arglist[1]
        file = compiler.file
        if arg[0] == :str
          dir = File.dirname(file)
          compiler.requires << Pathname(dir).join(arg[1]).cleanpath.to_s
        end
        push fragment("self.$require(#{file.inspect}+ '/../' + ")
        push process(arglist)
        push fragment(')')
      end

      add_special :autoload do
        if scope.class_scope?
          compile_default!
          str = DependencyResolver.new(compiler, arglist[2]).resolve
          compiler.requires << str unless str.nil?
          push fragment('')
        end
      end

      add_special :require_tree do
        arg = arglist[1]
        if arg[0] == :str
          relative_path = arg[1]
          compiler.required_trees << relative_path

          dir = File.dirname(compiler.file)
          full_path = Pathname(dir).join(relative_path).cleanpath.to_s
          arg[1] = full_path
        end
        compile_default!
        push fragment('')
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

      add_special :debugger do
        push fragment 'debugger'
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
            return sexp[1]
          elsif type == :call
            _, recv, meth, args = sexp

            parts = args[1..-1].map { |s| handle_part s }

            if recv == [:const, :File]
              if meth == :expand_path
                return expand_path(*parts)
              elsif meth == :join
                return expand_path parts.join('/')
              elsif meth == :dirname
                return expand_path parts[0].split('/')[0...-1].join('/')
              end
            end
          end

          msg = "Cannot handle dynamic require"
          case @compiler.dynamic_require_severity
          when :error
            @compiler.error msg, @sexp.line
          when :warning
            @compiler.warning msg, @sexp.line
          end
        end

        def expand_path(path, base = '')
          "#{base}/#{path}".split("/").inject([]) do |p, part|
            if part == ''
              # we had '//', so ignore
            elsif part == '..'
              p.pop
            else
              p << part
            end

            p
          end.join "/"
        end
      end
    end
  end
end
