# frozen_string_literal: true

require 'opal/nodes/node_with_args'
require 'opal/rewriters/break_finder'

module Opal
  module Nodes
    class IterNode < NodeWithArgs
      handle :iter

      children :inline_args, :body

      def compile
        inline_params = nil

        to_vars = identity = body_code = nil

        in_scope do
          identity = scope.identify!
          # REMIND: 0 is resolved to null (Number)
          # Don't know exactly why but #{identity}.$$s contain the value!
          add_temp "self = this ? this : #{identity}.$$s"

          inline_params = process(inline_args)

          compile_arity_check

          body_code = stmt(returned_body)
          to_vars = scope.to_vars
        end

        line body_code

        unshift to_vars

        unshift "(#{identity} = function(", inline_params, '){'
        push "}, #{identity}.$$s = self,"
        push " #{identity}.$$brk = $brk," if contains_break?
        push " #{identity}.$$arity = #{arity},"

        if compiler.arity_check?
          push " #{identity}.$$parameters = #{parameters_code},"
        end

        # MRI expands a passed argument if the block:
        # 1. takes a single argument that is an array
        # 2. has more that one argument
        # With a few exceptions:
        # 1. mlhs arg: if a block takes |(a, b)| argument
        # 2. trailing ',' in the arg list (|a, |)
        # This flag on the method indicates that a block has a top level mlhs argument
        # which means that we have to expand passed array explicitly in runtime.
        if has_top_level_mlhs_arg?
          push " #{identity}.$$has_top_level_mlhs_arg = true,"
        end

        if has_trailing_comma_in_args?
          push " #{identity}.$$has_trailing_comma_in_args = true,"
        end

        push " #{identity})"
      end

      def compile_block_arg
        if block_arg
          scope.block_name = block_arg
          scope.add_temp block_arg
          scope_name = scope.identify!

          line "#{block_arg} = #{scope_name}.$$p || nil;"
          line "if (#{block_arg}) #{scope_name}.$$p = null;"
        end
      end

      def extract_underscore_args
        valid_args = []
        caught_blank_argument = false

        args.children.each do |arg|
          arg_name = arg.children.first
          if arg_name == :_
            unless caught_blank_argument
              caught_blank_argument = true
              valid_args << arg
            end
          else
            valid_args << arg
          end
        end

        @sexp = @sexp.updated(
          nil, [
            args.updated(nil, valid_args),
            body
          ]
        )
      end

      def returned_body
        compiler.returns(body || s(:nil))
      end

      def has_top_level_mlhs_arg?
        original_args.children.any? { |arg| arg.type == :mlhs }
      end

      def has_trailing_comma_in_args?
        if original_args.loc && original_args.loc.expression
          args_source = original_args.loc.expression.source
          args_source.match(/,\s*\|/)
        end
      end

      def arity_check_node
        s(:iter_arity_check, original_args)
      end

      def contains_break?
        finder = Opal::Rewriters::BreakFinder.new
        finder.process(@sexp)
        finder.found_break?
      end
    end
  end
end
