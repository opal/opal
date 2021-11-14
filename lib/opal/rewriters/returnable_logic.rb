# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ReturnableLogic < Base
      def next_tmp
        @counter ||= 0
        @counter += 1
        "$ret_or_#{@counter}"
      end

      def free_tmp
        @counter -= 1
      end

      def reset_tmp_counter!
        @counter = nil
      end

      def on_or(node)
        lhs, rhs = *node.children
        lhs_tmp = next_tmp

        out = node.updated(:if, [s(:lvasgn, lhs_tmp, process(lhs)), s(:js_tmp, lhs_tmp), process(rhs)])
        free_tmp
        out
      end

      def on_and(node)
        lhs, rhs = *node.children
        lhs_tmp = next_tmp

        out = node.updated(:if, [s(:lvasgn, lhs_tmp, process(lhs)), process(rhs), s(:js_tmp, lhs_tmp)])
        free_tmp
        out
      end
    end
  end
end
