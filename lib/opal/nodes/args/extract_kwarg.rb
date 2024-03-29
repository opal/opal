# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a single
      # required keyword argument from $kwargs
      #
      # $kwargs always exist (as argument when inlining is possible
      # and as a local variable when it's not)
      #
      class ExtractKwarg < Base
        handle :extract_kwarg
        children :lvar_name

        def compile
          key_name = @sexp.meta[:arg_name]
          scope.used_kwargs << key_name

          add_temp lvar_name

          helper :get_kwarg

          push "#{lvar_name} = $get_kwarg($kwargs, #{key_name.to_s.inspect})"
        end
      end
    end
  end
end
