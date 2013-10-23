require 'opal/nodes/base'

module Opal
  module Nodes
    class BaseYieldNode < Base
      def compile_call(children, level)
        scope.uses_block!

        if yields_single_arg?(children)
          push expr(children.first)
          wrap "$opal.$yield1(#{block_name}, ", ')'
        else
          push expr(s(:arglist, *children))

          if uses_splat?(children)
            wrap "$opal.$yieldX(#{block_name}, ", ')'
          else
            wrap "$opal.$yieldX(#{block_name}, [", '])'
          end
        end
      end

      def block_name
        scope.block_name || '$yield'
      end

      def yields_single_arg?(children)
        !uses_splat?(children) and children.size == 1
      end

      def uses_splat?(children)
        children.any? { |child| child.type == :splat }
      end
    end

    class YieldNode < BaseYieldNode
      handle :yield

      def compile
        compile_call(children, @level)

        if stmt?
          wrap 'if (', ' === $breaker) return $breaker.$v'
        else
          with_temp do |tmp|
            wrap "(((#{tmp} = ", ") === $breaker) ? $breaker.$v : #{tmp})"
          end
        end
      end

    end

    # special opal yield assign, for `a = yield(arg1, arg2)` to assign
    # to a temp value to make yield expr into stmt.
    #
    # level will always be stmt as its the reason for this to exist
    #
    # s(:yasgn, :a, s(:yield, arg1, arg2))
    class YasgnNode < BaseYieldNode
      handle :yasgn

      children :var_name, :yield_args

      def compile
        compile_call(s(*yield_args[1..-1]), :stmt)
        wrap "if ((#{var_name} = ", ") === $breaker) return $breaker.$v"
      end
    end

    # Created by `#returns()` for when a yield statement should return
    # it's value (its last in a block etc).
    class ReturnableYieldNode < BaseYieldNode
      handle :returnable_yield

      def compile
        compile_call children, @level

        with_temp do |tmp|
          wrap "return #{tmp} = ", ", #{tmp} === $breaker ? #{tmp} : #{tmp}"
        end
      end
    end
  end
end
