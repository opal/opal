require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    # FIXME: needs rewrite
    class DefNode < NodeWithArgs
      handle :def

      children :recvr, :mid, :args, :stmts

      attr_accessor :block_arg

      def extract_block_arg
        if args.last.is_a?(Sexp) && args.last.type == :blockarg
          @block_arg = args.pop[1]
        end
      end

      def compile
        extract_block_arg
        split_args

        inline_params = nil
        scope_name = nil

        # block name (&block)
        if block_arg
          block_name = variable(block_arg).to_sym
        end

        in_scope do
          scope.mid = mid
          scope.defs = true if recvr

          if block_name
            scope.uses_block!
            scope.add_arg block_name
          end

          scope.block_name = block_name || '$yield'

          inline_params = process(inline_args_sexp)
          stmt_code = stmt(compiler.returns(stmts))

          add_temp 'self = this'

          compile_inline_args
          compile_post_args

          scope.identify!
          scope_name = scope.identity

          compile_block_arg

          if compiler.arity_check?
            compile_arity_check
          end

          if scope.uses_zuper
            add_local '$zuper'
            add_local '$zuper_index'
            add_local '$zuper_length'

            line "$zuper = [];"
            line
            line "for($zuper_index = 0; $zuper_index < arguments.length; $zuper_index++) {"
            line "  $zuper[$zuper_index] = arguments[$zuper_index];"
            line "}"
          end

          unshift "\n#{current_indent}", scope.to_vars

          line stmt_code

          if scope.catch_return
            unshift "try {\n"
            line "} catch ($returner) { if ($returner === Opal.returner) { return $returner.$v }"
            push " throw $returner; }"
          end
        end

        # There are some special utf8 chars that can be used as valid JS
        # identifiers, some examples:
        #
        # utf8_pond = 'ⵌ'
        # utf8_question = 'ʔ̣'
        # utf8_exclamation 'ǃ'
        #
        # For now we're just using $, to maintain compatibility with older IEs.
        function_name = valid_name?(mid) ? " $$#{mid}" : ''

        unshift ") {"
        unshift(inline_params)
        unshift "function#{function_name}("
        unshift "#{scope_name} = " if scope_name
        line "}"

        push ", #{scope_name}.$$arity = #{arity}"

        if compiler.arity_check?
          push ", #{scope_name}.$$parameters = #{parameters_code}"
        end

        if    recvr                         then unshift 'Opal.defs(', recv(recvr), ", '$#{mid}', "
        elsif scope.iter?                   then unshift "Opal.def(self, '$#{mid}', "
        elsif scope.module? || scope.class? then unshift "Opal.defn(self, '$#{mid}', "
        elsif scope.sclass? && scope.defs   then unshift "Opal.defs(self, '$#{mid}', "
        elsif scope.sclass?                 then unshift "Opal.defn(self, '$#{mid}', "
        elsif compiler.eval?                then unshift "Opal.def(self, '$#{mid}', "
        elsif scope.top?                    then unshift "Opal.defn(Opal.Object, '$#{mid}', "
        elsif scope.def?                    then unshift "Opal.def(self, '$#{mid}', "
        else raise "Unsupported use of `def`; please file a bug at https://github.com/opal/opal/issues/new reporting this message."
        end
        push ')'

        wrap '(', ", nil) && '#{mid}'" if expr?
      end

      # Returns code used in debug mode to check arity of method call
      def compile_arity_check
        if arity_checks.size > 0
          meth = scope.mid.to_s.inspect
          line "var $arity = arguments.length;"
          push " if (#{arity_checks.join(' || ')}) { Opal.ac($arity, #{arity}, this, #{meth}); }"
        end
      end
    end
  end
end
