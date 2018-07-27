# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a single
      # required post-argument from $post_args
      #
      class ExtractPostArg < Base
        handle :extract_post_arg
        children :name

        def compile
          add_temp name

          line "#{name} = $post_args[0];"
          line "$post_args.splice(0, 1);"

          line "if (#{name} == null) {"
          line "  #{name} = nil"
          line "}"
        end
      end
    end
  end
end
