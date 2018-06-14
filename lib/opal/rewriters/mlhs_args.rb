# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    # Rewrites
    #
    # def m( (a, b), (c, d) )
    #   body
    # end
    #
    # To
    #
    # def m($mlhs_tmp1, $mlhs_tmp2)
    #   (a, b) = $mlhs_tmp1
    #   (c, d) = $mlhs_tmp2
    #   body
    # end
    #
    class MlhsArgs < Base
      def on_def(node)
        node = super(node)
        mid, args, body = *node

        arguments = Arguments.new(args)

        args = args.updated(nil, arguments.rewritten)
        if arguments.initialization
          body ||= s(:nil) # prevent returning mlhs assignment
          body = prepend_to_body(body, arguments.initialization)
        end

        node.updated(nil, [mid, args, body])
      end

      def on_defs(node)
        node = super(node)
        recv, mid, args, body = *node

        arguments = Arguments.new(args)

        args = args.updated(nil, arguments.rewritten)
        if arguments.initialization
          body ||= s(:nil) # prevent returning mlhs assignment
          body = prepend_to_body(body, arguments.initialization)
        end

        node.updated(nil, [recv, mid, args, body])
      end

      def on_iter(node)
        node = super(node)
        args, body = *node

        arguments = Arguments.new(args)

        args = args.updated(nil, arguments.rewritten)
        if arguments.initialization
          body ||= s(:nil) # prevent returning mlhs assignment
          body = prepend_to_body(body, arguments.initialization)
        end

        node.updated(nil, [args, body])
      end

      class Arguments < Base
        attr_reader :rewritten, :initialization

        def initialize(args)
          @args = args
          @rewritten = []
          @initialization = []
          @rewriter = MlhsRewriter.new

          split!
        end

        def reset_tmp_counter!
          @counter = 0
        end

        def new_mlhs_tmp
          @counter ||= 0
          @counter += 1
          :"$mlhs_tmp#{@counter}"
        end

        def split!
          @args.children.each do |arg|
            if arg.type == :mlhs
              var_name = new_mlhs_tmp
              rhs = s(:lvar, var_name)
              mlhs = @rewriter.process(arg)
              @initialization << s(:masgn, mlhs, rhs)
              @rewritten << s(:arg, var_name).updated(nil, nil, meta: { arg_name: var_name })
            else
              @rewritten << arg
            end
          end

          if @initialization.length == 1
            @initialization = @initialization[0]
          elsif @initialization.empty?
            @initialization = nil
          else
            @initialization = s(:begin, *@initialization)
          end
        end
      end

      class MlhsRewriter < Base
        def on_arg(node)
          node.updated(:lvasgn)
        end

        def on_restarg(node)
          name = node.children[0]
          if name
            s(:splat, node.updated(:lvasgn))
          else
            s(:splat)
          end
        end
      end
    end
  end
end
