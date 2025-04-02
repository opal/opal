# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, prop, Object

module ::Opal
  # We use a helper to create new Strings, globally, so that it
  # will be easer to change that later on to a mutable string class.
  # Also this helper always sets a encoding. If encoding is not
  # provided, "UTF-8" will be used.
  # @returns a new String object with encoding set.
  def self.str(str = undefined, encoding = undefined)
    %x{
      if (!encoding || encoding === nil) encoding = "UTF-8";
      str = Opal.set_encoding(new String(str), encoding);
      str.binary_encoding = str.encoding;
      return str;
    }
  end

  # String#+ might be triggered early by a call $dstr below, so provide a solution until String class is fully loaded.
  `String.prototype["$+"] = function(other) { return this + other; }`

  # Helper for dynamic strings like "menu today: #{meal[:name]} for only #{meal[:price]}"
  def self.dstr
    %x{
      let res = arguments[0];
      if (arguments.length > 1) {
        for (let i = 1; i < arguments.length; i++) { res = res["$+"](arguments[i]); }
      } else if (typeof res === "string") {
        res = Opal.str(res);
      }
      return res;
    }
  end

  # Provide the encoding register with a default "UTF-8" encoding, because
  # its used from the start and will be raplaced by the real UTF-8 encoding
  # when 'corelib/string/encoding' is loaded.
  `Opal.encodings = { __proto__: null, "UTF-8": { name: "UTF-8", names: ["UTF-8"] }}`

  # Sets the encoding on a string, will treat string literals as frozen strings
  # raising a FrozenError.
  #
  # @param str [String] the string on which the encoding should be set
  # @param name [String] the canonical name of the encoding
  # @param type [String] possible values are either `"encoding"`, `"binary_encoding"`, or `undefined
  def self.set_encoding(str = undefined, name = undefined, type = undefined)
    %x{
      if (typeof type === "undefined") type = "encoding";
      if (typeof str === 'string' || str.$$frozen === true)
        $raise(Opal.FrozenError, "can't modify frozen String", new Map([["receiver", str]]));

      let encoding = Opal.find_encoding(name);
      if (encoding === str[type]) return str;
      str[type] = encoding;

      return str;
    }
  end

  # Fetches the encoding for the given name or raises ArgumentError.
  def self.find_encoding(name = undefined)
    %x{
      if (typeof name === "object") {
        if (name.$$is_string) name = name.toString();
        else if (name.name && name.names) return name; // assuming a ::Encoding
      }
      if (typeof name !== "string") $raise(Opal.ArgumentError, "not a encoding name " + name);
      let register = Opal.encodings;
      let encoding = register[name] || register[name.toUpperCase()];
      if (!encoding) $raise(Opal.ArgumentError, "unknown encoding name - " + name);
      return encoding;
    }
  end

  def self.fallback_to_s(obj = undefined)
    %x{`#<${obj.$$class.$to_s()}:0x${Opal.id(obj).toString(16)}>`}
  end

  def self.to_s(obj = undefined)
    %x{
      // A case for someone calling Opal.to_s
      if (arguments.length == 0) return "Opal";

      var stringified;
      if (obj == null) {
        return "`"+String(obj)+"`";
      }
      else if (typeof obj === 'string' || (typeof obj === 'object' && obj.$$is_string)) {
        return obj;
      }
      else if (obj.$to_s != null && !obj.$to_s.$$stub) {
        stringified = obj.$to_s();
        if (typeof stringified !== 'string' && !stringified.$$is_string) {
          stringified = Opal.fallback_to_s(obj);
        }
        return stringified;
      }
      else {
        return obj.toString();
      }
    }
  end

  # Forward .toString() to #to_s
  %x{
    $prop($Object.$$prototype, 'toString', function() {
      var to_s = this.$to_s();
      if (to_s.$$is_string && typeof(to_s) === 'object') {
        // a string created using new String('string')
        return to_s.valueOf();
      } else {
        return to_s;
      }
    });
  }

  # Return UTF-16 char length, returns 0 if end of string is reached,
  # otherwise 1 for simple characters or 2 for surrogates.
  def self.mbclen(str, idx)
    %x{
      let cp = str.codePointAt(idx);
      return (cp == null) ? 0 : ((cp < 0x10000) ? 1 : 2);
    }
  end

  # Increment index of str by UTF-16 char length, returns new index.
  def self.mbinc(str, idx)
    `idx + Opal.mbclen(str, idx)`
  end
end

::Opal
