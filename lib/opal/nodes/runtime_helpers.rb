require 'set'
require 'opal/nodes/base'

module Opal
  module Nodes
    class RuntimeHelpers < Base
      HELPERS = Set.new

      children :recvr, :meth, :arglist

      def self.s(type, *children)
        ::Parser::AST::Node.new(type, children)
      end

      def self.compatible?(recvr, meth, arglist)
        recvr == s(:const, nil, :Opal) and HELPERS.include?(meth.to_sym)
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

      helper :truthy? do
        unless sexp = arglist.children[0]
          raise "truthy? requires an object"
        end

        js_truthy(sexp)
      end

      helper :falsy? do
        unless sexp = arglist.children[0]
          raise "falsy? requires an object"
        end

        js_falsy(sexp)
      end
    end
  end
end
