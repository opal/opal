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

        in_ensure do
          line compiler.process(body_sexp, @level)
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
                line compiler.process(compiler.returns(scope.rescue_else_sexp), @level)
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
        recv? or expr? or has_rescue_else?
      end
    end

    class RescueNode < Base
      handle :rescue

      children :body

      def compile
        processed_body = process(body_code, @level)
        if inline_body_function?
          # Current rescue node is the only node in the def,
          # and it's a simple begin/rescue(s)/end statement,
          # here we can optimize it by extracting the code
          # between begin and rescue to the separate inline function
          scope.inline_rescue_body = [
            "#{scope_name}.$$rescue_body = #{scope_name}.$$rescue_body || function(#{inline_body_arguments}) {",
            processed_body,
            "}"
          ]
        end

        scope.rescue_else_sexp = children[1..-1].detect { |sexp| sexp.type != :resbody }
        has_rescue_handlers = false

        if handle_rescue_else_manually?
          line "var $no_errors = true;"
        end

        line "try {"
        indent do
          if inline_body_function?
            line "return #{scope_name}.$$rescue_body(#{inline_body_arguments});"
          else
            line processed_body
          end
        end
        line "} catch ($err) {"

        indent do
          if has_rescue_else?
            line "$no_errors = false;"
          end

          children[1..-1].each_with_index do |child, idx|
            # counting only rescue, ignoring rescue-else statement
            if child.type == :resbody
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
              line "return (function() {"
              indent do
                line compiler.process(compiler.returns(scope.rescue_else_sexp), @level)
              end
              line "})();"
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
        body_code = compiler.returns body_code unless stmt?
        body_code
      end

      # Returns true when there's no 'ensure' statement
      #  wrapping current rescue.
      #
      def handle_rescue_else_manually?
        !scope.in_ensure? && scope.has_rescue_else?
      end

      def scope_name
        scope.identity
      end

      def inline_body_function?
        scope.def? && scope.stmts.children == [@sexp]
      end

      def inline_body_arguments
        result = ['self']
        result.concat(scope.arg_names)
        result << scope.block_name if scope.uses_block?
        result.uniq.join(',')
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
