# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a single
      # optional keyword argument from $kwargs
      #
      # $kwargs always exist (as argument when inlining is possible
      # and as a local variable when it's not)
      #
      class ExtractKwoptarg < Base
        handle :extract_kwoptarg
        children :lvar_name, :default_value

        def compile
          key_name = @sexp.meta[:arg_name]
          scope.used_kwargs << key_name

          add_temp lvar_name

          line "#{lvar_name} = $kwargs.$$smap[#{key_name.to_s.inspect}];"

          return if default_value.children[1] == :undefined

          line "if (#{lvar_name} == null) {"
          line "  #{lvar_name} = ", expr(default_value)
          line "}"
        end
      end
    end
  end
end
