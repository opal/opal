# frozen_string_literal: true

require 'ast'
require 'parser/ast/node'

module Opal
  module AST
    class Matcher
      def initialize(&block)
        @root = instance_exec(&block)
      end

      def s(type, *children)
        Node.new(type, children)
      end

      def cap(capture)
        Node.new(:capture, [capture])
      end

      def match(ast)
        @captures = []
        @root.match(ast, self) || (return false)
        @captures
      end

      def inspect
        "#<Opal::AST::Matcher: #{@root.inspect}>"
      end

      attr_accessor :captures

      Node = Struct.new(:type, :children) do
        def match(ast, matcher)
          return false if ast.nil?

          ast_parts = [ast.type] + ast.children
          self_parts = [type] + children

          return false if ast_parts.length != self_parts.length

          ast_parts.length.times.all? do |i|
            ast_elem = ast_parts[i]
            self_elem = self_parts[i]

            if self_elem.is_a?(Node) && self_elem.type == :capture
              capture = true
              self_elem = self_elem.children.first
            end

            res = case self_elem
                  when Node
                    self_elem.match(ast_elem, matcher)
                  when Array
                    self_elem.include?(ast_elem)
                  when :*
                    true
                  else
                    self_elem == ast_elem
                  end

            matcher.captures << ast_elem if capture
            res
          end
        end

        def inspect
          if type == :capture
            "{#{children.first.inspect}}"
          else
            "s(#{type.inspect}, #{children.inspect[1..-2]})"
          end
        end
      end
    end
  end
end
