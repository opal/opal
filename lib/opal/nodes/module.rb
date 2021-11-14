# frozen_string_literal: true

require 'opal/nodes/scope'

module Opal
  module Nodes
    class ModuleNode < ScopeNode
      handle :module

      children :cid, :body

      def compile
        name, base = name_and_base
        helper :module

        if body.nil?
          # Simplified compile for empty body
          if stmt?
            unshift '$module(', base, ", '#{name}')"
          else
            unshift '($module(', base, ", '#{name}'), nil)"
          end
        else
          line "  var self = $module($base, '#{name}');"
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

          unshift "#{await_begin}(#{async}function($base, $parent_nesting) {"
          line '})(', base, ", #{scope.nesting})#{await_end}"
        end
      end

      private

      # cid is always s(:const, scope_sexp_or_nil, :ConstName)
      def name_and_base
        base, name = cid.children

        if base.nil?
          [name, "#{scope.nesting}[0]"]
        else
          [name, expr(base)]
        end
      end

      def compile_body
        body_code = stmt(compiler.returns(body))
        empty_line

        add_temp "$nesting = [self].concat($parent_nesting)" if @define_nesting
        add_temp '$$ = Opal.$r($nesting)' if @define_relative_access

        line scope.to_vars
        line body_code
      end
    end
  end
end
