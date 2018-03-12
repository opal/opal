require 'opal/nodes/call'

module Opal
  module Nodes
    class LambdaNode < Base
      handle :lambda
      children :iter

      def compile
        helper :lambda

        push '$lambda(', expr(iter), ')'
      end
    end
  end
end
