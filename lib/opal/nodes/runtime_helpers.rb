require 'set'
require 'opal/nodes/base'

module Opal
  module Nodes
    class RuntimeHelpers < Base
      HELPERS = Set.new

      children :recvr, :meth, :arglist

      def self.compatible?(recvr, meth, arglist)
        recvr == [:const, :Opal] and HELPERS.include?(meth.to_sym)
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
        unless sexp = arglist[1]
          raise "truthy? requires an object"
        end

        js_truthy(sexp)
      end

      helper :falsy? do
        unless sexp = arglist[1]
          raise "falsy? requires an object"
        end

        js_falsy(sexp)
      end
    end
  end
end
