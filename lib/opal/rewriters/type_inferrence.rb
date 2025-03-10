# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    # The TypeInferrence rewriter is adding an annotation to types of
    # local variables and constants by setting a `:type` sexp attribute.
    #
    # This will allow us, at a later stage, to compile certain expressions
    # directly to their JavaScript counterparts.
    #
    # The logic is that, if we encounter an expression that we are sure
    # will compile to a certain type, we set a `:type` attribute.
    #
    # Such expressions, are for instance:
    # - `10` - 10 is a float, so we set `:type` to `:float` to this node
    # - `a = 10` - till the end of the scope, or if reassignment happens
    #              we can be sure, that `a` is a :float, since `10` is
    #              a float
    # - `a` - if a previously assigned `lvasgn` is a `:float`, then this
    #         lvar is a :float as well
    # - `a + 5` - since both operations of an addition are a `:float`,
    #             this operation will become `:float` as well.
    # - `a |= 0xff` - likewise
    class TypeInferrence < Base
      def initialize
        super
        @scopes = [{scope_type: :global, vars: {}}]
      end

      INFERRABLE_BINARY_METHODS = %i[+ - * ** / ^ | & << >>]
      INFERRABLE_UNARY_METHODS = %i[+@ -@ ~@ !@ length]

      INFERRENCE_AVAILABILITY = {
        :+ => %i[string float],
        :- => %i[float],
        :* => %i[float],
        :** => [], # unsupported until >ES5: %i[float],
        :/ => %i[float bool],
        :^ => %i[float],
        :| => %i[float bool],
        :& => %i[float bool],
        :<< => %i[float array],
        :>> => %i[float],
        :+@ => %i[float],
        :-@ => %i[float],
        :~@ => %i[float],
        :!@ => %i[bool],
        :length => %i[string array]
      }

      def process(node)
        return super if node.nil?

        case node.type
        when :int, :float
          set_type(node, :float)
        when :str, :sym
          set_type(node, :string)
        when :array
          set_type(super, :array)
        when :true, :false
          set_type(node, :bool)
        when :nil
          set_type(node, :nil)
        when :def, :defs, :iter, :class, :module
          enter_scope(node.type)
          super
          exit_scope
        when :lvasgn
          if node.children.length == 2
            set_type(node, child_type(node, 1))
            save_type(0, node)
          else
            super
          end
        when :casgn
          if node.children[0].nil?
            set_type(node, child_type(node, 2))
            save_type(1, node)
          else
            super
          end
        when :lvar
          set_type(node, find_type(node.children[0]))
        when :const
          if node.children[0].nil?
            set_type(node, find_type(node.children[1], :const))
          else
            super
          end
        when :send
          operator = node.children[1]
          if INFERRABLE_BINARY_METHODS.include?(operator) && node.children.length == 3
            type_left = child_type(node, 0)
            type_right = child_type(node, 2)
            if [type_right, :array].include?(type_left) && INFERRENCE_AVAILABILITY[operator].include?(type_left)
              set_type(node, infer_resulting_type(operator, type_left))
            end
          elsif INFERRABLE_UNARY_METHODS.include?(operator) && node.children.length == 2
            type = child_type(node, 0)
            if INFERRENCE_AVAILABILITY[operator].include?(type)
              set_type(node, infer_resulting_type(operator, type))
            end
          else
            super
          end
        when :begin
          if node.children.length == 0
            set_type(node, :nil)
          else
            set_type(node, super(node).children.last.meta[:type])
          end
        else
          super
        end
    
        node
      end

      private

      def infer_resulting_type(operator, type)
        if operator == :length
          :float
        else
          type
        end
      end

      def child_type(node, index)
        processed = process(node.children[index])
        processed.meta[:type] if processed
      end

      def set_type(node, type)
        node.meta[:type] = type
      end

      def save_type(childno, node)
        type = current_scope[:vars][node.children[childno]]
        if type && type != node.meta[:type]
          current_scope[:vars][node.children[childno]] = :DYNAMIC
        else
          current_scope[:vars][node.children[childno]] = node.meta[:type]
        end
      end

      def current_scope
        @scopes.last
      end

      def enter_scope(scope_type)
        @scopes.push({scope_type: scope_type, vars: {}})
      end

      def exit_scope
        @scopes.pop
      end

      def find_type(var_name, const = false)
        @scopes.reverse_each do |scope|
          if scope[:vars].key?(var_name)
            if scope[:vars][var_name] == :DYNAMIC
              return nil
            else
              return scope[:vars][var_name]
            end
          end
      
          # Break if we encounter a breaking scope
          if const
            break if %i[class module].include? scope[:scope_type]
          else
            break unless scope[:scope_type] == :iter
          end
        end
        nil
      end
    end
  end
end
