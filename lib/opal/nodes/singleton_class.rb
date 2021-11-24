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
          body_stmt = stmt(compiler.returns(body))

          add_temp '$nesting = [self].concat($parent_nesting)' if @define_nesting
          add_temp '$$ = Opal.$r($nesting)' if @define_relative_access

          line scope.to_vars
          line body_stmt
        end

        line '})(Opal.get_singleton_class(', recv(object), "), #{scope.nesting})"
      end
    end
  end
end
