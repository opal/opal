# frozen_string_literal: true

# rubocop:disable Layout/EmptyLineBetweenDefs, Style/SingleLineMethods
module Opal
  module Rewriters
    # ThrowerFinder attempts to track the presence of throwers, like
    # break, redo, so we can make an informed guess in the early
    # compilation phase before traversing other nodes whether we
    # want to track a closure. Tracking a closure is often a deoptimizing
    # step, so we want to get that knowledge earlier.
    class ThrowerFinder < Opal::Rewriters::Base
      def initialize
        @break_stack = []
        @redo_stack = []
        @rescue_else_stack = []
      end

      def on_break(node)
        tracking(:break, @break_stack)
        super
      end

      def on_redo(node)
        tracking(:redo, @redo_stack)
        super
      end

      def on_iter(node)
        pushing(@break_stack => node) { super }
      end

      def on_loop(node, &block)
        pushing(@redo_stack => node, @break_stack => nil, &block)
      end

      def on_for(node);        on_loop(node) { super }; end
      def on_while(node);      on_loop(node) { super }; end
      def on_while_post(node); on_loop(node) { super }; end
      def on_until(node);      on_loop(node) { super }; end
      def on_until_post(node); on_loop(node) { super }; end

      # ignore throwers inside defined
      def on_defined(node)
        pushing(@redo_stack => nil, @break_stack => nil) { super }
      end

      # In Opal we handle rescue-else either in ensure or in
      # rescue. If ensure is present, we handle it in ensure.
      # Otherwise we handle it in rescue. ensure is always
      # above a rescue. This logic is about tracking if a given
      # ensure node should expect a rescue-else inside a
      # rescue node.
      def on_ensure(node)
        pushing(@rescue_else_stack => node) { super }
      end

      def on_rescue(node)
        if node.children[1..-1].detect { |sexp| sexp && sexp.type != :resbody }
          tracking(:rescue_else, @rescue_else_stack)
        end

        pushing(@rescue_else_stack => nil) { super }
      end

      private

      def pushing(stacks)
        stacks.each { |stack, node| stack.push(node) }
        result = yield
        stacks.keys.each(&:pop)
        result
      end

      def tracking(breaker, stack)
        if stack.last
          stack.last.meta[:"has_#{breaker}"] = true
        end
      end
    end
  end
end
# rubocop:enable Layout/EmptyLineBetweenDefs, Style/SingleLineMethods
