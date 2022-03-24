# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/ast/matcher'

module Opal
  module Nodes
    class IfNode < Base
      handle :if

      children :test, :true_body, :false_body

      def compile
        if should_compile_as_simple_expression?
          if true_body == s(:true)
            compile_with_binary_or
          elsif false_body == s(:false)
            compile_with_binary_and
          else
            compile_with_ternary
          end
        elsif could_become_switch?
          compile_with_switch
        else
          compile_with_if
        end
      end

      def compile_with_if
        truthy = self.truthy
        falsy = self.falsy

        if falsy && !truthy
          # Let's optimize a little bit `unless` calls.
          push 'if (!', js_truthy(test), ') {'
          falsy, truthy = truthy, falsy
        else
          push 'if (', js_truthy(test), ') {'
        end

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
          line '}'

          # This resolution isn't finite. Let's ensure this block
          # always return something if we expect a return
          line 'return nil;' if expects_expression?
        end

        if expects_expression?
          if scope.await_encountered
            wrap '(await (async function() {', '})())'
          else
            wrap '(function() {', '})()'
          end
        end
      end

      def truthy
        returnify(true_body)
      end

      def falsy
        returnify(false_body)
      end

      def returnify(body)
        if expects_expression? && body
          compiler.returns(body)
        else
          body
        end
      end

      def expects_expression?
        expr? || recv?
      end

      # There was a particular case in the past, that when we
      # expected an expression from if, we always had to closure
      # it. This produced an ugly code that was hard to minify.
      # This addition tries to make a few cases compiled with
      # a ternary operator instead and possibly a binary operator
      # even?
      def should_compile_as_simple_expression?
        expects_expression? && simple?(true_body) && simple?(false_body)
      end

      def compile_with_ternary
        truthy = true_body
        falsy = false_body

        push '('

        push js_truthy(test), ' ? '

        push '(', expr(truthy || s(:nil)), ') : '
        if !falsy || falsy.type == :if
          push expr(falsy || s(:nil))
        else
          push '(', expr(falsy || s(:nil)), ')'
        end

        push ')'
      end

      def compile_with_binary_and
        if sexp.meta[:do_js_truthy_on_true_body]
          truthy = js_truthy(true_body || s(:nil))
        else
          truthy = expr(true_body || s(:nil))
        end

        push '('
        push js_truthy(test), ' && '
        push '(', truthy, ')'
        push ')'
      end

      def compile_with_binary_or
        if sexp.meta[:do_js_truthy_on_false_body]
          falsy = js_truthy(false_body || s(:nil))
        else
          falsy = expr(false_body || s(:nil))
        end

        push '('
        push js_truthy(test), ' || '
        push '(', falsy, ')'
        push ')'
      end

      # Let's ensure there are no control flow statements inside.
      def simple?(body)
        case body
        when AST::Node
          case body.type
          when :return, :js_return, :break, :next, :redo, :retry
            false
          when :xstr
            XStringNode.single_line?(
              XStringNode.strip_empty_children(body.children)
            )
          else
            body.children.all? { |i| simple?(i) }
          end
        else
          true
        end
      end

      SWITCH_TEST_MATCH = AST::Matcher.new do
        s(:send,
          cap(s(%i[int sym str], :*)), :===,
          s(:lvasgn, cap(:*), cap(:*))
        )
      end

      SWITCH_BRANCH_TEST_MATCH = AST::Matcher.new do
        s(:send,
          cap(s(%i[int sym str], :*)), :===,
          s(:js_tmp, cap(:*))
        )
      end

      def could_become_switch?
        return false if expects_expression?

        return true if sexp.meta[:switch_child]

        test_match = SWITCH_TEST_MATCH.match(test)
        return false unless test_match
        @switch_test, @switch_variable, @switch_first_test = *test_match

        return false unless valid_switch_body?(true_body)

        could_become_switch_branch?(false_body)
      end

      def could_become_switch_branch?(body)
        if !body
          return true
        elsif body.type != :if
          if valid_switch_body?(body)
            body.meta[:switch_default] = true
            return true
          end
          return false
        end

        test, true_body, false_body = *body

        test_match = SWITCH_BRANCH_TEST_MATCH.match(test)
        return false unless test_match
        switch_test, switch_variable = *test_match

        return false unless switch_variable == @switch_variable

        return false unless valid_switch_body?(true_body)
        return false unless could_become_switch_branch?(false_body)

        body.meta.merge!(switch_child: true,
                         switch_test: switch_test,
                         switch_variable: @switch_variable
        )

        true
      end

      def valid_switch_body?(body)
        case body
        when AST::Node
          case body.type
          when :break, :next, :redo, :retry
            false
          else
            body.children.all? { |i| simple?(i) }
          end
        else
          true
        end
      end

      def compile_with_switch
        if sexp.meta[:switch_child]
          @switch_variable = sexp.meta[:switch_variable]
          compile_switch_case(sexp.meta[:switch_test])
        else
          line "switch (", expr(@switch_first_test), ") {"
          indent do
            compile_switch_case(@switch_test)
          end
          line "}"
        end
      end

      def returning?(body)
        %i[return js_return].include?(body.type) ||
          (body.type == :begin && %i[return js_return].include?(body.children.last.type))
      end

      def compile_switch_case(test)
        line "case ", expr(test), ":"
        indent do
          line stmt(true_body)
          line "break;" if !true_body || !returning?(true_body)
        end
        if false_body
          if false_body.meta[:switch_default]
            compile_switch_default
          elsif false_body.meta[:switch_child]
            push stmt(false_body)
          end
        else
          push stmt(s(:nil))
        end
      end

      def compile_switch_default
        line "default:"
        indent do
          line stmt(false_body)
        end
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
