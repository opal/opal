require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Base
      handle :const

      children :scope, :name

      def compile
        if scope.nil? && name == :DATA and compiler.eof_content
          push("$__END__")
        elsif scope && scope.type == :cbase
          push "Opal.get('#{name}')"
        elsif scope
          push expr(scope), ".$$scope.get('#{name}')"
        else
          push "$scope.get('#{name}')"
        end
      end
    end

    # ::CONST
    # s(:const, s(:cbase), :CONST)
    class CbaseNode < Base
      handle :cbase

      def compile
        push "Opal.Object"
      end
    end

    class ConstAssignNode < Base
      handle :casgn

      children :base, :name, :value

      def compile
        if base
          push "Opal.casgn(", expr(base), ", '#{name}', ", expr(value), ")"
        else
          push "Opal.cdecl($scope, '#{name}', ", expr(value), ")"
        end
      end
    end
  end
end
