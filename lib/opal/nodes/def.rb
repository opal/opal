require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    # FIXME: needs rewrite
    class DefNode < NodeWithArgs
      handle :def

      children :mid, :args, :stmts

      attr_accessor :block_arg

      def extract_block_arg
        *regular_args, last_arg = args.children
        if last_arg && last_arg.type == :blockarg
          @block_arg = last_arg.children[0]
          @sexp = @sexp.updated(nil, [
            mid,
            s(:args, *regular_args),
            stmts
          ])
        end
      end

      def compile
        extract_block_arg
        split_args

        inline_params = nil
        scope_name = nil

        # block name (&block)
        if block_arg
          block_name = block_arg
        end

        in_scope do
          scope.mid = mid
          scope.defs = true if @sexp.type == :defs

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
            add_local '$zuper_i'
            add_local '$zuper_ii'

            line "// Prepare super implicit arguments"
            line "for($zuper_i = 0, $zuper_ii = arguments.length, $zuper = new Array($zuper_ii); $zuper_i < $zuper_ii; $zuper_i++) {"
            line "  $zuper[$zuper_i] = arguments[$zuper_i];"
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

        #     This is a special utf8 char ---v
        function_name = valid_name?(mid) ? " ː#{mid}" : ''

        unshift ") {"
        unshift(inline_params)
        unshift "function#{function_name}("
        unshift "#{scope_name} = " if scope_name
        line "}"

        push ", #{scope_name}.$$arity = #{arity}"

        if compiler.arity_check?
          push ", #{scope_name}.$$parameters = #{parameters_code}"
        end

        wrap_with_definition
      end

      def wrap_with_definition
        if    scope.iter?                   then unshift "Opal.def(self, '$#{mid}', "
        elsif scope.module? || scope.class? then unshift "Opal.defn(self, '$#{mid}', "
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
