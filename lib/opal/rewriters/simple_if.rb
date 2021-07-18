# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class SimpleIf < Base
      def initialize
        @simple = {}
      end

      def on_if(node)
        if body_is_simple?(node)
          node.updated(:simple_if, nil)
        else
          super
        end
      end

      private

      def body_is_simple?(body)
        if @simple.key? (id = body.object_id.to_s)
          return @simple[id]
        end

        @simple[id] = begin
                        body ||= s(:nil)
                        case body.type
                        when :nil, :true, :false, :str, :sym, :int,
                             :lvar, :const, :js_tmp, :regexp, :ivar,
                             :hash, :iter, :ivasgn
                          true
                        when :lvasgn
                          _, value = *body.children
                          body_is_simple? value
                        when :if
                          body.children.all? { |arg| body_is_simple?(arg) }
                        when :send
                          lhs, _, *args = *body.children
                          body_is_simple?(lhs) && args.all? { |arg| body_is_simple?(arg) }
                        else
                          #p body.type
                          false
                        end
                      end
      end
    end
  end
end