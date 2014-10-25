require 'opal/nodes/scope'

module Opal
  module Nodes
    class ModuleNode < ScopeNode
      handle :module

      children :cid, :body

      def compile
        name, base = name_and_base
        helper :module

        push "(function($base) {"
        line "  var self = $module($base, '#{name}');"

        in_scope do
          scope.name = name
          add_temp "#{scope.proto} = self.$$proto"
          add_temp '$scope = self.$$scope'

          body_code = stmt(body || s(:nil))
          empty_line

          line scope.to_vars
          line body_code
          line scope.to_donate_methods
        end

        line "})(", base, ")"
      end

      def name_and_base
        if cid.type == :const
          [cid[1].to_s, 'self']
        elsif cid.type == :colon2
          [cid[2].to_s, expr(cid[1])]
        elsif cid.type == :colon3
          [cid[1].to_s, 'Opal.Object']
        else
          raise "Bad receiver in module"
        end
      end
    end
  end
end
