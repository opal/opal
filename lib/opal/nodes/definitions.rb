require 'opal/nodes/base'

module Opal
  class Parser

    class BaseScopeNode < Node
      def in_scope(type, &block)
        @parser.in_scope(type, &block)
      end
    end

    class SClassNode < BaseScopeNode
      def compile
        in_scope(:sclass) do
          add_temp '$scope = self._scope'
          add_temp 'def = self._proto'

          push scope.to_vars
          push stmt(@sexp[2])
        end

        push "})("
        push recv(@sexp[1])
        wrap "(function(self) {", ".$singleton_class())"
      end
    end

    class UndefNode < Node
      # FIXME: we should be setting method to a stub method here
      def compile
        push "delete #{scope.proto}#{@parser.mid_to_jsid @sexp[1][1].to_s}"
      end
    end
  end
end
