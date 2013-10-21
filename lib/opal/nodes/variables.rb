require 'opal/nodes/base'

module Opal
  class Parser
    class LocalVariableNode < Node
      children :var_name

      def using_irb?
        @parser.instance_variable_get(:@irb_vars) and scope.top?
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
      children :var_name, :value

      def using_irb?
        @parser.instance_variable_get(:@irb_vars) and scope.top?
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
      def compile
        push "nil"
      end
    end

    class ClassVariableNode < Node
      children :name

      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.cvars['#{name}']) == null ? nil : #{tmp})"
        end
      end
    end

    class ClassVarAssignNode < Node
      children :name, :value

      def compile
        push "($opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end

    class ClassVarDeclNode < Node
      children :name, :value

      def compile
        push "($opal.cvars['#{name}'] = "
        push expr(value)
        push ")"
      end
    end
  end
end
