# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class ForRewriter < Base
      def self.reset_tmp_counter!
        @counter = 0
      end

      def self.next_tmp
        @counter ||= 0
        @counter += 1
        :"$for_tmp#{@counter}"
      end

      # Handles
      #   for i in 0..3; j = i + 1; end
      #
      # The problem here is that in Ruby for loop makes its
      # loop variable + all local variables available outside.
      # I.e. after this loop variable `i` is 3 and `j` is 4
      #
      # This class rewrites it to the following code:
      #   j = nil
      #   i = nil
      #   (0..3).each { |__jstmp| i = __jstmp; j = i + 1 }
      #
      # Complex stuff with multiple loop variables:
      #   for i, j in [[1, 2], [3, 4]]; end
      # Becomes multiple left-hand assignment:
      #   i = nil
      #   j = nil
      #   [[1, 2], [3, 4]].each { |__jstmp| i, j = __jstmp }
      #

      def on_for(node)
        loop_variable, loop_range, loop_body = *node

        # Declare local variables used in the loop and the loop body at the outer scope
        outer_assignments = generate_outer_assignments(loop_variable, loop_body)

        # Generate temporary loop variable
        tmp_loop_variable = self.class.next_tmp
        get_tmp_loop_variable = s(:js_tmp, tmp_loop_variable)

        # Assign the loop variables in the loop body
        loop_body = prepend_to_body(loop_body, assign_loop_variable(loop_variable, get_tmp_loop_variable))

        # Transform the for-loop into each-loop with updated loop body
        node = transform_for_to_each_loop(node, loop_range, tmp_loop_variable, loop_body)

        node.updated(:begin, [*outer_assignments, node])
      end

      private

      def generate_outer_assignments(loop_variable, loop_body)
        loop_local_vars = LocalVariableAssigns.find(loop_variable)
        body_local_vars = LocalVariableAssigns.find(loop_body)

        (loop_local_vars + body_local_vars).map { |lvar_name| s(:lvdeclare, lvar_name) }
      end

      def assign_loop_variable(loop_variable, tmp_loop_variable)
        case loop_variable.type
        when :mlhs # multiple left-hand statement like in "for i,j in [[1, 2], [3, 4]]"
          loop_variable.updated(:masgn, [loop_variable, tmp_loop_variable])
        else # single argument like "for i in (0..3)"
          loop_variable << tmp_loop_variable
        end
      end

      # rubocop:disable Layout/MultilineMethodCallBraceLayout,Layout/MultilineArrayBraceLayout
      def transform_for_to_each_loop(node, loop_range, tmp_loop_variable, loop_body)
        node.updated(:send, [loop_range, :each,                                         # (0..3).each {
                             node.updated(:iter, [s(:args, s(:arg, tmp_loop_variable)), # |__jstmp|
                                                  process(loop_body)                    # i = __jstmp; j = i + 1 }
                                                 ])])
      end
      # rubocop:enable Layout/MultilineMethodCallBraceLayout,Layout/MultilineArrayBraceLayout

      class LocalVariableAssigns < Base
        attr_reader :result

        def self.find(node)
          processor = new
          processor.process(node)
          processor.result.to_a
        end

        def initialize
          @result = Set.new
        end

        def on_lvasgn(node)
          name, _ = *node
          result << name
          super
        end
      end
    end
  end
end
