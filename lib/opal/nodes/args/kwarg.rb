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
      children :name

      def compile
        initialize_kw_args_if_needed

        add_temp name

        line "if (!Opal.hasOwnProperty.call($kwargs.$$smap, '#{name}')) {"
        line "  throw Opal.ArgumentError.$new('missing keyword: #{name}');"
        line "}"
        line "#{name} = $kwargs.$$smap['#{name}'];"

        scope.used_kwargs << name
      end
    end
  end
end
