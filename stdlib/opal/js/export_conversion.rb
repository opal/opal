# backtick_javascript: true

%x{
  (function() {
    if (Opal.Export.$$conversion) return;

    var functionCache = typeof WeakMap === 'undefined' ? null : new WeakMap();

    function camelToSnake(name) {
      return name.replace(/([A-Z])/g, function(chr) { return '_' + chr.toLowerCase(); });
    }

    function snakeToCamel(name) {
      return name.replace(/_([a-zA-Z0-9])/g, function(_match, chr) { return chr.toUpperCase(); });
    }

    function isSnakeName(name) {
      return name.indexOf('_') !== -1;
    }

    function isUpperName(name) {
      return /^[A-Z]/.test(name);
    }

    function isPlainObject(value) {
      if (value == null || typeof value !== 'object') return false;
      var proto = Object.getPrototypeOf(value);
      return proto === Object.prototype || proto === null;
    }

    function raiseConversionError() {
      throw Opal.JS.ConversionError.$new('cyclic object graph cannot be converted to plain JavaScript values');
    }

    function toRuby(value, seen) {
      seen = seen || [];

      if (value == null) return nil;
      if (value.$$is_hash) return value;
      if (value.$$opal_export_member) return memberToRuby(value);
      if (value.$$opal_export_proxy) return value.$$opal_export_value;
      if (value.$$opal_js_wrapper) return value;

      if (Array.isArray(value)) {
        if (seen.indexOf(value) !== -1) raiseConversionError();
        seen.push(value);
        try {
          return value.map(function(item) { return toRuby(item, seen); });
        }
        finally {
          seen.pop();
        }
      }

      if (typeof value === 'function') return functionToRuby(value);
      if (isPlainObject(value)) return objectToHash(value, seen);
      return Opal.JS.$from_js(value);
    }

    function functionToRuby(value) {
      var wrapper;

      if (functionCache && functionCache.has(value)) return functionCache.get(value);

      wrapper = function() {
        var args = new Array(arguments.length);
        for (var i = 0; i < arguments.length; i++) args[i] = Opal.JS.$to_js(arguments[i]);
        return Opal.JS.$from_js(value.apply(this, args));
      };

      if (functionCache) functionCache.set(value, wrapper);
      return wrapper;
    }

    function memberToRuby(member) {
      var receiver = member.$$opal_export_receiver, name = member.$$opal_export_name;

      try {
        return Opal.send(receiver, 'method', [name], nil);
      }
      catch (error) {
        return function() {
          var converted = argsToRuby(arguments);
          return Opal.send(receiver, name, converted.args, converted.block);
        };
      }
    }

    function objectToHash(object, seen) {
      var hash = Opal.Hash.$new(), keys = Object.keys(object);

      if (seen.indexOf(object) !== -1) raiseConversionError();
      seen.push(object);

      try {
        for (var i = 0; i < keys.length; i++) Opal.hash_put(hash, camelToSnake(keys[i]), toRuby(object[keys[i]], seen));
        return hash;
      }
      finally {
        seen.pop();
      }
    }

    function functionToBlock(fn) {
      return function() {
        var blockArgs = new Array(arguments.length);
        for (var i = 0; i < arguments.length; i++) blockArgs[i] = Opal.JS.$to_js(arguments[i]);
        return Opal.JS.$from_js(fn.apply(this, blockArgs));
      };
    }

    function argsToRuby(args) {
      var result = Array.prototype.slice.call(args), block = nil;

      if (result.length > 0 && typeof result[result.length - 1] === 'function' && !result[result.length - 1].$$opal_export_member) {
        var fn = result.pop();
        block = functionToBlock(fn);
      }

      if (result.length > 0 && isPlainObject(result[result.length - 1])) {
        result[result.length - 1] = objectToHash(result[result.length - 1], []);
      }

      for (var j = 0; j < result.length; j++) result[j] = toRuby(result[j], []);

      return { args: result, block: block };
    }

    function rawArgsToRuby(args) {
      var input = Array.prototype.slice.call(args), result = [], block = nil, positional, kwargs, callback;

      if (input.length > 0 && Array.isArray(input[0])) positional = input.shift();
      else positional = [];

      if (input.length > 0 && isPlainObject(input[0])) kwargs = input.shift();
      if (input.length > 0 && typeof input[0] === 'function') callback = input.shift();

      if (input.length > 0) throw new TypeError('invalid __send_raw__ argument shape');

      for (var i = 0; i < positional.length; i++) result.push(toRuby(positional[i], []));
      if (kwargs !== undefined) result.push(objectToHash(kwargs, []));
      if (callback !== undefined) block = functionToBlock(callback);

      return { args: result, block: block };
    }

    Opal.Export.$$conversion = {
      argsToRuby: argsToRuby,
      rawArgsToRuby: rawArgsToRuby,
      camelToSnake: camelToSnake,
      snakeToCamel: snakeToCamel,
      isSnakeName: isSnakeName,
      isPlainObject: isPlainObject,
      isUpperName: isUpperName
    };
  })();
}
