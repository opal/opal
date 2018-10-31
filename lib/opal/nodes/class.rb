# frozen_string_literal: true

require 'opal/nodes/module'

module Opal
  module Nodes
    class ClassNode < ModuleNode
      handle :class

      children :cid, :sup, :body

      def compile
        name, base = name_and_base
        helper :klass

        push '(function($base, $super, $parent_nesting) {'
        line "  var self = $klass($base, $super, '#{name}');"

        in_scope do
          scope.name = name
          add_temp '$nesting = [self].concat($parent_nesting)'

          body_code = self.body_code
          empty_line

          line scope.to_vars
          line body_code
        end

        line '})(', base, ', ', super_code, ', $nesting)'
      end

      def super_code
        sup ? expr(sup) : 'null'
      end

      def body_code
        stmt(compiler.returns(body || s(:nil)))
      end
    end
  end
end
