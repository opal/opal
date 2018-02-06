# frozen_string_literal: true

require 'ast'
require 'parser/ast/node'

module Opal
  module AST
    class Node < ::Parser::AST::Node
      attr_reader :meta

      def assign_properties(properties)
        if meta = properties[:meta]
          meta = meta.dup if meta.frozen?
          @meta.merge!(meta)
        else
          @meta ||= {}
        end

        super
      end

      def line
        loc.line if loc
      end

      def column
        loc.column if loc
      end
    end
  end
end
