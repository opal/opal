# frozen_string_literal: true
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
      children :lvar_name

      def compile
        key_name = @sexp.meta[:arg_name]

        initialize_kw_args_if_needed

        add_temp lvar_name

        line "if (!Opal.hasOwnProperty.call($kwargs.$$smap, '#{key_name}')) {"
        line "  throw Opal.ArgumentError.$new('missing keyword: #{key_name}');"
        line "}"
        line "#{lvar_name} = $kwargs.$$smap[#{key_name.to_s.inspect}];"

        scope.used_kwargs << key_name
      end
    end
  end
end
