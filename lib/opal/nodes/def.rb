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

          if compiler.arity_check?
            arity_code = arity_check(mid)
          end

          scope_name = scope.identity

          compile_block_arg

          line arity_code if arity_code

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

        if recvr
          unshift 'Opal.defs(', recv(recvr), ", '$#{mid}', "
          push ')'
        elsif scope.iter?
          wrap "Opal.def(self, '$#{mid}', ", ')'
        elsif scope.module? || scope.class?
          wrap "Opal.defn(self, '$#{mid}', ", ')'
        elsif scope.sclass?
          if scope.defs
            unshift "Opal.defs(self, '$#{mid}', "
          else
            unshift "Opal.defn(self, '$#{mid}', "
          end
          push ')'
        elsif compiler.eval?
          unshift "Opal.def(self, '$#{mid}', "
          push ')'
        elsif scope.top?
          unshift "Opal.defn(Opal.Object, '$#{mid}', "
          push ')'
        elsif scope.def?
          wrap "Opal.def(self, '$#{mid}', ", ')'
        else
          raise "Unsupported use of `def`; please file a bug at https://github.com/opal/opal reporting this message."
        end

        wrap '(', ", nil) && '#{mid}'" if expr?
      end

      # Returns code used in debug mode to check arity of method call
      def arity_check(mid)
        meth = mid.to_s.inspect

        arity = args.size - 1
        arity -= (opt_args.size)

        arity -= 1 if rest_arg

        arity -= (keyword_args.size)

        arity = -arity - 1 if !opt_args.empty? or !keyword_args.empty? or rest_arg

        # $arity will point to our received arguments count
        aritycode = "var $arity = arguments.length;"

        if arity < 0 # splat or opt args
          min_arity = -(arity + 1)
          max_arity = args.size - 1
          checks = []
          checks << "$arity < #{min_arity}" if min_arity > 0
          checks << "$arity > #{max_arity}" if max_arity and not(rest_arg)
          aritycode + "if (#{checks.join(' || ')}) { Opal.ac($arity, #{arity}, this, #{meth}); }" if checks.size > 0
        else
          aritycode + "if ($arity !== #{arity}) { Opal.ac($arity, #{arity}, this, #{meth}); }"
        end
      end
    end
  end
end
