require 'opal/nodes/base'

module Opal
  module Nodes
    class NextNode < Base
      handle :next

      children :value

      def compile
        if in_while?
          push "continue;"
        else
          push expr_or_nil(value)
          wrap "return ", ";"
        end
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
        compiler.has_break!
        line 'Opal.brk(', break_val, ', $brk)'
      end

      def break_val
        if value.nil?
          expr(s(:nil))
        else
          expr(value)
        end
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

    class SplatNode < Base
      handle :splat

      children :value

      # FIXME: must be something like value == s(:array)
      def empty_splat?
        value == [:nil] or value == [:paren, [:nil]]
      end

      def compile
        if empty_splat?
          push '[]'
        else
          push "Opal.to_a(", recv(value), ")"
        end
      end
    end

    class BinaryOp < Base
      def compile
        if rhs.type == :break
          compile_if
        else
          compile_ternary
        end
      end

      def compile_ternary
        raise NotImplementedError
      end

      def compile_if
        raise NotImplementedError
      end
    end

    class OrNode < BinaryOp
      handle :or

      children :lhs, :rhs

      def compile_ternary
        with_temp do |tmp|
          push "(((#{tmp} = "
          push expr(lhs)
          push ") !== false && #{tmp} !== nil && #{tmp} != null) ? #{tmp} : "
          push expr(rhs)
          push ")"
        end
      end

      def compile_if
        with_temp do |tmp|
          push "if (#{tmp} = ", expr(lhs), ", #{tmp} !== false && #{tmp} !== nil && #{tmp} != null) {"
          indent do
            line tmp
          end
          line "} else {"
            indent do
              line expr(rhs)
            end
          line "}"
        end
      end
    end

    class AndNode < BinaryOp
      handle :and

      children :lhs, :rhs

      def compile_ternary
        truthy_opt = nil

        with_temp do |tmp|
          if truthy_opt = js_truthy_optimize(lhs)
            push "((#{tmp} = ", truthy_opt
            push ") ? "
            push expr(rhs)
            push " : ", expr(lhs), ")"
          else
            push "(#{tmp} = "
            push expr(lhs)
            push ", #{tmp} !== false && #{tmp} !== nil && #{tmp} != null ?"
            push expr(rhs)
            push " : #{tmp})"
          end
        end
      end

      def compile_if
        with_temp do |tmp|
          if truthy_opt = js_truthy_optimize(lhs)
            push "if (#{tmp} = ", truthy_opt, ") {"
          else
            push "if (#{tmp} = ", expr(lhs), ", #{tmp} !== false && #{tmp} !== nil && #{tmp} != null) {"
          end
          indent do
            line expr(rhs)
          end
          line "} else {"
          indent do
            line expr(lhs)
          end
          line "}"
        end
      end
    end

    class ReturnNode < Base
      handle :return

      children :value

      def return_val
        if value.nil?
          expr(s(:nil))
        elsif children.size > 1
          expr(s(:array, *children))
        else
          expr(value)
        end
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
          push 'Opal.ret(', return_val, ')'
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
        push expr(s(:send, value, :to_proc, s(:arglist)))
      end
    end
  end
end
