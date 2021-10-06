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

      def on_case(node)
        lhs, *whens, els = *node.children
        els ||= s(:nil)
        lhs_tmp = next_tmp if lhs

        build_if_from_when(node, lhs, lhs_tmp, whens, els)
      end

      def on_or(node)
        lhs, rhs = *node.children
        lhs_tmp = next_tmp

        out = node.updated(:if, [s(:lvasgn, lhs_tmp, process(lhs)), s(:js_tmp, lhs_tmp), process(rhs)])
        free_tmp
        out
      end

      def on_and(node)
        lhs, rhs = *node.children
        lhs_tmp = next_tmp

        out = node.updated(:if, [s(:lvasgn, lhs_tmp, process(lhs)), process(rhs), s(:js_tmp, lhs_tmp)])
        free_tmp
        out
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
