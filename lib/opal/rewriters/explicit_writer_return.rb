# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ExplicitWriterReturn < Base
      def initialize
        @in_masgn = false
      end

      TMP_NAME = '$writer'
      GET_ARGS_NODE = s(:lvar, TMP_NAME)
      RETURN_ARGS_NODE = s(:jsattr,
                           GET_ARGS_NODE,
                           s(:send, s(:jsattr, GET_ARGS_NODE, s(:str, 'length')), :-, s(:int, 1)))

      def on_send(node)
        return super if @in_masgn

        recv, method_name, *args = *node

        if method_name.to_s =~ /#{REGEXP_START}\w+=#{REGEXP_END}/ || method_name.to_s == '[]='
          set_args_node = s(:lvasgn, TMP_NAME, s(:array, *process_all(args)))

          s(:begin,
            set_args_node,
            node.updated(nil, [recv, method_name, s(:splat, GET_ARGS_NODE)]),
            RETURN_ARGS_NODE)
        else
          super
        end
      end

      # Multiple assignment is handled by Opal::Nodes::MassAssignNode
      #
      # For example, "self.a, self.b = 1, 2" parses to:
      # s(:masgn,
      #   s(:mlhs,
      #     s(:send,
      #       s(:self), :a=),
      #     s(:send,
      #       s(:self), :b=)),
      #   s(:array,
      #     s(:int, 1),
      #     s(:int, 2)))
      #
      # And this AST rewriter skips this node.
      def on_masgn(node)
        @in_masgn = true
        result = super
        @in_masgn = false
        result
      end
    end
  end
end
