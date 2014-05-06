require 'opal/nodes/base'

module Opal
  module Nodes
    class ForNode < Base
      handle :for

      def compile
        raise "s(:for) nodes are not supported"
      end
    end
  end
end
