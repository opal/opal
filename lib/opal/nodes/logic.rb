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

    class BreakNode < Node
      children :value

      def compile
        if in_while?
          compile_while
        elsif scope.iter?
          compile_iter
        else
          error "void value expression: cannot use break outside of iter/while"
        end
      end

      def compile_while
        if while_loop[:closure]
          push "return ", expr_or_nil(value)
        else
          push "break;"
        end
      end

      def compile_iter
        error "break must be used as a statement" unless stmt?
        push expr_or_nil(value)
        wrap "return ($breaker.$v = ", ", $breaker)"
      end
    end

    class RedoNode < Node
      def compile
        if in_while?
          compile_while
        elsif scope.iter?
          compile_iter
        else
          push "REDO()"
        end
      end

      def compile_while
        while_loop[:use_redo] = true
        push "#{while_loop[:redo_var]} = true"
      end

      def compile_iter
        push "return #{scope.identity}.apply(null, $slice.call(arguments))"
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
          push '[', expr(value), ']'
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
