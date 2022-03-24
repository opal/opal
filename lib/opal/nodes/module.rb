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
          if stmt? || compressed?
            push '$module(', base, ", '#{name}')"
          else
            push '($module(', base, ", '#{name}'), nil)"
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

          unshift "#{await_begin}(#{async}function($base#{', $parent_nesting' if @define_nesting}) {"
          line '})(', base, "#{', ' + scope.nesting if @define_nesting})#{await_end}"
        end

        handle_compressed_scope_variables
      end

      private

      # cid is always s(:const, scope_sexp_or_nil, :ConstName)
      def name_and_base
        base, name = cid.children

        base = if base.nil?
                 if has_compressed_parent_scopes?
                   temp = scope.new_temp
                   parent_scope = compressed_parent_scopes.first
                   parent_scope.meta[:compressed_scope_temp_var] = temp
                   expr(parent_scope)
                 else
                   "#{scope.nesting}[0]"
                 end
               else
                 expr(base)
               end

        [name, base]
      end

      def compile_body
        body_code = stmt(compiler.returns(body))
        empty_line

        if @define_nesting
          if has_compressed_parent_scopes?
            other_nestings = ''
            compressed_parent_scopes.each do |parent_scope|
              temp_var = parent_scope.meta[:compressed_scope_temp_var]
              other_nestings += ", #{temp_var}"
            end
          end

          add_temp "$nesting = [self#{other_nestings}].concat($parent_nesting)"
        end
        add_temp '$$ = Opal.$r($nesting)' if @define_relative_access

        line scope.to_vars
        line body_code
      end

      # Utility function for simplified compilation.
      # This is facilitated by the CompressNestedScopes rewriter.
      def compressed?
        sexp.meta[:compressed]
      end

      def has_compressed_parent_scopes?
        !sexp.meta[:parent_scopes].nil?
      end

      def compressed_parent_scopes
        sexp.meta[:parent_scopes]
      end

      def compressed_scope_temp_var
        sexp.meta[:compressed_scope_temp_var]
      end

      def handle_compressed_scope_variables
        if compressed?
          unshift "#{compressed_scope_temp_var} = "
        elsif has_compressed_parent_scopes?
          compressed_parent_scopes.reverse_each do |parent_scope|
            temp_var = parent_scope.meta[:compressed_scope_temp_var]
            scope.queue_temp(temp_var)
          end
        end
      end
    end
  end
end
