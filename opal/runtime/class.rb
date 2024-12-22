# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, prop, Object, BasicObject, Class, Module, set_proto, allocate_class, const_get_name, const_set, has_own, ancestors

module ::Opal
  %x{
    // TracePoint support
    // ------------------
    //
    // Support for `TracePoint.trace(:class) do ... end`
    Opal.trace_class = false;
    Opal.tracers_for_class = [];

    function invoke_tracers_for_class(klass_or_module) {
      var i, ii, tracer;

      for(i = 0, ii = Opal.tracers_for_class.length; i < ii; i++) {
        tracer = Opal.tracers_for_class[i];
        tracer.trace_object = klass_or_module;
        tracer.block.$call(tracer);
      }
    }

    function find_existing_class(scope, name) {
      // Try to find the class in the current scope
      var klass = $const_get_name(scope, name);

      // If the class exists in the scope, then we must use that
      if (klass) {
        // Make sure the existing constant is a class, or raise error
        if (!klass.$$is_class) {
          $raise(Opal.TypeError, name + " is not a class");
        }

        return klass;
      }
    }

    function ensureSuperclassMatch(klass, superclass) {
      if (klass.$$super !== superclass) {
        $raise(Opal.TypeError, "superclass mismatch for class " + klass.$$name);
      }
    }
  }

  def self.klass(scope = undefined, superclass = undefined, name = undefined)
    %x{
      var bridged;

      if (scope == null || scope === '::') {
        // Global scope
        scope = $Object;
      } else if (!scope.$$is_class && !scope.$$is_module) {
        // Scope is an object, use its class
        scope = scope.$$class;
      }

      // If the superclass is not an Opal-generated class then we're bridging a native JS class
      if (
        superclass != null && (!superclass.hasOwnProperty || (
          superclass.hasOwnProperty && !superclass.hasOwnProperty('$$is_class')
        ))
      ) {
        if (superclass.constructor && superclass.constructor.name == "Function") {
          bridged = superclass;
          superclass = $Object;
        } else {
          $raise(Opal.TypeError, "superclass must be a Class (" + (
            (superclass.constructor && (superclass.constructor.name || superclass.constructor.$$name)) ||
            typeof(superclass)
          ) + " given)");
        }
      }

      var klass = find_existing_class(scope, name);

      if (klass != null) {
        if (superclass) {
          // Make sure existing class has same superclass
          ensureSuperclassMatch(klass, superclass);
        }
      }
      else {
        // Class doesn't exist, create a new one with given superclass...

        // Not specifying a superclass means we can assume it to be Object
        if (superclass == null) {
          superclass = $Object;
        }

        // Create the class object (instance of Class)
        klass = $allocate_class(name, superclass);
        $const_set(scope, name, klass);

        // Call .inherited() hook with new class on the superclass
        if (superclass.$inherited) {
          superclass.$inherited(klass);
        }

        if (bridged) {
          Opal.bridge(bridged, klass);
        }
      }

      if (Opal.trace_class) { invoke_tracers_for_class(klass); }

      return klass;
    }
  end

  # Class variables
  # ---------------

  # Returns an object containing all pairs of names/values
  # for all class variables defined in provided +module+
  # and its ancestors.
  #
  # @param module [Module]
  # @return [Object]
  def self.class_variables(mod = undefined)
    %x{
      var ancestors = $ancestors(mod),
          i, length = ancestors.length,
          result = {};

      for (i = length - 1; i >= 0; i--) {
        var ancestor = ancestors[i];

        for (var cvar in ancestor.$$cvars) {
          result[cvar] = ancestor.$$cvars[cvar];
        }
      }

      return result;
    }
  end

  # Sets class variable with specified +name+ to +value+
  # in provided +module+
  #
  # @param module [Module]
  # @param name [String]
  # @param value [Object]
  def self.class_variable_set(mod = undefined, name = undefined, value = undefined)
    %x{
      var ancestors = $ancestors(mod),
          i, length = ancestors.length;

      for (i = length - 2; i >= 0; i--) {
        var ancestor = ancestors[i];

        if ($has_own(ancestor.$$cvars, name)) {
          ancestor.$$cvars[name] = value;
          return value;
        }
      }

      mod.$$cvars[name] = value;

      return value;
    }
  end

  # Gets class variable with specified +name+ from provided +module+
  #
  # @param module [Module]
  # @param name [String]
  def self.class_variable_get(mod = undefined, name = undefined, tolerant = undefined)
    %x{
      if ($has_own(mod.$$cvars, name))
        return mod.$$cvars[name];

      var ancestors = $ancestors(mod),
        i, length = ancestors.length;

      for (i = 0; i < length; i++) {
        var ancestor = ancestors[i];

        if ($has_own(ancestor.$$cvars, name)) {
          return ancestor.$$cvars[name];
        }
      }

      if (!tolerant)
        $raise(Opal.NameError, 'uninitialized class variable '+name+' in '+mod.$name());

      return nil;
    }
  end

  # Singleton classes
  # -----------------

  # Return the singleton class for the passed object.
  #
  # If the given object alredy has a singleton class, then it will be stored on
  # the object as the `$$meta` property. If this exists, then it is simply
  # returned back.
  #
  # Otherwise, a new singleton object for the class or object is created, set on
  # the object at `$$meta` for future use, and then returned.
  #
  # @param object [Object] the ruby object
  # @return [Class] the singleton class for object
  def self.get_singleton_class(object = undefined)
    %x{
      if (object.$$is_number) {
        $raise(Opal.TypeError, "can't define singleton");
      }
      if (object.$$meta) {
        return object.$$meta;
      }

      if (object.hasOwnProperty('$$is_class')) {
        return Opal.build_class_singleton_class(object);
      } else if (object.hasOwnProperty('$$is_module')) {
        return Opal.build_module_singleton_class(object);
      } else {
        return Opal.build_object_singleton_class(object);
      }
    }
  end

  # Helper to set $$meta on klass, module or instance
  %x{
    function set_meta(obj, meta) {
      if (obj.hasOwnProperty('$$meta')) {
        obj.$$meta = meta;
      } else {
        $prop(obj, '$$meta', meta);
      }
      if (obj.$$frozen) {
        // If a object is frozen (sealed), freeze $$meta too.
        // No need to inject $$meta.$$prototype in the prototype chain,
        // as $$meta cannot be modified anyway.
        obj.$$meta.$freeze();
      } else {
        $set_proto(obj, meta.$$prototype);
      }
    };
  }

  # Build the singleton class for an existing class. Class object are built
  # with their singleton class already in the prototype chain and inheriting
  # from their superclass object (up to `Class` itself).
  #
  # NOTE: Actually in MRI a class' singleton class inherits from its
  # superclass' singleton class which in turn inherits from Class.
  #
  # @param klass [Class]
  # @return [Class]
  def self.build_class_singleton_class(klass = undefined)
    %x{
      if (klass.$$meta) {
        return klass.$$meta;
      }

      // The singleton_class superclass is the singleton_class of its superclass;
      // but BasicObject has no superclass (its `$$super` is null), thus we
      // fallback on `Class`.
      var superclass = klass === $BasicObject ? $Class : Opal.get_singleton_class(klass.$$super);

      var meta = $allocate_class(null, superclass, true);

      $prop(meta, '$$is_singleton', true);
      $prop(meta, '$$singleton_of', klass);
      set_meta(klass, meta);
      // Restoring ClassName.class
      $prop(klass, '$$class', $Class);

      return meta;
    }
  end

  def self.build_module_singleton_class(mod = undefined)
    %x{
      if (mod.$$meta) {
        return mod.$$meta;
      }

      var meta = $allocate_class(null, $Module, true);

      $prop(meta, '$$is_singleton', true);
      $prop(meta, '$$singleton_of', mod);
      set_meta(mod, meta);
      // Restoring ModuleName.class
      $prop(mod, '$$class', $Module);

      return meta;
    }
  end

  # Build the singleton class for a Ruby (non class) Object.
  #
  # @param object [Object]
  # @return [Class]
  def self.build_object_singleton_class(object = undefined)
    %x{
      var superclass = object.$$class,
          klass = $allocate_class(nil, superclass, true);

      $prop(klass, '$$is_singleton', true);
      $prop(klass, '$$singleton_of', object);

      delete klass.$$prototype.$$class;

      set_meta(object, klass);

      return klass;
    }
  end
end

::Opal
