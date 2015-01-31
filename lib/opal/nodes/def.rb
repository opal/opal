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
        jsid = mid_to_jsid mid.to_s
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

          unshift "\n#{current_indent}", scope.to_vars
          line stmt_code

          unshift arity_code if arity_code

          unshift "var $zuper = $slice.call(arguments, 0);" if scope.uses_zuper

          if scope.catch_return
            unshift "try {\n"
            line "} catch ($returner) { if ($returner === Opal.returner) { return $returner.$v }"
            push " throw $returner; }"
          end
        end

        unshift ") {"
        unshift(params)
        unshift "function("
        unshift "#{scope_name} = " if scope_name
        line "}"

        if recvr
          unshift 'Opal.defs(', recv(recvr), ", '$#{mid}', "
          push ')'
        elsif uses_defn?(scope)
          wrap "Opal.defn(self, '$#{mid}', ", ')'
        elsif scope.class?
          unshift "#{scope.proto}#{jsid} = "
        elsif scope.sclass?
          unshift "self.$$proto#{jsid} = "
        elsif scope.top?
          unshift "Opal.Object.$$proto#{jsid} = "
        else
          unshift "def#{jsid} = "
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
          splat = variable(rest_arg[1].to_sym)
          line "#{splat} = $slice.call(arguments, #{argc});"
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
            line "if ((#{var_name} = $kwargs.smap['#{arg_name}']) == null) {"
            line "  #{var_name} = ", expr(kwarg[2])
            line "}"
          when :kwarg
            arg_name = kwarg[1]
            var_name = variable(arg_name.to_s)
            add_local var_name
            line "if ((#{var_name} = $kwargs.smap['#{arg_name}']) == null) {"
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

      # Simple helper to check whether this method should be defined through
      # `Opal.defn()` runtime helper.
      #
      # @param [Opal::Scope] scope
      # @returns [Boolean]
      #
      def uses_defn?(scope)
        if scope.iter? or scope.module?
          true
        elsif scope.class? and %w(Object BasicObject).include?(scope.name)
          true
        else
          false
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
          aritycode + "if ($arity < #{-(arity + 1)}) { Opal.ac($arity, #{arity}, this, #{meth}); }"
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
        children.each_with_index do |child, idx|
          next if :blockarg == child.first
          next if :restarg == child.first and child[1].nil?

          case child.first
          when :kwarg, :kwoptarg, :kwrestarg
            unless done_kwargs
              done_kwargs = true
              push ', ' unless idx == 0
              scope.add_arg '$kwargs'
              push '$kwargs'
            end
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
