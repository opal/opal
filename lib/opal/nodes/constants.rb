require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Node
      handle :const

      children :name

      def compile
        if compiler.const_missing?
          with_temp do |tmp|
            push "((#{tmp} = $scope.#{name}) == null ? $opal.cm('#{name}') : #{tmp})"
          end
        else
          push "$scope.#{name}"
        end
      end
    end

    class ConstDeclarationNode < Node
      handle :cdecl

      children :name, :base

      def compile
        push expr(base)
        wrap "$opal.cdecl($scope, '#{name}', ", ")"
      end
    end

    class ConstAssignNode < Node
      handle :casgn

      children :base, :name, :value

      def compile
        push "$opal.casgn("
        push expr(base)
        push ", '#{name}', "
        push expr(value)
        push ")"
      end
    end

    class ConstGetNode < Node
      handle :colon2

      children :base, :name

      def compile
        if compiler.const_missing?
          with_temp do |tmp|
            push "((#{tmp} = ("
            push expr(base)
            push ")._scope).#{name} == null ? #{tmp}.cm('#{name}') : "
            push "#{tmp}.#{name})"
          end
        else
          push expr(base)
          wrap '(', ")._scope.#{name}"
        end
      end
    end

    class TopConstNode < Node
      handle :colon3

      children :name

      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.Object._scope.#{name}) == null ? "
          push "$opal.cm('#{name}') : #{tmp})"
        end
      end
    end

    class TopConstAssignNode < Node
      handle :casgn3

      children :name, :value

      def compile
        push "$opal.casgn($opal.Object, '#{name}', "
        push expr(value)
        push ")"
      end
    end
  end
end
