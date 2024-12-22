# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: prop, raise, uid, return_val

module ::Opal
  # Support for #freeze
  # -------------------

  # Common #freeze runtime support
  def self.freeze(obj = undefined)
    %x{
      $prop(obj, "$$frozen", true);

      // set $$id
      if (!obj.hasOwnProperty('$$id')) { $prop(obj, '$$id', $uid()); }

      if (obj.hasOwnProperty('$$meta')) {
        // freeze $$meta if it has already been set
        obj.$$meta.$freeze();
      } else {
        // ensure $$meta can be set lazily, $$meta is frozen when set in runtime.js
        $prop(obj, '$$meta', null);
      }

      // $$comparable is used internally and set multiple times
      // defining it before sealing ensures it can be modified later on
      if (!obj.hasOwnProperty('$$comparable')) { $prop(obj, '$$comparable', null); }

      // seal the Object
      Object.seal(obj);

      return obj;
    }
  end

  # Freeze props, make setters of instance variables throw FrozenError
  def self.freeze_props(obj = undefined)
    %x{
      var own_props = Object.keys(obj), own_props_length = own_props.length, i, prop, desc,
        dp_template = {
          get: null,
          set: function (_val) { Opal.deny_frozen_access(obj); },
          enumerable: true
        };

      for (i = 0; i < own_props_length; i++) {
        prop = own_props[i];

        if (prop[0] === '$') continue;

        desc = Object.getOwnPropertyDescriptor(obj, prop);

        if (desc && desc.writable) {
          dp_template.get = $return_val(desc.value);
          Object.defineProperty(obj, prop, dp_template);
        }
      }
    }
  end

  # Helper that can be used from methods
  def self.deny_frozen_access(obj = undefined)
    %x{
      if (obj.$$frozen)
        $raise(Opal.FrozenError, "can't modify frozen " + (obj.$class()) + ": " + (obj), new Map([["receiver", obj]]));
    }
  end
end

::Opal
