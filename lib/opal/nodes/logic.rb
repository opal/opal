# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class NextNode < Base
      handle :next

      def compile
        thrower(:next, value)
      end

      def value
        case children.size
        when 0
          s(:nil)
        when 1
          children.first
        else
          s(:array, *children)
        end
      end
    end

    class BreakNode < Base
      handle :break

      children :value

      def compile
        thrower(:break, value)
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
          push 'REDO()'
        end
      end

      def compile_while
        push "#{while_loop[:redo_var]} = true;"
        thrower(:redo)
      end

      def compile_iter
        helper :slice
        push "return #{scope.identity}.apply(null, $slice.call(arguments))"
      end
    end

    class SplatNode < Base
      handle :splat

      children :value

      def empty_splat?
        value == s(:array)
      end

      def compile
        if empty_splat?
          push '[]'
        else
          helper :to_a
          push '$to_a(', recv(value), ')'
        end
      end
    end

    class RetryNode < Base
      handle :retry

      def compile
        thrower(:retry)
      end
    end

    class ReturnNode < Base
      handle :return

      children :value

      def return_val
        if value.nil?
          s(:nil)
        elsif children.size > 1
          s(:array, *children)
        else
          value
        end
      end

      def compile
        thrower(:return, return_val)
      end
    end

    class JSReturnNode < Base
      handle :js_return

      children :value

      def compile
        push 'return '
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
