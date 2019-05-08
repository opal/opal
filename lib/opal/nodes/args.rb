# frozen_string_literal: true

require 'opal/nodes/base'

require 'opal/nodes/args/arg'
require 'opal/nodes/args/arity_check'
require 'opal/nodes/args/ensure_kwargs_are_kwargs'
require 'opal/nodes/args/extract_block_arg'
require 'opal/nodes/args/extract_kwarg'
require 'opal/nodes/args/extract_kwargs'
require 'opal/nodes/args/extract_kwoptarg'
require 'opal/nodes/args/extract_kwrestarg'
require 'opal/nodes/args/extract_optarg'
require 'opal/nodes/args/extract_post_arg'
require 'opal/nodes/args/extract_post_optarg'
require 'opal/nodes/args/extract_restarg'
require 'opal/nodes/args/fake_arg'
require 'opal/nodes/args/initialize_iterarg'
require 'opal/nodes/args/initialize_shadowarg'
require 'opal/nodes/args/parameters'
require 'opal/nodes/args/prepare_post_args'

module Opal
  module Nodes
    class ArgsNode < Base
      handle :args

      # ruby allows for args with the same name, if the arg starts with a '_', like:
      #   def funny_method_name(_, _)
      #     puts _
      #   end
      # but javascript in strict mode does not allow for args with the same name
      # ruby assigns the value of the first arg given
      #   funny_method_name(1, 2) => 1
      # 1. check for args starting with '_'
      # 2. check if they appear multiple times
      # 3. leave the first appearance as it is and rename the other ones
      # compiler result:
      #   function $$funny_method_name(_, __opal_js_strict_mode_arg_2)

      def compile
        same_arg_counter = {}
        children.each_with_index do |arg, idx|

          if arg.children.count == 1 && arg.children.first.to_s.start_with?('_')
            arg_count = children.count(arg)
            if arg_count > 1 && arg.type == :arg
              same_arg_counter[arg] = 0 unless same_arg_counter.has_key?(arg)
              same_arg_counter[arg] += 1
              if same_arg_counter[arg] > 1
                arg = Opal::AST::Node.new(arg.type, [:"#{arg.children[0]}_opal_js_strict_mode_arg_#{same_arg_counter[arg]}"])
              end
            end
          end

          push ', ' if idx != 0
          push process(arg)
        end
      end
    end
  end
end
