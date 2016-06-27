require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    # recvr.JS[:prop]
    # => recvr.prop
    class JsAttrNode < Base
      handle :jsattr
      children :recvr, :property

      def compile
        push recv(recvr), '[', expr(property), ']'
      end
    end

    # recvr.JS[:prop] = value
    # => recvr.prop = value
    class JsAttrAsgnNode < Base
      handle :jsattrasgn

      children :recvr, :property, :value

      def compile
        push recv(recvr), '[', expr(property), '] = ', expr(value)
      end
    end

    class JsCallNode < CallNode
      handle :jscall

      def initialize(*)
        super

        # For .JS. call we pass a block
        # as a plain JS callback
        if @iter
          @arglist = @arglist << @iter
        end
        @iter = nil
      end

      def compile
        default_compile
      end

      def method_jsid
        "." + meth.to_s
      end
    end

    # /regexp/ =~ rhs
    # s(:match_with_lvasgn, lhs, rhs)
    class Match3Node < Base
      handle :match_with_lvasgn

      children :lhs, :rhs

      def compile
        sexp = s(:send, lhs, :=~, rhs)
        push process(sexp, @level)
      end
    end

    class LogicalOpAssignNode < Base
      children :lhs

      def compile
        get_node = case lhs.type
        when :lvasgn then lhs.updated(:lvar)
        when :ivasgn then lhs.updated(:ivar)
        when :casgn then lhs.updated(:const)
        when :cvasgn then lhs.updated(:cvar)
        when :gvasgn then lhs.updated(:gvar)
        when :send
          compile_send
          return
        else
          raise "Unsupported node in LogicalOpAssignNode #{lhs.type}"
        end
        set_node = lhs.updated(nil, lhs.children + [rhs])
        sexp = s(evaluates_to, get_node, set_node)
        push expr(sexp)
      end

      # RHS can be begin..end
      # In this case we need to mark it so it will be wrapped with a function
      def rhs
        children.last
      end

      def compile_send
        send_lhs, send_op, *send_args = lhs.children
        if send_op == :[]
          # Here we should build a pseudo-node
          # s(:op_asgn1, lhs, args, :||, rhs)
          sexp = s(:op_asgn1, send_lhs, s(:array, *send_args), send_evaluates_to, rhs)
        else
          # Otherwise we have a.b ||= 1
          # which doesn't have send_args,
          # so we should build a pseudo-node
          # s(:op_asgn2, lhs, :b=, :+, rhs)
          send_op = (send_op.to_s + '=').to_sym
          sexp = s(:op_asgn2, send_lhs, send_op, send_evaluates_to, rhs)
        end
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

      def send_evaluates_to
        '||'
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

      def send_evaluates_to
        '&&'
      end
    end

    class OpAsgnNode < Base
      handle :op_asgn
      children :lhs, :op, :rhs

      def compile
        if lhs.type == :send
          compile_temporary_assignments
        end

        push expr(set_sexp)
      end

      def compile_temporary_assignments
        with_temp do |lhs_recv_tmp|
          with_temp do |lhs_arg_tmp|
            lhs_recv, lhs_op, lhs_arg = *lhs

            lhs_recv_asgn = s(:lvasgn, lhs_recv_tmp, lhs_recv)
            new_lhs_recv = s(:lvar, lhs_recv_tmp)
            push stmt(lhs_recv_asgn), ','

            if lhs_arg
              lhs_arg_asgn = s(:lvasgn, lhs_arg_tmp, lhs_arg)
              new_lhs_arg = s(:lvar, lhs_arg_tmp)
              push stmt(lhs_arg_asgn), ','
            end

            new_lhs = lhs.updated(nil, [new_lhs_recv, lhs_op, new_lhs_arg].compact)
            @sexp = @sexp.updated(nil, [new_lhs, op, rhs])
          end
        end
      end

      def get_sexp
        case lhs.type
        when :lvasgn then lhs.updated(:lvar)
        when :ivasgn then lhs.updated(:ivar)
        when :casgn  then lhs.updated(:const)
        when :cvasgn then lhs.updated(:cvar)
        when :gvasgn then lhs.updated(:gvar)
        when :send   then lhs
        else
          raise NotImplementedError
        end
      end

      def get_and_update_sexp
        case lhs.type
        when :lvasgn, :ivasgn, :casgn, :cvasgn, :gvasgn, :send
          s(:send, get_sexp, op, rhs)
        else
          raise NotImplementedError
        end
      end

      def set_sexp
        case lhs.type
        when :lvasgn, :ivasgn, :casgn, :cvasgn, :gvasgn
          lhs.updated(nil, lhs.children + [get_and_update_sexp])
        when :send
          recvr, meth, *rest = *lhs.children
          meth = (meth.to_s + "=").to_sym
          lhs.updated(nil, [recvr, meth, *rest, get_and_update_sexp])
        end
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
