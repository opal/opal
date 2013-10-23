require 'opal/nodes/base'

module Opal
  module Nodes
    class WhileNode < Base
      handle :while

      children :test, :body

      def compile
        with_temp do |redo_var|
          test_code = js_truthy(test)

          compiler.in_while do
            while_loop[:closure] = true if wrap_in_closure?
            while_loop[:redo_var] = redo_var

            body_code = stmt(body)

            if uses_redo?
              push "#{redo_var} = false; #{while_open}#{redo_var} || "
              push test_code
              push while_close
            else
              push while_open, test_code, while_close
            end

            push "#{redo_var} = false;" if uses_redo?
            line body_code, "}"
          end
        end

        wrap '(function() {', '; return nil; })()' if wrap_in_closure?
      end

      def while_open
        "while ("
      end

      def while_close
        ") {"
      end

      def uses_redo?
        while_loop[:use_redo]
      end

      def wrap_in_closure?
        expr? or recv?
      end
    end

    class UntilNode < WhileNode
      handle :until

      def while_open
        "while (!("
      end

      def while_close
        ")) {"
      end
    end
  end
end
