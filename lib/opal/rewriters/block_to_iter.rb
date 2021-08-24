# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class BlockToIter < Base
      def on_block(node)
        recvr, args, body = *node
        iter_node = s(:iter, args, body)
        process recvr.updated(
          nil,
          (recvr.children + [iter_node]),
        )
      end
    end
  end
end
