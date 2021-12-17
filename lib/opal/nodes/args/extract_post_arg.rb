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

          line "#{name} = $post_args.shift();"

          line "if (#{name} == null) #{name} = nil;"
        end
      end
    end
  end
end
