# frozen_string_literal: true

require 'opal/rewriters/base'
require 'opal/rewriters/arguments'

module Opal
  module Rewriters
    # Converts
    #
    #   def m( a, b = 1, *c, d, e:, f: 1, **g, &blk )
    #   end
    #
    # To something like
    #
    #   def m( a, <fake b>, <fake c>, <fake d>, <fake kwargs>)
    #     blk = <extract block>
    #     $post_args = arguments[1..-1]
    #     $kwargs = $post_args.pop
    #     a = <enough args> ? $post_args.shift : 1
    #     c = <enough args> ? $post_args[0..-1] : []
    #     d = $post_args.last
    #     e = $kwargs.delete(:e)
    #     f = $kwargs.delete(:f) || 1
    #     g = $kwargs.except(:e, :f)
    #   end
    #
    class InlineArgs < Base
      def on_def(node)
        node = super(node)
        mid, args, body = *node

        body ||= s(:nil) # prevent returning initialization statement

        initializer = Initializer.new(args, type: :def)
        inline_args = args.updated(nil, initializer.inline)
        body = prepend_to_body(body, initializer.initialization)

        node.updated(nil, [mid, inline_args, body])
      end

      def on_defs(node)
        node = super(node)
        recv, mid, args, body = *node

        body ||= s(:nil) # prevent returning initialization statement

        initializer = Initializer.new(args, type: :defs)
        inline_args = args.updated(nil, initializer.inline)
        body = prepend_to_body(body, initializer.initialization)

        node.updated(nil, [recv, mid, inline_args, body])
      end

      def on_iter(node)
        node = super(node)
        args, body = *node

        body ||= s(:nil) # prevent returning initialization statement

        initializer = Initializer.new(args, type: :iter)
        inline_args = args.updated(nil, initializer.inline)
        body = prepend_to_body(body, initializer.initialization)

        node.updated(nil, [inline_args, body])
      end

      class Initializer < ::Opal::Rewriters::Base
        attr_reader :inline, :initialization

        STEPS = %i[
          extract_blockarg
          initialize_shadowargs
          extract_args

          prepare_post_args
          prepare_kwargs

          extract_optargs
          extract_restarg
          extract_post_args

          extract_kwargs
          extract_kwoptargs
          extract_kwrestarg
        ].freeze

        def initialize(args, type:)
          @args = Arguments.new(args.children)

          @inline = []
          @initialization = []

          @type = type
          @underscore_found = false

          STEPS.each do |step|
            send(step)
          end

          if @initialization.any?
            @initialization = s(:begin, *@initialization)
          else
            @initialization = nil
          end
        end

        def extract_blockarg
          if (arg = @args.blockarg)
            @initialization << arg.updated(:extract_blockarg)
          end
        end

        def initialize_shadowargs
          @args.shadowargs.each do |arg|
            @initialization << arg.updated(:initialize_shadowarg)
          end
        end

        def extract_args
          @args.args.each do |arg|
            if @type == :iter
              # block args are not required,
              # so we neeed to tell compiler that required args
              # must be initialized with nil-s
              @initialization << arg.updated(:initialize_iter_arg)

              if arg.children[0] == :_
                if @underscore_found
                  # for proc { |_, _| _ }.call(1, 2) result must be 1
                  # here we convert all underscore args starting from the 2nd
                  # to a "fake" arg
                  arg = s(:fake_arg)
                end

                @underscore_found = true
              end
            else
              # required inline def argument like 'def m(req)'
              # no initialization is required
            end
            @inline << arg
          end
        end

        def prepare_post_args
          if @args.has_post_args?
            @initialization << s(:prepare_post_args, @args.args.length)
          end
        end

        def prepare_kwargs
          return unless @args.has_any_kwargs?

          if @args.can_inline_kwargs?
            @inline << s(:arg, :'$kwargs')
          else
            @initialization << s(:extract_kwargs)
            @inline << s(:fake_arg)
          end

          @initialization << s(:ensure_kwargs_are_kwargs)
        end

        def extract_kwargs
          @args.kwargs.each do |arg|
            @initialization << arg.updated(:extract_kwarg)
          end
        end

        def extract_kwoptargs
          @args.kwoptargs.each do |arg|
            @initialization << arg.updated(:extract_kwoptarg)
          end
        end

        def extract_kwrestarg
          if (arg = @args.kwrestarg)
            @initialization << arg.updated(:extract_kwrestarg)
          end
        end

        def extract_post_args
          # post arguments must be extracted with an offset
          @args.postargs.each do |arg|
            @initialization << arg.updated(:extract_post_arg)
            @inline << s(:fake_arg)
          end
        end

        def extract_optargs
          has_post_args = @args.has_post_args?
          @args.optargs.each do |arg|
            if has_post_args
              # optional post argument like 'def m(opt = 1, a)'
              arg_name, default_value = *arg
              @initialization << arg.updated(:extract_post_optarg, [arg_name, default_value, args_to_keep])
              @inline << s(:fake_arg)
            else
              # optional inline argument like 'def m(a, opt = 1)'
              @inline << arg.updated(:arg)
              @initialization << arg.updated(:extract_optarg)
            end
          end
        end

        def extract_restarg
          if (arg = @args.restarg)
            arg_name = arg.children[0]
            @initialization << arg.updated(:extract_restarg, [arg_name, args_to_keep])
            @inline << s(:fake_arg)
          end
        end

        def args_to_keep
          @args.postargs.length
        end
      end
    end
  end
end
