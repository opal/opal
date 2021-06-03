# frozen_string_literal: true

require 'opal/nodes/scope'
require 'opal/nodes/args/parameters'

module Opal
  module Nodes
    class NodeWithArgs < ScopeNode
      attr_reader :used_kwargs
      attr_accessor :arity
      attr_reader :original_args

      def initialize(*)
        super

        @original_args = @sexp.meta[:original_args]
        @used_kwargs = []
        @arity = 0
      end

      def arity_check_node
        s(:arity_check, original_args)
      end

      # Returns code used in debug mode to check arity of method call
      def compile_arity_check
        push process(arity_check_node)
      end

      def compile_block_arg
        if scope.uses_block?
          scope_name  = scope.identity
          yielder     = scope.block_name || '$yield'

          add_temp "$iter = #{scope_name}[Opal.s.$$p]"
          add_temp "#{yielder} = $iter || nil"

          line "if ($iter) #{scope_name}[Opal.s.$$p] = null;"
        end
      end

      def parameters_code
        Args::Parameters.new(original_args).to_code
      end
    end
  end
end
