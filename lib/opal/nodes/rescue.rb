# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class EnsureNode < Base
      handle :ensure

      children :begn, :ensr

      def compile
        push_closure if wrap_in_closure?

        push 'try {'

        in_ensure do
          line stmt(body_sexp)
        end

        line '} finally {'

        indent do
          if has_rescue_else?
            # $no_errors indicates thate there were no error raised
            unshift 'var $no_errors = true; '

            # when there's a begin;rescue;else;ensure;end statement,
            # ruby returns a result of the 'else' branch
            # but invokes it before 'ensure'.
            # so, here we
            # 1. save the result of calling else to $rescue_else_result
            # 2. call ensure
            # 2. return $rescue_else_result
            line 'var $rescue_else_result;'
            line 'if ($no_errors) { '
            indent do
              line '$rescue_else_result = (function() {'
              indent do
                line stmt(rescue_else_code)
              end
              line '})();'
            end
            line '}'
            line compiler.process(ensr_sexp, @level)
            line 'if ($no_errors) { return $rescue_else_result; }'
          else
            line compiler.process(ensr_sexp, @level)
          end
        end

        line '}'

        pop_closure if wrap_in_closure?

        if wrap_in_closure?
          if scope.await_encountered
            wrap '(await (async function() { ', '; })())'
          else
            wrap '(function() { ', '; })()'
          end
        end
      end

      def body_sexp
        if wrap_in_closure?
          compiler.returns(begn)
        else
          begn
        end
      end

      def ensr_sexp
        ensr || s(:nil)
      end

      def wrap_in_closure?
        recv? || expr? || has_rescue_else?
      end

      def rescue_else_code
        rescue_else_code = scope.rescue_else_sexp
        rescue_else_code = compiler.returns(rescue_else_code) unless stmt?
        rescue_else_code
      end

      def has_rescue_else?
        @sexp.meta[:has_rescue_else]
      end
    end

    class RescueNode < Base
      handle :rescue

      children :body

      def compile
        scope.rescue_else_sexp = children[1..-1].detect { |sexp| sexp && sexp.type != :resbody }
        _has_rescue_handlers = false

        if handle_rescue_else_manually?
          line 'var $no_errors = true;'
        end

        closure_type = Closure::NONE
        closure_type |= Closure::JS_FUNCTION if expr? || recv?
        if has_retry?
          closure_type |= Closure::JS_LOOP        \
                       |  Closure::JS_LOOP_INSIDE \
                       |  Closure::RESCUE_RETRIER
        end
        push_closure(closure_type) if closure_type != Closure::NONE

        in_rescue(self) do
          push 'try {'
          indent do
            line stmt(body_code)
          end
          line '} catch ($err) {'

          indent do
            if has_rescue_else?
              line '$no_errors = false;'
            end

            children[1..-1].each_with_index do |child, idx|
              # counting only rescue, ignoring rescue-else statement
              next unless child && child.type == :resbody
              _has_rescue_handlers = true

              push ' else ' unless idx == 0
              line process(child, @level)
            end

            # if no resbodys capture our error, then rethrow
            push ' else { throw $err; }'
          end

          line '}'

          if handle_rescue_else_manually?
            # here we must add 'finally' explicitly
            push 'finally {'
            indent do
              line 'if ($no_errors) { '
              indent do
                line stmt(rescue_else_code)
              end
              line '}'
            end
            push '}'
          end
        end

        pop_closure if closure_type != Closure::NONE

        wrap 'do { ', ' break; } while(1)' if has_retry?

        # Wrap a try{} catch{} into a function
        # when it's an expression
        # or when there's a method call after begin;rescue;end
        if expr? || recv?
          if scope.await_encountered
            wrap '(await (async function() { ', '})())'
          else
            wrap '(function() { ', '})()'
          end
        end
      end

      def body_code
        body_code = (body.nil? || body.type == :resbody ? s(:nil) : body)
        body_code = compiler.returns(body_code) unless stmt?
        body_code
      end

      def rescue_else_code
        rescue_else_code = scope.rescue_else_sexp
        rescue_else_code = compiler.returns(rescue_else_code) unless stmt?
        rescue_else_code
      end

      # Returns true when there's no 'ensure' statement
      #  wrapping current rescue.
      #
      def handle_rescue_else_manually?
        !in_ensure? && has_rescue_else?
      end

      def has_retry?
        @sexp.meta[:has_retry]
      end
    end

    class ResBodyNode < Base
      handle :resbody

      children :klasses_sexp, :lvar, :body

      def compile
        helper :rescue
        helper :pop_exception

        push 'if ($rescue($err, ', expr(klasses), ')) {'
        indent do
          if lvar
            push expr(lvar.updated(nil, [*lvar.children, s(:js_tmp, '$err')]))
          end

          # Need to ensure we clear the current exception out after the rescue block ends
          line 'try {'
          indent do
            in_resbody do
              line stmt(rescue_body)
            end
          end
          line '} finally { $pop_exception($err); }'
        end
        line '}'
      end

      def klasses
        klasses_sexp || s(:array, s(:const, nil, :StandardError))
      end

      def rescue_body
        body_code = body || s(:nil)
        body_code = compiler.returns(body_code) unless stmt?
        body_code
      end
    end
  end
end
