require 'opal/nodes/base'

module Opal
  module Nodes
    class BaseScopeNode < Base
      def in_scope(type, &block)
        indent { compiler.in_scope(type, &block) }
      end
    end

    class SingletonClassNode < BaseScopeNode
      handle :sclass

      children :object, :body

      def compile
        push "(function(self) {"

        in_scope(:sclass) do
          add_temp '$scope = self._scope'
          add_temp 'def = self._proto'

          line scope.to_vars
          line stmt(body)
        end

        line "})(", recv(object), ".$singleton_class())"
      end
    end

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
