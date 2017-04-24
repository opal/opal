# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    class ForNode < Base
      handle :for

      children :arg, :value, :body_sexp

      def compile
        # All variables that are used for iterating
        # must be available outside of the for loop
        plain_arg_names.each do |arg_name|
          add_local arg_name
        end

        with_temp do |loop_var|
          if arg.type == :mlhs
            masgn_source_sexp = s(:js_tmp, loop_var)
            assign = s(:masgn, arg, masgn_source_sexp)
          else
            assign = arg << s(:js_tmp, loop_var)
          end

          if body_sexp
            assign = s(:begin, assign, body_sexp)
          end

          locals_in_for_body.each do |lvar|
            add_local lvar
          end

          # block_sexp is a sexp of our for loop
          # converted to "value.each { |arg| body_sexp }"
          block_sexp = s(:send, value, :each,
            s(:iter, s(:args, s(:arg, loop_var)), assign)
          )
          push expr(block_sexp)
        end
      end

      def plain_arg_names(node = arg)
        case node.type
        when :lvasgn
          node.children
        when :mlhs
          node.children.flat_map { |mlhs_arg| plain_arg_names(mlhs_arg) }
        else
          []
        end
      end

      class LocalsFinder < ::Parser::AST::Processor
        attr_reader :lvasgns

        def initialize
          @lvasgns = Set.new
        end

        def on_lvasgn(node)
          name, _value = *node
          self.lvasgns << name
          super
        end
      end

      def locals_in_for_body
        finder = LocalsFinder.new
        finder.process(body_sexp)
        finder.lvasgns.to_a
      end
    end
  end
end
