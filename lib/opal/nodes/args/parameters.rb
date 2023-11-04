# frozen_string_literal: true

module Opal
  module Nodes
    module Args
      class Parameters
        def initialize(args)
          @args = args.children
        end

        def to_code
          stringified_parameters = @args.map do |arg|
            public_send(:"on_#{arg.type}", arg)
          end

          "[#{stringified_parameters.compact.join(', ')}]"
        end

        def on_arg(arg)
          arg_name = arg.meta[:arg_name]
          %{['req', '#{arg_name}']}
        end

        def on_mlhs(_arg)
          %{['req']}
        end

        def on_optarg(arg)
          arg_name = arg.meta[:arg_name]
          %{['opt', '#{arg_name}']}
        end

        def on_restarg(arg)
          arg_name = arg.meta[:arg_name]
          if arg_name
            arg_name = :* if arg_name == :fwd_rest_arg
            %{['rest', '#{arg_name}']}
          else
            %{['rest']}
          end
        end

        def on_kwarg(arg)
          arg_name = arg.meta[:arg_name]
          %{['keyreq', '#{arg_name}']}
        end

        def on_kwoptarg(arg)
          arg_name = arg.meta[:arg_name]
          %{['key', '#{arg_name}']}
        end

        def on_kwrestarg(arg)
          arg_name = arg.meta[:arg_name]
          if arg_name
            %{['keyrest', '#{arg_name}']}
          else
            %{['keyrest']}
          end
        end

        def on_blockarg(arg)
          arg_name = arg.meta[:arg_name]
          arg_name = :& if arg_name == :fwd_block_arg
          %{['block', '#{arg_name}']}
        end

        def on_kwnilarg(_arg)
          %{['nokey']}
        end

        def on_shadowarg(_arg); end
      end
    end
  end
end
