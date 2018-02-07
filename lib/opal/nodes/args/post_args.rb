# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    # Node responsible for extracting post-splat args
    # 1. There can be some arguments after the splat, this is why this node exist.
    #    In this case if:
    #     a. JS arguments length > args sexp length - then our splat has some items
    #        and we know how many of them should come to splat
    #     b. JS arguments length < args sexp length - then our splat is blank
    #
    # 2. Super important:
    #    a) optional arg always goes BEFORE the rest arg
    #    b) optional args always appear in the sequence (i.e. you can't have def m(a=1,b,c=1))
    #    c) precedence order:
    #         1. required arg (norm arg, mlhs arg)
    #         2. optional argument (optarg)
    #         3. splat/rest argument (restarg)
    #    These statements simplify everything, keep them in mind.
    # 3. post_args here _always_ have the same structure:
    #    1. list of required arguments (only for mlhs, can be blank)
    #    2. list of optargs (only for post-args, can be blank)
    #    3. restarg (for both mlhs/post-args, can be nil)
    #    4. list of required args (for both mlhs/post-args, can be blank)
    #
    class PostArgsNode < Base
      handle :post_args

      # kwargs contains the list of all post-kw* arguments
      # all of them can be processed in the first oder
      attr_reader :kwargs

      # required_left_args contains the list of required post args
      # like normarg or mlhs
      # For post-args: always blank (post args always start with optarg/restarg)
      # For mlhs: can be provided from
      #   mlhs = (a, b, c)
      #   required_left_args = [(:arg, :a), (:arg, :b)]
      attr_reader :required_left_args

      # optargs contains the list of optarg arguments
      # all of them must be populated depending on the "arguments.length"
      # if we have enough arguments - we fill them,
      # if not - we populate it with its default value
      # For post-args: can be provided from
      #   def m(a=1, *b)
      #   post-args = [(:optarg, :a, (:int, 1)), (:restarg, :b)]
      #   optargs = [(:optarg, :a, (:int, 1))]
      # For mlhs: always blank
      attr_reader :optargs

      # returns a restarg sexp
      # if we have enough "arguments" - we fill it
      # if not - we populate it with "[]"
      # For post-args: can be provided from
      #   def m(a=1, *b)
      #   post-args = [(:optarg, :a, (:int, 1)), (:restarg, :b)]
      #   restarg (:restarg, :b)
      attr_reader :restarg

      # required_right_args contains the list of required post args
      # like normarg and mlhs arg
      # For post-args: can be provided from
      #   def m(a=1,*b,c)
      #   post-args = [(:optarg, :a, (:int, 1)), (:restarg, :b), (:arg, :c)]
      #   required_right_args = [(:arg, :c)]
      # For mlhs: can be provided from
      #   (*a, b)
      #   required_right_args = [(:arg, :b)]
      attr_reader :required_right_args

      def initialize(*)
        super

        @kwargs = []
        @required_left_args = []
        @optargs = []
        @restarg = nil
        @required_right_args = []
      end

      def extract_arguments
        found_opt_or_rest = false

        children.each do |arg|
          arg.meta[:post] = true

          case arg.type
          when :kwarg, :kwoptarg, :kwrestarg
            @kwargs << arg
          when :restarg
            @restarg = arg
            found_opt_or_rest = true
          when :optarg
            @optargs << arg
            found_opt_or_rest = true
          when :arg, :mlhs
            if found_opt_or_rest
              @required_right_args << arg
            else
              @required_left_args << arg
            end
          end
        end
      end

      def compile
        return if children.empty?

        old_working_arguments = scope.working_arguments

        if @sexp.meta[:js_source]
          js_source = @sexp.meta[:js_source]
          scope.working_arguments = "#{js_source}_args"
        else
          js_source = 'arguments'
          scope.working_arguments = '$post_args'
        end

        add_temp "#{scope.working_arguments}"
        line "#{scope.working_arguments} = Opal.slice.call(#{js_source}, #{scope.inline_args.size}, #{js_source}.length);"

        extract_arguments

        push process(kwargs_sexp)

        required_left_args.each do |arg|
          compile_required_arg(arg)
        end

        optargs.each do |optarg|
          compile_optarg(optarg)
        end

        compile_restarg

        required_right_args.each do |arg|
          compile_required_arg(arg)
        end

        scope.working_arguments = old_working_arguments
      end

      def compile_optarg(optarg)
        var_name, = *optarg
        add_temp var_name

        line "if (#{required_right_args.size} < #{scope.working_arguments}.length) {"
        indent do
          line "#{var_name} = #{scope.working_arguments}.splice(0,1)[0];"
        end
        line '}'
        push process(optarg)
      end

      def compile_required_arg(arg)
        push process(arg)
      end

      def compile_restarg
        return unless restarg

        line "if (#{required_right_args.size} < #{scope.working_arguments}.length) {"
        indent do
          # there are some items coming to the splat, extracting them
          extract_restarg
        end
        line '} else {'
        indent do
          # splat is empty
          extract_blank_restarg
        end
        line '}'
      end

      def extract_restarg
        extract_code = "#{scope.working_arguments}.splice(0, #{scope.working_arguments}.length - #{required_right_args.size});"
        var_name, = *restarg
        if var_name
          add_temp var_name
          line "#{var_name} = #{extract_code}"
        else
          line extract_code
        end
      end

      def extract_blank_restarg
        var_name, = *restarg
        if var_name
          add_temp var_name
          line "#{var_name} = [];"
        end
      end

      def kwargs_sexp
        s(:post_kwargs, *kwargs)
      end
    end
  end
end
