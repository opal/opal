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

      # Converts `self` to a s-expression ruby string.
      # The code return will recreate the node, using the sexp module s()
      #
      # This is modified from the original method to also contain information
      # about type inferrence
      #
      # @param  [Integer] indent Base indentation level.
      # @return [String]
      def inspect(indent = 0)
        indented = '  ' * indent
        sexp = "#{indented}s(:#{@type}"

        if meta[:type]
          sexp += "[#{meta[:type]}]"
        end

        children.each do |child|
          if child.is_a?(Node)
            sexp += ",\n#{child.inspect(indent + 1)}"
          else
            sexp += ", #{child.inspect}"
          end
        end

        sexp += ')'

        sexp
      end
    end
  end
end
