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

        if force_function_wrap?
          force_return!
        end

        if stmt?
          compile_plain_stmt_block
        elsif recv? || expr?
          if contains_only_simple_nodes?
            compile_expr_block
          else
            wrap_with_function do
              force_return!
              compiler_closure_stmt_block
            end
          end
        end
      end

      def force_return!
        @sexp = @sexp.updated(nil,
          children[0..-2] + [compiler.returns(children.last)]
        )
      end

      def compile_plain_stmt_block
        children.each do |child|
          line stmt(child), ';'
        end
      end

      def compiler_closure_stmt_block
        children.each do |child|
          child = child.updated(nil, nil, meta: { closure: true })
          line stmt(child), ';'
        end
      end

      def compile_expr_block
        if children == [s(:next)]
          push expr(children.first)
          return
        end

        children.each_with_index do |child, idx|
          push ',' unless idx == 0
          push expr(child)
        end

        wrap '(', ')'
      end

      ALWAYS_WRAPPABLE_NODES = %i(return js_return rescue if while while_post until until_post ensure)

      def force_function_wrap?
        @sexp.meta[:force_function_wrap]
      end

      def contains_only_simple_nodes?
        children.each do |child|
          case child.type
          when *ALWAYS_WRAPPABLE_NODES, :begin, :kwbegin
            return false
          end
        end

        true
      end
    end

    class KwBeginNode < BeginNode
      handle :kwbegin
    end
  end
end
