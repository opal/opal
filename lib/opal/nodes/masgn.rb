require 'opal/nodes/base'

module Opal
  module Nodes
    class MassAssignNode < Base
      handle :masgn

      children :lhs, :rhs

      def compile
        tmp = scope.new_temp
        len = 0 # how many rhs items are we sure we have

        if rhs.type == :array
          len = rhs.size - 1
          push "#{tmp} = ", expr(rhs)
        elsif rhs.type == :to_ary
          push "#{tmp} = $opal.to_ary(", expr(rhs[1]), ")"
        elsif rhs.type == :splat
          push "(#{tmp} = ", expr(rhs[1]), ")['$to_a'] && !#{tmp}['$to_a'].rb_stub ? (#{tmp} = #{tmp}['$to_a']())"
          push " : (#{tmp}).$$is_array ? #{tmp} : (#{tmp} = [#{tmp}])"
        else
          raise "unsupported mlhs type"
        end

        lhs.children.each_with_index do |child, idx|
          push ', '

          if child.type == :splat
            if part = child[1]
              part = part.dup
              part << s(:js_tmp, "$slice.call(#{tmp}, #{idx})")
              push expr(part)
            end
          else
            if idx >= len
              assign = s(:js_tmp, "(#{tmp}[#{idx}] == null ? nil : #{tmp}[#{idx}])")
            else
              assign = s(:js_tmp, "#{tmp}[#{idx}]")
            end

            part = child.dup
            if child.type == :lasgn or child.type == :iasgn or child.type == :lvar or child.type == :gasgn
              part << assign
            elsif child.type == :call
              part[2] = "#{part[2]}=".to_sym
              part.last << assign
            elsif child.type == :attrasgn
              part.last << assign
            else
              raise "Bad lhs for masgn"
            end

            push expr(part)
          end
        end

        scope.queue_temp tmp
      end
    end
  end
end
