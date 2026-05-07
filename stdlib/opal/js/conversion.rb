# backtick_javascript: true
# helpers: hash_each, hash_put

module ::Opal
  module JS
    class << self
      def global
        wrap(`Opal.global`)
      end

      def wrap(value)
        from_js(value)
      end

      def unwrap(value)
        to_js(value)
      end

      def from_js(value)
        %x{
          var wrapper, cache, klass;

          if (value == null) return nil;

          if (value.$$opal_js_wrapper) return value;

          if (typeof Promise !== 'undefined' && value instanceof Promise) {
            cache = Opal.JS.$$wrapper_cache;
            if (cache && cache.has(value)) return cache.get(value);

            wrapper = #{::PromiseV2.resolve(value).then { |resolved| from_js(resolved) }};
            if (cache) cache.set(value, wrapper);
            return wrapper;
          }

          if (typeof value === 'function') {
            cache = Opal.JS.$$wrapper_cache;
            if (cache && cache.has(value)) return cache.get(value);

            klass = #{wrapper_class_for(value)};
            wrapper = klass === nil ? #{::Opal::JS::Function.new(`value`)} : klass.$wrap(value);
            if (cache) cache.set(value, wrapper);
            return wrapper;
          }

          if (typeof value === 'object') {
            cache = Opal.JS.$$wrapper_cache;
            if (cache && cache.has(value)) return cache.get(value);

            klass = #{wrapper_class_for(value)};
            if (klass !== nil) {
              wrapper = klass.$wrap(value);
            }
            else if (Array.isArray(value) || #{array_like?(value)}) {
              wrapper = #{::Opal::JS::Array.new(`value`)};
            }
            else {
              wrapper = #{::Opal::JS::Object.new(`value`)};
            }

            if (cache) cache.set(value, wrapper);
            return wrapper;
          }

          return value;
        }
      end

      def to_js(value, seen = nil)
        %x{
          if (value === nil) return undefined;

          if (value != null && value.$$opal_js_wrapper) return value.$to_js();

          if (value != null && value.$$opal_export_proxy) return value;

          if (value != null && value.$$is_hash) return #{hash_to_js_object(value, seen)};

          if (value != null && value.$$is_array) return #{array_to_js(value, seen)};

          if (typeof value === 'function' && value.$$is_proc) return #{proc_to_js(value)};

          if (value != null && Opal.respond_to(value, '$to_js', true)) return value.$to_js();

          if (#{native_wrapper?(value)}) return value.$to_n();

          if (typeof Promise !== 'undefined' && value instanceof Promise) {
            return value.then(function(resolved) { return #{to_js(`resolved`, seen)}; });
          }

          if (value != null &&
              (typeof value === 'object' || typeof value === 'function') &&
              value.$$class && Opal.Export.$$proxy_for) {
            return Opal.Export.$$proxy_for(value);
          }

          return value;
        }
      end

      def native_wrapper?(value)
        %x{
          return value != null &&
            typeof Opal.Native !== 'undefined' &&
            typeof Opal.Native.Wrapper !== 'undefined' &&
            Opal.is_a(value, Opal.Native.Wrapper);
        }
      end

      def native?(value)
        `#{value} === nil || #{value} == null || (typeof #{value} !== 'object' && typeof #{value} !== 'function') || !#{value}.$$class`
      end

      def object?(value)
        `#{value} != null && (typeof #{value} === 'object' || typeof #{value} === 'function') && !#{value}.$$class`
      end

      def array_like?(value)
        %x{
          if (value == null || typeof value !== 'object') return false;
          if (!('length' in value)) return false;

          var length = value.length;
          return typeof length === 'number' &&
            length >= 0 &&
            length <= Number.MAX_SAFE_INTEGER &&
            Math.floor(length) === length;
        }
      end

      def raise_unsupported_hash_key
        raise ::Opal::JS::ConversionError, 'unsupported Hash key for JS object conversion'
      end

      def raise_cyclic_conversion
        raise ::Opal::JS::ConversionError, 'cyclic object graph cannot be converted to plain JavaScript values'
      end

      def raise_not_callable(name)
        raise ::NoMethodError, "JavaScript property `#{name}' is not callable"
      end

      def hash_to_js_object(hash, seen = nil)
        %x{
          var result = {};

          seen = (seen === nil || seen == null) ? [] : seen;
          if (seen.indexOf(hash) !== -1) #{raise_cyclic_conversion};
          seen.push(hash);

          try {
            $hash_each(hash, false, function(key, value) {
              var type = typeof key;

              if (type !== 'string' && type !== 'number') {
                #{raise_unsupported_hash_key};
              }

              result[key] = #{to_js(`value`, seen)};
              return [false, false];
            });
          }
          finally {
            seen.pop();
          }

          return result;
        }
      end

      def array_to_js(array, seen = nil)
        %x{
          var result = new Array(array.length);

          seen = (seen === nil || seen == null) ? [] : seen;
          if (seen.indexOf(array) !== -1) #{raise_cyclic_conversion};
          seen.push(array);

          try {
            for (var i = 0; i < array.length; i++) {
              result[i] = #{to_js(`array[i]`, seen)};
            }
          }
          finally {
            seen.pop();
          }

          return result;
        }
      end

      def proc_to_js(proc)
        %x{
          if (proc.$$opal_js_function) return proc.$$opal_js_function;

          var fn = function() {
            var previous = Opal.JS.$$this, args = new Array(arguments.length);

            Opal.JS.$$this = this;

            try {
              for (var i = 0; i < arguments.length; i++) {
                args[i] = #{from_js(`arguments[i]`)};
              }

              return #{to_js(`proc.apply(proc.$$s, args)`)};
            }
            finally {
              Opal.JS.$$this = previous;
            }
          };

          proc.$$opal_js_function = fn;
          return fn;
        }
      end

      def this
        # Exposes JavaScript `this` only while a Ruby callback is synchronously
        # executing from a JS call. Outside that callback boundary it is nil.
        from_js(`Opal.JS.$$this`)
      end

      def call(receiver, name, *args, &block)
        property = property_name_for(to_js(receiver), name)

        if property.nil?
          raise ::NoMethodError, "undefined JavaScript property or method `#{name}'"
        end

        `var fn = #{to_js(receiver)}[property]`
        raise_not_callable(name) unless `typeof fn === 'function'`

        call_function(`fn`, to_js(receiver), args, block)
      end

      def new(constructor, *args, &block)
        construct(to_js(constructor), args, block)
      end

      def instanceof?(value, constructor)
        `#{to_js(value)} instanceof #{to_js(constructor)}`
      end

      def object_to_hash(object)
        %x{
          return #{snapshot_js_value(object, `[]`)};
        }
      end

      def array_to_ruby(array)
        %x{
          return #{snapshot_js_value(array, `[]`)};
        }
      end

      # rubocop:disable Style/EmptyLiteral
      def snapshot_js_value(value, seen)
        %x{
          var hash, array, keys;

          if (value == null) return nil;

          if (typeof value === 'object') {
            if (seen.indexOf(value) !== -1) #{raise_cyclic_conversion};
            seen.push(value);

            try {
              if (Array.isArray(value) || #{array_like?(value)}) {
                array = [];
                for (var i = 0, length = value.length; i < length; i++) {
                  array.push(#{snapshot_js_value(`value[i]`, seen)});
                }
                return array;
              }

              hash = #{::Hash.new};
              keys = Object.keys(value);

              for (var j = 0; j < keys.length; j++) {
                $hash_put(hash, keys[j], #{snapshot_js_value(`value[keys[j]]`, seen)});
              }

              return hash;
            }
            finally {
              seen.pop();
            }
          }

          return #{from_js(value)};
        }
      end
      # rubocop:enable Style/EmptyLiteral
    end
  end
end
