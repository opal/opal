require 'opal/nodes/base'

module Opal
  module Nodes
    # A ndoe responsible for extracting
    # a single argument
    #
    # def m(a)
    #
    class NormargNode < Base
      handle :arg

      def compile
        arg_name = @sexp[1].to_sym
        var_name = variable(arg_name)

        default_value = scope.in_mlhs? ? "|| nil" : ""

        if @sexp.meta[:post]
          add_temp var_name
          line "#{var_name} = #{scope.working_arguments}.splice(0,1)[0] #{default_value};"
        end
      end
    end
  end
end
