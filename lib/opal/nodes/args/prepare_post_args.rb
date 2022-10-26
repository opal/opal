# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # A utility node responsible for preparing
      # post-argument for :extract_post_* nodes
      class PreparePostArgs < Base
        handle :prepare_post_args
        children :offset

        def compile
          add_temp '$post_args'

          helper :slice

          if offset == 0
            push "$post_args = $slice.call(arguments)"
          else
            push "$post_args = $slice.call(arguments, #{offset})"
          end
        end
      end
    end
  end
end
