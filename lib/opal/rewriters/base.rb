# frozen_string_literal: true

require 'parser'
require 'opal/ast/node'

module Opal
  module Rewriters
    class Base < ::Parser::AST::Processor
      class DummyLocation
        def node=(*)
          # stub
        end

        def expression
          self
        end

        def begin_pos
          0
        end

        def end_pos
          0
        end

        def source
          ''
        end

        def line
          0
        end

        def column
          0
        end

        def last_line
          Float::INFINITY
        end
      end
      DUMMY_LOCATION = DummyLocation.new

      def s(type, *children)
        loc = current_node ? current_node.loc : DUMMY_LOCATION
        ::Opal::AST::Node.new(type, children, location: loc)
      end

      def self.s(type, *children)
        ::Opal::AST::Node.new(type, children, location: DUMMY_LOCATION)
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
        stmts = stmts_of(node) + stmts_of(body)
        begin_with_stmts(stmts)
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
        stmts = stmts_of(body) + stmts_of(node)
        begin_with_stmts(stmts)
      end

      def stmts_of(node)
        if node.nil?
          []
        elsif %i[begin kwbegin].include?(node.type)
          node.children
        else
          [node]
        end
      end

      def begin_with_stmts(stmts)
        case stmts.length
        when 0
          nil
        when 1
          stmts[0]
        else
          s(:begin, *stmts)
        end
      end

      # Store the current node for reporting.
      attr_accessor :current_node

      # Intercept the main call and assign current node.
      def process(node)
        self.current_node = node
        super
      ensure
        self.current_node = nil
      end

      # This is called when a rewriting error occurs.
      def error(msg)
        error = ::Opal::RewritingError.new(msg)
        error.location = current_node.loc if current_node
        raise error
      end
    end
  end
end
