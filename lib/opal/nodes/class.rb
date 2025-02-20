# frozen_string_literal: true

require 'opal/nodes/module'

module Opal
  module Nodes
    class ClassNode < ModuleNode
      handle :class

      children :cid, :sup, :body

      def compile
        name, base = name_and_base
        helper :klass

        if body.nil?
          # Simplified compile for empty body
          if stmt?
            unshift '$klass(', base, ', ', super_code, ", '#{name}')"
          else
            unshift '($klass(', base, ', ', super_code, ", '#{name}'), nil)"
          end
        else
          line "  var self = $klass($base, $super, '#{name}');"
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
          else
            await_begin, await_end, async = '', '', ''
          end

          unshift "#{await_begin}(#{async}function($base, $super#{', $parent_nesting' if @define_nesting}) {"
          line '})(', base, ', ', super_code, "#{', ' + scope.nesting if @define_nesting})#{await_end}"
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
