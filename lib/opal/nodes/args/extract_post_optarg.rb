# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a single
      # optional post-argument
      #
      # args_to_keep is the number of required post-arguments
      #
      #   def m(a = 1, b, c, d); end
      # becomes something like:
      #   if post_args.length > 3
      #     a = post_args[0]
      #     post_args = post_args[1..-1]
      #   end
      #
      class ExtractPostOptarg < Base
        handle :extract_post_optarg
        children :name, :default_value, :args_to_keep

        def compile
          add_temp name

          line "if ($post_args.length > #{args_to_keep}) {"
          line "  #{name} = $post_args[0];"
          line "  $post_args.splice(0, 1);"
          line "}"

          return if default_value.children[1] == :undefined

          line "if (#{name} == null) {"
          line "  #{name} = ", expr(default_value), ";"
          line "}"
        end
      end
    end
  end
end
