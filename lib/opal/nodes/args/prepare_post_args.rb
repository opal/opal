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

          if offset == 0
            line "$post_args = Opal.slice.call(arguments)"
          else
            line "$post_args = Opal.slice.call(arguments, #{offset})"
          end
        end
      end
    end
  end
end
