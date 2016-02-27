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
          value = child[1]
          statements = []
          if child[0] == :js_return
             value = value[1]
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

      children :new_name, :old_name

      def new_mid
        mid_to_jsid new_name[1].to_s
      end

      def old_mid
        mid_to_jsid old_name[1].to_s
      end

      def compile
        if compiler.optimize_calls && !compiler.optimize_calls.include?(new_name[1].to_sym)
          push "/* DCE: Opal.alias(self, '#{new_name[1]}', '#{old_name[1]}') */"
          return
        end

        compiler.method_calls << old_name[1].to_sym if record_method?

        if scope.class? or scope.module?
          scope.methods << "$#{new_name[1]}"
        end

        push "Opal.alias(self, '#{new_name[1]}', '#{old_name[1]}')"
      end

      def record_method?
        true
      end
    end

    class BeginNode < Base
      handle :begin

      children :body

      def compile
        if !stmt? and body.type == :block
          push stmt(compiler.returns(body))
          wrap '(function() {', '})()'
        else
          push process(body, @level)
        end
      end
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

    class BlockNode < Base
      handle :block

      def compile
        return push "nil" if children.empty?

        children.each_with_index do |child, idx|
          push stmt_join unless idx == 0

          if yasgn = find_inline_yield(child)
            push compiler.process(yasgn, @level)
            push ";"
          end

          push compiler.process(child, @level)
          push ";" if child_is_expr?(child)
        end
      end

      def stmt_join
        scope.class_scope? ? "\n\n#{current_indent}" : "\n#{current_indent}"
      end

      def child_is_expr?(child)
        raw_expression?(child) and [:stmt, :stmt_closure].include?(@level)
      end

      def raw_expression?(child)
        ![:xstr, :dxstr].include?(child.type)
      end

      # When a block sexp gets generated, any inline yields (i.e. yield
      # statements that are not direct members of the block) need to be
      # generated as a top level member. This is because if a yield
      # is returned by a break statement, then the method must return.
      #
      # As inline expressions in javascript cannot return, the block
      # must be rewritten.
      #
      # For example, a yield inside an array:
      #
      #     [1, 2, 3, yield(4)]
      #
      # Must be rewitten into:
      #
      #     tmp = yield 4
      #     [1, 2, 3, tmp]
      #
      # This rewriting happens on sexps directly.
      #
      # @param [Sexp] stmt sexps to (maybe) rewrite
      # @return [Sexp]
      def find_inline_yield(stmt)
        found = nil
        case stmt.first
        when :js_return
          if found = find_inline_yield(stmt[1])
            found = found[2]
          end
        when :array
          stmt[1..-1].each_with_index do |el, idx|
            if el.first == :yield
              found = el
              stmt[idx+1] = s(:js_tmp, '$yielded')
            end
          end
        when :call
          arglist = stmt[3]
          arglist[1..-1].each_with_index do |el, idx|
            if el.first == :yield
              found = el
              arglist[idx+1] = s(:js_tmp, '$yielded')
            end
          end
        end

        if found
          scope.add_temp '$yielded' unless scope.has_temp? '$yielded'
          s(:yasgn, '$yielded', found)
        end
      end
    end
  end
end
