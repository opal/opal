# frozen_string_literal: true

require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    class DefNode < NodeWithArgs
      handle :def

      children :mid, :inline_args, :stmts

      def compile
        compile_body_or_shortcut

        blockopts = {}

        blockopts["$$arity"] = arity if arity < 0

        if compiler.arity_check?
          blockopts["$$parameters"] = parameters_code
        end

        if compiler.parse_comments?
          blockopts["$$comments"] = comments_code
        end

        if compiler.enable_source_location?
          blockopts["$$source_location"] = source_location
        end

        if compiler.pristine?
          blockopts["$$pristine"] = true
        end

        if blockopts.keys == ["$$arity"]
          push ", #{arity}"
        elsif !blockopts.empty?
          push ', {', blockopts.map { |k, v| "#{k}: #{v}" }.join(', '), '}'
        end

        wrap_with_definition

        scope.nesting if @define_nesting
        scope.relative_access if @define_relative_access
      end

      def compile_body
        inline_params = nil
        scope_name = nil

        in_scope do
          scope.mid = mid
          scope.defs = true if @sexp.type == :defs

          scope.identify!
          scope_name = scope.identity

          # Setting a default block name (later can be overwritten by a blockarg)
          scope.block_name = '$yield'

          inline_params = process(inline_args)

          in_closure(Closure::DEF | Closure::JS_FUNCTION) do
            stmt_code = stmt(compiler.returns(stmts))

            compile_block_arg

            add_temp 'self = this' if @define_self

            compile_arity_check

            unshift "\n#{current_indent}", scope.to_vars

            line stmt_code
          end
        end

        unshift ') {'
        unshift(inline_params)
        unshift "function #{scope_name}("
        if await_encountered
          unshift "async "
        end
        line '}'
      end

      def wrap_with_definition
        helper :def
        wrap "$def(#{scope.self}, '$#{mid}', ", ')'

        unshift "\n#{current_indent}" unless expr?
      end

      def comments_code
        '[' + comments.map { |comment| comment.text.inspect }.join(', ') + ']'
      end
    end
  end
end
