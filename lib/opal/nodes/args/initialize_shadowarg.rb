# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for initializing a shadow arg
      #
      # proc { |;a| }
      #
      class InitializeShadowarg < Base
        handle :initialize_shadowarg
        children :name

        def compile
          scope.locals << name
          scope.add_arg(name)
          line "#{name} = nil;"
        end
      end
    end
  end
end
