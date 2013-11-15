require 'opal/nodes/scope'

module Opal
  module Nodes
    class SingletonClassNode < ScopeNode
      handle :sclass

      children :object, :body

      def compile
        push "(function(self) {"

        in_scope do
          add_temp '$scope = self._scope'
          add_temp 'def = self._proto'

          line scope.to_vars
          line stmt(compiler.returns(body))
        end

        line "})(", recv(object), ".$singleton_class())"
      end
    end
  end
end
