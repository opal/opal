# frozen_string_literal: true

require 'opal/nodes/def'

module Opal
  module Nodes
    class DefsNode < DefNode
      handle :defs
      children :recvr, :mid, :inline_args, :stmts

      def wrap_with_definition
        unshift 'Opal.defs(', expr(recvr), ", '$#{mid}', "
        push ')'

        if expr?
          wrap '', " && '#{mid}'"
        end
      end
    end
  end
end
