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
      children :name, :default_value

      def compile
        var_name = variable(name)

        return if default_value.children[1] == :undefined

        line "if (#{var_name} == null) {"
        line "  #{var_name} = ", expr(default_value)
        push ";"
        line "}"
      end
    end
  end
end
