# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: prop, raise, Object, ancestors, has_own

module ::Opal
  %x{
    // Walk up the nesting array looking for the constant
    function const_lookup_nesting(nesting, name) {
      var i, ii, constant;

      if (nesting.length === 0) return;

      // If the nesting is not empty the constant is looked up in its elements
      // and in order. The ancestors of those elements are ignored.
      for (i = 0, ii = nesting.length; i < ii; i++) {
        constant = nesting[i].$$const[name];
        if (constant != null) {
          return constant;
        } else if (nesting[i].$$autoload && nesting[i].$$autoload[name]) {
          return Opal.handle_autoload(nesting[i], name);
        }
      }
    }

    // Walk up Object's ancestors chain looking for the constant,
    // but only if cref is missing or a module.
    function const_lookup_Object(cref, name) {
      if (cref == null || cref.$$is_module) {
        return Opal.const_lookup_ancestors($Object, name);
      }
    }

    // Call const_missing if nothing else worked
    function const_missing(cref, name) {
      return (cref || $Object).$const_missing(name);
    }
  }

  def self.const_get_name(cref = undefined, name = undefined)
    %x{
      if (cref) {
        if (cref.$$const[name] != null) { return cref.$$const[name]; }
        if (cref.$$autoload && cref.$$autoload[name]) {
          return Opal.handle_autoload(cref, name);
        }
      }
    }
  end

  # Walk up the ancestors chain looking for the constant
  def self.const_lookup_ancestors(cref = undefined, name = undefined)
    %x{
      var i, ii, ancestors;

      if (cref == null) return;

      ancestors = $ancestors(cref);

      for (i = 0, ii = ancestors.length; i < ii; i++) {
        if (ancestors[i].$$const && $has_own(ancestors[i].$$const, name)) {
          return ancestors[i].$$const[name];
        } else if (ancestors[i].$$autoload && ancestors[i].$$autoload[name]) {
          return Opal.handle_autoload(ancestors[i], name);
        }
      }
    }
  end

  def self.handle_autoload(cref = undefined, name = undefined)
    %x{
      if (!cref.$$autoload[name].loaded) {
        cref.$$autoload[name].loaded = true;
        try {
          Opal.Kernel.$require(cref.$$autoload[name].path);
        } catch (e) {
          cref.$$autoload[name].exception = e;
          throw e;
        }
        cref.$$autoload[name].required = true;
        if (cref.$$const[name] != null) {
          cref.$$autoload[name].success = true;
          return cref.$$const[name];
        }
      } else if (cref.$$autoload[name].loaded && !cref.$$autoload[name].required) {
        if (cref.$$autoload[name].exception) { throw cref.$$autoload[name].exception; }
      }
    }
  end

  # Look for the constant just in the current cref or call `#const_missing`
  def self.const_get_local(cref = undefined, name = undefined, skip_missing = undefined)
    %x{
      var result;

      if (cref == null) return;

      if (cref === '::') cref = $Object;

      if (!cref.$$is_module && !cref.$$is_class) {
        $raise(Opal.TypeError, cref.toString() + " is not a class/module");
      }

      result = Opal.const_get_name(cref, name);
      return result != null || skip_missing ? result : const_missing(cref, name);
    }
  end

  # Look for the constant relative to a cref or call `#const_missing` (when the
  # constant is prefixed by `::`).
  def self.const_get_qualified(cref = undefined, name = undefined, skip_missing = undefined)
    %x{
      var result, cache, cached, current_version = Opal.const_cache_version;

      if (name == null) {
        // A shortpath for calls like ::String => $$$("String")
        result = Opal.const_get_name($Object, cref);

        if (result != null) return result;
        return Opal.const_get_qualified($Object, cref, skip_missing);
      }

      if (cref == null) return;

      if (cref === '::') cref = $Object;

      if (!cref.$$is_module && !cref.$$is_class) {
        $raise(Opal.TypeError, cref.toString() + " is not a class/module");
      }

      if ((cache = cref.$$const_cache) == null) {
        $prop(cref, '$$const_cache', Object.create(null));
        cache = cref.$$const_cache;
      }
      cached = cache[name];

      if (cached == null || cached[0] !== current_version) {
        ((result = Opal.const_get_name(cref, name))              != null) ||
        ((result = Opal.const_lookup_ancestors(cref, name))      != null);
        cache[name] = [current_version, result];
      } else {
        result = cached[1];
      }

      return result != null || skip_missing ? result : const_missing(cref, name);
    }
  end

  # Look for the constant in the open using the current nesting and the nearest
  # cref ancestors or call `#const_missing` (when the constant has no :: prefix).
  def self.const_get_relative(nesting = undefined, name = undefined, skip_missing = undefined)
    %x{
      var cref = nesting[0], result, current_version = Opal.const_cache_version, cache, cached;

      if ((cache = nesting.$$const_cache) == null) {
        $prop(nesting, '$$const_cache', Object.create(null));
        cache = nesting.$$const_cache;
      }
      cached = cache[name];

      if (cached == null || cached[0] !== current_version) {
        ((result = Opal.const_get_name(cref, name))              != null) ||
        ((result = const_lookup_nesting(nesting, name))     != null) ||
        ((result = Opal.const_lookup_ancestors(cref, name))      != null) ||
        ((result = const_lookup_Object(cref, name))         != null);

        cache[name] = [current_version, result];
      } else {
        result = cached[1];
      }

      return result != null || skip_missing ? result : const_missing(cref, name);
    }
  end

  # Get all the constants reachable from a given cref, by default will include
  # inherited constants.
  def self.constants(cref = undefined, inherit = undefined)
    %x{
      if (inherit == null) inherit = true;

      var module, modules = [cref], i, ii, constants = {}, constant;

      if (inherit) modules = modules.concat(Opal.ancestors(cref));
      if (inherit && cref.$$is_module) modules = modules.concat([Opal.Object]).concat(Opal.ancestors(Opal.Object));

      for (i = 0, ii = modules.length; i < ii; i++) {
        module = modules[i];

        // Do not show Objects constants unless we're querying Object itself
        if (cref !== $Object && module == $Object) break;

        for (constant in module.$$const) {
          constants[constant] = true;
        }
        if (module.$$autoload) {
          for (constant in module.$$autoload) {
            constants[constant] = true;
          }
        }
      }

      return Object.keys(constants);
    }
  end

  # Remove a constant from a cref.
  def self.const_remove(cref = undefined, name = undefined)
    %x{
      Opal.const_cache_version++;

      if (cref.$$const[name] != null) {
        var old = cref.$$const[name];
        delete cref.$$const[name];
        return old;
      }

      if (cref.$$autoload && cref.$$autoload[name]) {
        delete cref.$$autoload[name];
        return nil;
      }

      $raise(Opal.NameError, "constant "+cref+"::"+cref.$name()+" not defined");
    }
  end

  # Generates a function that is a curried const_get_relative.
  def self.const_get_relative_factory(nesting = undefined)
    %x{
      return function(name, skip_missing) {
        return Opal.$$(nesting, name, skip_missing);
      }
    }
  end

  %x{
    // For compatibility, let's copy properties from
    // earlier Opal.$$.

    for (var i in Opal.$$) {
      if ($has_own(Opal.$$, i)) {
        Opal.const_get_relative[i] = Opal.$$[i];
      }
    }

    // Setup some shortcuts to reduce compiled size
    Opal.$$ = Opal.const_get_relative;
    Opal.$$$ = Opal.const_get_qualified;
    Opal.$r = Opal.const_get_relative_factory;
  }
end

::Opal
