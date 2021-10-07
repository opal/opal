# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rubyspec
    class FiltersRewriter < Opal::Rewriters::Base
      class << self
        def filters
          @filters ||= []
        end

        def filter(spec_name)
          filters << spec_name
        end

        alias fails filter
        alias fails_badly filter

        def filtered?(spec_name)
          filters.include?(spec_name)
        end

        def clear_filters!
          @filters = []
        end
      end

      def initialize
        @specs_stack = []
      end

      RUBYSPEC_DSL = %i[describe it context].freeze

      def on_send(node)
        _recvr, method_name, *args = *node

        if rubyspec_dsl?(method_name)
          spec_name, _ = *args.first
          begin
            @specs_stack.push(spec_name)
            if skip?
              s(:nil)
            else
              super
            end
          ensure
            @specs_stack.pop
          end
        elsif method_name == :fixture
          # We want to expand the fixture paths before autoload happens.
          if args.all? { |i| i.type == :str }
            as = args.map { |i| i.children.first }
            s(:str, fixture(*as))
          else
            super
          end
        else
          super
        end
      end

      def skip?
        self.class.filtered?(current_spec_name)
      end

      def rubyspec_dsl?(method_name)
        RUBYSPEC_DSL.include?(method_name)
      end

      def current_spec_name
        @specs_stack.join(' ')
      end

      # Adapted from: spec/mspec/lib/mspec/helpers/fixture.rb
      def fixture(file, *args)
        path = File.dirname(file)
        path = path[0..-7] if path[-7..-1] == '/shared'
        fixtures = path[-9..-1] == '/fixtures' ? '' : 'fixtures'
        File.join(path, fixtures, args)
      end
    end
  end
end
