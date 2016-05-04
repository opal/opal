require 'opal/nodes/base'

module Opal
  module Nodes

    class SvalueNode < Base
      handle :svalue

      children :value

      def compile
        push process(value, @level)
      end
    end

    class UndefNode < Base
      handle :undef

      def compile
        children.each do |child|
          value = child.children[0]
          statements = []
          if child.type == :js_return
             value = value.children[0]
             statements << expr(s(:js_return))
          end
          statements << "Opal.udef(self, '$#{value.to_s}');"
          if children.length > 1 && child != children.first
            line *statements
          else
            push *statements
          end
        end
      end
    end

    class AliasNode < Base
      handle :alias

      children :new_name_sexp, :old_name_sexp

      def new_name
        new_name_sexp.children[0].to_s
      end

      def old_name
        old_name_sexp.children[0].to_s
      end

      def compile
        if scope.class? or scope.module?
          scope.methods << "$#{new_name}"
        end

        push "Opal.alias(self, '#{new_name}', '#{old_name}')"
      end
    end

    class BeginNode < Base
      handle :begin

      def compile
        return push "nil" if children.empty?
        if !stmt?
          compile_body
          wrap '(function() {', '})()'
        else
          compile_body
        end
      end

      def compile_body
        children[0..-2].each do |child|
          line stmt(child), ';'
        end

        line stmt(compiler.returns(children.last))
      end
    end

    class KwBeginNode < BeginNode
      handle :kwbegin
    end

    class ParenNode < Base
      handle :paren

      children :body

      def compile
        if body.type == :block
          body.children.each_with_index do |child, idx|
            push ', ' unless idx == 0
            push expr(child)
          end

          wrap '(', ')'
        else
          push process(body, @level)
          wrap '(', ')' unless stmt?
        end
      end
    end
  end
end
