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
      children :name

      def compile
        return unless name

        add_temp name

        if @sexp.meta[:post]
          # post restarg case (in mlhs or in deoptimized arguments)
          # splat is always the last item in scope.working_arguments
          line "#{name} = #{scope.working_arguments};"
        else
          # inline restarg case
          offset = @sexp.meta[:offset]
          # restarg value should be taken directly from parameters
          line "var $args_len = arguments.length, $rest_len = $args_len - #{offset};"
          line "if ($rest_len < 0) { $rest_len = 0; }"
          line "#{name} = new Array($rest_len);"
          line "for (var $arg_idx = #{offset}; $arg_idx < $args_len; $arg_idx++) {"
          line "  #{name}[$arg_idx - #{offset}] = arguments[$arg_idx];"
          line "}"
        end
      end
    end
  end
end
