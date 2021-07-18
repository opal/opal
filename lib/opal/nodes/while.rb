# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class WhileNode < Base
      handle :while

      children :test, :body

      def compile
        test_code = js_truthy(test)

        with_temp do |redo_var|
          compiler.in_while do
            while_loop[:closure] = true if wrap_in_closure?
            while_loop[:redo_var] = redo_var

            body_code = indent { stmt(body) }
            if uses_redo?
              compile_with_redo(test_code, body_code, redo_var)
            else
              compile_without_redo(test_code, body_code)
            end
          end
        end

        wrap '(function() {', '; return nil; })()' if wrap_in_closure?
      end

      private

      def compile_with_redo(test_code, body_code, redo_var)
        push "#{redo_var} = false; "
        compile_while(
          [redo_var, " || ", test_code],
          ["#{redo_var} = false;", body_code]
        )
      end

      def compile_without_redo(test_code, body_code)
        compile_while([test_code], [body_code])
      end

      def compile_while(test_code, body_code)
        push while_open, *test_code, while_close
        indent { line(*body_code) }
        line '}'
      end

      def while_open
        'while ('
      end

      def while_close
        ') {'
      end

      def uses_redo?
        while_loop[:use_redo]
      end

      def wrap_in_closure?
        expr? || recv?
      end
    end

    class UntilNode < WhileNode
      handle :until

      private

      def while_open
        'while (!('
      end

      def while_close
        ')) {'
      end
    end

    class WhilePostNode < WhileNode
      handle :while_post

      private

      def compile_while(test_code, body_code)
        push "do {"
        indent { line(*body_code) }
        line "} ", while_open, *test_code, while_close
      end

      def while_close
        ');'
      end
    end

    class UntilPostNode < WhilePostNode
      handle :until_post

      private

      def while_open
        'while(!('
      end

      def while_close
        '));'
      end
    end
  end
end
