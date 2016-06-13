require 'opal/nodes/def'

module Opal
  module Nodes
    class DefsNode < DefNode
      handle :defs
      children :recvr, :mid, :args, :stmts

      def extract_block_arg
        *regular_args, last_arg = args.children
        if last_arg && last_arg.type == :blockarg
          @block_arg = last_arg.children[0]
          @sexp = @sexp.updated(nil, [
            recvr,
            mid,
            s(:args, *regular_args),
            stmts
          ])
        end
      end

      def wrap_with_definition
        unshift "Opal.defs(", expr(recvr), ", '$#{mid}', "
        push ")"
      end
    end
  end
end
