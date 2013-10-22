require 'opal/nodes/base'

module Opal
  class Parser
    class CaseNode < Node
      children :condition

      def compile
        handled_else = false

        @parser.in_case do
          if condition
            case_stmt[:cond] = true
            add_local '$case'

            push "$case = ", expr(condition), ";"
          end

          case_parts.each_with_index do |wen, idx|
            if wen and wen.type == :when
              @parser.returns(wen) if needs_closure?
              push "else " unless idx == 0
              push stmt(wen)
            elsif wen # s(:else)
              handled_else = true
              wen = @parser.returns(wen) if needs_closure?
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
        @parser.instance_variable_get(:@case_stmt)
      end
    end

    class WhenNode < Node
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
              push @parser.js_truthy(check)
            end
          end
        end

        push ") {", @parser.process(body_code, @level), "}"
      end

      def when_checks
        whens.children
      end

      def case_stmt
        @parser.instance_variable_get(:@case_stmt)
      end

      def body_code
        body || s(:nil)
      end
    end
  end
end
