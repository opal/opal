# frozen_string_literal: true

require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    class DefNode < NodeWithArgs
      handle :def

      children :mid, :inline_args, :stmts

      def compile
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

          stmt_code = stmt(compiler.returns(stmts))

          compile_block_arg

          add_temp 'self = this'

          compile_arity_check

          unshift "\n#{current_indent}", scope.to_vars

          line stmt_code

          if scope.catch_return
            unshift "try {\n"
            line '} catch ($returner) { if ($returner === Opal.returner) { return $returner.$v }'
            push ' throw $returner; }'
          end
        end

        # There are some special utf8 chars that can be used as valid JS
        # identifiers, some examples:
        #
        # utf8_pond = 'ⵌ'
        # utf8_question = 'ʔ̣'
        # utf8_exclamation 'ǃ'
        #
        # For now we're just using $$, to maintain compatibility with older IEs.
        function_name = valid_name?(mid) ? " $$#{mid}" : ''

        unshift ') {'
        unshift(inline_params)
        unshift "function#{function_name}("
        unshift "#{scope_name} = " if scope_name
        line '}'

        push ", #{scope_name}.$$arity = #{arity}"

        if compiler.arity_check?
          push ", #{scope_name}.$$parameters = #{parameters_code}"
        end

        if compiler.parse_comments?
          push ", #{scope_name}.$$comments = #{comments_code}"
        end

        if compiler.enable_source_location?
          push ", #{scope_name}.$$source_location = #{source_location}"
        end

        wrap_with_definition
      end

      def wrap_with_definition
        wrap "Opal.def(self, '$#{mid}', ", ')'

        if expr?
          wrap '(', ", nil) && '#{mid}'"
        else
          unshift "\n#{current_indent}"
        end
      end

      def comments_code
        '[' + comments.map { |comment| comment.text.inspect }.join(', ') + ']'
      end
    end
  end
end
