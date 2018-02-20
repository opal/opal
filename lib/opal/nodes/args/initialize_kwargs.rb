# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    # An abstract node responsible for validating
    # keyword arguments in the post-splat list of arguments.
    #
    # @see PostArgsNode
    #
    class InitializeKwargsNode < Base
      def initialize_kw_args_if_needed
        return if scope.kwargs_initialized

        helper :hash2

        line 'if ($kwargs == null || !$kwargs.$$is_hash) {'
        line '  if ($kwargs == null) {'
        line '    $kwargs = $hash2([], {});'
        line '  } else {'
        line "    throw Opal.ArgumentError.$new('expected kwargs');"
        line '  }'
        line '}'

        scope.kwargs_initialized = true
      end
    end
  end
end
