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
        pre_splat  = args.take_while { |a| a.type != :splat }
        post_splat = args.drop(pre_splat.size)

        pre_splat.zip(params).each do |arg, param|
          if arg.type == :lasgn
            compile_normal_arg(arg, opt_args)
          elsif arg.type == :array
            compile_destructuring(arg, param)
          else
            raise "Unexpected arg type: #{arg}"
          end
        end

        unless post_splat.empty?
          splat = post_splat.shift
          splat_var = splat[1][1]

          if post_splat.empty?
            # trailing splat
            if splat_var != :""
              line "#{splat_var} = $slice.call(arguments, #{pre_splat.size});"
            end
          else
            tmp = scope.new_temp # end index for items consumed by splat

            if splat_var != :""
              line "#{tmp} = arguments.length - #{post_splat.size};"
              line "#{tmp} = (#{tmp} < #{pre_splat.size}) ? #{pre_splat.size} : #{tmp};"
              line "#{splat_var} = $slice.call(arguments, #{pre_splat.size}, #{tmp});"
            end

            post_splat.each_with_index do |arg, idx|
              val = (idx == 0) ? "arguments[#{tmp}]" : "arguments[#{tmp} + #{idx}]"

              if arg.type == :lasgn
                compile_post_splat_arg(arg, val, opt_args)
              else
                raise "Unexpected arg type: #{arg}"
              end
            end

            scope.queue_temp(tmp)
          end
        end
      end

      def compile_normal_arg(arg, opt_args)
        var = variable(arg[1])
        if opt_args and current_opt = opt_args.find { |s| s[1] == var.to_sym }
          line "if (#{var} == null) #{var} = ", expr(current_opt[2]), ";"
        else
          line "if (#{var} == null) #{var} = nil;"
        end
      end

      def compile_destructuring(arg, param)
        # TODO: this will only work with one level of destructuring
        return if arg.children.empty?
        push "var "
        arg.children.each_with_index do |child, child_idx|
          var = variable(child[1])
          push ", " unless child_idx == 0
          push "#{var} = #{param}[#{child_idx}]"
        end
        push "; "
      end

      def compile_post_splat_arg(arg, val, opt_args)
        var = variable(arg[1])
        line "#{var} = #{val};"
        if opt_args and current_opt = opt_args.find { |s| s[1] == var.to_sym }
          line "if (#{var} == null) #{var} = #{expr(current_opt[2])};"
        else
          line "if (#{var} == null) #{var} = nil;"
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
      # The returned array will be used for emitting the parameter list for
      # the JS function which this block compiles to.
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
            if splat != :""
              add_arg splat
            end
            result << splat
          else
            raise "Bad block arg: #{arg}"
          end
        end
      end
    end
  end
end
