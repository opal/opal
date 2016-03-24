require 'opal/nodes/base'

module Opal
  module Nodes
    # A node responsible for extracting a single
    # optional argument
    #
    # def m(a=1)
    #
    class OptargNode < Base
      handle :optarg

      def compile
        optarg_name = @sexp[1].to_sym
        default_value = @sexp[2]
        var_name = variable(optarg_name)

        return if default_value[2] == :undefined

        line "if (#{var_name} == null) {"
        line "  #{var_name} = ", expr(default_value)
        push ";"
        line "}"
      end
    end
  end
end
