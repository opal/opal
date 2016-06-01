require 'opal/nodes/base'

module Opal
  module Nodes
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

    class BeginNode < ScopeNode
      handle :begin

      def compile
        return push "nil" if children.empty?

        if stmt?
          compile_children(children, @level)
        elsif simple_children?
          compile_inline_children(children, @level)
          wrap '(', ')' if children.size > 1
        elsif children.size == 1
          compile_inline_children(returned_children, @level)
        else
          compile_children(returned_children, @level)
          wrap '(function() {', '})()'
        end
      end

      def returned_children
        @returned_children ||= begin
          *rest, last_child = *children
          if last_child
            rest + [compiler.returns(last_child)]
          else
            [s(:nil)]
          end
        end
      end

      def compile_children(children, level)
        children.each do |child|
          line process(child, level), ";"
        end
      end

      COMPLEX_CHILDREN = [:while, :while_post, :until, :until_post, :until, :js_return]

      def simple_children?
        children.none? do |child|
          COMPLEX_CHILDREN.include?(child.type)
        end
      end

      def compile_inline_children(children, level)
        children.each_with_index do |child, idx|
          push ', ' unless idx == 0
          push process(child, level)
        end
      end
    end

    class KwBeginNode < BeginNode
      handle :kwbegin
    end
  end
end
