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

        line "if ((#{name} = $kwargs.$$smap['#{name}']) == null) {"
        line "  #{name} = ", expr(default_value)
        line "}"

        scope.used_kwargs << name
      end
    end
  end
end
