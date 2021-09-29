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

        unshift "#{await_begin}(#{async}function($base, $super, $parent_nesting) {"
        line '})(', base, ', ', super_code, ", $nesting)#{await_end}"
      end

      def super_code
        sup ? expr(sup) : 'null'
      end
    end
  end
end
