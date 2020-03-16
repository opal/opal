# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/rewriters/arguments'

module Opal
  module Nodes
    class ArityCheckNode < Base
      handle :arity_check
      children :args_node

      def initialize(*)
        super

        arguments = Rewriters::Arguments.new(args_node.children)

        @args      = arguments.args
        @optargs   = arguments.optargs
        @restarg   = arguments.restarg
        @postargs  = arguments.postargs
        @kwargs    = arguments.kwargs
        @kwoptargs = arguments.kwoptargs
        @kwrestarg = arguments.kwrestarg
      end

      def compile
        scope.arity = arity

        return unless compiler.arity_check?

        unless arity_checks.empty?
          helper :ac
          meth = scope.mid.to_s.inspect
          line 'var $arity = arguments.length;'
          push " if (#{arity_checks.join(' || ')}) { $ac($arity, #{arity}, this, #{meth}); }"
        end
      end

      def kwargs
        [*@kwargs, *@kwoptargs, @kwrestarg].compact
      end

      def all_args
        @all_args ||= [*@args, *@optargs, @restarg, *@postargs, *kwargs].compact
      end

      # Returns an array of JS conditions for raising and argument
      # error caused by arity check
      def arity_checks
        return @arity_checks if defined?(@arity_checks)

        arity = all_args.size
        arity -= @optargs.size

        arity -= 1 if @restarg

        arity -= kwargs.size

        arity = -arity - 1 if !@optargs.empty? || !kwargs.empty? || @restarg

        @arity_checks = []

        if arity < 0 # splat or opt args
          min_arity = -(arity + 1)
          max_arity = all_args.size
          @arity_checks << "$arity < #{min_arity}" if min_arity > 0
          @arity_checks << "$arity > #{max_arity}" unless @restarg
        else
          @arity_checks << "$arity !== #{arity}"
        end

        @arity_checks
      end

      def arity
        if @restarg || @optargs.any? || has_only_optional_kwargs?
          negative_arity
        else
          positive_arity
        end
      end

      def negative_arity
        required_plain_args = all_args.select do |arg|
          %i[arg mlhs].include?(arg.type)
        end

        result = required_plain_args.size

        if has_required_kwargs?
          result += 1
        end

        result = -result - 1

        result
      end

      def positive_arity
        result = all_args.size

        result -= kwargs.size
        result += 1 if kwargs.any?

        result
      end

      def has_only_optional_kwargs?
        kwargs.any? && kwargs.all? { |arg| %i[kwoptarg kwrestarg].include?(arg.type) }
      end

      def has_required_kwargs?
        kwargs.any? { |arg| arg.type == :kwarg }
      end
    end

    class IterArityCheckNode < ArityCheckNode
      handle :iter_arity_check

      def compile
        scope.arity = arity

        return unless compiler.arity_check?

        unless arity_checks.empty?
          parent_scope = scope
          until parent_scope.def? || parent_scope.class_scope? || parent_scope.top?
            parent_scope = parent_scope.parent
          end

          context =
            if parent_scope.top?
              "'<main>'"
            elsif parent_scope.def?
              "'#{parent_scope.mid}'"
            elsif parent_scope.class?
              "'<class:#{parent_scope.name}>'"
            elsif parent_scope.module?
              "'<module:#{parent_scope.name}>'"
            end

          identity = scope.identity

          line "if (#{identity}.$$is_lambda || #{identity}.$$define_meth) {"
          line '  var $arity = arguments.length;'
          line "  if (#{arity_checks.join(' || ')}) { Opal.block_ac($arity, #{arity}, #{context}); }"
          line '}'
        end
      end
    end
  end
end
