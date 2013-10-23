require 'opal/nodes/base'

module Opal
  class Parser
    class EnsureNode < Node
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

    class RescueNode < Node
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
        body.type == :resbody ? s(:nil) : body
      end
    end

    class ResBodyNode < Node
      handle :resbody

      children :args, :body

      def compile
        push "if ("

        rescue_classes.each_with_index do |cls, idx|
          push ', ' unless idx == 0
          call = s(:call, cls, :===, s(:arglist, s(:js_tmp, '$err')))
          push expr(call)
        end

        # if no classes are given, then catch all errors
        push "true" if rescue_classes.empty?

        push ") {"

        if variable = rescue_variable
          variable[2] = s(:js_tmp, '$err')
          push expr(variable), ';'
        end

        line process(rescue_body, @level)
        line "}"
      end

      def rescue_variable
        variable = args.last

        if Sexp === variable and [:lasgn, :iasgn].include?(variable.type)
          variable.dup
        end
      end

      def rescue_classes
        classes = args.children
        classes.pop if classes.last and classes.last.type != :const
        classes
      end

      def rescue_body
        body || s(:nil)
      end
    end
  end
end
