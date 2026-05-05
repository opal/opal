# backtick_javascript: true

require 'opal/js/wrapper_access'
require 'opal/js/wrapper_registry'
require 'opal/js/wrapper_arguments'
require 'opal/js/wrapper_array'

module ::Opal
  module JS
    module Wrapper
      def self.included(base)
        base.extend ClassMethods
        `base.$$prototype && (base.$$prototype.$$opal_js_wrapper = true)`
      end

      module ClassMethods
        def wrap(value)
          wrapper = allocate
          wrapper.initialize_wrapped(value)
          wrapper
        end

        def js_object
          include ::Opal::JS::DynamicObjectAccess
        end

        def js_array
          include ::Opal::JS::DynamicObjectAccess
          include ::Opal::JS::ArrayAccess
        end

        def js_register_wrapper(constructor = nil, priority: 0, &block)
          ::Opal::JS.register_wrapper(self, constructor, priority, block)
        end

        def js_constructor(constructor, args: nil, kwargs: nil)
          ::Opal::JS.register_wrapper(self, constructor, 0, nil)
          ::Opal::JS.register_constructor(self, constructor)

          define_method(:initialize) do |*ruby_args, &block|
            js_args = ::Opal::JS.project_args(ruby_args, block, args, kwargs, self.class.name)
            initialize_wrapped(::Opal::JS.construct(::Opal::JS.to_js(constructor), js_args, nil))
          end
        end

        def js_method(ruby_name, js_name = ruby_name, args: nil, kwargs: nil)
          define_method(ruby_name) do |*ruby_args, &block|
            js_args = ::Opal::JS.project_args(ruby_args, block, args, kwargs, ruby_name)
            ::Opal::JS.call(self, js_name, *js_args)
          end
        end

        def js_reader(ruby_name, js_name = ruby_name)
          define_method(ruby_name) { self[js_name] }
        end

        def js_writer(ruby_name, js_name = ruby_name)
          method_name = ruby_name.to_s.end_with?('=') ? ruby_name : "#{ruby_name}="
          define_method(method_name) do |value|
            self[js_name] = value
          end
        end

        def js_accessor(ruby_name, js_name = ruby_name)
          js_reader(ruby_name, js_name)
          js_writer(ruby_name, js_name)
        end
      end

      def initialize(native = nil)
        initialize_wrapped(native) unless `#{native} === nil || #{native} == null`
      end

      def initialize_wrapped(value)
        raise ::ArgumentError, 'wrapper is already initialized' if instance_variable_defined?(:@native)

        @native = `#{value} != null && #{value}.$$opal_js_wrapper ? #{value}.$to_js() : #{value}`
        self
      end

      def to_js
        @native
      end
    end
  end
end
