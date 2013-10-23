require 'opal/nodes/base'

module Opal
  class Parser
    class LocalVariableNode < Node
      handle :lvar

      children :var_name

      def using_irb?
        compiler.irb_vars? and scope.top?
      end

      def compile
        return push(variable(var_name.to_s)) unless using_irb?

        with_temp do |tmp|
          push property(var_name.to_s)
          wrap "((#{tmp} = $opal.irb_vars", ") == null ? nil : #{tmp})"
        end
      end
    end

    class LocalAssignNode < Node
      handle :lasgn

      children :var_name, :value

      def using_irb?
        compiler.irb_vars? and scope.top?
      end

      def compile
        if using_irb?
          push "$opal.irb_vars#{property var_name.to_s} = "
          push expr(value)
        else
          add_local variable(var_name.to_s)

          push "#{variable(var_name.to_s)} = "
          push expr(value)
        end

        wrap '(', ')' if recv?
      end
    end

    class InstanceVariableNode < Node
      handle :ivar

      children :name

      def var_name
        name.to_s[1..-1]
      end

      def compile
        name = property var_name
        add_ivar name
        push "self#{name}"
      end
    end

    class InstanceAssignNode < Node
      handle :iasgn

      children :name, :value

      def var_name
        name.to_s[1..-1]
      end

      def compile
        name = property var_name
        push "self#{name} = "
        push expr(value)
      end
    end

    class GlobalVariableNode < Node
      handle :gvar

      children :name

      def var_name
        name.to_s[1..-1]
      end

      def compile
        helper :gvars
        push "$gvars[#{var_name.inspect}]"
      end
    end

    class GlobalAssignNode < Node
      handle :gasgn

      children :name, :value

      def var_name
        name.to_s[1..-1]
      end

      def compile
        helper :gvars
        push "$gvars[#{var_name.inspect}] = "
        push expr(value)
      end
    end

    class BackrefNode < Node
      handle :nth_ref

      def compile
        push "nil"
      end
    end

    class ClassVariableNode < Node
      handle :cvar

      children :name

      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.cvars['#{name}']) == null ? nil : #{tmp})"
        end
      end
    end

    class ClassVarAssignNode < Node
      handle :casgn

      children :name, :value

      def compile
        push "($opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end

    class ClassVarDeclNode < Node
      handle :cvdecl

      children :name, :value

      def compile
        push "($opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end

    class MassAssignNode < Node
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
          push "(#{tmp} = ", expr(rhs[1]), ")['$to_a'] ? (#{tmp} = #{tmp}['$to_a']())"
          push " : (#{tmp})._isArray ? #{tmp} : (#{tmp} = [#{tmp}])"
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
            if child.type == :lasgn or child.type == :iasgn or child.type == :lvar
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
