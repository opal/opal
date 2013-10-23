require 'opal/nodes/base_scope'

module Opal
  module Nodes
    class ModuleNode < BaseScopeNode
      handle :module

      children :cid, :body

      def compile
        name, base = name_and_base
        helper :module

        push "(function($base) {"
        line "  var self = $module($base, '#{name}');"

        in_scope(:module) do
          scope.name = name
          add_temp "#{scope.proto} = self._proto"
          add_temp '$scope = self._scope'

          body_code = stmt(body)
          empty_line

          line scope.to_vars
          line body_code
          line scope.to_donate_methods
        end

        line "})(", base, ")"
      end

      def name_and_base
        if Symbol === cid or String === cid
          [cid.to_s, 'self']
        elsif cid.type == :colon2
          [cid[2].to_s, expr(cid[1])]
        elsif cid.type == :colon3
          [cid[1].to_s, '$opal.Object']
        else
          raise "Bad receiver in module"
        end
      end
    end
  end
end
