# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a splat argument from post-arguments
      #
      # args_to_keep is the number of required post-arguments
      #
      #   def m(*a, b, c, d); end
      # becomes something like:
      #   a = post_args[0..-3]
      #   post_args = post_args[-3..-1]
      #
      class ExtractRestarg < Base
        handle :extract_restarg
        children :name, :args_to_keep

        def compile
          # def m(*)
          # arguments are assigned to `$rest_arg` for super call
          name = self.name || '$rest_arg'

          add_temp name

          helper :extract_restargs

          push "#{name} = $extract_restargs($post_args, #{args_to_keep}, ", scope.identity, ")"
        end
      end
    end
  end
end
