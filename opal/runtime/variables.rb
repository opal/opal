# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: gvars

module ::Opal
  # Instance variables
  # ------------------

  %x{
    var reserved_ivar_names = [
      // properties
      "constructor", "displayName", "__count__", "__noSuchMethod__",
      "__parent__", "__proto__",
      // methods
      "hasOwnProperty", "valueOf"
    ];
  }

  # Get the ivar name for a given name.
  # Mostly adds a trailing $ to reserved names.
  def self.ivar(name = undefined)
    %x{
      if (reserved_ivar_names.indexOf(name) !== -1) {
        name += "$";
      }

      return name;
    }
  end

  # Iterate over every instance variable and call func for each one
  # giving name of the ivar and optionally the property descriptor.
  def self.each_ivar(obj = undefined, func = undefined)
    %x{
      var own_props = Object.keys(obj), own_props_length = own_props.length, i, prop;

      for (i = 0; i < own_props_length; i++) {
        prop = own_props[i];

        if (prop[0] === '$') continue;

        func(prop);
      }
    }
  end

  # Global variables
  # ----------------

  def self.alias_gvar(new_name = undefined, old_name = undefined)
    %x{
      Object.defineProperty($gvars, new_name, {
        configurable: true,
        enumerable: true,
        get: function() {
          return $gvars[old_name];
        },
        set: function(new_value) {
          $gvars[old_name] = new_value;
        }
      });
    }
    nil
  end
end

::Opal
