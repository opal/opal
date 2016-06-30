require 'parser'

module Opal
  module Rewriters
    class Base < ::Parser::AST::Processor
      def s(type, *children)
        ::Parser::AST::Node.new(type, children)
      end

      def self.s(type, *children)
        ::Parser::AST::Node.new(type, children)
      end

      alias on_iter process_regular_node

      # TODO: remove patches above after releasing
      # https://github.com/whitequark/parser/commit/cd8d5db
      def on_vasgn(node)
        name, value_node = *node

        if !value_node.nil?
          node.updated(nil, [
            name, process(value_node)
          ])
        else
          node
        end
      end

      def on_casgn(node)
        scope_node, name, value_node = *node

        if !value_node.nil?
          node.updated(nil, [
            process(scope_node), name, process(value_node)
          ])
        else
          node.updated(nil, [
            process(scope_node), name
          ])
        end
      end

      def on_argument(node)
        arg_name, value_node = *node

        if !value_node.nil?
          node.updated(nil, [
            arg_name, process(value_node)
          ])
        else
          node
        end
      end
    end
  end
end
