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

        var_name = variable(name)
        add_temp var_name

        line "if ((#{var_name} = $kwargs.$$smap['#{name}']) == null) {"
        line "  #{var_name} = ", expr(default_value)
        line "}"

        scope.used_kwargs << name
      end
    end
  end
end
