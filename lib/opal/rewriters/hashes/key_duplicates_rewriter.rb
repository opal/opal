# frozen_string_literal: true
require 'opal/rewriters/base'
require 'set'

module Opal
  module Rewriters
    module Hashes
      class KeyDuplicatesRewriter < ::Opal::Rewriters::Base
        def initialize
          @keys = UniqKeysSet.new
        end

        def on_hash(node)
          previous_keys, @keys = @keys, UniqKeysSet.new
          super(node)
        ensure
          @keys = previous_keys
        end

        def on_pair(node)
          key, _value = *node

          if %i(str sym).include?(key.type)
            @keys << key
          end

          super(node)
        end

        def on_kwsplat(node)
          hash, _ = *node

          if hash.type == :hash
            hash = process_regular_node(hash)
          end

          node.updated(nil, [hash])
        end

        class UniqKeysSet
          def initialize
            @set = Set.new
          end

          def <<(element)
            if @set.include?(element)
              key, _ = *element
              key = element.type == :str ? key.inspect : ":#{key}"
              Kernel.warn "warning: key #{key} is duplicated and overwritten"
            else
              @set << element
            end
          end
        end
      end
    end
  end
end
