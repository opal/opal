require 'opal/nodes/base'

module Opal
  module Nodes
    class HashNode < Base
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
  end
end
