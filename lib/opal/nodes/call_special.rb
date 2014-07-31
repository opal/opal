require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    # recv.mid = rhs
    # s(:recv, :mid=, s(:arglist, rhs))
    class AttrAssignNode < CallNode
      handle :attrasgn

      children :recvr, :meth, :arglist

      def default_compile
        # Skip, for now, if the method has square brackets: []=
        return super if meth.to_s !~ /^\w+=$/

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
    end

    # lhs =~ rhs
    # s(:match3, lhs, rhs)
    class Match3Node < Base
      handle :match3

      children :lhs, :rhs

      def compile
        sexp = s(:call, lhs, :=~, s(:arglist, rhs))
        push process(sexp, @level)
      end
    end

    # a ||= rhs
    # s(:op_asgn_or, s(:lvar, :a), s(:lasgn, :a, rhs))
    class OpAsgnOrNode < Base
      handle :op_asgn_or

      children :recvr, :rhs

      def compile
        sexp = s(:or, recvr, rhs)
        push expr(sexp)
      end
    end

    # a &&= rhs
    # s(:op_asgn_and, s(:lvar, :a), s(:lasgn, a:, rhs))
    class OpAsgnAndNode < Base
      handle :op_asgn_and

      children :recvr, :rhs

      def compile
        sexp = s(:and, recvr, rhs)
        push expr(sexp)
      end
    end

    # lhs[args] ||= rhs
    # s(:op_asgn1, lhs, args, :||, rhs)
    class OpAsgn1Node < Base
      handle :op_asgn1

      children :lhs, :args, :op, :rhs

      def first_arg
        args[1]
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
            cur = s(:call, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            rhs = s(:call, cur, op.to_sym, s(:arglist, self.rhs))
            call = s(:call, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))

            push "(#{a} = ", expr(first_arg), ", #{r} = ", expr(lhs)
            push ", ", expr(call), ")"
          end
        end
      end

      def compile_or
        with_temp do |a| # args
          with_temp do |r| # recv
            aref = s(:call, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            aset = s(:call, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))
            orop = s(:or, aref, aset)

            push "(#{a} = ", expr(first_arg), ", #{r} = ", expr(lhs)
            push ", ", expr(orop), ")"
          end
        end
      end

      def compile_and
        with_temp do |a| # args
          with_temp do |r| # recv
            aref = s(:call, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
            aset = s(:call, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))
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
          getr = s(:call, s(:js_tmp, tmp), meth, s(:arglist))
          asgn = s(:call, s(:js_tmp, tmp), mid, s(:arglist, rhs))
          orop = s(:or, getr, asgn)

          push "(#{tmp} = ", expr(lhs), ", ", expr(orop), ")"
        end
      end

      def compile_and
        with_temp do |tmp|
          getr = s(:call, s(:js_tmp, tmp), meth, s(:arglist))
          asgn = s(:call, s(:js_tmp, tmp), mid, s(:arglist, rhs))
          andop = s(:and, getr, asgn)

          push "(#{tmp} = ", expr(lhs), ", ", expr(andop), ")"
        end
      end

      def compile_operator
        with_temp do |tmp|
          getr = s(:call, s(:js_tmp, tmp), meth, s(:arglist))
          oper = s(:call, getr, op, s(:arglist, rhs))
          asgn = s(:call, s(:js_tmp, tmp), mid, s(:arglist, oper))

          push "(#{tmp} = ", expr(lhs), ", ", expr(asgn), ")"
        end
      end
    end
  end
end
