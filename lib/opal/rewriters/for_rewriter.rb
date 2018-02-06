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
        loop_variable, iterating_value, loop_body = *node

        iterating_lvars        = LocalVariableAssigns.find(loop_variable) # [:i]
        lvars_declared_in_body = LocalVariableAssigns.find(loop_body)     # [:j]

        # i = nil; j = nil
        outer_assigns = (iterating_lvars + lvars_declared_in_body).map do |lvar_name|
          s(:lvdeclare, lvar_name)
        end

        # :__jstmp
        tmp_loop_variable = self.class.next_tmp
        get_tmp_loop_variable = s(:js_tmp, tmp_loop_variable)

        loop_variable_assignment = case loop_variable.type
        when :mlhs # multiple left-hand statement like in "for i,j in [[1, 2], [3, 4]]"
          # i, j = __jstmp
          s(:masgn, loop_variable, get_tmp_loop_variable)
        else # single argument like "for i in (0..3)"
          # i = __jstmp
          loop_variable << get_tmp_loop_variable
        end

        loop_body = prepend_to_body(loop_body, loop_variable_assignment)

        node = s(:send, iterating_value, :each,                 # (0..3).each {
                 s(:iter, s(:args, s(:arg, tmp_loop_variable)), #                |__jstmp|
                   loop_body))                                  #                          i = __jstmp; j = i + 1 }

        s(:begin, *outer_assigns, node)
      end

      private

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
          self.result << name
          super
        end
      end
    end
  end
end
