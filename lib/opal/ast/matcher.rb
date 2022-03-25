# frozen_string_literal: true

require 'ast'
require 'parser/ast/node'

module Opal
  module AST
    class Matcher
      def initialize(&block)
        raise 'No support for variable arity blocks' if block.arity < 0
        args = Array.new(block.arity) do |i|
          s(:am_arg, i)
        end
        @root = instance_exec(*args, &block)
        @root = s(:am_any_top, *@root) if @root.is_a? Array
      end

      def s(type, *children)
        Node.new(type, children, self)
      end

      def cap(capture = :*, options = {}, &block)
        pass_captures = options[:pass_captures]
        s(:am_capture, capture, block, pass_captures)
      end

      def cap_eq(id)
        s(:am_capture_eq, id)
      end

      def match(ast, options = {})
        @captures = []
        @root.match(ast, options) || (return false)
        @captures
      end

      # Acts as a generic matcher
      def ===(ast)
        match(ast) != false
      end

      # Acts as a matching proc
      def to_proc
        matcher = self
        proc do |ast = sexp, *args|
          matcher.match(ast, args: args, lambda_self: self)
        end
      end

      def inspect
        "#<Opal::AST::Matcher: #{@root.inspect}>"
      end

      attr_accessor :captures
      attr_reader :lambda_self

      Node = Struct.new(:type, :children, :matcher) do
        def match(ast, options = {})
          if type == :am_any_top
            ast = AST::Node.new(:*, [ast])
            myself = Node.new(:*, [children], matcher)
          else
            myself = self
          end

          return false unless ast.is_a?(AST::Node)

          lambda_self = options[:lambda_self]
          args = options[:args]

          ast_parts = [ast.type] + ast.children
          self_parts = [myself.type] + myself.children

          skip = 0

          self_parts.length.times.all? do |i|
            ast_elem = ast_parts[i + skip]
            self_elem = self_parts[i]

            if self_elem.is_a?(Node) && self_elem.type == :am_capture
              capture = true
              additional_test = self_elem.children[1]
              pass_captures = self_elem.children[2]
              self_elem = self_elem.children.first
            end

            res = case self_elem
                  when Node
                    case self_elem.type
                    when :am_capture_eq
                      ast_elem == matcher.captures[self_elem.children.first]
                    when :am_arg
                      ast_elem == args[self_elem.children.first]
                    else
                      self_elem.match(ast_elem, options)
                    end
                  when Array
                    self_elem.any? do |elem|
                      if elem.is_a?(Node) && elem.type == :am_capture
                        # TODO: refactor this mess...
                        capture = true
                        elem = elem.children.first
                      end

                      case elem
                      when Node
                        elem.match(ast_elem, options)
                      else
                        if elem.is_a?(Proc) && lambda_self
                          lambda_self.instance_exec(ast_elem, &elem)
                        else
                          elem === ast_elem
                        end
                      end
                    end
                  when :*
                    true
                  when :**
                    skip = ast_parts.length - self_parts.length
                    ast_elem = ast_parts[i..i + skip]
                    true
                  else
                    if self_elem.is_a?(Proc) && lambda_self
                      lambda_self.instance_exec(ast_elem, &self_elem)
                    else
                      self_elem === ast_elem
                    end
                  end

            if additional_test && res
              pass_captures = Array(pass_captures || []).map { |cap| matcher.captures[cap] }
              res = if additional_test.is_a?(Proc) && lambda_self
                      lambda_self.instance_exec(ast_elem, *pass_captures, &additional_test)
                    else
                      additional_test === ast_elem
                    end
            end

            if (i == self_parts.length - 1 && i + skip != ast_parts.length - 1) ||
               (i + skip) >= ast_parts.length
              next false
            end

            matcher.captures << ast_elem if capture
            res
          end
        end

        def inspect
          if type == :am_capture
            "{#{children.first.inspect}}"
          else
            "s(#{type.inspect}, #{children.inspect[1..-2]})"
          end
        end
      end
    end
  end
end
