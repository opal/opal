require 'opal/nodes/base'

module Opal
  module Nodes
    # FIXME: needs rewrite
    class ArglistNode < Base
      handle :arglist

      def compile
        code, work = [], []

        children.each do |current|
          splat = current.first == :splat
          arg   = expr(current)

          if splat
            if work.empty?
              if code.empty?
                code << fragment("[].concat(")
                code << arg
                code << fragment(")")
              else
                code += ".concat(#{arg})"
              end
            else
              if code.empty?
                code << [fragment("["), work, fragment("]")]
              else
                code << [fragment(".concat(["), work, fragment("])")]
              end

              code << [fragment(".concat("), arg, fragment(")")]
            end

            work = []
          else
            work << fragment(", ") unless work.empty?
            work << arg
          end
        end

        unless work.empty?
          join = work

          if code.empty?
            code = join
          else
            code << fragment(".concat(") << join << fragment(")")
          end
        end

        push(*code)
      end
    end
  end
end
