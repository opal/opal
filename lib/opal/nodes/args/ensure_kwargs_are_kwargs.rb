# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # A utility node responsible for compiling
      # a runtime validation for kwargs.
      #
      # This node is used for both inline and post-kwargs
      #
      class EnsureKwargsAreKwargs < Base
        handle :ensure_kwargs_are_kwargs

        def compile
          helper :ensure_kwargs

          push '$kwargs = $ensure_kwargs($kwargs)'
        end
      end
    end
  end
end
