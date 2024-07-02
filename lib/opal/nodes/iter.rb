# frozen_string_literal: true

require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    class IterNode < NodeWithArgs
      handle :iter

      children :inline_args, :stmts

      def compile
        is_lambda! if scope.lambda_definition?

        compile_body_or_shortcut

        blockopts = {}
        blockopts["$$arity"] = arity if arity < 0
        blockopts["$$s"] = scope.self if @define_self
        blockopts["$$brk"] = @closure.throwers[:break] if @closure&.throwers&.key? :break
        blockopts["$$ret"] = @closure.throwers[:return] if @closure&.throwers&.key? :return

        if compiler.arity_check?
          blockopts["$$parameters"] = parameters_code
        end

        if compiler.enable_source_location?
          blockopts["$$source_location"] = source_location
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
          blockopts["$$has_top_level_mlhs_arg"] = "true"
        end

        if has_trailing_comma_in_args?
          blockopts["$$has_trailing_comma_in_args"] = "true"
        end

        unless plain_js_function?
          if blockopts.keys == ["$$arity"]
            push ", #{arity}"
          elsif !blockopts.empty?
            push ', {', blockopts.map { |k, v| "#{k}: #{v}" }.join(', '), '}'
          end
        end

        scope.nesting if @define_nesting
        scope.relative_access if @define_relative_access
      end

      def plain_js_function?
        sexp.meta[:plain_js_function]
      end

      def compile_body
        inline_params = nil

        to_vars = identity = body_code = nil

        in_scope do
          identity = scope.identify!

          inline_params = process(inline_args)

          compile_arity_check

          in_closure(Closure::JS_FUNCTION | Closure::ITER | (@is_lambda ? Closure::LAMBDA : 0)) do
            body_code = stmt(returned_body)

            if @define_self && !plain_js_function?
              add_temp "self = #{identity}.$$s == null ? this : #{identity}.$$s"
            end

            to_vars = scope.to_vars

            line body_code
          end
        end

        unshift to_vars

        if await_encountered
          unshift "async function #{identity}(", inline_params, '){'
        else
          unshift "function #{identity}(", inline_params, '){'
        end
        push '}'
      end

      def compile_block_arg
        if block_arg
          scope.prepare_block
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
            stmts
          ]
        )
      end

      def returned_body
        compiler.returns(stmts || s(:nil))
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
    end
  end
end
