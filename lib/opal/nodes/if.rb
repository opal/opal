# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    class IfNode < Base
      handle :if

      children :test, :true_body, :false_body

      def compile
        truthy, falsy = self.truthy, self.falsy

        push "if (", js_truthy(test), ") {"

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

    class IFlipFlop < Base
      handle :iflipflop

      def compile
        # Unsupported
        # Always compiles to 'true' to not break generated JS
        push 'true'
      end
    end

    class EFlipFlop < Base
      handle :eflipflop

      def compile
        # Unsupported
        # Always compiles to 'true' to not break generated JS
        push 'true'
      end
    end
  end
end
