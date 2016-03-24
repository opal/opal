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

      def compile
        initialize_kw_args_if_needed

        kwoptarg_name = @sexp[1].to_sym
        default_value = @sexp[2]
        var_name = variable(kwoptarg_name)
        add_temp var_name

        line "if ((#{var_name} = $kwargs.$$smap['#{kwoptarg_name}']) == null) {"
        line "  #{var_name} = ", expr(default_value)
        line "}"

        scope.used_kwargs << kwoptarg_name
      end
    end
  end
end
