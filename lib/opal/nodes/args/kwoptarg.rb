# frozen_string_literal: true
require 'opal/nodes/args/initialize_kwargs'

module Opal
  module Nodes
    # A node responsible for extracting a
    # single *optional* keyword argument
    #
    # def m(kw: 1)
    #
    class KwoptArgNode < InitializeKwargsNode
      handle :kwoptarg
      children :name, :default_value

      def compile
        initialize_kw_args_if_needed

        add_temp name

        line "#{name} = $kwargs.$$smap['#{name}'];"

        scope.used_kwargs << name

        return if default_value.children[1] == :undefined

        line "if (#{name} == null) {"
        line "  #{name} = ", expr(default_value)
        line "}"
      end
    end
  end
end
