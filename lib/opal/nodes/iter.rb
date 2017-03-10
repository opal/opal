require 'opal/nodes/node_with_args'
require 'opal/rewriters/break_finder'

module Opal
  module Nodes
    class IterNode < NodeWithArgs
      handle :iter

      children :args, :body

      attr_accessor :block_arg, :shadow_args

      def compile
        inline_params = nil
        extract_block_arg
        extract_shadow_args
        extract_underscore_args
        split_args

        to_vars = identity = body_code = nil

        in_scope do
          inline_params = process(inline_args_sexp)

          identity = scope.identify!
          add_temp "self = #{identity}.$$s || this"

          compile_block_arg
          compile_shadow_args
          compile_inline_args
          compile_post_args
          compile_norm_args

          if compiler.arity_check?
            compile_arity_check
          end

          body_code = stmt(returned_body)
          to_vars = scope.to_vars
        end

        line body_code

        unshift to_vars

        unshift "(#{identity} = function(", inline_params, "){"
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

      def norm_args
        @norm_args ||= args.children.select { |arg| arg.type == :arg }
      end

      def compile_norm_args
        norm_args.each do |arg|
          arg_name, _ = *arg
          push "if (#{arg_name} == null) #{arg_name} = nil;"
        end
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

      def extract_block_arg
        *regular_args, last_arg = args.children
        if last_arg && last_arg.type == :blockarg
          @block_arg = last_arg.children[0]
          @sexp = @sexp.updated(nil, [
            s(:args, *regular_args),
            body
          ])
        end
      end

      def compile_shadow_args
        shadow_args.each do |shadow_arg|
          arg_name = shadow_arg.children[0]
          scope.locals << arg_name
          scope.add_arg(arg_name)
        end
      end

      def extract_shadow_args
        @shadow_args = []
        valid_args = []
        return unless args

        args.children.each_with_index do |arg, idx|
          if arg.type == :shadowarg
            @shadow_args << arg
          else
            valid_args << arg
          end
        end

        @sexp = @sexp.updated(nil, [
          args.updated(nil, valid_args),
          body
        ])
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

        @sexp = @sexp.updated(nil, [
          args.updated(nil, valid_args),
          body
        ])
      end

      def returned_body
        compiler.returns(body || s(:nil))
      end

      def mlhs_args
        scope.mlhs_mapping.keys
      end

      def has_top_level_mlhs_arg?
        args.children.any? { |arg| arg.type == :mlhs }
      end

      def has_trailing_comma_in_args?
        if args.loc && args.loc.expression
          args_source = args.loc.expression.source
          args_source.match(/,\s*\|/)
        end
      end

      # Returns code used in debug mode to check arity of method call
      def compile_arity_check
        if arity_checks.size > 0
          parent_scope = scope
          while !(parent_scope.top? || parent_scope.def? || parent_scope.class_scope?)
            parent_scope = parent_scope.parent
          end

          context = if parent_scope.top?
            "'<main>'"
          elsif parent_scope.def?
            "'#{parent_scope.mid}'"
          elsif parent_scope.class?
            "'<class:#{parent_scope.name}>'"
          elsif parent_scope.module?
            "'<module:#{parent_scope.name}>'"
          end

          identity = scope.identity

          line "if (#{identity}.$$is_lambda || #{identity}.$$define_meth) {"
          line "  var $arity = arguments.length;"
          line "  if (#{arity_checks.join(' || ')}) { Opal.block_ac($arity, #{arity}, #{context}); }"
          line "}"
        end
      end

      def contains_break?
        finder = Opal::Rewriters::BreakFinder.new
        finder.process(@sexp)
        finder.found_break?
      end
    end
  end
end
