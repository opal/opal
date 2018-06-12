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
      def reset_tmp_counter!
        @counter = 0
      end

      def new_mlhs_tmp
        @counter ||= 0
        @counter += 1
        :"$mlhs_tmp#{@counter}"
      end

      def initialize
        @rewriter = MlhsRewriter.new
      end

      def on_def(node)
        node = super
        mid, args, body = *node

        stmts = []
        new_args = args.children.map do |arg|
          if arg.type == :mlhs
            var_name = new_mlhs_tmp
            rhs = s(:lvar, var_name)
            mlhs = @rewriter.process(arg)
            stmts << s(:masgn, mlhs, rhs)
            s(:arg, var_name).updated(nil, nil, meta: { arg_name: var_name })
          else
            arg
          end
        end

        if stmts.length == 1
          stmts = stmts[0]
        elsif stmts.empty?
          stmts = nil
        else
          stmts = s(:begin, *stmts)
        end

        args = args.updated(nil, new_args)
        if stmts
          body ||= s(:nil) # prevent returning mlhs assignment
          body = prepend_to_body(body, stmts)
        end

        node.updated(nil, [mid, args, body])
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
