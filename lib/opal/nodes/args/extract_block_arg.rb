# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # Compiles extraction of the block argument
      # def m(&block); end
      #       ^^^^^^
      #
      # This node doesn't exist in the original AST,
      # InlineArgs rewriter creates it to simplify compilation
      class ExtractBlockarg < Base
        handle :extract_blockarg
        children :name

        def compile
          scope.uses_block!
          scope.add_arg name

          scope.prepare_block(name)
        end
      end
    end
  end
end
