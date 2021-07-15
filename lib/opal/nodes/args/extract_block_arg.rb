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
          scope.block_name = name

          scope_name  = scope.identity
          yielder     = scope.block_name

          add_temp "$iter = #{scope_name}[Opal.s.$$p]"
          add_temp "#{yielder} = $iter || nil"

          line "if ($iter) #{scope_name}[Opal.s.$$p] = null;"
        end
      end
    end
  end
end
