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

      def compile
        children.each_with_index do |arg, idx|
          push ', ' if idx != 0
          push process(arg)
        end
      end
    end
  end
end
