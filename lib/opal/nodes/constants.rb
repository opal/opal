require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Base
      handle :const

      children :name

      def compile
        if name == :DATA and compiler.eof_content
          push("$__END__")
        else
          push "$scope.get('#{name}')"
        end
      end
    end

    class ConstDeclarationNode < Base
      handle :cdecl

      children :name, :base

      def compile
        push expr(base)
        wrap "Opal.cdecl($scope, '#{name}', ", ")"
      end
    end

    class ConstAssignNode < Base
      handle :casgn

      children :base, :name, :value

      def compile
        push "Opal.casgn("
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
        push "(("
        push expr(base)
        push ").$$scope.get('#{name}'))"
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
        push "Opal.casgn(Opal.Object, '#{name}', "
        push expr(value)
        push ")"
      end
    end
  end
end
