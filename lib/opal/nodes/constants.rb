require 'opal/nodes/base'

module Opal
  class Parser
    class ConstNode < Node
      children :name

      def initialize(*)
        super
        @const_missing = true
      end

      def compile
        if @const_missing
          with_temp do |tmp|
            push "((#{tmp} = $scope.#{name}) == null ? $opal.cm('#{name}') : #{tmp})"
          end
        else
          push "$scope.#{name}"
        end
      end
    end

    class ConstDeclarationNode < Node
      children :name, :base

      def compile
        push expr(base)
        wrap "$opal.cdecl($scope, '#{name}', ", ")"
      end
    end

    class ConstAssignNode < Node
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
      children :base, :name

      def initialize(*)
        super
        @const_missing = true
      end

      def compile
        if @const_missing
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
      children :name

      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.Object._scope.#{name}) == null ? "
          push "$opal.cm('#{name}') : #{tmp})"
        end
      end
    end

    class TopConstAssignNode < Node
      children :name, :value

      def compile
        push "$opal.casgn($opal.Object, '#{name}', "
        push expr(value)
        push ")"
      end
    end
  end
end
