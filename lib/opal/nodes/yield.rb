# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class BaseYieldNode < Base
      def compile_call
        yielding_scope = find_yielding_scope

        yielding_scope.uses_block!
        block_name = yielding_scope.block_name || '$yield'

        if yields_single_arg?(children)
          push expr(children.first)
          wrap "Opal.yield1(#{block_name}, ", ')'
        else
          push expr(s(:arglist, *children))

          if uses_splat?(children)
            wrap "Opal.yieldX(#{block_name}, ", ')'
          else
            wrap "Opal.yieldX(#{block_name}, [", '])'
          end
        end
      end

      def find_yielding_scope
        working = scope
        while working
          if working.block_name || working.def?
            break
          end
          working = working.parent
        end

        working
      end

      def yields_single_arg?(children)
        !uses_splat?(children) && children.size == 1
      end

      def uses_splat?(children)
        children.any? { |child| child.type == :splat }
      end
    end

    class YieldNode < BaseYieldNode
      handle :yield

      def compile
        compile_call
      end
    end

    # Created by `#returns()` for when a yield statement should return
    # it's value (its last in a block etc).
    class ReturnableYieldNode < BaseYieldNode
      handle :returnable_yield

      def compile
        compile_call

        wrap 'return ', ';'
      end
    end
  end
end
