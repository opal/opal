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
          else
            super
          end
        else
          super
        end
      end

      def on_array(node)
        children = node.children

        # Optimize large arrays produced by lexer, but mainly we are interested
        # in improving compile times, by reducing the tree for the further
        # compilation efforts (also reducing the bundle size a bit)
        #
        # This particular patch reduces compile time of the following command
        # by 12.5%:
        #
        #     OPAL_CACHE_DISABLE=true OPAL_PREFORK_DISABLE=true bin/opal \
        #         --no-source-map -ropal-parser -ce \
        #         'puts ::Opal.compile($stdin.read)' > _Cnow.js
        #
        # So, in short, an array of a kind:
        #
        #     [1, 2, 3, nil, nil, :something, :abc, nil, ...]
        #
        # Becomes compiled to:
        #
        #     Opal.large_array_unpack("1,2,3,,something,abc,,...")

        if children.length > 32
          ssin_array = children.all? do |child|
            # Break for wrong types
            next false unless %i[str sym int nil].include?(child.type)
            # Break for strings that may conflict with our numbers, nils and separator
            next false if %i[str sym].include?(child.type) && child.children.first.to_s =~ /\A[0-9-]|\A\z|,/
            # Break for too numbers out of range, as there may be decoding issues
            next false if child.type == :int && !(-1_000_000..1_000_000).cover?(child.children.first)
            true
          end

          if ssin_array
            str = children.map { |i| i.children.first.to_s }.join(',')
            node.updated(:jscall, [s(:js_tmp, :Opal), :large_array_unpack, s(:sym, str)])
          else
            super
          end
        else
          super
        end
      end
    end
  end
end
