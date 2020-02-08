# frozen_string_literal: true

require 'set'
require 'opal/nodes/base'

module Opal
  module Nodes
    class RuntimeHelpers < Base
      HELPERS = Set.new

      children :recvr, :meth, :arglist

      def self.s(type, *children)
        ::Opal::AST::Node.new(type, children)
      end

      def self.compatible?(recvr, meth)
        recvr == s(:const, nil, :Opal) && HELPERS.include?(meth.to_sym)
      end

      def self.helper(name, &block)
        HELPERS << name
        define_method("compile_#{name}", &block)
      end

      def compile
        if HELPERS.include?(meth.to_sym)
          __send__("compile_#{meth}")
        else
          raise "Helper not supported: #{meth}"
        end
      end
    end
  end
end
