# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class WhileNode < Base
      handle :while

      children :test, :body

      def compile
        test_code = js_truthy(test)

        @redo_var = scope.new_temp if uses_redo?

        compiler.in_while do
          while_loop[:closure] = true if wrap_in_closure?
          while_loop[:redo_var] = @redo_var

          has_retry = node_has?(body, :retry)

          in_closure(Closure::LOOP |
                     Closure::JS_LOOP |
                     (wrap_in_closure? ? Closure::JS_FUNCTION : 0) |
                     (has_retry ? Closure::RETRY_CONTAINER : 0)) do
            in_closure(Closure::LOOP_INSIDE | Closure::JS_LOOP_INSIDE | (has_retry ? Closure::RETRY_CONTAINER : 0)) do
              line(indent { stmt(body) })
            end

            if uses_redo?
              compile_with_redo(test_code)
            else
              compile_without_redo(test_code)
            end
          end
        end

        scope.queue_temp(@redo_var) if uses_redo?

        if wrap_in_closure?
          if scope.await_encountered
            wrap '(await (async function() {', '; return nil; })())'
          else
            wrap '(function() {', '; return nil; })()'
          end
        end
      end

      private

      def compile_with_redo(test_code)
        compile_while(test_code, "#{@redo_var} = false;")
      end

      def compile_without_redo(test_code)
        compile_while(test_code)
      end

      def compile_while(test_code, redo_code = nil)
        unshift redo_code if redo_code
        unshift while_open, test_code, while_close
        unshift redo_code if redo_code
        line '}'
      end

      def while_open
        if uses_redo?
          redo_part = "#{@redo_var} || "
        end

        "while (#{redo_part}"
      end

      def while_close
        ') {'
      end

      def uses_redo?
        @sexp.meta[:has_redo]
      end

      def wrap_in_closure?
        expr? || recv?
      end
    end

    class UntilNode < WhileNode
      handle :until

      private

      def while_open
        if uses_redo?
          redo_part = "#{@redo_var} || "
        end

        "while (#{redo_part}!("
      end

      def while_close
        ')) {'
      end
    end

    class WhilePostNode < WhileNode
      handle :while_post

      private

      def compile_while(test_code, redo_code = nil)
        unshift redo_code if redo_code
        unshift "do {"
        line "} ", while_open, test_code, while_close
      end

      def while_close
        ');'
      end
    end

    class UntilPostNode < WhilePostNode
      handle :until_post

      private

      def while_open
        if uses_redo?
          redo_part = "#{@redo_var} || "
        end

        "while (#{redo_part}!("
      end

      def while_close
        '));'
      end
    end
  end
end
