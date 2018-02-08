# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class BlockToIter < Base
      def on_block(node)
        recvr, args, body = *super
        iter_node = s(:iter, args, body)
        recvr.updated(
          nil,
          recvr.children + [iter_node],
        )
      end
    end
  end
end
