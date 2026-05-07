# backtick_javascript: true

module ::Opal
  module JS
    module DynamicObjectAccess
      def [](name)
        ::Opal::JS.read(@native, name)
      end

      def []=(name, value)
        `#{@native}[#{name}] = #{::Opal::JS.to_js(value)}`
      end

      def dig(key, *keys)
        value = self[key]
        return value if keys.empty? || value.nil?

        value.dig(*keys)
      end

      def constructor
        self[:constructor]
      end

      def prototype
        self[:prototype]
      end

      def respond_to_missing?(name, include_all = false)
        !::Opal::JS.property_name_for(@native, name).nil? || super
      end

      def method_missing(name, *args, &block)
        ::Opal::JS.dispatch(@native, name, args, block)
      end

      def to_h
        ::Opal::JS.object_to_hash(@native)
      end
    end

    module ArrayAccess
      include ::Enumerable

      def length
        `#{@native}.length`
      end

      alias size length

      def each(&block)
        return enum_for :each unless block

        %x{
          for (var i = 0, length = #{@native}.length; i < length; i++) {
            block(#{::Opal::JS.from_js(`#{@native}[i]`)});
          }
        }

        self
      end

      def to_a
        ::Opal::JS.array_to_ruby(@native)
      end

      def <<(value)
        push(value)
        self
      end

      def push(*values)
        values.each { |value| ::Opal::JS.array_push(@native, value) }
        self
      end

      def pop
        ::Opal::JS.array_pop(@native)
      end

      def shift
        ::Opal::JS.array_shift(@native)
      end

      def unshift(*values)
        values.reverse_each { |value| ::Opal::JS.array_unshift(@native, value) }
        self
      end
    end
  end
end
