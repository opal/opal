require 'opal/nodes/base'

module Opal
  module Nodes
    class HashNode < Base
      handle :hash

      attr_accessor :has_kwsplat, :keys, :values

      def initialize(*)
        super
        @has_kwsplat = false
        @keys = []
        @values = []
      end

      # Splits keys/values/kwsplats
      #
      # hash like { **{ nested: 1 }, d: 2 }
      # is represetned by sexp:
      # (:hash,
      #   (:kwsplat,
      #     (:hash,
      #       (:sym, :nested),
      #       (:int, 1)
      #     )
      #   ),
      #   (:sym, :d),
      #   (:int, 2),
      # )
      # So k/v pairs and kwsplats can be mixed in any order.
      def extract_kv_pairs_and_kwsplats
        found_key = false

        children.each do |obj|
          if obj.type == :kwsplat
            self.has_kwsplat = true
          elsif found_key
            values << obj
            found_key = false
          else
            keys << obj
            found_key = true
          end
        end

        [keys, values]
      end

      def simple_keys?
        keys.all? { |key| [:sym, :str].include?(key.type) }
      end

      def compile
        extract_kv_pairs_and_kwsplats

        if has_kwsplat
          compile_merge
        elsif simple_keys?
          compile_hash2
        else
          compile_hash
        end
      end

      # Compiles hashes containing kwsplats inside.
      # hash like { **{ nested: 1 }, a: 1, **{ nested: 2} }
      # should be compiled to
      # { nested: 1}.merge(a: 1).merge(nested: 2)
      # Each kwsplat overrides previosly defined keys
      # Hash k/v pairs override previously defined kwsplat values
      def compile_merge
        helper :hash

        result, seq = [], []

        children.each do |child|
          if child.type == :kwsplat
            unless seq.empty?
              result << expr(s(:hash, *seq))
            end
            result << expr(child)
            seq = []
          else
            seq << child
          end
        end
        unless seq.empty?
          result << expr(s(:hash, *seq))
        end

        result.each_with_index do |fragment, idx|
          if idx == 0
            push fragment
          else
            push ".$merge(", fragment, ")"
          end
        end
      end

      # Compiles a hash without kwsplats
      # with complex keys.
      def compile_hash
        helper :hash

        children.each_with_index do |child, idx|
          push ', ' unless idx == 0
          push expr(child)
        end

        wrap '$hash(', ')'
      end

      # Compiles a hash without kwsplats
      # and containing **only** string/symbols as keys.
      def compile_hash2
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

    class KwSplatNode < Base
      handle :kwsplat
      children :value

      def compile
        push "Opal.to_hash(", expr(value), ")"
      end
    end
  end
end
