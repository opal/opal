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

          if args_to_keep == 0
            # no post-args, we are free to grab everything
            line "#{name} = $post_args;"
          else
            line "#{name} = $post_args.splice(0, $post_args.length - #{args_to_keep});"
          end
        end
      end
    end
  end
end
