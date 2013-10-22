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

    class UndefNode < Node
      children :mid

      # FIXME: we should be setting method to a stub method here
      def compile
        push "delete #{scope.proto}#{@parser.mid_to_jsid mid[1].to_s}"
      end
    end

    class AliasNode < Node
      children :new_name, :old_name

      def new_mid
        @parser.mid_to_jsid new_name[1].to_s
      end

      def old_mid
        @parser.mid_to_jsid old_name[1].to_s
      end

      def compile
        if scope.class? or scope.module?
          scope.methods << "$#{new_name[1]}"
          push "$opal.defn(self, '$#{new_name[1]}', #{scope.proto}#{old_mid})"
        else
          push "self._proto#{new_mid} = self._proto#{old_mid}"
        end
      end
    end

    class BeginNode < Node
      children :body

      def compile
        if !stmt? and body.type == :block
          push stmt(@parser.returns(body))
          wrap '(function() {', '})()'
        else
          push @parser.process(body, @level)
        end
      end
    end

    class ParenNode < Node
      children :body

      def compile
        if body.type == :block
          body.children.each_with_index do |child, idx|
            push ', ' unless idx == 0
            push expr(child)
          end

          wrap '(', ')'
        else
          push @parser.process(body, @level)
          wrap '(', ')' unless stmt?
        end
      end
    end

    class RescueModNode < Node
      children :lhs, :rhs

      def body
        stmt? ? lhs : @parser.returns(lhs)
      end

      def rescue_val
        stmt? ? rhs : @parser.returns(rhs)
      end

      def compile
        push "try {", expr(body), " } catch ($err) { ", expr(rescue_val), " }"

        wrap '(function() {', '})()' unless stmt?
      end
    end
  end
end
