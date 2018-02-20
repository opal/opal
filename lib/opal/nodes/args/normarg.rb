# frozen_string_literal: true

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
        if @sexp.meta[:post]
          add_temp name
          line "#{name} = #{scope.working_arguments}.splice(0,1)[0];"
        end

        if scope.in_mlhs?
          line "if (#{name} == null) {"
          line "  #{name} = nil;"
          line '}'
        end
      end
    end
  end
end
