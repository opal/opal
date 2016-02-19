require 'opal/nodes/scope'

module Opal
  module Nodes
    class NodeWithArgs < ScopeNode
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

      def args_before_rest
        args[1..-1] - args_after_rest - [rest_arg] - [block_arg]
      end

      def args_after_rest
        scope.args_after_rest_args
      end

      def compile_rest_arg
        if rest_arg and rest_arg[1]
          rest_var = variable(rest_arg[1].to_sym)
          add_temp '$rest_idx'
          add_temp "$rest_start = #{args_before_rest.size}"
          args_after_rest_size = (args_after_rest - keyword_args).size
          add_temp "$rest_len = arguments.length - #{args_after_rest_size} - $rest_start"

          line "var #{rest_var} = new Array($rest_len > 0 ? $rest_len : 0);"
          line "if ($rest_len > 0) {"
          indent do
            line "for ($rest_idx = 0; $rest_idx < $rest_len; $rest_idx++) {"
            line "  #{rest_var}[$rest_idx] = arguments[$rest_idx + $rest_start];"
            line "}"
          end

          # compile_keyword_args is responsible for compiling kwargs
          post_rest_args = args_after_rest - keyword_args
          post_rest_args.each_with_index do |arg, idx|
            arg_name = variable(arg[1])
            add_temp "#{arg_name} = arguments[$rest_len + #{idx} + 2]"
          end
          line '}'
        end
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
          rest_arg_name = variable(rest_arg[1].to_sym)
          add_temp "$kwargs"

          with_temp do |tmp|
            line "#{tmp} = #{rest_arg_name}[#{rest_arg_name}.length - 1];"
            line "if (#{tmp} == null || !#{tmp}.$$is_hash) {"
            line "  $kwargs = $hash2([], {});"
            line "} else {"
            line "  $kwargs = #{rest_arg_name}.pop();"
            line "}"
          end
        elsif opt_args && last_opt_arg = opt_args.last
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
            line "  throw Opal.ArgumentError.$new('expecting keyword arg: #{arg_name}')"
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
    end
  end
end
