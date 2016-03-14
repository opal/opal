require 'opal/nodes/base'

module Opal
  module Nodes
    # def args list
    class InlineArgs < Base
      handle :inline_args

      def compile
        push(arg_names.join(', '))
      end

      def arg_names
        done_kwargs = false

        children.inject([]) do |result, child|
          case child.type
          when :kwarg, :kwoptarg, :kwrestarg
            unless done_kwargs
              done_kwargs = true
              result << '$kwargs'
            end
            add_arg(child)
          when :mlhs
            tmp = scope.next_temp
            result << tmp
            scope.mlhs_mapping[child] = tmp
          when :arg, :optarg
            arg_name = variable(child[1]).to_s
            if !child.meta[:inline] && arg_name[0] != '$'
              arg_name = "$#{arg_name}"
            end
            result << arg_name
            add_arg(child)
          when :restarg
            # To make function.length working
            # in cases like def m(*rest)
            tmp_arg_name = scope.next_temp + "_rest"
            result << tmp_arg_name
            add_arg(child)
          else
            raise "Unknown argument type #{child.inspect}"
          end

          result
        end
      end

      # If the argument has a name,
      # we should mark it as an argument for current scope
      # Otherwise, these args will be interpreted
      # in the child scope as local variables
      def add_arg(arg)
        if arg[1]
          arg_name = variable(arg[1].to_sym)
          scope.add_arg(arg_name)
        end
      end
    end
  end
end
