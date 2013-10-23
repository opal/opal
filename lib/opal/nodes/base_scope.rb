require 'opal/nodes/base'

module Opal
  module Nodes
    class BaseScopeNode < Base
      def in_scope(type, &block)
        indent { compiler.in_scope(type, &block) }
      end
    end
  end
end
