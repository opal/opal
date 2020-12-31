# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    # This rewriter transforms the Ruby 2.7 numblocks to regular blocks:
    #
    # proc { _1 }
    #      v
    # proc { |_1| _1 }
    class Numblocks < Base
      def on_numblock(node)
        left, arg_count, right = node.children

        s(
          :block,
          left,
          s(:args, *gen_args(arg_count)),
          right
        )
      end

      def gen_args(arg_count)
        (1..arg_count).map do |i|
          s(:arg, :"_#{i}")
        end
      end
    end
  end
end
