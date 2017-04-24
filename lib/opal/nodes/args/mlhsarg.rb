# frozen_string_literal: true
require 'opal/nodes/base'

module Opal
  module Nodes
    # A node responsible for extracting a
    # single MLHS argument
    #
    # MLHS argument is the left hand side
    # of a multiple assignment (Multiple Left Hand Side)
    #
    # def m((a, b))
    # def m((a, *b))
    #
    # MLHS can include simple arguments (see NormargNode)
    # and rest arguments (see RestargNode)
    #
    class MlhsArgNode < Base
      handle :mlhs

      def compile
        args_sexp = s(:post_args, *children)

        if @sexp.meta[:post]
          # In this case source is an item in the current scope.working_arguments
          # First we should extract mlhs as a simple argument
          mlhs_sexp = s(:arg, mlhs_name)
          mlhs_sexp.meta[:post] = true
          scope.with_inline_args([]) do
            push process(mlhs_sexp)
          end
          var_name = args_sexp.meta[:js_source] = mlhs_name
        else
          # Otherwise we already have it in our scope.working_arguments
          # (of course, in this case scope.working_arguments = 'arguments')
          var_name = args_sexp.meta[:js_source] = scope.mlhs_mapping[@sexp]
        end

        line "if (#{var_name} == null) {"
        line "  #{var_name} = nil;"
        line "}"

        line "#{var_name} = Opal.to_ary(#{var_name});"

        scope.with_inline_args([]) do
          scope.in_mlhs do
            push process(args_sexp)
          end
        end
      end

      def mlhs_name
        @mlhs_name ||= begin
          if @sexp.meta[:post]
            result = ["$mlhs_of"]

            children.each do |child|
              case child.type
              when :arg
                result << child.children[0]
              when :mlhs
                result << 'mlhs'
              end
            end

            result.join("_")
          else
            @sexp.children[0].to_s
          end
        end
      end

      def inline_args
        @inline_args ||= children.take_while { |arg| arg.type != :restarg && arg.type != :optarg }
      end
    end
  end
end
