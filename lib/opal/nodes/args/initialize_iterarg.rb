# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    module Args
      # This node is responsible for initializing a single
      # required block arg
      #
      #   proc { |a| }
      #
      # Procs don't have arity checking and code like
      #   proc { |a| }.call
      # must return nil
      class InitializeIterarg < Base
        handle :initialize_iter_arg
        children :name

        def compile
          line "if (#{name} == null) #{name} = nil;"
        end
      end
    end
  end
end
