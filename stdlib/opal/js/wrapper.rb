# backtick_javascript: true

require 'opal/js/wrapper_access'

module ::Opal
  module JS
    module Wrapper
      def initialize(native)
        @native = native
      end

      def to_js
        @native
      end
    end

    class Object
      include Wrapper
      include DynamicObjectAccess

      def ==(other)
        `#{@native} === #{::Opal::JS.to_js(other)}`
      end
    end

    class Array < Object
      include ArrayAccess
    end

    class Function < Object
      def initialize(native, receiver = nil)
        super(native)
        @receiver = receiver
      end

      def call(*args, &block)
        ::Opal::JS.call_function(@native, @receiver, args, block)
      end

      def new(*args, &block)
        ::Opal::JS.construct(@native, args, block)
      end
    end
  end
end

%x{
  Opal.JS.$$this = undefined;
  Opal.JS.$$wrapper_cache = typeof WeakMap === 'undefined' ? null : new WeakMap();
  Opal.JS.$$bound_function_cache = typeof WeakMap === 'undefined' ? null : new WeakMap();
  Opal.JS.Object.$$prototype.$$opal_js_wrapper = true;
  Opal.JS.Array.$$prototype.$$opal_js_wrapper = true;
  Opal.JS.Function.$$prototype.$$opal_js_wrapper = true;
}
