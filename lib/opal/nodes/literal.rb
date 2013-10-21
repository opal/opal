require 'opal/nodes/base'

module Opal
  class Parser
    class ValueNode < Node
      def compile
        # :self, :true, :false, :nil
        push type.to_s
      end
    end

    class LiteralNode < Node
      children :value
    end

    class NumericNode < LiteralNode
      def compile
        push value.to_s
        wrap '(', ')' if recv?
      end
    end

    class StringNode < LiteralNode
      def compile
        push value.inspect
      end
    end

    class SymbolNode < LiteralNode
      def compile
        push value.to_s.inspect
      end
    end

    class RegexpNode < LiteralNode
      def compile
        push((value == // ? /^/ : value).inspect)
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

          wrap '(', ')' if recv?
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
      children :start, :finish

      def compile
        helper :range

        push "$range("
        push expr(start)
        push ", "
        push expr(finish)
        push ", false)"
      end
    end

    class InclusiveRangeNode < Node
      children :start, :finish

      def compile
        helper :range

        push "$range("
        push expr(start)
        push ", "
        push expr(finish)
        push ", true)"
      end
    end

    class HashNode < Node
      def keys_and_values
        keys, values = [], []

        children.each_with_index do |obj, idx|
          if idx.even?
            keys << obj
          else
            values << obj
          end
        end

        [keys, values]
      end

      def simple_keys?(keys)
        keys.all? { |key| [:sym, :str].include? key.type }
      end

      def compile
        keys, values = keys_and_values

        if simple_keys? keys
          compile_hash2 keys, values
        else
          compile_hash
        end
      end

      def compile_hash
        helper :hash

        children.each_with_index do |child, idx|
          push ', ' unless idx == 0
          push expr(child)
        end

        wrap '$hash(', ')'
      end

      def compile_hash2(keys, values)
        hash_obj, hash_keys = {}, []
        helper :hash2

        keys.size.times do |idx|
          key = keys[idx][1].to_s.inspect
          hash_keys << key unless hash_obj.include? key
          hash_obj[key] = expr(values[idx])
        end

        hash_keys.each_with_index do |key, idx|
          push ', ' unless idx == 0
          push "#{key}: "
          push hash_obj[key]
        end

        wrap "$hash2([#{hash_keys.join ', '}], {", "})"
      end
    end
  end
end
