require 'opal/nodes/base'

module Opal
  module Nodes
    # A node responsible for extracting a rest argument
    # (or splat argument)
    #
    # def m(*rest)
    #
    class RestargNode < Base
      handle :restarg

      def compile
        restarg_name = @sexp[1]
        return unless restarg_name
        var_name = variable(restarg_name.to_sym)

        add_temp var_name

        if @sexp.meta[:post]
          # post restarg case (in mlhs or in deoptimized arguments)
          # splat is always the last item in scope.working_arguments
          line "#{var_name} = #{scope.working_arguments};"
        else
          # inline restarg case
          offset = @sexp.meta[:offset]
          # restarg value should be taken directly from parameters
          line "#{var_name} = $slice.call(arguments, #{offset}, arguments.length);"
        end
      end
    end
  end
end
