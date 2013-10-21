require 'opal/nodes/base'

module Opal
  class Parser

    class BaseScopeNode < Node
      def in_scope(type, &block)
        @parser.in_scope(type, &block)
      end
    end

    class SingletonClassNode < BaseScopeNode
      children :object, :body

      def compile
        in_scope(:sclass) do
          add_temp '$scope = self._scope'
          add_temp 'def = self._proto'

          push scope.to_vars
          push stmt(body)
        end

        push "})("
        push recv(object)
        wrap "(function(self) {", ".$singleton_class())"
      end
    end

    class UndefNode < Node
      children :mid

      # FIXME: we should be setting method to a stub method here
      def compile
        push "delete #{scope.proto}#{@parser.mid_to_jsid mid[1].to_s}"
      end
    end
  end
end
