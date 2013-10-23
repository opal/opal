require 'opal/nodes/base'

module Opal
  module Nodes
    class NextNode < Base
      handle :next

      children :value

      def compile
        return push "continue;" if in_while?

        push expr_or_nil(value)
        wrap "return ", ";"
      end
    end

    class BreakNode < Base
      handle :break

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

    class RedoNode < Base
      handle :redo

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

    class NotNode < Base
      handle :not

      children :value

      def compile
        with_temp do |tmp|
          push expr(value)
          wrap "(#{tmp} = ", ", (#{tmp} === nil || #{tmp} === false))"
        end
      end
    end

    class SplatNode < Base
      handle :splat

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

    class OrNode < Base
      handle :or

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

    class AndNode < Base
      handle :and

      children :lhs, :rhs

      def compile
        truthy_opt = nil

        with_temp do |tmp|
          if truthy_opt = js_truthy_optimize(lhs)
            push "((#{tmp} = ", truthy_opt
            push ") ? "
            push expr(rhs)
            push " : #{tmp})"
          else
            push "(#{tmp} = "
            push expr(lhs)
            push ", #{tmp} !== false && #{tmp} !== nil ?"
            push expr(rhs)
            push " : #{tmp})"
          end
        end
      end
    end

    class ReturnNode < Base
      handle :return

      children :value

      def return_val
        expr_or_nil value
      end

      def return_in_iter?
        if scope.iter? and parent_def = scope.find_parent_def
          parent_def
        end
      end

      def return_expr_in_def?
        return scope if expr? and scope.def?
      end

      def scope_to_catch_return
        return_in_iter? or return_expr_in_def?
      end

      def compile
        if def_scope = scope_to_catch_return
          def_scope.catch_return = true
          push '$opal.$return(', return_val, ')'
        elsif stmt?
          push 'return ', return_val
        else
          raise SyntaxError, "void value expression: cannot return as an expression"
        end
      end
    end

    class JSReturnNode < Base
      handle :js_return

      children :value

      def compile
        push "return "
        push expr(value)
      end
    end

    class JSTempNode < Base
      handle :js_tmp

      children :value

      def compile
        push value.to_s
      end
    end

    class BlockPassNode < Base
      handle :block_pass

      children :value

      def compile
        push expr(s(:call, value, :to_proc, s(:arglist)))
      end
    end
  end
end
