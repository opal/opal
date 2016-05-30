require 'opal/nodes/base'

module Opal
  module Nodes
    class BlockNode < NodeWithArgs
      handle :block
      children :recvr, :args, :body

      def compile
        iter_node = s(:iter, args, body)
        call_node = recvr.updated(
          nil,
          recvr.children + [iter_node]
        )

        push expr call_node
      end
    end
  end
end
