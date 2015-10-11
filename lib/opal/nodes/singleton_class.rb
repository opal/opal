require 'opal/nodes/scope'

module Opal
  module Nodes
    class SingletonClassNode < ScopeNode
      handle :sclass

      children :object, :body

      def compile
        push "(function(self) {"

        in_scope do
          add_temp '$scope = self.$$scope'
          add_temp 'def = self.$$proto'

          body_stmt = stmt(compiler.returns(body))
          line scope.to_vars
          line body_stmt
        end

        line "})(Opal.get_singleton_class(", recv(object), "))"
      end
    end
  end
end
