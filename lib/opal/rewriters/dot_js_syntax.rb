# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class DotJsSyntax < Base
      def on_send(node)
        recv, meth, *args = *node
        if recv && recv.type == :send
          recv_of_recv, meth_of_recv, _ = *recv
          if meth_of_recv == :JS
            case meth
            when :[]
              if args.size != 1
                error '.JS[:property] syntax supports only one argument'
              end
              property = args.first

              node = to_js_attr_call(recv_of_recv, property)
            when :[]=
              if args.size != 2
                error '.JS[:property]= syntax supports only two arguments'
              end

              property, value = *args
              node = to_js_attr_assign_call(recv_of_recv, property, value)
            else
              node = to_native_js_call(recv_of_recv, meth, args)
            end
            super(node)
          else
            super
          end
        else
          super
        end
      end

      # @param recv [AST::Node] receiver of .JS. method
      # @param meth [Symbol] name of the JS method
      # @param args [Array<AST::Node>] list of the arguments passed to JS method
      def to_native_js_call(recv, meth, args)
        s(:jscall, recv, meth, *args)
      end

      # @param recv [AST::Node] receiver of .JS[] method
      # @param property [AST::Node] argument passed to .JS[] method
      def to_js_attr_call(recv, property)
        s(:jsattr, recv, property)
      end

      # @param recv [AST::Node] receiver of .JS[]= method
      # @param property [AST::Node] property passed to brackets
      # @param value [AST::Node] value of assignment
      def to_js_attr_assign_call(recv, property, value)
        s(:jsattrasgn, recv, property, value)
      end
    end
  end
end
