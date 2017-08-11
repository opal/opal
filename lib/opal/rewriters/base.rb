# frozen_string_literal: true
require 'parser'
require 'opal/ast/node'

module Opal
  module Rewriters
    class Base < ::Parser::AST::Processor
      def s(type, *children)
        ::Opal::AST::Node.new(type, children)
      end

      def self.s(type, *children)
        ::Opal::AST::Node.new(type, children)
      end

      alias on_iter       process_regular_node
      alias on_top        process_regular_node
      alias on_zsuper     process_regular_node
      alias on_jscall     on_send
      alias on_jsattr     process_regular_node
      alias on_jsattrasgn process_regular_node
      alias on_kwsplat    process_regular_node

      # Prepends given +node+ to +body+ node.
      #
      # Supports +body+ to be one of:
      # 1. nil                     - empty body
      # 2. s(:begin) / s(:kwbegin) - multiline body
      # 3. s(:anything_else)       - singleline body
      #
      # Returns a new body with +node+ injected as a first statement.
      #
      def prepend_to_body(body, node)
        if body.nil?
          node
        elsif [:begin, :kwbegin].include?(body.type)
          body.updated(nil, [node, *body])
        else
          s(:begin, node, body)
        end
      end

      # Appends given +node+ to +body+ node.
      #
      # Supports +body+ to be one of:
      # 1. nil                     - empty body
      # 2. s(:begin) / s(:kwbegin) - multiline body
      # 3. s(:anything_else)       - singleline body
      #
      # Returns a new body with +node+ injected as a last statement.
      #
      def append_to_body(body, node)
        if body.nil?
          node
        elsif [:begin, :kwbegin].include?(body.type)
          body.updated(nil, [*body, node])
        else
          s(:begin, body, node)
        end
      end
    end
  end
end
