require 'opal/nodes/base'

module Opal
  module Nodes
    class ValueNode < Node
      handle :true, :false, :self, :nil

      def compile
        # :self, :true, :false, :nil
        push type.to_s
      end
    end

    class LiteralNode < Node
      children :value
    end

    class NumericNode < LiteralNode
      handle :int, :float

      def compile
        push value.to_s
        wrap '(', ')' if recv?
      end
    end

    class StringNode < LiteralNode
      handle :str

      def compile
        push value.inspect
      end
    end

    class SymbolNode < LiteralNode
      handle :sym

      def compile
        push value.to_s.inspect
      end
    end

    class RegexpNode < LiteralNode
      handle :regexp

      def compile
        push((value == // ? /^/ : value).inspect)
      end
    end

    class XStringNode < LiteralNode
      handle :xstr

      def needs_semicolon?
        stmt? and !value.to_s.include?(';')
      end

      def compile
        push value.to_s
        push ';' if needs_semicolon?

        wrap '(', ')' if recv?
      end
    end

    class DynamicStringNode < Node
      handle :dstr

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
      handle :dsym

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

    class DynamicXStringNode < Node
      handle :dxstr

      def requires_semicolon(code)
        stmt? and !code.include?(';')
      end

      def compile
        needs_semicolon = false

        children.each do |part|
          if String === part
            push part.to_s
            needs_semicolon = true if requires_semicolon(part.to_s)
          elsif part.type == :evstr
            push expr(part[1])
          elsif part.type == :str
            push part.last.to_s
            needs_semicolon = true if requires_semicolon(part.last.to_s)
          else
            raise "Bad dxstr part"
          end
        end

        push ';' if needs_semicolon
        wrap '(', ')' if recv?
      end
    end

    class DynamicRegexpNode < Node
      handle :dregx

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
      handle :dot2

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
      handle :dot3

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
      handle :hash

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

    class ArrayNode < Node
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

    # def args list
    class ArgsNode < Node
      handle :args

      def compile
        children.each_with_index do |child, idx|
          next if child.to_s == '*'

          child = child.to_sym
          push ', ' unless idx == 0
          child = variable(child)
          scope.add_arg child.to_sym
          push child.to_s
        end
      end
    end
  end
end
