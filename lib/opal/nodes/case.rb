require 'opal/nodes/base'

module Opal
  module Nodes
    class CaseNode < Base
      handle :case

      children :condition

      def compile
        handled_else = false

        compiler.in_case do
          if condition
            case_stmt[:cond] = true
            add_local '$case'

            push "$case = ", expr(condition), ";"
          end

          case_parts.each_with_index do |wen, idx|
            if wen and wen.type == :when
              compiler.returns(wen) if needs_closure?
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

          wrap '(function() {', '})()' if needs_closure?
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
            push "} return false; })(", expr(check[1]), ")"
          else
            if case_stmt[:cond]
              call = s(:call, check, :===, s(:arglist, s(:js_tmp, '$case')))
              push expr(call)
            else
              push js_truthy(check)
            end
          end
        end

        push ") {", process(body_code, @level), "}"
      end

      def when_checks
        whens.children
      end

      def case_stmt
        compiler.case_stmt
      end

      def body_code
        body || s(:nil)
      end
    end
  end
end
