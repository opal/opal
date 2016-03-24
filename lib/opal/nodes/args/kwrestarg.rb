require 'opal/nodes/args/initialize_kwargs'

module Opal
  module Nodes
    # A node responsible for extracting a
    # keyword splat argument
    #
    # def m(**kwrest)
    # def m(**)
    #
    class KwrestArgNode < InitializeKwargsNode
      handle :kwrestarg

      def compile
        initialize_kw_args_if_needed

        kwrestarg_name = @sexp[1]
        extract_code = "Opal.kwrestargs($kwargs, #{used_kwargs});"

        # kwrestarg can be blank def m(**) end
        # we need to perform assignment only for named kwrestarg
        if kwrestarg_name
          var_name = variable(kwrestarg_name.to_sym)
          add_temp var_name

          line "#{var_name} = #{extract_code}"
        end
      end

      def used_kwargs
        args = scope.used_kwargs.map do |arg_name|
          "'#{arg_name}': true"
        end

        "{#{args.join ','}}"
      end
    end
  end
end
