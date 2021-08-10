# frozen_string_literal: true

module Opal
  module Rewriters
    class Arguments
      attr_reader :args, :optargs, :restarg, :postargs,
        :kwargs, :kwoptargs, :kwrestarg, :kwnilarg,
        :shadowargs, :blockarg

      def initialize(args)
        @args = []
        @optargs = []
        @restarg = nil
        @postargs = []
        @kwargs = []
        @kwoptargs = []
        @kwrestarg = nil
        @kwnilarg = false
        @shadowargs = []
        @blockarg = nil

        args.each do |arg|
          case arg.type
          when :arg, :mlhs
            (@restarg || @optargs.any? ? @postargs : @args) << arg
          when :optarg
            @optargs << arg
          when :restarg
            @restarg = arg
          when :kwarg
            @kwargs << arg
          when :kwoptarg
            @kwoptargs << arg
          when :kwnilarg
            @kwnilarg = true
          when :kwrestarg
            @kwrestarg = arg
          when :shadowarg
            @shadowargs << arg
          when :blockarg
            @blockarg = arg
          else
            raise "Unsupported arg type #{arg.type}"
          end
        end
      end

      def has_post_args?
        !@restarg.nil? || @postargs.any? || (has_any_kwargs? && !can_inline_kwargs?)
      end

      def has_any_kwargs?
        @kwargs.any? || @kwoptargs.any? || !@kwrestarg.nil?
      end

      def can_inline_kwargs?
        @optargs.empty? && @restarg.nil? && @postargs.empty?
      end
    end
  end
end
