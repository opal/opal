require 'opal/nodes/scope'

module Opal
  module Nodes
    class IterNode < ScopeNode
      handle :iter
      children :args_sexp, :body_sexp

      def compile
        opt_args  = extract_opt_args
        block_arg = extract_block_arg
        params    = args_to_params(args.children)
        body_code = nil

        in_scope do
          add_temp "self = #{identify!}.$$s || this"

          compile_args(args.children, opt_args, params)

          if block_arg
            scope.block_name = block_arg
            scope.add_temp block_arg
            line "#{block_arg} = #{identify!}.$$p || nil, #{identify!}.$$p = null;"
          end

          body_code = stmt(body)
        end

        line body_code
        unshift to_vars

        unshift "(#{identity} = function(#{params.join ', '}){"
        push "}, #{identity}.$$s = self, #{identity})"
      end

      def compile_args(args, opt_args, params)
        args.each_with_index do |arg, idx|
          if arg.type == :lasgn
            var = variable(arg[1])
            if opt_args and current_opt = opt_args.find { |s| s[1] == var.to_sym }
              push "if (#{var} == null) #{var} = ", expr(current_opt[2]), "; "
            else
              push "if (#{var} == null) #{var} = nil; "
            end
          elsif arg.type == :array
            next if arg.children.empty?
            push "var "
            arg.children.each_with_index do |child, child_idx|
              var = variable(child[1])
              push ", " unless child_idx == 0
              push "#{var} = #{params[idx]}[#{child_idx}]"
            end
            push "; "
          elsif arg.type == :splat
            push "#{params[idx]} = $slice.call(arguments, #{idx}); "
          else
            raise "Bad block arg type"
          end
        end
      end

      # opt args are last (if present) and are a s(:block)
      def extract_opt_args
        if args.children.last && args.children.last.type == :block
          args.pop.children
        end
      end

      # does this iter define a block_pass?
      def extract_block_arg
        if args.children.last && args.children.last.type == :block_pass
          block_arg = args.pop
          block_arg = block_arg[1][1].to_sym
        end
      end

      def args
        if Fixnum === args_sexp or args_sexp.nil?
          s(:array)
        elsif args_sexp.type == :lasgn
          s(:array, args_sexp)
        else
          args_sexp[1]
        end
      end

      def body
        compiler.returns(body_sexp || s(:nil))
      end

      # Maps block args into array of jsid. Adds $ suffix to invalid js
      # identifiers.
      #
      # s(:args, parts...) => ["a", "b", "break$"]
      def args_to_params(sexp)
        sexp.each_with_object([]) do |arg, result|
          if arg.type == :lasgn
            ref = variable(arg[1])
            if ref == :_ && result.include?(:_)
              # so that the number of arguments is correct, we need to put
              # something here. but we don't want to put _, because that would
              # cause the LAST _ parameter to be assigned, and we want the FIRST
              # such parameter to be assigned
              # just put a unique name which will not be used for anything else
              result << new_temp
            else
              add_arg ref
              result << ref
            end
          elsif arg.type == :array
            result << new_temp
          elsif arg.type == :splat
            splat = arg[1][1]
            add_arg splat
            result << splat
          else
            raise "Bad js_block_arg: #{arg[0]}"
          end
        end
      end
    end
  end
end
