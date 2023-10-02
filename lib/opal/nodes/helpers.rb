# frozen_string_literal: true

require 'opal/regexp_anchors'

module Opal
  module Nodes
    module Helpers
      def property(name)
        valid_name?(name) ? ".#{name}" : "[#{name.inspect}]"
      end

      def valid_name?(name)
        Opal::Rewriters::JsReservedWords.valid_name?(name)
      end

      # Converts a ruby method name into its javascript equivalent for
      # a method/function call.
      def mid_to_jsid(mid)
        helper :sym

        sym = symbol(mid)

        "[#{sym}]"
      end

      def indent(&block)
        compiler.indent(&block)
      end

      def current_indent
        compiler.parser_indent
      end

      def line(*strs)
        push fragment("\n#{current_indent}", loc: false)
        push(*strs)
      end

      def empty_line
        push fragment("\n", loc: false)
      end

      def js_truthy(sexp)
        if optimize = js_truthy_optimize(sexp)
          return optimize
        end

        helper :truthy
        [fragment('$truthy('), expr(sexp), fragment(')')]
      end

      def js_truthy_optimize(sexp)
        case sexp.type
        when :send
          receiver, mid, *args = *sexp
          receiver_handler_class = receiver && compiler.handlers[receiver.type]

          # Only operator calls on the truthy_optimize? node classes should be optimized.
          # Monkey patch method calls might return 'self'/aka a bridged instance and need
          # the nil check - see discussion at https://github.com/opal/opal/pull/1097
          allow_optimization_on_type = Compiler::COMPARE.include?(mid.to_s) &&
                                       receiver_handler_class &&
                                       receiver_handler_class.truthy_optimize?

          if allow_optimization_on_type ||
             mid == :block_given?
            expr(sexp)
          elsif args.count == 1
            case mid
            when :==
              helper :eqeq
              compiler.record_method_call mid
              [fragment('$eqeq('), expr(receiver), fragment(', '), expr(args.first), fragment(')')]
            when :===
              helper :eqeqeq
              compiler.record_method_call mid
              [fragment('$eqeqeq('), expr(receiver), fragment(', '), expr(args.first), fragment(')')]
            when :!=
              helper :neqeq
              compiler.record_method_call mid
              [fragment('$neqeq('), expr(receiver), fragment(', '), expr(args.first), fragment(')')]
            end
          elsif args.count == 0
            case mid
            when :!
              helper :not
              compiler.record_method_call mid
              [fragment('$not('), expr(receiver), fragment(')')]
            end
          end
        when :begin
          if sexp.children.count == 1
            js_truthy_optimize(sexp.children.first)
          end
        when :if
          _test, true_body, false_body = *sexp
          if true_body == s(:true)
            # Ensure we recurse the js_truthy call on the `false_body` of the if `expr`.
            # This transforms an expression like:
            #
            # $truthy($truthy(a) || b)
            #
            # Into:
            #
            # $truthy(a) || $truthy(b)
            sexp.meta[:do_js_truthy_on_false_body] = true
            expr(sexp)
          elsif false_body == s(:false)
            sexp.meta[:do_js_truthy_on_true_body] = true
            expr(sexp)
          end
        end
      end
    end
  end
end
