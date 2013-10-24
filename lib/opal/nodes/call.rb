require 'opal/nodes/base'

module Opal
  module Nodes
    class CallNode < Base
      handle :call

      children :recvr, :meth, :arglist, :iter

      def compile
        if handled = compiler.handle_call(@sexp)
          push handled
          return
        end

        mid = mid_to_jsid meth.to_s

        compiler.method_calls << meth.to_sym

        # trying to access an lvar in irb mode
        if using_irb?
          with_temp do |tmp|
            lvar = variable(meth)
            call = s(:call, s(:self), meth.intern, s(:arglist))
            push "((#{tmp} = $opal.irb_vars.#{lvar}) == null ? ", expr(call), " : #{tmp})"
          end

          return
        end

        case meth
        when :block_given?
          return push @compiler.js_block_given(@sexp, @level)
        when :__method__, :__callee__
          if scope.def?
            return push(scope.mid.to_s.inspect)
          else
            return push("nil")
          end
        end

        splat = arglist[1..-1].any? { |a| a.first == :splat }

        if Sexp === arglist.last and arglist.last.type == :block_pass
          block = expr(arglist.pop)
        elsif iter
          block = expr(iter)
        end

        tmpfunc = scope.new_temp if block
        tmprecv = scope.new_temp if splat || tmpfunc

        recv_code = recv(recv_sexp)
        call_recv = s(:js_tmp, tmprecv || recv_code)

        if tmpfunc and !splat
          arglist.insert 1, call_recv
        end

        args = expr(arglist)

        if tmprecv
          push "(#{tmprecv} = ", recv_code, ")#{mid}"
        else
          push recv_code, mid
        end

        if tmpfunc
          unshift "(#{tmpfunc} = "
          push ", #{tmpfunc}._p = ", block, ", #{tmpfunc})"
        end

        if splat
          push ".apply("
          push(tmprecv || recv_code)
          push ", ", args, ")"
        elsif tmpfunc
          push ".call(", args, ")"
        else
          push "(", args, ")"
        end

        scope.queue_temp tmpfunc if tmpfunc
      end

      def recv_sexp
        recvr || s(:self)
      end

      def using_irb?
        @compiler.irb? and scope.top? and arglist == s(:arglist) and recvr.nil? and iter.nil?
      end
    end

    # FIXME: needs rewrite
    class ArglistNode < Base
      handle :arglist

      def compile
        code, work = [], []

        children.each do |current|
          splat = current.first == :splat
          arg   = expr(current)

          if splat
            if work.empty?
              if code.empty?
                code << fragment("[].concat(")
                code << arg
                code << fragment(")")
              else
                code += ".concat(#{arg})"
              end
            else
              if code.empty?
                code << [fragment("["), work, fragment("]")]
              else
                code << [fragment(".concat(["), work, fragment("])")]
              end

              code << [fragment(".concat("), arg, fragment(")")]
            end

            work = []
          else
            work << fragment(", ") unless work.empty?
            work << arg
          end
        end

        unless work.empty?
          join = work

          if code.empty?
            code = join
          else
            code << fragment(".concat(") << join << fragment(")")
          end
        end

        push(*code)
      end
    end
  end
end
