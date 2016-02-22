require 'opal/nodes/scope'

module Opal
  module Nodes
    # FIXME: needs rewrite
    class DefNode < ScopeNode
      handle :def

      children :recvr, :mid, :args, :stmts

      def opt_args
        @opt_args ||= args[1..-1].select { |arg| arg.first == :optarg }
      end

      def rest_arg
        @rest_arg ||= args[1..-1].find { |arg| arg.first == :restarg }
      end

      def keyword_args
        @keyword_args ||= args[1..-1].select do |arg|
          [:kwarg, :kwoptarg, :kwrestarg].include? arg.first
        end
      end

      def block_arg
        @block_arg ||= args[1..-1].find { |arg| arg.first == :blockarg }
      end

      def argc
        return @argc if @argc

        @argc = args.length - 1
        @argc -= 1 if block_arg
        @argc -= 1 if rest_arg
        @argc -= keyword_args.size

        @argc
      end

      def compile
        return if compiler.calls && !compiler.calls.include?(:mid)

        params = nil
        scope_name = nil

        # block name (&block)
        if block_arg
          block_name = variable(block_arg[1]).to_sym
        end

        if compiler.arity_check?
          arity_code = arity_check(args, opt_args, rest_arg, keyword_args, block_name, mid)
        end

        in_scope do
          scope.mid = mid
          scope.defs = true if recvr

          if block_name
            scope.uses_block!
            scope.add_arg block_name
          end

          scope.block_name = block_name || '$yield'

          params = process(args)
          stmt_code = stmt(compiler.returns(stmts))

          add_temp 'self = this'

          compile_rest_arg
          compile_opt_args
          compile_keyword_args

          # must do this after opt args incase opt arg uses yield
          scope_name = scope.identity

          compile_block_arg

          if rest_arg
            scope.locals.delete(rest_arg[1])
          end

          if scope.uses_zuper
            add_local '$zuper'
            add_local '$zuper_index'

            line "$zuper = [];"
            line "for($zuper_index = 0; $zuper_index < arguments.length; $zuper_index++) {"
            line "  $zuper[$zuper_index] = arguments[$zuper_index];"
            line "}"
          end

          unshift "\n#{current_indent}", scope.to_vars

          line arity_code if arity_code

          line stmt_code

          if scope.catch_return
            unshift "try {\n"
            line "} catch ($returner) { if ($returner === Opal.returner) { return $returner.$v }"
            push " throw $returner; }"
          end
        end

        unshift ") {"
        unshift(params)
        unshift "function #{function_name(mid)}("
        unshift "#{scope_name} = " if scope_name
        line "}"

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
        else
          raise "Unsupported use of `def`; please file a bug at https://github.com/opal/opal reporting this message."
        end

        wrap '(', ", nil) && '#{mid}'" if expr?
      end

      def compile_block_arg
        if scope.uses_block?
          scope_name  = scope.identity
          yielder     = scope.block_name

          add_temp "$iter = #{scope_name}.$$p"
          add_temp "#{yielder} = $iter || nil"

          line "#{scope_name}.$$p = null;"
        end
      end

      def compile_rest_arg
        if rest_arg and rest_arg[1]
          rest_var = variable(rest_arg[1].to_sym)
          add_temp '$rest_idx'
          add_temp "$rest_len = arguments.length - #{argc}"

          line "var #{rest_var} = new Array($rest_len > 0 ? $rest_len : 0);"
          line "if ($rest_len > 0) {"
          indent do
            line "for ($rest_idx = 0; $rest_idx < $rest_len; $rest_idx++) {"
            line "  #{rest_var}[$rest_idx] = arguments[$rest_idx + #{argc}];"
            line "}"
          end
          line '}'
        end
      end

      def compile_opt_args
        opt_args.each do |arg|
          next if arg[2][2] == :undefined
          line "if (#{variable(arg[1])} == null) {"
          line "  #{variable(arg[1])} = ", expr(arg[2])
          line "}"
        end
      end

      def compile_keyword_args
        return if keyword_args.empty?
        helper :hash2

        if rest_arg
          with_temp do |tmp|
            rest_arg_name = variable(rest_arg[1].to_sym)
            line "#{tmp} = #{rest_arg_name}[#{rest_arg_name}.length - 1];"
            line "if (#{tmp} == null || !#{tmp}.$$is_hash) {"
            line "  $kwargs = $hash2([], {});"
            line "} else {"
            line "  $kwargs = #{rest_arg_name}.pop();"
            line "}"
          end
        elsif last_opt_arg = opt_args.last
          opt_arg_name = variable(last_opt_arg[1])
          line "if (#{opt_arg_name} == null) {"
          line "  $kwargs = $hash2([], {});"
          line "}"
          line "else if (#{opt_arg_name}.$$is_hash) {"
          line "  $kwargs = #{opt_arg_name};"
          line "  #{opt_arg_name} = ", expr(last_opt_arg[2]), ";"
          line "}"
          line "else if ($kwargs == null) {"
          line "  $kwargs = $hash2([], {});"
          line "}"
        else
          line "if ($kwargs == null) {"
          line "  $kwargs = $hash2([], {});"
          line "}"
        end

        line "if (!$kwargs.$$is_hash) {"
        line "  throw Opal.ArgumentError.$new('expecting keyword args');"
        line "}"

        keyword_args.each do |kwarg|
          case kwarg.first
          when :kwoptarg
            arg_name = kwarg[1]
            var_name = variable(arg_name.to_s)
            add_local var_name
            line "if ((#{var_name} = $kwargs.$$smap['#{arg_name}']) == null) {"
            line "  #{var_name} = ", expr(kwarg[2])
            line "}"
          when :kwarg
            arg_name = kwarg[1]
            var_name = variable(arg_name.to_s)
            add_local var_name
            line "if ((#{var_name} = $kwargs.$$smap['#{arg_name}']) == null) {"
            line "  throw new Error('expecting keyword arg: #{arg_name}')"
            line "}"
          when :kwrestarg
            arg_name = kwarg[1]
            var_name = variable(arg_name.to_s)
            add_local var_name

            kwarg_names = keyword_args.select do |kw|
              [:kwoptarg, :kwarg].include? kw.first
            end.map { |kw| "#{kw[1].to_s.inspect}: true" }

            used_args = "{#{kwarg_names.join ','}}"
            line "#{var_name} = Opal.kwrestargs($kwargs, #{used_args});"
          else
            raise "unknown kwarg type #{kwarg.first}"
          end
        end
      end

      # Returns code used in debug mode to check arity of method call
      def arity_check(args, opt, splat, kwargs, block_name, mid)
        meth = mid.to_s.inspect

        arity = args.size - 1
        arity -= (opt.size)

        arity -= 1 if splat

        arity -= (kwargs.size)

        arity -= 1 if block_name
        arity = -arity - 1 if !opt.empty? or !kwargs.empty? or splat

        # $arity will point to our received arguments count
        aritycode = "var $arity = arguments.length;"

        if arity < 0 # splat or opt args
          min_arity = -(arity + 1)
          max_arity = args.size - 1
          max_arity -= 1 if block_name
          checks = []
          checks << "$arity < #{min_arity}" if min_arity > 0
          checks << "$arity > #{max_arity}" if max_arity and not(splat)
          aritycode + "if (#{checks.join(' || ')}) { Opal.ac($arity, #{arity}, this, #{meth}); }" if checks.size > 0
        else
          aritycode + "if ($arity !== #{arity}) { Opal.ac($arity, #{arity}, this, #{meth}); }"
        end
      end
    end

    # def args list
    class ArgsNode < Base
      handle :args

      def compile
        done_kwargs = false
        have_rest   = false

        children.each_with_index do |child, idx|
          case child.first
          when :kwarg, :kwoptarg, :kwrestarg
            unless done_kwargs
              done_kwargs = true
              push ', ' unless idx == 0 || have_rest
              scope.add_arg '$kwargs'
              push '$kwargs'
            end

          when :blockarg
            # we ignore it because we don't need it

          when :restarg
            have_rest = true

          else
            child = child[1].to_sym
            push ', ' unless idx == 0
            child = variable(child)
            scope.add_arg child.to_sym
            push child.to_s
          end
        end
      end
    end
  end
end
