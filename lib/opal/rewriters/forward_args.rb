# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ForwardArgs < Base
      def on_forward_args(_node)
        process(
          s(:args, s(:forward_arg, :"$"))
        )
      end

      def on_args(node)
        if node.children.last && node.children.last.type == :forward_arg
          prev_children = node.children[0..-2]

          node.updated(nil,
            [
              *prev_children,
              s(:restarg, '$fwd_rest'),
              s(:blockarg, '$fwd_block')
            ]
          )
        else
          super
        end
      end

      def on_send(node)
        if node.children.last &&
           node.children.last.class != Symbol &&
           node.children.last.type == :forwarded_args

          prev_children = node.children[0..-2]

          node.updated(nil,
            [
              *prev_children,
              s(:splat,
                s(:lvar, '$fwd_rest')
              ),
              s(:block_pass,
                s(:lvar, '$fwd_block')
              )
            ]
          )
        else
          super
        end
      end
    end
  end
end
