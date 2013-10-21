require 'opal/nodes/base'

module Opal
  class Parser
    class ValueNode < Node
      def compile
        push type.to_s
      end
    end

    class LiteralNode < Node
      def literal
        @sexp[1]
      end
    end

    class NumericNode < LiteralNode
      def compile
        push literal.to_s
        wrap '(', ')' if @level == :recv
      end
    end

    class StringNode < LiteralNode
      def compile
        push literal.inspect
      end
    end

    class SymbolNode < LiteralNode
      def compile
        push literal.to_s.inspect
      end
    end

    class RegexpNode < LiteralNode
      def compile
        push((literal == // ? /^/ : literal).inspect)
      end
    end

    class DynamicStringNode < Node
      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :evstr
            push "("
            push expr(part[1])
            push ")"
          elsif part.type == :str
            push part[1].inspect
          else
            raise "Bad dstr part"
          end

          wrap '(', ')' if @level == :recv
        end
      end
    end

    class DynamicSymbolNode < Node
      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :evstr
            push expr(s(:call, part.last, :to_s, s(:arglist)))
          elsif part.type == :str
            push part.last.inspect
          else
            raise "Bad dsym part"
          end
        end

        wrap '(', ')'
      end
    end

    class DynamicRegexpNode < Node
      def compile
        children.each_with_index do |part, idx|
          push " + " unless idx == 0

          if String === part
            push part.inspect
          elsif part.type == :str
            push part[1].inspect
          else
            push expr(part[1])
          end
        end

        wrap '(new RegExp(', '))'
      end
    end

    class ExclusiveRangeNode < Node
      def compile
        helper :range

        push "$range("
        push expr(@sexp[1])
        push ", "
        push expr(@sexp[2])
        push ", false)"
      end
    end

    class InclusiveRangeNode < Node
      def compile
        helper :range

        push "$range("
        push expr(@sexp[1])
        push ", "
        push expr(@sexp[2])
        push ", true)"
      end
    end

  end
end
