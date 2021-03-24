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
            public_send(:"on_#{arg.type}", *arg)
          end

          "[#{stringified_parameters.compact.join(', ')}]"
        end

        def on_arg(arg_name)
          %{['req', '#{arg_name}']}
        end

        def on_mlhs(*)
          %{['req']}
        end

        def on_optarg(arg_name, _default_value)
          %{['opt', '#{arg_name}']}
        end

        def on_restarg(arg_name = nil)
          if arg_name
            arg_name = :* if arg_name == :fwd_rest_arg
            %{['rest', '#{arg_name}']}
          else
            %{['rest']}
          end
        end

        def on_kwarg(arg_name)
          %{['keyreq', '#{arg_name}']}
        end

        def on_kwoptarg(arg_name, _default_value)
          %{['key', '#{arg_name}']}
        end

        def on_kwrestarg(arg_name = nil)
          if arg_name
            %{['keyrest', '#{arg_name}']}
          else
            %{['keyrest']}
          end
        end

        def on_blockarg(arg_name)
          arg_name = :& if arg_name == :fwd_block_arg
          %{['block', '#{arg_name}']}
        end

        def on_shadowarg(_arg_name); end
      end
    end
  end
end
