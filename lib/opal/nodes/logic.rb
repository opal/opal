require 'opal/nodes/base'

module Opal
  class Parser
    class NextNode < Node
      def compile
        return push "continue;" if in_while?

        push expr_or_nil(@sexp[1])
        wrap "return ", ";"
      end
    end

    class NotNode < Node
      def compile
        with_temp do |tmp|
          push expr(@sexp[1])
          wrap "(#{tmp} = ", ", (#{tmp} === nil || #{tmp} === false))"
        end
      end
    end

    class SplatNode < Node
      def empty_splat?
        @sexp[1] == [:nil] or @sexp[1] == [:paren, [:nil]]
      end

      def compile
        if empty_splat?
          push '[]'
        elsif @sexp[1].type == :sym
          push expr(@sexp[1])
          wrap '[', ']'
        else
          push recv(@sexp[1])
        end
      end
    end

    class OrNode < Node
      def lhs
        expr @sexp[1]
      end

      def rhs
        expr @sexp[2]
      end

      def compile
        with_temp do |tmp|
          push "(((#{tmp} = "
          push lhs
          push ") !== false && #{tmp} !== nil) ? #{tmp} : "
          push rhs
          push ")"
        end
      end
    end
  end
end
