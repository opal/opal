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
        push "try {", expr(body), " } catch ($err) { "
        push "if (Opal.rescue($err, ["
        push expr(Sexp.new([:const, :StandardError]))
        push "])) {", expr(rescue_val), "}"
        push "else { throw $err; } }"

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
        wrap_in_closure? ? compiler.returns(begn) : begn
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
        line(indent { process(body_code, @level) })
        line "} catch ($err) {"

        children[1..-1].each_with_index do |child, idx|
          handled_else = true unless child.type == :resbody

          push "else " unless idx == 0
          push(indent { process(child, @level) })
        end

        # if no resbodys capture our error, then rethrow
        unless handled_else
          push "else { throw $err; }"
        end

        line "}"

        wrap '(function() { ', '})()' if expr?
      end

      def body_code
        body_code = (body.type == :resbody ? s(:nil) : body)

        if !stmt?
          compiler.returns body_code
        else
          body_code
        end
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

        if variable = rescue_variable
          variable[2] = s(:js_tmp, '$err')
          push expr(variable), ';'
        end

        line process(rescue_body, @level)
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
        body_code = compiler.returns(body_code) if !stmt?
        body_code
      end
    end
  end
end
