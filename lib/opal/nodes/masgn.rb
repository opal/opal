# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class MassAssignNode < Base
      handle :masgn
      children :lhs, :rhs

      def compile
        with_temp do |array|
          if rhs.type == :array
            push "#{array} = ", expr(rhs)
            rhs_len = rhs.children.any? { |c| c.type == :splat } ? nil : rhs.children.size
            compile_masgn(lhs.children, array, rhs_len)
            push ", #{array}" # a mass assignment evaluates to the RHS
          else
            helper :to_ary
            with_temp do |retval|
              push "#{retval} = ", expr(rhs)
              push ", #{array} = $to_ary(#{retval})"
              compile_masgn(lhs.children, array)
              push ", #{retval}"
            end
          end
        end
      end

      # 'len' is how many rhs items are we sure we have
      def compile_masgn(lhs_items, array, len = nil)
        pre_splat  = lhs_items.take_while { |child| child.type != :splat }
        post_splat = lhs_items.drop(pre_splat.size)

        pre_splat.each_with_index do |child, idx|
          compile_assignment(child, array, idx, len)
        end

        unless post_splat.empty?
          splat = post_splat.shift

          if post_splat.empty? # trailing splat
            if part = splat.children[0]
              helper :slice
              part = part.dup << s(:js_tmp, "$slice(#{array}, #{pre_splat.size})")
              push ', '
              push expr(part)
            end
          else
            tmp = scope.new_temp # end index for items consumed by splat
            push ", #{tmp} = #{array}.length - #{post_splat.size}"
            push ", #{tmp} = (#{tmp} < #{pre_splat.size}) ? #{pre_splat.size} : #{tmp}"

            if part = splat.children[0]
              helper :slice
              part = part.dup << s(:js_tmp, "$slice(#{array}, #{pre_splat.size}, #{tmp})")
              push ', '
              push expr(part)
            end

            post_splat.each_with_index do |child, idx|
              if idx == 0
                compile_assignment(child, array, tmp)
              else
                compile_assignment(child, array, "#{tmp} + #{idx}")
              end
            end

            scope.queue_temp(tmp)
          end
        end
      end

      def compile_assignment(child, array, idx, len = nil)
        assign =
          if !len || idx >= len
            s(:js_tmp, "(#{array}[#{idx}] == null ? nil : #{array}[#{idx}])")
          else
            s(:js_tmp, "#{array}[#{idx}]")
          end

        part = child.updated
        case child.type
        when :lvasgn, :ivasgn, :lvar, :gvasgn, :cdecl, :casgn, :send # Simple assignment
          part = part.updated(nil, part.children + [assign])
        when :attrasgn
          part.last << assign
        when :mlhs
          helper :to_ary
          # nested destructuring
          tmp = scope.new_temp
          push ", (#{tmp} = $to_ary(#{assign.children[0]})"
          compile_masgn(child.children, tmp)
          push ')'
          scope.queue_temp(tmp)
          return
        else
          raise "Bad child node in masgn LHS: #{child}. LHS: #{lhs}"
        end

        push ', '
        push expr(part)
      end
    end
  end
end
