# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ReturnableLogic < Base
      def next_tmp
        @counter ||= 0
        @counter += 1
        "$ret_or_#{@counter}"
      end

      def free_tmp
        @counter -= 1
      end

      def reset_tmp_counter!
        @counter = nil
      end

      def on_if(node)
        test, = *node.children
        # The if_test metadata signifies that we don't care about the return value except if it's
        # truthy or falsy. And those tests will be carried out by the respective $truthy helper calls.
        test.meta[:if_test] = true if test
        super
      end

      def on_case(node)
        lhs, *whens, els = *node.children
        els ||= s(:nil)
        lhs_tmp = next_tmp if lhs

        out = build_if_from_when(node, lhs, lhs_tmp, whens, els)
        free_tmp if lhs
        out
      end

      # `a || b` / `a or b`
      def on_or(node)
        lhs, rhs = *node.children

        if node.meta[:if_test]
          # Let's forward the if_test to the lhs and rhs - since we don't care about the exact return
          # value of our or, we neither do care about a return value of our lhs or rhs.
          lhs.meta[:if_test] = rhs.meta[:if_test] = true
          out = process(node.updated(:if, [lhs, s(:true), rhs]))
        else
          lhs_tmp = next_tmp
          out = process(node.updated(:if, [s(:lvasgn, lhs_tmp, lhs), s(:js_tmp, lhs_tmp), rhs]))
          free_tmp
        end
        out
      end

      # `a && b` / `a and b`
      def on_and(node)
        lhs, rhs = *node.children

        if node.meta[:if_test]
          lhs.meta[:if_test] = rhs.meta[:if_test] = true
          out = process(node.updated(:if, [lhs, rhs, s(:false)]))
        else
          lhs_tmp = next_tmp
          out = process(node.updated(:if, [s(:lvasgn, lhs_tmp, lhs), rhs, s(:js_tmp, lhs_tmp)]))
          free_tmp
        end
        out
      end

      # Parser sometimes generates parentheses as a begin node. If it's a single node begin value, then
      # let's forward the if_test metadata.
      def on_begin(node)
        if node.meta[:if_test] && node.children.count == 1
          node.children.first.meta[:if_test] = true
        end
        node.meta.delete(:if_test)
        super
      end

      private

      def build_if_from_when(node, lhs, lhs_tmp, whens, els)
        first_when, *next_whens = *whens

        *parts, expr = *first_when.children

        rule = build_rule_from_parts(node, lhs, lhs_tmp, parts)

        first_when.updated(:if, [rule, process(expr), next_whens.empty? ? process(els) : build_if_from_when(nil, nil, lhs_tmp, next_whens, els)])
      end

      def build_rule_from_parts(node, lhs, lhs_tmp, parts)
        lhs = if node && lhs_tmp
                node.updated(:lvasgn, [lhs_tmp, process(lhs)])
              else
                s(:js_tmp, lhs_tmp)
              end

        first_part, *next_parts = *parts

        subrule = if first_part.type == :splat
                    splat_on = first_part.children.first
                    iter_val = next_tmp
                    block = s(:send, process(splat_on), :any?,
                      s(:iter,
                        s(:args, s(:arg, iter_val)),
                        build_rule_from_parts(nil, nil, lhs_tmp, [s(:lvar, iter_val)])
                      )
                    )
                    if node && lhs_tmp
                      s(:begin, lhs, block)
                    else
                      block
                    end
                  elsif lhs_tmp
                    s(:send, process(first_part), :===, lhs)
                  else
                    process(first_part)
                  end

        if next_parts.empty?
          subrule
        else
          s(:if, subrule, s(:true), build_rule_from_parts(nil, nil, lhs_tmp, next_parts))
        end
      end
    end
  end
end
