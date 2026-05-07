# backtick_javascript: true

module ::Opal
  module JS
    class << self
      def register_wrapper(klass, constructor = nil, priority = 0, block = nil)
        %x{
          Opal.JS.$$wrapper_registry.push({
            klass: klass,
            constructor: constructor == nil || constructor == null ? null : #{to_js(constructor)},
            priority: priority,
            block: block,
            order: Opal.JS.$$wrapper_registry.length
          });
        }
      end

      def register_constructor(klass, constructor)
        `klass.$$opal_js_constructor = #{to_js(constructor)}`
      end

      def wrapper_class_for(value)
        %x{
          var entries = Opal.JS.$$wrapper_registry, best = null;

          for (var i = 0; i < entries.length; i++) {
            var entry = entries[i], ctor = entry.constructor;
            if (ctor == null) continue;
            if (typeof ctor !== 'function') continue;
            if (!(value instanceof ctor)) continue;

            if (!best || entry.priority > best.priority || (entry.priority === best.priority && entry.order > best.order)) best = entry;
          }

          if (best) return best.klass;

          for (var j = 0; j < entries.length; j++) {
            var predicate = entries[j];
            if (predicate.block === nil || predicate.block == null) continue;
            if (predicate.block(value)) {
              if (!best || predicate.priority > best.priority || (predicate.priority === best.priority && predicate.order > best.order)) best = predicate;
            }
          }

          return best ? best.klass : nil;
        }
      end
    end
  end
end

%x{
  Opal.JS.$$wrapper_registry = Opal.JS.$$wrapper_registry || []
}
