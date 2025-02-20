# frozen_string_literal: true

require 'opal/nodes/module'

module Opal
  module Nodes
    class ClassNode < ModuleNode
      handle :class

      children :cid, :sup, :body

      def compile
        name, base = name_and_base
        helper :klass_def

        if body.nil?
          # Empty body: rely on runtime $klass_def (no callback) to return nil
          unshift '$klass_def(', base, ', ', super_code, ", '#{name}')"
        else
          in_scope do
            scope.name = name
            in_closure(Closure::MODULE | Closure::JS_FUNCTION) do
              compile_body
            end
          end

          if await_encountered
            await_begin = '(await '
            await_end = ')'
            async = 'async '
            parent.await_encountered = true
          end

          # Emit a direct runtime call with an inline body function.
          unshift "#{await_begin}$klass_def(", base, ', ', super_code, ", '#{name}', #{async}function(self#{', $nesting' if @define_nesting}) {"
          line "}#{", #{scope.nesting}" if @define_nesting})#{await_end}"
        end

        forbid_dce_if_bridged
        mark_dce(name)
      end

      def super_code
        sup ? expr(sup) : 'null'
      end

      def bridged?
        sup&.type == :xstr
      end

      def forbid_dce_if_bridged
        push dce_use(name, type: :*, force: true) if bridged?
      end
    end
  end
end
