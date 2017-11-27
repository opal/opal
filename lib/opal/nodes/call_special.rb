# frozen_string_literal: true
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
        ".#{meth}"
      end

      def compile_using_send
        push recv(receiver_sexp), method_jsid, ".apply(null"
        compile_arguments
        if iter
          push ".concat(", expr(iter), ")"
        end
        push ")"
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
  end
end
