require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Base
      handle :const

      children :name

      def compile
        if name == :DATA and compiler.eof_content
          push("$__END__")
        elsif compiler.const_missing?
          push "$scope.get('#{name}')"
        else
          push "$scope.#{name}"
        end
      end
    end

    class ConstDeclarationNode < Base
      handle :cdecl

      children :name, :base

      def compile
        push expr(base)
        wrap "$opal.cdecl($scope, '#{name}', ", ")"
      end
    end

    class ConstAssignNode < Base
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

    class ConstGetNode < Base
      handle :colon2

      children :base, :name

      def compile
        if compiler.const_missing?
          push "(("
          push expr(base)
          push ")._scope.get('#{name}'))"
        else
          push expr(base)
          wrap '(', ")._scope.#{name}"
        end
      end
    end

    class TopConstNode < Base
      handle :colon3

      children :name

      def compile
        push "Opal.get('#{name}')"
      end
    end

    class TopConstAssignNode < Base
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
