require 'opal/nodes/module'

module Opal
  module Nodes
    class ClassNode < ModuleNode
      handle :class

      children :cid, :sup, :body

      def compile
        name, base = name_and_base
        helper :klass

        push "(function($base, $super) {"
        line "  function #{name}(){};"
        line "  var self = #{name} = $klass($base, $super, '#{name}', #{name});"

        in_scope(:class) do
          scope.name = name
          add_temp "#{scope.proto} = #{name}._proto"
          add_temp "$scope = #{name}._scope"

          body_code = self.body_code
          empty_line

          line scope.to_vars
          line body_code
        end

        line "})(", base, ", ", self.super_code, ")"
      end

      def super_code
        sup ? expr(sup) : 'null'
      end

      def body_code
        body[1] = s(:nil) unless body[1]
        stmt(compiler.returns(body))
      end
    end
  end
end
