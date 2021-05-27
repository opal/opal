# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class LocalVariableNode < Base
      handle :lvar

      children :var_name

      def using_irb?
        compiler.irb? && scope.top?
      end

      def compile
        return push(var_name.to_s) unless using_irb?

        with_temp do |tmp|
          push property(var_name.to_s)
          wrap "((#{tmp} = Opal.irb_vars", ") == null ? nil : #{tmp})"
        end
      end
    end

    class LocalAssignNode < Base
      handle :lvasgn

      children :var_name, :value

      def using_irb?
        compiler.irb? && scope.top?
      end

      def compile
        if using_irb?
          push "Opal.irb_vars#{property var_name.to_s} = "
        else
          add_local var_name.to_s

          push "#{var_name} = "
        end

        push expr(value)

        wrap '(', ')' if (recv? || expr?) && value
      end
    end

    class LocalDeclareNode < Base
      handle :lvdeclare

      children :var_name

      def compile
        add_local(var_name.to_s)
        nil
      end
    end

    class InstanceVariableNode < Base
      handle :ivar

      children :name

      def var_name
        name.to_s[1..-1]
      end

      def compile
        name = property(var_name)
        add_ivar name
        push "self#{name}"
      end
    end

    class InstanceAssignNode < Base
      handle :ivasgn

      children :name, :value

      def var_name
        name.to_s[1..-1]
      end

      def compile
        name = property(var_name)
        push "self#{name} = "
        push expr(value)

        wrap '(', ')' if (recv? || expr?) && value
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

        name = property var_name
        add_gvar name
        push "$gvars#{name}"
      end
    end

    # back_ref can be:
    # $`
    # $'
    # $&
    # $+ (currently unsupported)
    class BackRefNode < GlobalVariableNode
      handle :back_ref

      def compile
        helper :gvars

        case var_name
        when '&'
          handle_global_match
        when "'"
          handle_post_match
        when '`'
          handle_pre_match
        when '+'
          super
        else
          raise NotImplementedError
        end
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
      handle :gvasgn

      children :name, :value

      def var_name
        name.to_s[1..-1]
      end

      def compile
        helper :gvars
        name = property var_name
        push "$gvars#{name} = "
        push expr(value)

        wrap '(', ')' if (recv? || expr?) && value
      end
    end

    # $1 => s(:nth_ref, 1)
    class NthrefNode < Base
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
          push "((#{tmp} = #{class_variable_owner}[Opal.s.$$cvars]['#{name}']) == null ? nil : #{tmp})"
        end
      end
    end

    class ClassVarAssignNode < Base
      handle :cvasgn

      children :name, :value

      def compile
        push "(Opal.class_variable_set(#{class_variable_owner}, '#{name}', ", expr(value), '))'
      end
    end
  end
end
