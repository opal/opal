require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    class IterNode < NodeWithArgs
      handle :iter

      children :args_sexp, :body_sexp

      attr_accessor :block_arg, :shadow_args

      def compile
        inline_params = nil
        extract_block_arg
        extract_shadow_args
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

          body_code = stmt(body)
          to_vars = scope.to_vars
        end

        line body_code

        unshift to_vars

        unshift "(#{identity} = function(", inline_params, "){"
        push "}, #{identity}.$$s = self,"
        push " #{identity}.$$brk = $brk," if compiler.has_break?
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
        @norm_args ||= args[1..-1].select { |arg| arg.type == :arg }
      end

      def compile_norm_args
        norm_args.each do |arg|
          arg = variable(arg[1])
          push "if (#{arg} == null) #{arg} = nil;"
        end
      end

      def compile_block_arg
        if block_arg
          scope.block_name = block_arg
          scope.add_temp block_arg
          scope_name = scope.identify!

          line "#{block_arg} = #{scope_name}.$$p || nil, #{scope_name}.$$p = null;"
        end
      end

      def extract_block_arg
        if args.is_a?(Sexp) && args.last.is_a?(Sexp) and args.last.type == :block_pass
          self.block_arg = args.pop[1][1].to_sym
        end
      end

      def compile_shadow_args
        shadow_args.each do |shadow_arg|
          scope.add_local(shadow_arg.last)
        end
      end

      def extract_shadow_args
        if args.is_a?(Sexp)
          @shadow_args = []
          args.children.each_with_index do |arg, idx|
            if arg.type == :shadowarg
              @shadow_args << args.delete(arg)
            end
          end
        end
      end

      def args
        sexp = if Fixnum === args_sexp or args_sexp.nil?
          s(:args)
        elsif args_sexp.is_a?(Sexp) && args_sexp.type == :lasgn
          s(:args, s(:arg, *args_sexp[1]))
        else
          args_sexp[1]
        end

        # compacting _ arguments into a single one (only the first one leaves in the sexp)
        caught_blank_argument = false

        sexp.each_with_index do |part, idx|
          if part.is_a?(Sexp) && part.last == :_
            if caught_blank_argument
              sexp.delete_at(idx)
            end
            caught_blank_argument = true
          end
        end

        sexp
      end

      def body
        compiler.returns(body_sexp || s(:nil))
      end

      def mlhs_args
        scope.mlhs_mapping.keys
      end

      def has_top_level_mlhs_arg?
        args.children.any? { |arg| arg.type == :mlhs }
      end

      def has_trailing_comma_in_args?
        args.meta[:has_trailing_comma]
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
          line "if (#{scope.identity}.$$is_lambda) {"
          line "  var $arity = arguments.length;"
          line "  if (#{arity_checks.join(' || ')}) { Opal.block_ac($arity, #{arity}, #{context}); }"
          line "}"
        end
      end
    end
  end
end
