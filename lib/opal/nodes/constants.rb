require 'opal/nodes/base'

module Opal
  class Parser
    class ConstNode < Node
      def initialize(*)
        super
        @const_missing = true
      end

      def compile
        name = @sexp[1]

        if @const_missing
          with_temp do |tmp|
            push "((#{tmp} = $scope.#{name}) == null ? $opal.cm('#{name}') : #{tmp})"
          end
        else
          push "$scope.#{name}"
        end
      end
    end

    class CdeclNode < Node
      def compile
        push expr(@sexp[2])
        wrap "$opal.cdecl($scope, '#{@sexp[1]}', ", ")"
      end
    end

    class CasgnNode < Node
      def compile
        push "$opal.casgn("
        push expr(@sexp[1])
        push ", '#{@sexp[2]}', "
        push expr(@sexp[3])
        push ")"
      end
    end

    class Colon2Node < Node
      def initialize(*)
        super
        @const_missing = true
      end

      def lhs
        expr @sexp[1]
      end

      def compile
        if @const_missing
          with_temp do |tmp|
            push "((#{tmp} = ("
            push lhs
            push ")._scope).#{@sexp[2]} == null ? #{tmp}.cm('#{@sexp[2]}') : "
            push "#{tmp}.#{@sexp[2]})"
          end
        else
          push lhs
          wrap '(', ")._scope.#{@sexp[1]}"
        end
      end
    end

    class Colon3Node < Node
      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.Object._scope.#{@sexp[1]}) == null ? "
          push "$opal.cm('#{@sexp[1]}') : #{tmp})"
        end
      end
    end

    class Casgn3Node < Node
      def compile
        push "$opal.casgn($opal.Object, '#{@sexp[1]}', "
        push expr(@sexp[2])
        push ")"
      end
    end
  end
end
