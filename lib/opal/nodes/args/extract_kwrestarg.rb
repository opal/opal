# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for extracting a single
      # splat keyword argument from $kwargs
      #
      # $kwargs always exist (as argument when inlining is possible
      # and as a local variable when it's not)
      #
      class ExtractKwrestarg < Base
        handle :extract_kwrestarg
        children :name

        def compile
          if name
            add_temp name
            line "#{name} = Opal.kwrestargs($kwargs, #{used_kwargs});"
          end
        end

        def used_kwargs
          args = scope.used_kwargs.map do |arg_name|
            "'#{arg_name}': true"
          end

          "{#{args.join ','}}"
        end
      end
    end
  end
end
