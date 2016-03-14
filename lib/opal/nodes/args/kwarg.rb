require 'opal/nodes/args/initialize_kwargs'

module Opal
  module Nodes
    # A node responsible for extracting a
    # single *required* keyword argument
    #
    # def m(kw: )
    #
    class KwargNode < InitializeKwargsNode
      handle :kwarg

      def compile
        initialize_kw_args_if_needed

        kwarg_name = @sexp[1].to_sym
        var_name = variable(kwarg_name)
        add_temp var_name

        line "if (!$kwargs.$$smap.hasOwnProperty('#{kwarg_name}')) {"
        line "  throw Opal.ArgumentError.$new('missing keyword: #{kwarg_name}');"
        line "}"
        line "#{var_name} = $kwargs.$$smap['#{kwarg_name}'];"

        scope.used_kwargs << kwarg_name
      end
    end
  end
end
