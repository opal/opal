# backtick_javascript: true

%x{
  (function() {
    if (Opal.$$export_proxy_initialized) return;
    Opal.$$export_proxy_initialized = true;

    var proxyCache = typeof WeakMap === 'undefined' ? null : new WeakMap();
    var memberCache = typeof WeakMap === 'undefined' ? null : new WeakMap();
    var conversion = Opal.Export.$$conversion;

    function constantsFor(value) {
      if (value && (value.$$is_class || value.$$is_module)) return Opal.constants(value, true);
      if (value && value.$$class) return Opal.constants(value.$$class, true);
      return [];
    }

    function methodsFor(value) {
      var names = {}, seen = typeof WeakSet === 'undefined' ? null : new WeakSet();

      function collect(proto) {
        while (proto != null) {
          if (seen) {
            if (seen.has(proto)) return;
            seen.add(proto);
          }

          Object.getOwnPropertyNames(proto).forEach(function(name) {
            if (name[0] === '$' && name[1] !== '$' && name !== '$then') names[conversion.snakeToCamel(name.slice(1))] = true;
          });
          proto = Object.getPrototypeOf(proto);
        }
      }

      collect(value);

      if (value && (value.$$is_class || value.$$is_module)) {
        collect(value.$$prototype || value);
      }

      return Object.keys(names);
    }

    function proxyFor(value) {
      if (value == null) return value;
      if (value.$$is_hash || value.$$is_array) return Opal.JS.$to_js(value);
      if (typeof value !== 'object' && typeof value !== 'function') return Opal.JS.$to_js(value);
      if (value.$$opal_export_proxy) return value;
      if (typeof Promise !== 'undefined' && value instanceof Promise) {
        return value.then(function(resolved) { return proxyFor(resolved); });
      }

      if (proxyCache && proxyCache.has(value)) return proxyCache.get(value);

      var proxy = new Proxy(function() {}, handlerFor(value));
      if (proxyCache) proxyCache.set(value, proxy);
      return proxy;
    }

    function memberFor(receiver, rubyName) {
      var receiverCache, proxy;

      if (memberCache) {
        receiverCache = memberCache.get(receiver);
        if (!receiverCache) memberCache.set(receiver, receiverCache = Object.create(null));
        if (receiverCache[rubyName]) return receiverCache[rubyName];
      }

      proxy = new Proxy(function() {}, {
        apply: function(_target, _thisArg, args) {
          var converted = conversion.argsToRuby(args);
          return proxyFor(Opal.send(receiver, rubyName, converted.args, converted.block));
        },
        get: function(_target, prop) {
          if (prop === '$$opal_export_member') return true;
          if (prop === '$$opal_export_value') return function() { return Opal.send(receiver, rubyName, [], nil); };
          if (prop === '$$opal_export_receiver') return receiver;
          if (prop === '$$opal_export_name') return rubyName;
          if (prop === 'then') return undefined;
          return undefined;
        }
      });

      if (receiverCache) receiverCache[rubyName] = proxy;
      return proxy;
    }

    function getConstant(receiver, name) {
      if (receiver && (receiver.$$is_class || receiver.$$is_module)) return Opal.$$$ (receiver, name, true);
      if (receiver === Opal.Object) return Opal.$$$ (Opal.Object, name, true);
      return null;
    }

    function handlerFor(value) {
      return {
        apply: function(_target, _thisArg, args) {
          var converted;
          if (Opal.respond_to(value, '$call', true)) {
            converted = conversion.argsToRuby(args);
            return proxyFor(Opal.send(value, 'call', converted.args, converted.block));
          }
          throw new TypeError('Opal.$ facade is not directly callable');
        },

        construct: function(_target, args) {
          var converted = conversion.argsToRuby(args);
          return proxyFor(Opal.send(value, 'new', converted.args, converted.block));
        },

        get: function(_target, prop) {
          var constant, rubyName;

          if (prop === '$$opal_export_proxy') return true;
          if (prop === '$$opal_export_value') return value;
          if (prop === '__send__') return function(method) {
            var converted = conversion.argsToRuby(Array.prototype.slice.call(arguments, 1));
            return proxyFor(Opal.send(value, method, converted.args, converted.block));
          };
          if (prop === '__send_raw__') return function(method) {
            var converted = conversion.rawArgsToRuby(Array.prototype.slice.call(arguments, 1));
            return proxyFor(Opal.send(value, method, converted.args, converted.block));
          };
          if (prop === '__const__') return function(name) { return proxyFor(Opal.$$$ (value, name, false)); };
          if (prop === Symbol.hasInstance) return function(object) {
            return !!(object && object.$$opal_export_proxy && Opal.is_a(object.$$opal_export_value, value));
          };
          if (prop === 'then') return undefined;
          if (typeof prop !== 'string') return undefined;

          if (conversion.isUpperName(prop)) {
            constant = getConstant(value, prop);
            if (constant != null) return proxyFor(constant);
          }

          rubyName = conversion.camelToSnake(prop);
          return memberFor(value, rubyName);
        },

        set: function(_target, prop, assigned) {
          var rubyName = conversion.camelToSnake(String(prop)) + '=', converted = conversion.argsToRuby([assigned]);
          Opal.send(value, rubyName, converted.args, converted.block);
          return true;
        },

        has: function(_target, prop) {
          if (typeof prop !== 'string') return false;
          if (prop === 'then') return false;
          if (conversion.isUpperName(prop) && getConstant(value, prop) != null) return true;
          if (conversion.isSnakeName(prop)) return false;
          return Opal.respond_to(value, '$' + conversion.camelToSnake(prop), true);
        },

        ownKeys: function(_target) {
          var keys = {}, out = [];

          Reflect.ownKeys(_target).concat(constantsFor(value), methodsFor(value)).forEach(function(key) {
            if (!keys[key]) {
              keys[key] = true;
              out.push(key);
            }
          });

          return out;
        },

        getOwnPropertyDescriptor: function(_target, prop) {
          var descriptor = Object.getOwnPropertyDescriptor(_target, prop);
          if (descriptor) return descriptor;
          if (this.has(_target, prop)) return { configurable: true, enumerable: true };
        }
      };
    }

    Object.defineProperty(Opal, '$', {
      configurable: true,
      get: function() { return proxyFor(Opal.Object); }
    });

    Opal.Export.$$proxy_for = proxyFor;
  })();
}
