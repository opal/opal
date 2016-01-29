require 'opal/nodes/base'

module Opal
  module Nodes
    class RescueModNode < Base
      handle :rescue_mod

      children :lhs, :rhs

      def body
        stmt? ? lhs : compiler.returns(lhs)
      end

      def rescue_val
        stmt? ? rhs : compiler.returns(rhs)
      end

      def compile
        line "try {", expr(body), " } catch ($err) { "

        indent do
          line "if (Opal.rescue($err, [", expr(Sexp.new([:const, :StandardError])), "])) {"
          line expr(rescue_val)
          line "} else { throw $err; } }"
        end

        wrap '(function() {', '})()' unless stmt?
      end
    end

    class EnsureNode < Base
      handle :ensure

      children :begn, :ensr

      def compile
        push "try {"
        line compiler.process(body_sexp, @level)
        line "} finally {"
        line compiler.process(ensr_sexp, @level)
        line "}"

        wrap '(function() {', '; })()' if wrap_in_closure?
      end

      def body_sexp
        if wrap_in_closure?
          sexp = compiler.returns(begn)
          # 'rescue' is an edge case that should be compiled to
          # try { return function(){ ..rescue through try/catch.. }() }
          sexp.type == :rescue ? s(:js_return, sexp) : sexp
        else
          sexp = begn
        end
      end

      def ensr_sexp
        ensr || s(:nil)
      end

      def wrap_in_closure?
        recv? or expr?
      end
    end

    class RescueNode < Base
      handle :rescue

      children :body

      def compile
        handled_else = false

        push "try {"
        indent do
          line process(body_code, @level)
        end
        line "} catch ($err) {"

        indent do
          children[1..-1].each_with_index do |child, idx|
            handled_else = true unless child.type == :resbody

            push " else " unless idx == 0
            line process(child, @level)
          end

          # if no resbodys capture our error, then rethrow
          unless handled_else
            push " else { throw $err; }"
          end
        end

        line "}"

        # Wrap a try{} catch{} into a function
        # when it's an expression
        # or when there's a method call after begin;rescue;end
        wrap '(function() { ', '})()' if expr? or recv?
      end

      def body_code
        body_code = (body.type == :resbody ? s(:nil) : body)
        body_code = compiler.returns body_code unless stmt?
        body_code
      end
    end

    class ResBodyNode < Base
      handle :resbody

      children :args, :body

      def compile
        push "if (Opal.rescue($err, ["
        if rescue_exprs.empty?
          # if no expressions are given, then catch StandardError only
          push expr(Sexp.new([:const, :StandardError]))
        else
          rescue_exprs.each_with_index do |rexpr, idx|
            push ', ' unless idx == 0
            push expr(rexpr)
          end
        end
        push "])) {"
        indent do
          if variable = rescue_variable
            variable[2] = s(:js_tmp, '$err')
            push expr(variable), ';'
          end

          # Need to ensure we clear the current exception out after the rescue block ends
          line "try {"
          indent do
            line process(rescue_body, @level)
          end
          line '} finally { Opal.pop_exception() }'
        end
        line "}"
      end

      def rescue_variable?(variable)
        Sexp === variable and [:lasgn, :iasgn].include?(variable.type)
      end

      def rescue_variable
        rescue_variable?(args.last) ? args.last.dup : nil
      end

      def rescue_exprs
        exprs = args.dup
        exprs.pop if rescue_variable?(exprs.last)
        exprs.children
      end

      def rescue_body
        body_code = (body || s(:nil))
        body_code = compiler.returns(body_code) unless stmt?
        body_code
      end
    end
  end
end
