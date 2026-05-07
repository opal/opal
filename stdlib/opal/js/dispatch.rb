# backtick_javascript: true

module ::Opal
  module JS
    class << self
      def read(receiver, name)
        %x{
          var value = receiver[name], cache, receiverCache, wrapper;

          if (typeof value === 'function') {
            cache = Opal.JS.$$bound_function_cache;
            if (cache) {
              receiverCache = cache.get(receiver);
              if (!receiverCache) cache.set(receiver, receiverCache = new WeakMap());
              if (receiverCache.has(value)) return receiverCache.get(value);
            }

            wrapper = #{::Opal::JS::Function.new(`value`, receiver)};
            if (receiverCache) receiverCache.set(value, wrapper);
            return wrapper;
          }

          return #{from_js(`value`)};
        }
      end

      def property_name_for(receiver, ruby_name)
        name = ruby_name.to_s
        name = name[0...-1] if name.end_with?('=')

        %x{
          if (name in receiver) return name;

          var translated = #{camelize(name)};
          if (translated in receiver) return translated;

          return nil;
        }
      end

      def dispatch(receiver, ruby_name, args, block)
        setter = ruby_name.to_s.end_with?('=')
        property = property_name_for(receiver, ruby_name)

        if setter
          value = args[0]
          property = camelize(ruby_name.to_s[0...-1]) if property.nil?
          `receiver[property] = #{to_js(value)}`
          return value
        end

        if property.nil?
          if !args.empty? || (!block.nil? && `block != null`)
            raise ::NoMethodError, "undefined JavaScript property or method `#{ruby_name}'"
          end

          return nil
        end

        %x{
          var value = receiver[property];

          if (typeof value === 'function') {
            if (args.length === 0 && (block === nil || block == null) && property !== 'constructor' && property !== 'prototype' && !/^[A-Z]/.test(property)) {
              return #{from_js(`value.apply(receiver, [])`)};
            }

            if (args.length === 0 && (block === nil || block == null)) {
              return #{::Opal::JS::Function.new(`value`, receiver)};
            }

            return #{call_function(`value`, receiver, args, block)};
          }

          if (args.length > 0 || (block !== nil && block != null)) {
            #{raise_not_callable(ruby_name)};
          }

          return #{from_js(`value`)};
        }
      end

      def call_function(fn, receiver, args, block)
        %x{
          var has_block = !(block === nil || block == null);
          var js_args = new Array(args.length + (has_block ? 1 : 0));

          for (var i = 0; i < args.length; i++) {
            js_args[i] = #{to_js(`args[i]`)};
          }

          if (has_block) js_args[args.length] = #{proc_to_js(block)};

          return #{from_js(`fn.apply(receiver == null ? undefined : receiver, js_args)`)};
        }
      end

      def construct(fn, args, block)
        %x{
          var has_block = !(block === nil || block == null);
          var js_args = new Array(args.length + (has_block ? 1 : 0));

          for (var i = 0; i < args.length; i++) {
            js_args[i] = #{to_js(`args[i]`)};
          }

          if (has_block) js_args[args.length] = #{proc_to_js(block)};

          return #{from_js(`new (Function.prototype.bind.apply(fn, [null].concat(js_args)))()`)};
        }
      end

      def camelize(name)
        `#{name}.replace(/_([a-zA-Z0-9])/g, function(_, chr) { return chr.toUpperCase(); })`
      end
    end
  end
end
