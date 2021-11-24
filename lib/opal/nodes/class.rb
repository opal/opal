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
            compile_body
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
      end

      def super_code
        sup ? expr(sup) : 'null'
      end
    end
  end
end
