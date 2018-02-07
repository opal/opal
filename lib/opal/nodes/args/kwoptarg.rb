# frozen_string_literal: true

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
      children :lvar_name, :default_value

      def compile
        key_name = @sexp.meta[:arg_name]

        initialize_kw_args_if_needed

        add_temp lvar_name

        line "#{lvar_name} = $kwargs.$$smap[#{key_name.to_s.inspect}];"

        scope.used_kwargs << key_name

        return if default_value.children[1] == :undefined

        line "if (#{lvar_name} == null) {"
        line "  #{lvar_name} = ", expr(default_value)
        line '}'
      end
    end
  end
end
