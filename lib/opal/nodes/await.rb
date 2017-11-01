# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    class AwaitNode < NodeWithArgs
      handle :await

      children :body

      def compile
        push process(body)
      end
    end
  end
end
