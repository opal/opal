# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    # A node responsible for extracting
    # keyword arguments list
    #
    # If a method/block arguments have splat we can't
    # find the place where **exactly** starts keyword arguments.
    #
    # @see PostArgsNode
    #
    class PostKwargsNode < Base
      handle :post_kwargs

      def compile
        return if children.empty?

        initialize_kw_args

        children.each do |arg|
          push process(arg)
        end
      end

      def initialize_kw_args
        line "$kwargs = Opal.extract_kwargs(#{scope.working_arguments});"
      end
    end
  end
end
