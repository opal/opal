# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, slice, splice, has_own

module ::Opal
  # Hashes
  # ------

  # Experiments have shown, that using new Map([[1,2]]) inline is rather slow
  # compared to using new Map() in combination with .set(1,2), because the former
  # creates a new Array for each pair and then discards it. Using .set though
  # would increase the size of the generated code. So lets use a compromise and
  # use a helper function, which allows the compiler to generate compact code
  # and at the same time provides the performance improvement of using .set
  # with a overall smaller overhead than creating arrays for each pair.
  # For primitive keys:
  def self.hash_new
    %x{
      let h = new Map();
      for (let i = 0; i < arguments.length; i += 2) {
        h.set(arguments[i], arguments[i + 1]);
      }
      return h;
    }
  end

  # The same as above, except for complex keys:
  def self.hash_new2
    %x{
      let h = new Map();
      for (let i = 0; i < arguments.length; i += 2) {
        Opal.hash_put(h, arguments[i], arguments[i + 1]);
      }
      return h;
    }
  end

  def self.hash_init(_hash = undefined)
    %x{
      console.warn("DEPRECATION: Opal.hash_init is deprecated and is now a no-op.")
    }
  end

  def self.hash_clone(from_hash = undefined, to_hash = undefined)
    %x{
      to_hash.$$none = from_hash.$$none;
      to_hash.$$proc = from_hash.$$proc;

      return Opal.hash_each(from_hash, to_hash, function(key, value) {
        Opal.hash_put(to_hash, key, value);
        return [false, to_hash];
      });
    }
  end

  def self.hash_put(hash = undefined, key = undefined, value = undefined)
    %x{
      var type = typeof key;
      if (type === "string" || type === "symbol" || type === "number" || type === "boolean" || type === "bigint") {
        hash.set(key, value)
      } else if (key.$$is_string) {
        hash.set(key.valueOf(), value);
      } else {
        if (!hash.$$keys)
          hash.$$keys = new Map();

        var key_hash = key.$$is_string ? key.valueOf() : (hash.$$by_identity ? Opal.id(key) : key.$hash()),
            keys = hash.$$keys;

        if (!keys.has(key_hash)) {
          keys.set(key_hash, [key]);
          hash.set(key, value);
          return;
        }

        var objects = keys.get(key_hash),
            object;

        for (var i=0; i<objects.length; i++) {
          object = objects[i];
          if (key === object || key['$eql?'](object)) {
            hash.set(object, value);
            return;
          }
        }

        objects.push(key);
        hash.set(key, value);
      }
    }
  end

  def self.hash_get(hash = undefined, key = undefined)
    %x{
      var type = typeof key;
      if (type === "string" || type === "symbol" || type === "number" || type === "boolean" || type === "bigint") {
        return hash.get(key)
      } else if (hash.$$keys) {
        var key_hash = key.$$is_string ? key.valueOf() : (hash.$$by_identity ? Opal.id(key) : key.$hash()),
            objects = hash.$$keys.get(key_hash),
            object;

        if (objects !== undefined) {
          for (var i=0; i<objects.length; i++) {
            object = objects[i];
            if (key === object || key['$eql?'](object))
              return hash.get(object);
          }
        } else if (key.$$is_string) {
          return hash.get(key_hash);
        }
      } else if (key.$$is_string) {
        return hash.get(key.valueOf());
      }
    }
  end

  %x{
    function $hash_delete_stage2(hash, key) {
      var value = hash.get(key);
      hash.delete(key);
      return value;
    }
  }

  def self.hash_delete(hash = undefined, key = undefined)
    %x{
      var type = typeof key
      if (type === "string" || type === "symbol" || type === "number" || type === "boolean" || type === "bigint") {
        return $hash_delete_stage2(hash, key);
      } else if (hash.$$keys) {
        var key_hash = key.$$is_string ? key.valueOf() : (hash.$$by_identity ? Opal.id(key) : key.$hash()),
            objects = hash.$$keys.get(key_hash),
            object;

        if (objects !== undefined) {
          for (var i=0; i<objects.length; i++) {
            object = objects[i];
            if (key === object || key['$eql?'](object)) {
              objects.splice(i, 1);
              if (objects.length === 0)
                hash.$$keys.delete(key_hash);
              return $hash_delete_stage2(hash, object);
            }
          }
        } else if (key.$$is_string) {
          return $hash_delete_stage2(hash, key_hash);
        }
      } else if (key.$$is_string) {
        return $hash_delete_stage2(hash, key.valueOf());
      }
    }
  end

  def self.hash_rehash(hash = undefined)
    %x{
      var keys = hash.$$keys;

      if (keys)
        keys.clear();

      Opal.hash_each(hash, false, function(key, value) {
        var type = typeof key;
        if (type === "string" || type === "symbol" || type === "number" || type === "boolean" || type === "bigint")
          return [false, false]; // nothing to rehash

        var key_hash = key.$$is_string ? key.valueOf() : (hash.$$by_identity ? Opal.id(key) : key.$hash());

        if (!keys)
          hash.$$keys = keys = new Map();

        if (!keys.has(key_hash)) {
          keys.set(key_hash, [key]);
          return [false, false];
        }

        var objects = keys.get(key_hash),
            objects_copy = (objects.length === 1) ? objects : $slice(objects),
            object;

        for (var i=0; i<objects_copy.length; i++) {
          object = objects_copy[i];
          if (key === object || key['$eql?'](object)) {
            // got a duplicate, remove it
            objects.splice(objects.indexOf(object), 1);
            hash.delete(object);
          }
        }

        objects.push(key);

        return [false, false]
      });

      return hash;
    }
  end

  def self.hash
    %x{
      var arguments_length = arguments.length,
        args,
        hash,
        i,
        length,
        key,
        value;

      if (arguments_length === 1 && arguments[0].$$is_hash) {
        return arguments[0];
      }

      hash = new Map();

      if (arguments_length === 1) {
        args = arguments[0];

        if (arguments[0].$$is_array) {
          length = args.length;

          for (i = 0; i < length; i++) {
            if (args[i].length !== 2) {
              $raise(Opal.ArgumentError, 'value not of length 2: ' + args[i].$inspect());
            }

            key = args[i][0];
            value = args[i][1];

            Opal.hash_put(hash, key, value);
          }

          return hash;
        } else {
          args = arguments[0];
          for (key in args) {
            if ($has_own(args, key)) {
              value = args[key];

              Opal.hash_put(hash, key, value);
            }
          }

          return hash;
        }
      }

      if (arguments_length % 2 !== 0) {
        $raise(Opal.ArgumentError, 'odd number of arguments for Hash');
      }

      for (i = 0; i < arguments_length; i += 2) {
        key = arguments[i];
        value = arguments[i + 1];

        Opal.hash_put(hash, key, value);
      }

      return hash;
    }
  end

  # A faster Hash creator for hashes that just use symbols and
  # strings as keys. The map and keys array can be constructed at
  # compile time, so they are just added here by the constructor
  # function.

  def self.hash2(keys = undefined, smap = undefined)
    %x{
      console.warn("DEPRECATION: `Opal.hash2` is deprecated and will be removed in Opal 2.0. Use $hash_new for primitive keys or $hash_new2 for complex keys instead.");

      var hash = new Map();
      for (var i = 0, max = keys.length; i < max; i++) {
        hash.set(keys[i], smap[keys[i]]);
      }
      return hash;
    }
  end

  def self.hash_each(hash = undefined, dres = undefined, fun = undefined)
    %x{
      // dres = default result, returned if hash is empty
      // fun is called as fun(key, value) and must return a array with [break, result]
      // if break is true, iteration stops and result is returned
      // if break is false, iteration continues and eventually the last result is returned
      var res;
      for (var i = 0, entry, entries = Array.from(hash.entries()), l = entries.length; i < l; i++) {
        entry = entries[i];
        res = fun(entry[0], entry[1]);
        if (res[0]) return res[1];
      }
      return res ? res[1] : dres;
    }
  end

  # Primitives for handling parameters
  def self.ensure_kwargs(kwargs = undefined)
    %x{
      if (kwargs == null) {
        return new Map();
      } else if (kwargs.$$is_hash) {
        return kwargs;
      } else {
        $raise(Opal.ArgumentError, 'expected kwargs');
      }
    }
  end

  def self.get_kwarg(kwargs = undefined, key = undefined)
    %x{
      var kwarg = Opal.hash_get(kwargs, key);
      if (kwarg === undefined) {
        $raise(Opal.ArgumentError, 'missing keyword: '+key);
      }
      return kwarg;
    }
  end

  # Used for extracting keyword arguments from arguments passed to
  # JS function.
  #
  # @param parameters [Array]
  # @return [Hash] or undefined

  def self.extract_kwargs(parameters = undefined)
    %x{
      var kwargs = parameters[parameters.length - 1];
      if (kwargs != null && Opal.respond_to(kwargs, '$to_hash', true)) {
        $splice(parameters, parameters.length - 1);
        return kwargs;
      }
    }
  end

  # Used to get a list of rest keyword arguments. Method takes the given
  # keyword args, i.e. the hash literal passed to the method containing all
  # keyword arguments passed to method, as well as the used args which are
  # the names of required and optional arguments defined. This method then
  # just returns all key/value pairs which have not been used, in a new
  # hash literal.
  #
  # @param given_args [Hash] all kwargs given to method
  # @param used_args [Object<String: true>] all keys used as named kwargs
  # @return [Hash]

  def self.kwrestargs(given_args = undefined, used_args = undefined)
    %x{
      var map = new Map();

      Opal.hash_each(given_args, false, function(key, value) {
        if (!used_args[key]) {
          Opal.hash_put(map, key, value);
        }
        return [false, false];
      });

      return map;
    }
  end

  # Helpers for extracting kwsplats
  # Used for: { **h }
  def self.to_hash(value = undefined)
    %x{
      if (value.$$is_hash) {
        return value;
      }
      else if (value['$respond_to?']('to_hash', true)) {
        var hash = value.$to_hash();
        if (hash.$$is_hash) {
          return hash;
        }
        else {
          $raise(Opal.TypeError, "Can't convert " + value.$$class +
            " to Hash (" + value.$$class + "#to_hash gives " + hash.$$class + ")");
        }
      }
      else {
        $raise(Opal.TypeError, "no implicit conversion of " + value.$$class + " into Hash");
      }
    }
  end

  # Opal32-checksum algorithm for #hash
  # -----------------------------------

  def self.opal32_init = 0x4f70616c

  %x{
    function $opal32_ror(n, d) {
      return (n << d)|(n >>> (32 - d));
    };
  }

  def self.opal32_add(hash = undefined, next_value = undefined)
    %x{
      hash ^= next_value;
      hash = $opal32_ror(hash, 1);
      return hash;
    }
  end
end

::Opal
