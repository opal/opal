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
        args = self.args[1..-1]
        args.each_with_index do |arg, idx|
          last_argument = (idx == args.length - 1)
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

        inline_args.each do |inline_arg|
          inline_arg.meta[:inline] = true
        end

        optimize_args!
      end

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

      def inline_args_sexp
        s(:inline_args, *args[1..-1])
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

          line "#{scope_name}.$$p = null;"
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
    end
  end
end
