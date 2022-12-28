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

      def on_forwarded_restarg(_node)
        process(
          s(:splat, s(:lvar, '$fwd_rest'))
        )
      end

      def on_forwarded_kwrestarg(_node)
        process(
          s(:kwsplat, s(:lvar, '$fwd_kwrest'))
        )
      end

      def on_block_pass(node)
        if !node.children.first
          process(
            node.updated(nil,
              [s(:lvar, '$fwd_block')]
            )
          )
        else
          super
        end
      end

      def on_args(node)
        if node.children.last && node.children.last.type == :forward_arg
          prev_children = node.children[0..-2]

          super(node.updated(nil,
            [
              *prev_children,
              s(:restarg, '$fwd_rest'),
              s(:kwrestarg, '$fwd_kwrest'),
              s(:blockarg, '$fwd_block')
            ]
          ))
        else
          super
        end
      end

      def on_restarg(node)
        if !node.children.first
          node.updated(nil, ['$fwd_rest'])
        else
          super
        end
      end

      def on_kwrestarg(node)
        if !node.children.first
          node.updated(nil, ['$fwd_kwrest'])
        else
          super
        end
      end

      def on_blockarg(node)
        if !node.children.first
          node.updated(nil, ['$fwd_block'])
        else
          super
        end
      end

      def on_send(node)
        if node.children.last &&
           node.children.last.class != Symbol &&
           node.children.last.type == :forwarded_args

          prev_children = node.children[0..-2]

          super(node.updated(nil,
            [
              *prev_children,
              s(:splat,
                s(:lvar, '$fwd_rest')
              ),
              s(:kwargs,
                s(:kwsplat, s(:lvar, '$fwd_kwrest'))
              ),
              s(:block_pass,
                s(:lvar, '$fwd_block')
              )
            ]
          ))
        else
          super
        end
      end
    end
  end
end
