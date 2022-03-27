# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    # This module attempts to run some optimizations or compatibility
    # improvements against some libraries used with Opal.
    #
    # This should be a last resort and must not break functionality in
    # existing applications.
    class TargetedPatches < Base
      def on_def(node)
        name, args, body = *node

        if body && body.type == :begin && body.children.length >= 2
          # parser/rubyxx.rb - racc generated code often looks like:
          #
          #     def _reduce_219(val, _values, result)
          #       result = @builder.op_assign(val[0], val[1], val[2])
          #       result
          #     end
          #
          # This converter transform this into just
          #
          #     def _reduce_219(val, _values, result)
          #       @builder.op_assign(val[0], val[1], val[2])
          #     end
          calls = body.children
          assignment, ret = calls.last(2)
          if assignment.type == :lvasgn && ret.type == :lvar &&
             assignment.children.first == ret.children.first

            if calls.length == 2
              node.updated(nil, [name, args, assignment.children[1]])
            else
              calls = calls[0..-3] << assignment.children[1]
              node.updated(nil, [name, args, body.updated(nil, calls)])
            end
          end
        end
      end
    end
  end
end
