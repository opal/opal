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
          helper :hash2

          line 'if ($kwargs == null) {'
          line '  $kwargs = $hash2([], {});'
          line '} else if (!$kwargs[Opal.s.$$is_hash]) {'
          line "  throw Opal.ArgumentError[Opal.s.$new]('expected kwargs');"
          line '}'
        end
      end
    end
  end
end
