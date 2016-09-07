require 'opal/nodes/call'

module Opal
  module Nodes
    # Save navigator recv&.meth(arglist, &block)
    class CSendNode < CallNode
      handle :csend

      # temporary variable that stores method receiver
      def receiver_temp
        @receiver_temp ||= scope.new_temp
      end

      def default_compile
        helper :send

        compile_receiver

        push ", #{check_receiver_code} ? nil : $send("
        push receiver_temp
        compile_method_name
        compile_arguments
        compile_block_pass
        wrap '(', '))'
      end

      def compile_receiver
        push "#{receiver_temp} = ", recv(receiver_sexp)
      end

      def check_receiver_code
        "(#{receiver_temp} === nil || #{receiver_temp} == null)"
      end
    end
  end
end
