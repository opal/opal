# frozen_string_literal: true

require 'opal/nodes/scope'

module Opal
  module Nodes
    class SingletonClassNode < ScopeNode
      handle :sclass

      children :object, :body

      def compile
        push '(function(self, $parent_nesting) {'

        in_scope do
          add_temp '$nesting = [self].concat($parent_nesting)'

          body_stmt = stmt(compiler.returns(body))
          line scope.to_vars
          line body_stmt
        end

        line '})(Opal.get_singleton_class(', recv(object), '), $nesting)'
      end
    end
  end
end
