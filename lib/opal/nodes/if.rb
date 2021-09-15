# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class IfNode < Base
      handle :if

      children :test, :true_body, :false_body

      def compile
        truthy = self.truthy
        falsy = self.falsy

        push 'if (', js_truthy(test), ') {'

        # skip if-body if no truthy sexp
        indent { line stmt(truthy) } if truthy

        if falsy
          if falsy.type == :if
            line '} else ', stmt(falsy)
          else
            line '} else {'
            indent do
              line stmt(falsy)
            end

            line '}'
          end
        else
          push '}'
        end

        if needs_wrapper?
          if scope.await_encountered
            wrap '(await (async function() {', '; return nil; })())'
          else
            wrap '(function() {', '; return nil; })()'
          end
        end
      end

      def truthy
        needs_wrapper? ? compiler.returns(true_body || s(:nil)) : true_body
      end

      def falsy
        needs_wrapper? ? compiler.returns(false_body || s(:nil)) : false_body
      end

      def needs_wrapper?
        expr? || recv?
      end
    end

    class IFlipFlop < Base
      handle :iflipflop

      children :from, :to

      # Is this an exclusive flip flop? If no, run both branches
      def excl
        ""
      end

      # We create a function that we put in the top scope, that stores the state of our
      # flip-flop. We pass to it functions that are ran with the current binding.
      def compile
        helper :truthy

        fun_name = top_scope.new_temp
        ff = "#{fun_name}.$$ff"

        push "(typeof #{fun_name} === 'undefined' ? (#{fun_name} = function(from, to){"
        push "  if (typeof #{ff} === 'undefined') #{ff} = false;"
        push "  var retval = #{ff};"
        push "  if (!#{ff}) {"
        push "    #{ff} = retval = $truthy(from());"
        push "  }"
        push "  #{excl}if (#{ff}) {"
        push "    if ($truthy(to())) #{ff} = false;"
        push "  }"
        push "  return retval;"
        push "}) : #{fun_name})("
        push "  function() { ", stmt(compiler.returns(from)), " },"
        push "  function() { ", stmt(compiler.returns(to)), " }"
        push ")"
      end
    end

    class EFlipFlop < IFlipFlop
      handle :eflipflop

      # Is this an exclusive flip flop? If yes, run only a single branch
      def excl
        "else "
      end
    end
  end
end
