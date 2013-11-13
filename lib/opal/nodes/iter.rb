require 'opal/nodes/scope'

module Opal
  module Nodes
    # FIXME: this needs a rewrite very urgently
    class IterNode < BaseScopeNode
      handle :iter

      children :args_sexp, :body_sexp

      def compile
        # opt args are last (if present) and are a s(:block)
        if args.last.is_a?(Sexp) and args.last.type == :block
          opt_args = args.pop
          opt_args.shift
        end

        # does this iter define a block_pass
        if args.last.is_a?(Sexp) and args.last.type == :block_pass
          block_arg = args.pop
          block_arg = block_arg[1][1].to_sym
        end

        # find any splat args
        if args.last.is_a?(Sexp) and args.last.type == :splat
          splat = args.last[1][1]
          args.pop
          len = args.length
        end

        params = args_to_params(args[1..-1])
        params << splat if splat

        to_vars = identity = nil

        in_scope(:iter) do
          identity = scope.identify!
          add_temp "self = #{identity}._s || this"


          args[1..-1].each_with_index do |arg, idx|
            if arg.type == :lasgn
              arg = variable(arg[1])

              if opt_args and current_opt = opt_args.find { |s| s[1] == arg.to_sym }
                push "if (#{arg} == null) #{arg} = ", expr(current_opt[2]), ";"
              else
                push "if (#{arg} == null) #{arg} = nil;"
              end
            elsif arg.type == :array
              arg[1..-1].each_with_index do |_arg, _idx|
                _arg = variable(_arg[1])
                push "#{_arg} = #{params[idx]}[#{_idx}];"
              end
            else
              raise "Bad block arg type"
            end
          end

          if splat
            scope.add_arg splat
            push "#{splat} = $slice.call(arguments, #{len - 1});"
          end

          if block_arg
            scope.block_name = block_arg
            scope.add_temp block_arg
            scope_name = scope.identify!

            line "#{block_arg} = #{scope_name}._p || nil, #{scope_name}._p = null;"
          end

          line stmt(body)
          to_vars = scope.to_vars
        end

        unshift to_vars
        unshift "function(#{params.join ', '}) {"
        wrap "(#{identity} = ", "}, #{identity}._s = self, #{identity})"
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
        result = []
        sexp.each do |arg|
          if arg[0] == :lasgn
            ref = variable(arg[1])
            scope.add_arg ref
            result << ref
          elsif arg[0] == :array
            result << scope.next_temp
          else
            raise "Bad js_block_arg: #{arg[0]}"
          end
        end

        result
      end
    end
  end
end
