# frozen_string_literal: true

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
        return if default_value.children[1] == :undefined

        line "if (#{name} == null) {"
        line "  #{name} = ", expr(default_value)
        push ";"
        line "}"
      end
    end
  end
end
