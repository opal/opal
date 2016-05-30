require 'opal/nodes/base'

module Opal
  module Nodes
    class CaseNode < Base
      handle :case

      children :condition

      def compile
        compiler.in_case do
          if needs_closure?
            wrap_with_function { compile_code }
          else
            compile_code
          end
        end
      end

      def compile_code
        handled_else = false

        if condition
          case_stmt[:cond] = true
          add_local '$case'

          push "$case = ", expr(condition), ";"
          empty_line
        end

        case_parts.each_with_index do |wen, idx|
          if wen and wen.type == :when
            wen = compiler.returns(wen) if needs_closure?
            push "else " unless idx == 0
            push stmt(wen)
          elsif wen # s(:else)
            handled_else = true
            wen = compiler.returns(wen) if needs_closure?
            push "else {", stmt(wen), "}"
          end
        end

        # if we are having a closure, we must return a usable value
        if needs_closure? and !handled_else
          push "else { return nil }"
        end
      end

      def needs_closure?
        !stmt?
      end

      def case_parts
        children[1..-1]
      end

      def case_stmt
        compiler.case_stmt
      end
    end

    class WhenNode < Base
      handle :when

      children :whens, :body

      def compile
        push "if ("

        when_checks.each_with_index do |check, idx|
          push ' || ' unless idx == 0

          if check.type == :splat
            push "(function($splt) { for (var i = 0; i < $splt.length; i++) {"
            push "if ($splt[i]['$===']($case)) { return true; }"
            push "} return false; })(", expr(check.children[0]), ")"
          else
            if case_stmt[:cond]
              call = s(:send, check, :===, s(:arglist, s(:js_tmp, '$case')))
              push expr(call)
            else
              push js_truthy(check)
            end
          end
        end

        push ") {", process(body_code, @level), "}"
      end

      def when_checks
        children[0..-2]
      end

      def case_stmt
        compiler.case_stmt
      end

      def body_code
        children.last || s(:nil)
      end
    end
  end
end
