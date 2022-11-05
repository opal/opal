# frozen_string_literal: true

require 'opal/rewriter'

module Opal
  module Rewriters
    class BreakFinder < Opal::Rewriters::Base
      def initialize
        @found_break = false
      end

      def found_break?
        @found_break
      end

      def on_break(node)
        @found_break = true
        node
      end

      # don't process nested blocks
      def on_send(node)
        node.children.each do |child|
          next unless child.is_a? Opal::AST::Node
          next if child.type == :iter

          process(child)
        end
      end

      def stop_lookup(node)
        # noop
      end

      # regular loops
      alias on_for        stop_lookup
      alias on_while      stop_lookup
      alias on_while_post stop_lookup
      alias on_until      stop_lookup
      alias on_until_post stop_lookup

      # ignore break inside defined
      alias on_defined?   stop_lookup

      # nested block
      alias on_block      stop_lookup
    end
  end
end
