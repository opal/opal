require 'opal/nodes/base'

module Opal
  module Nodes
    class BaseRescueEnsure < Base
      def rescue_else_code
        compiler.returns(scope.rescue_else_sexp)
      end
    end

    class EnsureNode < BaseRescueEnsure
      handle :ensure

      children :begn, :ensr

      def compile
        push "try {"

        in_ensure do
          line stmt(body_sexp)
        end

        line "} finally {"

        indent do
          if has_rescue_else?
            # $no_errors indicates thate there were no error raised
            unshift "var $no_errors = true; "

            # when there's a begin;rescue;else;ensure;end statement,
            # ruby returns a result of the 'else' branch
            # but invokes it before 'ensure'.
            # so, here we
            # 1. save the result of calling else to $rescue_else_result
            # 2. call ensure
            # 2. return $rescue_else_result
            line "var $rescue_else_result;"
            line "if ($no_errors) { "
            indent do
              line "$rescue_else_result = (function() {"
              indent do
                line stmt(rescue_else_code)
              end
              line "})();"
            end
            line "}"
            line compiler.process(ensr_sexp, @level)
            line "if ($no_errors) { return $rescue_else_result; }"
          else
            line compiler.process(ensr_sexp, @level)
          end
        end

        line "}"

        wrap '(function() { ', '; })()' if wrap_in_closure?
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
        recv? or expr? or has_rescue_else?
      end
    end

    class RescueNode < BaseRescueEnsure
      handle :rescue

      children :body

      def compile
        scope.rescue_else_sexp = children[1..-1].detect { |sexp| sexp && sexp.type != :resbody }
        has_rescue_handlers = false

        if handle_rescue_else_manually?
          line "var $no_errors = true;"
        end

        push "try {"
        indent do
          line stmt(body_code)
        end
        line "} catch ($err) {"

        indent do
          if has_rescue_else?
            line "$no_errors = false;"
          end

          children[1..-1].each_with_index do |child, idx|
            # counting only rescue, ignoring rescue-else statement
            if child && child.type == :resbody
              has_rescue_handlers = true

              push " else " unless idx == 0
              line process(child, @level)
            end
          end

          # if no resbodys capture our error, then rethrow
          push " else { throw $err; }"
        end

        line "}"

        if handle_rescue_else_manually?
          # here we must add 'finally' explicitly
          push "finally {"
          indent do
            line "if ($no_errors) { "
            indent do
              line stmt(rescue_else_code)
            end
            line "}"
          end
          push "}"
        end

        # Wrap a try{} catch{} into a function
        # when it's an expression
        # or when there's a method call after begin;rescue;end
        wrap '(function() { ', '})()' if expr? or recv?
      end

      def body_code
        body_code = (body.type == :resbody ? s(:nil) : body)
        body_code = compiler.returns(body_code) unless stmt?
        body_code
      end

      # Returns true when there's no 'ensure' statement
      #  wrapping current rescue.
      #
      def handle_rescue_else_manually?
        !scope.in_ensure? && scope.has_rescue_else?
      end
    end

    class ResBodyNode < Base
      handle :resbody

      children :klasses_sexp, :lvar, :body

      def compile
        push "if (Opal.rescue($err, ", expr(klasses), ")) {"
        indent do
          if lvar
            push expr(lvar), '$err;'
          end

          # Need to ensure we clear the current exception out after the rescue block ends
          line "try {"
          indent do
            line stmt(rescue_body)
          end
          line '} finally { Opal.pop_exception() }'
        end
        line "}"
      end

      def klasses
        klasses_sexp || s(:array, s(:const, nil, :StandardError))
      end

      def rescue_body
        body_code = (body || s(:nil))
        body_code = compiler.returns(body_code) unless stmt?
        body_code
      end
    end

    class RetryNode < Base
      handle :retry

      def compile
        push stmt(s(:send, nil, :retry))
      end
    end
  end
end
