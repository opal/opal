require 'opal/nodes/base'

module Opal
  class Parser
    class IfNode < Node
      handle :if

      children :test, :true_body, :false_body

      def compile
        truthy, falsy = self.truthy, self.falsy

        push "if ("

        # optimize unless (we don't want a else() unless we need to)
        if falsy and !truthy
          truthy = falsy
          falsy = nil
          push js_falsy(test)
        else
          push js_truthy(test)
        end

        push ") {"

        # skip if-body if no truthy sexp
        indent { line stmt(truthy) } if truthy

        if falsy
          if falsy.type == :if
            line "} else ", stmt(falsy)
          else
            indent do
              line "} else {"
              line stmt(falsy)
            end

            line "}"
          end
        else
          push "}"
        end

        wrap "(function() {", "; return nil; })()" if needs_wrapper?
      end

      def truthy
        needs_wrapper? ? compiler.returns(true_body || s(:nil)) : true_body
      end

      def falsy
        needs_wrapper? ? compiler.returns(false_body || s(:nil)) : false_body
      end

      def needs_wrapper?
        expr? or recv?
      end
    end
  end
end
