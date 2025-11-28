# frozen_string_literal: true

require 'opal/nodes/scope'

module Opal
  module Nodes
    class ModuleNode < ScopeNode
      handle :module

      children :cid, :body

      def compile
        if compiler.runtime_mode?
          # Skip class/module generation

          line stmt(body)
          return
        end

        name, base = name_and_base
        helper :module_def

        if body.nil?
          # Empty body: runtime $module_def without a callback returns nil
          unshift '$module_def(', base, ", '#{name}')"
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
          unshift "#{await_begin}$module_def(", base, ", '#{name}', #{async}function(self#{', $nesting' if @define_nesting}) {"
          line "}#{", #{scope.nesting}" if @define_nesting})#{await_end}"
        end

        mark_dce(name)
      end

      private

      # cid is always s(:const, scope_sexp_or_nil, :ConstName)
      def name_and_base
        base, name = cid.children

        base = if base.nil?
                 case scope
                 when ModuleNode, ClassNode
                   scope.self
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

        # $nesting is now provided as a parameter to the body callback by
        # $klass_def/$module_def. Just setup relative access when needed.
        add_temp '$$ = Opal.$r($nesting)' if @define_relative_access

        line scope.to_vars
        line body_code
      end

      def mark_dce(name)
        unshift dce_def_begin(name, type: :const)
        push dce_def_end(name, type: :const)
      end
    end
  end
end
