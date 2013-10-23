require 'opal/nodes/base'

module Opal
  module Nodes

    class SvalueNode < Node
      handle :svalue

      children :value

      def compile
        push process(value, @level)
      end
    end

    # :scope nodes are actually inside scopes (e.g. :module, :class).
    # These are not actually the scopes themselves.
    class ScopeNode < Node
      handle :scope

      children :body

      def compile
        body = self.body || s(:nil)
        body = compiler.returns(body) unless scope.class_scope?
        push stmt(body)
      end
    end

    class UndefNode < Node
      handle :undef

      children :mid

      # FIXME: we should be setting method to a stub method here
      def compile
        push "delete #{scope.proto}#{mid_to_jsid mid[1].to_s}"
      end
    end

    class AliasNode < Node
      handle :alias

      children :new_name, :old_name

      def new_mid
        mid_to_jsid new_name[1].to_s
      end

      def old_mid
        mid_to_jsid old_name[1].to_s
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

    class ParenNode < Node
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

    class RescueModNode < Node
      handle :rescue_mod

      children :lhs, :rhs

      def body
        stmt? ? lhs : compiler.returns(lhs)
      end

      def rescue_val
        stmt? ? rhs : compiler.returns(rhs)
      end

      def compile
        push "try {", expr(body), " } catch ($err) { ", expr(rescue_val), " }"

        wrap '(function() {', '})()' unless stmt?
      end
    end

    class BlockNode < Node
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

    class WhileNode < Node
      handle :while

      children :test, :body

      def compile
        with_temp do |redo_var|
          test_code = js_truthy(test)

          compiler.in_while do
            while_loop[:closure] = true if wrap_in_closure?
            while_loop[:redo_var] = redo_var

            body_code = stmt(body)

            if uses_redo?
              push "#{redo_var} = false; #{while_open}#{redo_var} || "
              push test_code
              push while_close
            else
              push while_open, test_code, while_close
            end

            push "#{redo_var} = false;" if uses_redo?
            line body_code, "}"
          end
        end

        wrap '(function() {', '; return nil; })()' if wrap_in_closure?
      end

      def while_open
        "while ("
      end

      def while_close
        ") {"
      end

      def uses_redo?
        while_loop[:use_redo]
      end

      def wrap_in_closure?
        expr? or recv?
      end
    end

    class UntilNode < WhileNode
      handle :until

      def while_open
        "while (!("
      end

      def while_close
        ")) {"
      end
    end
  end
end
