# frozen_string_literal: true

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

        children.each_with_object([]) do |arg, result|
          case arg.type
          when :kwarg, :kwoptarg, :kwrestarg
            unless done_kwargs
              done_kwargs = true
              result << '$kwargs'
            end
            add_arg(arg)
          when :mlhs
            tmp = scope.next_temp
            result << tmp
            scope.mlhs_mapping[arg] = tmp
          when :arg, :optarg
            arg_name, = *arg
            if !arg.meta[:inline] && arg_name[0] != '$'
              arg_name = "$#{arg_name}"
            end
            result << arg_name
            add_arg(arg)
          when :restarg
            # To make function.length working
            # in cases like def m(*rest)
            tmp_arg_name = scope.next_temp + '_rest'
            result << tmp_arg_name
            add_arg(arg)
          else
            raise "Unknown argument type #{arg.inspect}"
          end
        end
      end

      # If the argument has a name,
      # we should mark it as an argument for current scope
      # Otherwise, these args will be interpreted
      # in the child scope as local variables
      def add_arg(arg)
        arg_name, = *arg
        scope.add_arg(arg_name) if arg_name
      end
    end
  end
end
