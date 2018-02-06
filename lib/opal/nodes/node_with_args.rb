# frozen_string_literal: true

require 'opal/nodes/scope'

module Opal
  module Nodes
    class NodeWithArgs < ScopeNode
      attr_accessor :mlhs_args
      attr_accessor :used_kwargs
      attr_accessor :mlhs_mapping
      attr_accessor :working_arguments
      attr_writer :inline_args
      attr_accessor :kwargs_initialized

      attr_reader :inline_args, :post_args

      def initialize(*)
        super

        @mlhs_args = {}
        @used_kwargs = []
        @mlhs_mapping = {}
        @working_arguments = nil
        @in_mlhs = false
        @kwargs_initialized = false

        @inline_args = []
        @post_args = []

        @post_args_started = false
      end

      def split_args
        args = self.args.children
        args.each_with_index do |arg, idx|
          case arg.type
          when :arg, :mlhs, :kwarg, :kwoptarg, :kwrestarg
            if @post_args_started
              @post_args << arg
            else
              @inline_args << arg
            end
          when :restarg
            @post_args_started = true
            @post_args << arg
          when :optarg
            if args[idx, args.length].any? { |next_arg| next_arg.type != :optarg && next_arg.type != :restarg }
              @post_args_started = true
            end
            # otherwise we have:
            #   a. ... + optarg + [optargs]
            #   b. ... + optarg + [optargs] + restarg
            # and these cases are simple, we can handle args in inline mode

            if @post_args_started
              @post_args << arg
            else
              @inline_args << arg
            end
          end
        end

        inline_args.map! do |inline_arg|
          inline_arg.updated(nil, nil, meta: { inline: true })
        end

        optimize_args!
      end

      def opt_args
        @opt_args ||= args.children.select { |arg| arg.type == :optarg }
      end

      def rest_arg
        @rest_arg ||= args.children.find { |arg| arg.type == :restarg }
      end

      def keyword_args
        @keyword_args ||= args.children.select do |arg|
          [:kwarg, :kwoptarg, :kwrestarg].include? arg.type
        end
      end

      def inline_args_sexp
        s(:inline_args, *args.children)
      end

      def post_args_sexp
        s(:post_args, *post_args)
      end

      def compile_inline_args
        inline_args.each do |inline_arg|
          push process(inline_arg)
        end
      end

      def compile_post_args
        push process(post_args_sexp)
      end

      def compile_block_arg
        if scope.uses_block?
          scope_name  = scope.identity
          yielder     = scope.block_name

          add_temp "$iter = #{scope_name}.$$p"
          add_temp "#{yielder} = $iter || nil"

          line "if ($iter) #{scope_name}.$$p = null;"
        end
      end

      def with_inline_args(args)
        old_inline_args = inline_args
        self.inline_args = args
        yield
        self.inline_args = old_inline_args
      end

      def in_mlhs
        old_mlhs = @in_mlhs
        @in_mlhs = true
        yield
        @in_mlhs = old_mlhs
      end

      def in_mlhs?
        @in_mlhs
      end

      def optimize_args!
        # Simple cases like def m(a,b,*rest) can be processed inline
        if post_args.length == 1 && post_args.first.type == :restarg
          rest_arg = post_args.pop
          rest_arg.meta[:offset] = inline_args.length
          inline_args << rest_arg
        end
      end

      def has_only_optional_kwargs?
        keyword_args.any? && keyword_args.all? { |arg| [:kwoptarg, :kwrestarg].include?(arg.type) }
      end

      def has_required_kwargs?
        keyword_args.any? { |arg| arg.type == :kwarg }
      end

      def arity
        if rest_arg || opt_args.any? || has_only_optional_kwargs?
          negative_arity
        else
          positive_arity
        end
      end

      def negative_arity
        required_plain_args = args.children.select do |arg|
          [:arg, :mlhs].include?(arg.type)
        end

        result = required_plain_args.size

        if has_required_kwargs?
          result += 1
        end

        result = -result - 1

        result
      end

      def positive_arity
        result = args.children.size

        result -= keyword_args.size
        result += 1 if keyword_args.any?

        result
      end

      def build_parameter(parameter_type, parameter_name)
        if parameter_name
          "['#{parameter_type}', '#{parameter_name}']"
        else
          "['#{parameter_type}']"
        end
      end

      SEXP_TO_PARAMETERS = {
        arg: :req,
        mlhs: :req,
        optarg: :opt,
        restarg: :rest,
        kwarg: :keyreq,
        kwoptarg: :key,
        kwrestarg: :keyrest
      }

      def parameters_code
        stringified_parameters = args.children.map do |arg|
          value = arg.type == :mlhs ? nil : arg.children[0]
          build_parameter(SEXP_TO_PARAMETERS[arg.type], value)
        end

        if block_arg
          stringified_parameters << "['block', '#{block_arg}']"
        end

        "[#{stringified_parameters.join(', ')}]"
      end

      # Returns an array of JS conditions for raising and argument
      # error caused by arity check
      def arity_checks
        return @arity_checks if defined?(@arity_checks)

        arity = args.children.size
        arity -= (opt_args.size)

        arity -= 1 if rest_arg

        arity -= (keyword_args.size)

        arity = -arity - 1 if !opt_args.empty? or !keyword_args.empty? or rest_arg

        @arity_checks = []

        if arity < 0 # splat or opt args
          min_arity = -(arity + 1)
          max_arity = args.children.size
          @arity_checks << "$arity < #{min_arity}" if min_arity > 0
          @arity_checks << "$arity > #{max_arity}" if max_arity and not(rest_arg)
        else
          @arity_checks << "$arity !== #{arity}"
        end

        @arity_checks
      end
    end
  end
end
