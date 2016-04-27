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
      children :name

      def compile
        var_name = variable(name)

        if @sexp.meta[:post]
          add_temp var_name
          line "#{var_name} = #{scope.working_arguments}.splice(0,1)[0];"
        end

        if scope.in_mlhs?
          line "if (#{var_name} == null) {"
          line "  #{var_name} = nil;"
          line "}"
        end
      end
    end
  end
end
