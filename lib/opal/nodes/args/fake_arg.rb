# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # Compiles a fake argument produced by the InlineArgs rewriter.
      #
      # This argument represents an argument from the
      # Ruby code that gets initialized later in the function body.
      #
      # def m(a = 1, b); end
      #              ^
      class FakeArgNode < Base
        handle :fake_arg

        def compile
          name = scope.next_temp
          scope.add_arg name
          push name
        end
      end
    end
  end
end
