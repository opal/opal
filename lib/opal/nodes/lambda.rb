# frozen_string_literal: true

require 'opal/nodes/call'

module Opal
  module Nodes
    class LambdaNode < Base
      handle :lambda
      children :iter

      def compile
        helper :lambda

        scope.defines_lambda do
          push '$lambda(', expr(iter), ')'
        end
      end
    end
  end
end
