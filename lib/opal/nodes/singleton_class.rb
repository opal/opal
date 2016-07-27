require 'opal/nodes/scope'

module Opal
  module Nodes
    class SingletonClassNode < ScopeNode
      handle :sclass

      children :object, :body

      def compile
        push "(function(self, $visibility_scopes) {"

        in_scope do
          add_temp 'def = self.$$proto'
          add_temp '$scope = self.$$scope'
          add_temp '$scopes = $visibility_scopes.slice().concat(self)'

          body_stmt = stmt(compiler.returns(body))
          line scope.to_vars
          line body_stmt
        end

        line "})(Opal.get_singleton_class(", recv(object), "), $scopes)"
      end
    end
  end
end
