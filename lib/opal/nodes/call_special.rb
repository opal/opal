require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    # recv.mid = rhs
    # s(:recv, :mid=, s(:arglist, rhs))
    # UNUSED;
    # class AttrAssignNode < CallNode
    #   handle :attrasgn

    #   children :recvr, :meth, :arglist

    #   def default_compile
    #     # Skip, for now, if the method has square brackets: []=
    #     return super if meth.to_s !~ /#{REGEXP_START}\w+=#{REGEXP_END}/

    #     with_temp do |args_tmp|
    #       with_temp do |recv_tmp|
    #         args = expr(arglist)
    #         mid = mid_to_jsid meth.to_s
    #         push "((#{args_tmp} = [", args, "]), "+
    #              "#{recv_tmp} = ", recv(recv_sexp), ", ",
    #              recv_tmp, mid, ".apply(#{recv_tmp}, #{args_tmp}), "+
    #              "#{args_tmp}[#{args_tmp}.length-1])"
    #       end
    #     end
    #   end
    # end

    # recv.JS[1] = rhs
    # TODO: handle it through :send
    # class JsAttrAssignNode < CallNode
    #   handle :jsattrasgn

    #   def record_method?
    #     false
    #   end

    #   def default_compile
    #     push recv(recv_sexp), '[', expr(arglist[1]), ']', '=', expr(arglist[2])
    #   end
    # end

    # recv.JS.prop
    # recv.JS[1]
    # recv.JS.meth(arg1, arg2)
    # TODO: handle it through :send
    # class JsCallNode < CallNode
    #   handle :jscall

    #   def record_method?
    #     false
    #   end

    #   def default_compile
    #     if meth == :[]
    #       push recv(recv_sexp), '[', expr(arglist), ']'
    #     else
    #       mid = ".#{meth}"

    #       splat = arglist[1..-1].any? { |a| a.first == :splat }

    #       if Sexp === arglist.last and arglist.last.type == :block_pass
    #         block = arglist.pop
    #       elsif iter
    #         block = iter
    #       end

    #       blktmp  = scope.new_temp if block
    #       tmprecv = scope.new_temp if splat

    #       # must do this after assigning temp variables
    #       block = expr(block) if block

    #       recv_code = recv(recv_sexp)
    #       call_recv = s(:js_tmp, blktmp || recv_code)

    #       if blktmp
    #         arglist.push call_recv
    #       end

    #       args = expr(arglist)

    #       if tmprecv
    #         push "(#{tmprecv} = ", recv_code, ")#{mid}"
    #       else
    #         push recv_code, mid
    #       end

    #       if blktmp
    #         unshift "(#{blktmp} = ", block, ", "
    #         push ")"
    #       end

    #       if splat
    #         push ".apply(", tmprecv, ", ", args, ")"
    #       else
    #         push "(", args, ")"
    #       end

    #       scope.queue_temp blktmp if blktmp
    #     end
    #   end
    # end

    class LogicalOpAssignNode < Base
      children :lhs, :rhs

      def compile
        get_node = case lhs.type
        when :lvasgn then lhs.updated(:lvar)
        when :ivasgn then lhs.updated(:ivar)
        when :casgn then lhs.updated(:const)
        when :cvasgn then lhs.updated(:cvar)
        when :gvasgn then lhs.updated(:gvar)
        when :send
          send_lhs, send_op, *send_args = lhs.children
          sexp = expr s(:op_asgn1, send_lhs, s(:array, *send_args), send_op, rhs)
          push sexp
          return
        else
          raise "Unsupported node in LogicalOpAssignNode #{lhs.type}"
        end
        set_node = lhs.updated(nil, lhs.children + [rhs])
        sexp = s(evaluates_to, get_node, set_node)
        push expr(sexp)
      end

      def evaluates_to
        raise NotImplemetnedError
      end
    end

    # a ||= rhs
    # s(:or_asgn, s(:lvasgn, :a), rhs)
    #
    # @a ||= rhs
    # s(:or_asgn, s(:ivasgn, :@a), rhs)
    #
    # @@a ||= rhs
    # s(:or_asgn, s(:cvasgn, :@@a), rhs)
    #
    # A ||= 1
    # s(:or_asgn, s(:casgn, :nil), :A)
    class OpAsgnOrNode < LogicalOpAssignNode
      handle :or_asgn

      def evaluates_to
        :or
      end
    end

    # a &&= rhs
    # s(:and_asgn, s(:lvasgn, :a), rhs)
    #
    # @a &&= rhs
    # s(:and_asgn, s(:ivasgn, :@a), rhs)
    #
    # @@a &&= rhs
    # s(:and_asgn, s(:cvasgn, :@@a), rhs)
    #
    # A &&= 1
    # s(:and_asgn, s(:casgn, :nil), :A)
    class OpAsgnAndNode < LogicalOpAssignNode
      handle :and_asgn

      def evaluates_to
        :and
      end
    end

    class OpAsgnNode < Base
      handle :op_asgn
      children :lhs, :op, :rhs

      def compile
        get_sexp = case lhs.type
        when :lvasgn then lhs.updated(:lvar)
        when :ivasgn then lhs.updated(:ivar)
        when :casgn  then lhs.updated(:const)
        when :cvasgn then lhs.updated(:cvar)
        when :gvasgn then lhs.updated(:gvar)
          raise NotImplementedError
        end

        new_rhs_sexp = s(:send, get_sexp, op, rhs)

        set_sexp = lhs.updated(nil, lhs.children + [new_rhs_sexp])
        push expr(set_sexp)
      end
    end

    # lhs[args] ||= rhs
    # s(:op_asgn1, lhs, args, :||, rhs)
    class OpAsgn1Node < Base
      handle :op_asgn1

      children :lhs, :args, :op, :rhs

      def first_arg
        args.children[0]
      end

      def compile
        case op.to_s
        when '||' then compile_or
        when '&&' then compile_and
        else compile_operator
        end
      end

      # FIXME: possibly broken
      def compile_operator
        with_temp do |a| # args
          with_temp do |r| # recv
            cur = s(:send, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            rhs = s(:send, cur, op.to_sym, s(:arglist, self.rhs))
            call = s(:send, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))

            push "(#{a} = ", expr(first_arg), ", #{r} = ", expr(lhs)
            push ", ", expr(call), ")"
          end
        end
      end

      def compile_or
        with_temp do |a| # args
          with_temp do |r| # recv
            aref = s(:send, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            aset = s(:send, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))
            orop = s(:or, aref, aset)

            push "(#{a} = ", expr(first_arg), ", #{r} = ", expr(lhs)
            push ", ", expr(orop), ")"
          end
        end
      end

      def compile_and
        with_temp do |a| # args
          with_temp do |r| # recv
            aref = s(:send, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            aset = s(:send, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))
            andop = s(:and, aref, aset)

            push "(#{a} = ", expr(first_arg), ", #{r} = ", expr(lhs)
            push ", ", expr(andop), ")"
          end
        end
      end
    end

    # lhs.b += rhs
    # s(:op_asgn2, lhs, :b=, :+, rhs)
    class OpAsgn2Node < Base
      handle :op_asgn2

      children :lhs, :mid, :op, :rhs

      def meth
        mid.to_s[0..-2]
      end

      def compile
        case op.to_s
        when '||' then compile_or
        when '&&' then compile_and
        else compile_operator
        end
      end

      def compile_or
        with_temp do |tmp|
          getr = s(:send, s(:js_tmp, tmp), meth, s(:arglist))
          asgn = s(:send, s(:js_tmp, tmp), mid, s(:arglist, rhs))
          orop = s(:or, getr, asgn)

          push "(#{tmp} = ", expr(lhs), ", ", expr(orop), ")"
        end
      end

      def compile_and
        with_temp do |tmp|
          getr = s(:send, s(:js_tmp, tmp), meth, s(:arglist))
          asgn = s(:send, s(:js_tmp, tmp), mid, s(:arglist, rhs))
          andop = s(:and, getr, asgn)

          push "(#{tmp} = ", expr(lhs), ", ", expr(andop), ")"
        end
      end

      def compile_operator
        with_temp do |tmp|
          getr = s(:send, s(:js_tmp, tmp), meth, s(:arglist))
          oper = s(:send, getr, op, s(:arglist, rhs))
          asgn = s(:send, s(:js_tmp, tmp), mid, s(:arglist, oper))

          push "(#{tmp} = ", expr(lhs), ", ", expr(asgn), ")"
        end
      end
    end
  end
end
