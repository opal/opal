require 'opal/nodes/base'

module Opal
  class Parser
    class BaseScopeNode < Node
      def in_scope(type, &block)
        @parser.in_scope(type, &block)
      end
    end

    class SingletonClassNode < BaseScopeNode
      children :object, :body

      def compile
        in_scope(:sclass) do
          add_temp '$scope = self._scope'
          add_temp 'def = self._proto'

          push scope.to_vars
          push stmt(body)
        end

        push "})("
        push recv(object)
        wrap "(function(self) {", ".$singleton_class())"
      end
    end

    class ModuleNode < BaseScopeNode
      children :cid, :body

      def compile
        helper :module

        push pre_code

        @parser.indent do
          in_scope(:module) do
            scope.name = module_name
            add_temp "#{scope.proto} = self._proto"
            add_temp '$scope = self._scope'

            body_code = stmt(body)

            push "#{@indent}", scope.to_vars, "\n\n#{@indent}"
            push body_code
            push "\n#{@indent}", scope.to_donate_methods
          end
        end

        push "\n#{@indent}})(", module_base, ")"
      end

      def pre_code
        name = module_name
        "(function($base) {\n#{@indent}  var self = $module($base, '#{name}');\n"
      end

      def module_base
        if Symbol === cid or String === cid
          'self'
        elsif cid.type == :colon2
          expr(cid[1])
        elsif cid.type == :colon3
          '$opal.Object'
        else
          raise "Bad receiver in module"
        end
      end

      def module_name
        if Symbol === cid or String === cid
          cid.to_s
        elsif cid.type == :colon2
          cid[2].to_s
        elsif cid.type == :colon3
          cid[1].to_s
        else
          raise "Bad receiver in module"
        end
      end
    end
  end
end
