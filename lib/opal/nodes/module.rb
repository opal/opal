# frozen_string_literal: true

require 'opal/nodes/scope'

module Opal
  module Nodes
    class ModuleNode < ScopeNode
      handle :module

      children :cid, :body

      def compile
        name, base = name_and_base
        helper :module

        push '(function($base, $parent_nesting) {'
        line "  function $#{name}() {};"
        line "  var self = $#{name} = $module($base, '#{name}', $#{name});"

        in_scope do
          scope.name = name
          add_temp '$nesting = [self].concat($parent_nesting)'

          body_code = stmt(body || s(:nil))
          empty_line

          line scope.to_vars
          line body_code
        end

        line '})(', base, ', $nesting)'
      end

      # cid is always s(:const, scope_sexp_or_nil, :ConstName)
      def name_and_base
        base, name = cid.children

        if base.nil?
          [name, '$nesting[0]']
        else
          [name, expr(base)]
        end
      end
    end
  end
end
