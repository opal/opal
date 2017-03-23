require 'opal/nodes/scope'

module Opal
  module Nodes
    class ModuleNode < ScopeNode
      handle :module

      children :cid, :body

      def compile
        name, base = name_and_base
        helper :module

        push "(function($base, $parent_nesting) {"
        line "  var $#{name}, self = $#{name} = $module($base, '#{name}');"

        in_scope do
          scope.name = name
          add_temp "#{scope.proto} = self.$$proto"
          add_temp '$scope = self.$$scope'
          add_temp '$nesting = $parent_nesting.slice().concat($scope)'

          body_code = stmt(body || s(:nil))
          empty_line

          line scope.to_vars
          line body_code
        end

        line "})(", base, ", $nesting)"
      end

      # cid is always s(:const, scope_sexp_or_nil, :ConstName)
      def name_and_base
        base, name = cid.children

        if base.nil?
          [name, '$scope.base']
        else
          [name, expr(base)]
        end
      end
    end
  end
end
