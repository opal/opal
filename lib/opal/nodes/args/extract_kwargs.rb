# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # A utility node responsible for extracting
      # post-kwargs from post-arguments.
      #
      # This node is used when kwargs cannot be inlined:
      #   def m(a = 1, kw:); end
      #
      # This node is NOT used when kwargs can be inlined:
      #   def m(a, kw:); end
      #
      class ExtractKwargs < Base
        handle :extract_kwargs

        def compile
          add_temp '$kwargs'

          helper :extract_kwargs

          push '$kwargs = $extract_kwargs($post_args, ', scope.identity,')'
        end
      end
    end
  end
end
