require 'opal/nodes/base'

module Opal
  module Nodes
    class ArrayNode < Base
      handle :array

      def compile
        return push('[]') if children.empty?

        code, work = [], []

        children.each do |child|
          splat = child.type == :splat
          part  = expr(child)

          if splat
            if work.empty?
              if code.empty?
                code << fragment("[].concat(") << part << fragment(")")
              else
                code << fragment(".concat(") << part << fragment(")")
              end
            else
              if code.empty?
                code << fragment("[") << work << fragment("]")
              else
                code << fragment(".concat([") << work << fragment("])")
              end

              code << fragment(".concat(") << part << fragment(")")
            end
            work = []
          else
            work << fragment(", ") unless work.empty?
            work << part
          end
        end

        unless work.empty?
          join = [fragment("["), work, fragment("]")]

          if code.empty?
            code = join
          else
            code.push([fragment(".concat("), join, fragment(")")])
          end
        end

        push code
      end
    end
  end
end
