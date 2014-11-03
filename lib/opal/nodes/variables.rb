require 'opal/nodes/base'

module Opal
  module Nodes
    class LocalVariableNode < Base
      handle :lvar

      children :var_name

      def using_irb?
        compiler.irb? and scope.top?
      end

      def compile
        return push(variable(var_name.to_s)) unless using_irb?

        with_temp do |tmp|
          push property(var_name.to_s)
          wrap "((#{tmp} = Opal.irb_vars", ") == null ? nil : #{tmp})"
        end
      end
    end

    class LocalAssignNode < Base
      handle :lasgn

      children :var_name, :value

      def using_irb?
        compiler.irb? and scope.top?
      end

      def compile
        if using_irb?
          push "Opal.irb_vars#{property var_name.to_s} = "
          push expr(value)
        else
          add_local variable(var_name.to_s)

          push "#{variable(var_name.to_s)} = "
          push expr(value)
        end

        wrap '(', ')' if recv?
      end
    end

    class InstanceVariableNode < Base
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

    class InstanceAssignNode < Base
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

    class GlobalVariableNode < Base
      handle :gvar

      children :name

      def var_name
        name.to_s[1..-1]
      end

      def compile
        helper :gvars

        if var_name == '&'
          return handle_global_match
        elsif var_name == "'"
          return handle_post_match
        elsif var_name == '`'
          return handle_pre_match
        end

        name = property var_name
        add_gvar name
        push "$gvars#{name}"
      end

      def handle_global_match
        with_temp do |tmp|
          push "((#{tmp} = $gvars['~']) === nil ? nil : #{tmp}['$[]'](0))"
        end
      end

      def handle_pre_match
        with_temp do |tmp|
          push "((#{tmp} = $gvars['~']) === nil ? nil : #{tmp}.$pre_match())"
        end
      end

      def handle_post_match
        with_temp do |tmp|
          push "((#{tmp} = $gvars['~']) === nil ? nil : #{tmp}.$post_match())"
        end
      end
    end

    class GlobalAssignNode < Base
      handle :gasgn

      children :name, :value

      def var_name
        name.to_s[1..-1]
      end

      def compile
        helper :gvars
        name = property var_name
        push "$gvars#{name} = "
        push expr(value)
      end
    end

    class BackrefNode < Base
      handle :nth_ref

      children :index

      def compile
        helper :gvars

        with_temp do |tmp|
          push "((#{tmp} = $gvars['~']) === nil ? nil : #{tmp}['$[]'](#{index}))"
        end
      end
    end

    class ClassVariableNode < Base
      handle :cvar

      children :name

      def compile
        with_temp do |tmp|
          push "((#{tmp} = Opal.cvars['#{name}']) == null ? nil : #{tmp})"
        end
      end
    end

    class ClassVarAssignNode < Base
      handle :casgn

      children :name, :value

      def compile
        push "(Opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end

    class ClassVarDeclNode < Base
      handle :cvdecl

      children :name, :value

      def compile
        push "(Opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end
  end
end
