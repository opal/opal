require 'opal/nodes/node_with_args'

module Opal
  module Nodes
    class IterNode < NodeWithArgs
      handle :iter

      children :args_sexp, :body_sexp

      attr_accessor :block_arg, :shadow_args

      def compile
        params = nil
        extract_block_arg
        extract_shadow_args

        to_vars = identity = body_code = nil

        in_scope do
          params = process(args)

          identity = scope.identify!
          add_temp "self = #{identity}.$$s || this"

          compile_shadow_args
          compile_norm_args
          compile_mlhs_args
          compile_rest_arg
          compile_opt_args
          compile_keyword_args
          compile_block_arg

          body_code = stmt(body)
          to_vars = scope.to_vars
        end

        line body_code

        unshift to_vars

        if args[1..-1].any?
          unshift "(#{identity} = function(", params, "){"
        else
          unshift "(#{identity} = function(){"
        end
        push "}, #{identity}.$$s = self,"
        # TODO: Compiler config, default of false
        include_source_in_code = true
        if include_source_in_code
          file_path = File.expand_path("#{compiler.file}.rb")
          push " #{identity}.$$sourcemap = {line: #{body_sexp.line}, column: #{body_sexp.column}, file: '#{file_path}'},"
        end
        push " #{identity}.$$brk = $brk," if compiler.has_break?
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

      def compile_mlhs_args
        mlhs_args.each do |arg|
          # arg is (:mhls, (:arg, :a), (:arg, :b))
          # source is a raw JS representation of |(a, b)|
          source = scope.mlhs_mapping[arg]

          if arg.children.length == 1
            # "do |(a)|" case
            child = arg.children.first
            var = variable(child.last)
            line "if (#{source} == null || !#{source}.$$is_array) {"
            line "  #{var} = #{source};"
            line "} else {"
            line "  #{var} = #{source}[0];"
            line "}"
          else
            # No support for nested mlhs yet.
            non_mlhs_children = arg.children.select { |child| child.type != :mlhs }

            # decompressing |(a, b)| argument
            line "if (#{source} == null || !#{source}.$$is_array) {"
            indent do
              non_mlhs_children.each_with_index do |child, idx|
                var = variable(child.last)
                if idx == 0
                  line "if (#{source} != null) {"
                  line "  #{var} = #{source};"
                  line "} else {"
                  line "  #{var} = nil;"
                  line "}"
                else
                  line "#{var} = nil;"
                end
              end
            end
            line "} else {"
            non_mlhs_children.each_with_index do |child, idx|
              var = variable(child.last)
              line "  #{var} = #{source}[#{idx}];"
            end
            line "}"
          end
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
          s(:args, args_sexp)
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
    end
  end
end
