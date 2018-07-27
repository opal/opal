# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # Compiles extraction of a single inline optional argument
      # def m(a = 1); end
      #       ^^^^^
      #
      # This node doesn't exist in the original AST,
      # InlineArgs rewriter creates it to simplify compilation
      #
      # Sometimes the argument can't be inlined.
      # In such cases InlineArgs rewriter replaces
      #   s(:optarg, :arg_name, ...default value...)
      # to:
      #   s(:fakearg) + s(:extract_post_optarg, :arg_name, ...default value...)
      #
      class ExtractOptargNode < Base
        handle :extract_optarg
        children :name, :default_value

        def compile
          return if default_value.children[1] == :undefined

          line "if (#{name} == null) {"
          line "  #{name} = ", expr(default_value), ";"
          line "}"
        end
      end
    end
  end
end
