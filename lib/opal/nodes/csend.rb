require 'opal/nodes/call'

module Opal
  module Nodes
    # Save navigator recv&.meth(arglist, &block)
    class CSendNode < CallNode
      handle :csend

      attr_reader :args_temp

      def initialize(*)
        super

        @args_temp = scope.new_temp
      end

      # Safe navigator always needs a receiver
      # to check if it's nil
      def needs_temporary_receiver?
        true
      end

      def add_method(temporary_receiver)
        push "#{temporary_receiver} = ", receiver_fragment
        push ", #{temporary_receiver} === nil || #{temporary_receiver} == null ? "
        push "(#{args_temp} = [], Opal.nil_returner) : "
        push "(#{args_temp} = [", arguments_fragment, "], #{temporary_receiver}#{method_jsid})"
        wrap "(", ")"
      end

      def add_invocation(temporary_receiver)
        push ".apply("
        push apply_call_target(temporary_receiver), ", ", args_temp
        push ")"
      end
    end
  end
end
