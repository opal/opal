# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # Compiles a single inline required argument
      # def m(a); end
      #       ^
      class ArgNode < Base
        handle :arg
        children :name

        def compile
          scope.add_arg name
          push name.to_s
        end
      end
    end
  end
end
