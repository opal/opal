require 'opal/nodes/call'

module Opal
  module Nodes

    # Safe navigator recv&.meth(arglist, &block)
    class CSendNode < CallNode
      handle :csend

      def default_compile
        helper :send

        conditional_send(recv(receiver_sexp)) do |receiver_temp|
          push "$send(", receiver_temp
          compile_method_name
          compile_arguments
          compile_block_pass
          push ')'
        end
      end
    end

  end
end
