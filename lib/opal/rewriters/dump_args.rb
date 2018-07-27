# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class DumpArgs < Base
      def on_def(node)
        node = super(node)
        _mid, args, _body = *node
        node.updated(nil, nil, meta: { original_args: args })
      end

      def on_defs(node)
        node = super(node)
        _recv, _mid, args, _body = *node

        node.updated(nil, nil, meta: { original_args: args })
      end

      def on_iter(node)
        node = super(node)
        args, _body = *node
        node.updated(nil, nil, meta: { original_args: args })
      end
    end
  end
end
