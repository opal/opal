require 'opal/nodes/base'

module Opal
  class Parser
    class NextNode < Node
      children :value

      def compile
        return push "continue;" if in_while?

        push expr_or_nil(value)
        wrap "return ", ";"
      end
    end

    class NotNode < Node
      children :value

      def compile
        with_temp do |tmp|
          push expr(value)
          wrap "(#{tmp} = ", ", (#{tmp} === nil || #{tmp} === false))"
        end
      end
    end

    class SplatNode < Node
      children :value

      def empty_splat?
        value == [:nil] or value == [:paren, [:nil]]
      end

      def compile
        if empty_splat?
          push '[]'
        elsif value.type == :sym
          push expr(value)
          wrap '[', ']'
        else
          push recv(value)
        end
      end
    end

    class OrNode < Node
      children :lhs, :rhs

      def compile
        with_temp do |tmp|
          push "(((#{tmp} = "
          push expr(lhs)
          push ") !== false && #{tmp} !== nil) ? #{tmp} : "
          push expr(rhs)
          push ")"
        end
      end
    end
  end
end
