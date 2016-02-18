require 'opal/nodes/base'

module Opal
  module Nodes
    class MassAssignNode < Base
      SIMPLE_ASSIGNMENT = [:lasgn, :iasgn, :lvar, :gasgn, :cdecl]

      handle :masgn
      children :lhs, :rhs

      def compile
        array = scope.new_temp

        if rhs.type == :array
          push "#{array} = ", expr(rhs)
          compile_masgn(lhs.children, array, rhs.size - 1)
          push ", #{array}" # a mass assignment evaluates to the RHS
        elsif rhs.type == :to_ary
          retval = scope.new_temp
          push "#{retval} = ", expr(rhs[1])
          push ", #{array} = Opal.to_ary(#{retval})"
          compile_masgn(lhs.children, array)
          push ", #{retval}"
          scope.queue_temp(retval)
        elsif rhs.type == :splat
          push "#{array} = Opal.to_a(", expr(rhs[1]), ")"
          compile_masgn(lhs.children, array)
          push ", #{array}"
        else
          raise "unsupported mlhs type"
        end

        scope.queue_temp(array)
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
            if part = splat[1]
              part = part.dup << s(:js_tmp, "$slice.call(#{array}, #{pre_splat.size})")
              push ', '
              push expr(part)
            end
          else
            tmp = scope.new_temp # end index for items consumed by splat
            push ", #{tmp} = #{array}.length - #{post_splat.size}"
            push ", #{tmp} = (#{tmp} < #{pre_splat.size}) ? #{pre_splat.size} : #{tmp}"

            if part = splat[1]
              part = part.dup << s(:js_tmp, "$slice.call(#{array}, #{pre_splat.size}, #{tmp})")
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
        if !len || idx >= len
          assign = s(:js_tmp, "(#{array}[#{idx}] == null ? nil : #{array}[#{idx}])")
        else
          assign = s(:js_tmp, "#{array}[#{idx}]")
        end

        part = child.dup
        if SIMPLE_ASSIGNMENT.include?(child.type)
          part << assign
        elsif child.type == :call
          part[2] = "#{part[2]}=".to_sym
          part.last << assign
        elsif child.type == :attrasgn
          part.last << assign
        elsif child.type == :array
          # nested destructuring
          tmp = scope.new_temp
          push ", (#{tmp} = Opal.to_ary(#{assign[1]})"
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
