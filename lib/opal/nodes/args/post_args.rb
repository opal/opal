require 'opal/nodes/base'

module Opal
  module Nodes
    # Node responsible for extracting post-splat args
    # 1. There can be some arguments after the splat, this is why this node exist.
    #    In this case if:
    #     a. JS arguments length > args sexp length - then our splat has some items
    #        and we know how many of them should come to splat
    #     b. JS arguments lemgth < args sexp length - then our splat is blank
    #
    # 2. Super important - Ruby doesn't allow optional arg to come AFTER the rest arg
    #    This statement simplifies everything, keep it in mind.
    #
    class PostArgsNode < Base
      handle :post_args

      attr_reader :kwargs, :plain_args, :splat_arg, :post_splat_args

      def initialize(*)
        super

        @kwargs = []
        @plain_args = []
        @splat_arg = nil
        @post_splat_args = []
      end

      def extract_arguments
        found_splat = false

        children.each do |arg|
          arg.meta[:post] = true

          case arg.type
          when :kwarg, :kwoptarg, :kwrestarg
            @kwargs << arg
          when :restarg
            found_splat = true
            @splat_arg = arg
          when :arg, :optarg, :mlhs
            if found_splat
              @post_splat_args << arg
            else
              @plain_args << arg
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
          js_source = "arguments"
          scope.working_arguments = "$post_args"
        end

        add_temp "#{scope.working_arguments}"
        line "#{scope.working_arguments} = Opal.slice.call(#{js_source}, #{scope.inline_args.size}, #{js_source}.length);"

        extract_arguments

        push process(kwargs_sexp)

        plain_args.each do |arg|
          push process(arg)
        end

        if splat_arg
          line "if (#{post_splat_args.size} < #{scope.working_arguments}.length) {"
            indent do
              # there are some items coming to the splat, extracting them
              extract_splat_arg
            end
          line "} else {"
            indent do
              # splat is empty
              extract_blank_splat
            end
          line "}"
        end

        extract_post_splat_args

        scope.working_arguments = old_working_arguments
      end

      def extract_splat_arg
        extract_code = "#{scope.working_arguments}.splice(0, #{scope.working_arguments}.length - #{post_splat_args.size});"
        if splat_arg[1]
          var_name = variable(splat_arg[1].to_sym)
          add_temp var_name
          line "#{var_name} = #{extract_code}"
        else
          line extract_code
        end
      end

      def extract_post_splat_args
        post_splat_args.each do |arg|
          push process(arg)
        end
      end

      def extract_blank_splat
        if splat_arg[1]
          var_name = variable(splat_arg[1].to_sym)
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
