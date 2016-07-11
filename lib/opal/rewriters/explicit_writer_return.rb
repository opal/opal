require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ExplicitWriterReturn < Base
      def initialize
        @in_masgn = false
      end

      def on_send(node)
        return super if @in_masgn

        recv, method_name, *args = *node

        if method_name.to_s =~ /#{REGEXP_START}\w+=#{REGEXP_END}/
          args_tmp = "$writer_args"
          set_args_node = s(:lvasgn, args_tmp, s(:array, *process_all(args)))
          get_args_node = s(:lvar, args_tmp)
          return_args_node = s(:jsattr, get_args_node, s(:int, 0))

          s(:begin,
            set_args_node,
            node.updated(nil, [recv, method_name, s(:splat, get_args_node)]),
            return_args_node
          )
        else
          super
        end
      end

      # Multiple assignment is quite complex
      #
      # For example, "self.a, self.b = 1, 2" parses to:
      # s(:masgn,
      #   s(:mlhs,
      #     s(:send,
      #       s(:self), :a=),
      #     s(:send,
      #       s(:self), :b=)),
      #   s(:array,
      #     s(:int, 1),
      #     s(:int, 2)))
      #
      # For now we just ignore its returning value
      def on_masgn(node)
        @in_masgn = true
        result = super
        @in_masgn = false
        result
      end
    end
  end
end
