(function(undefined) {
  // @note
  //   A few conventions for the documentation of this file:
  //   1. Always use "//" (in contrast with "/**/")
  //   2. The syntax used is Yardoc (yardoc.org), which is intended for Ruby (se below)
  //   3. `@param` and `@return` types should be preceded by `JS.` when referring to
  //      JavaScript constructors (e.g. `JS.Function`) otherwise Ruby is assumed.
  //   4. `nil` and `null` being unambiguous refer to the respective
  //      objects/values in Ruby and JavaScript
  //   5. This is still WIP :) so please give feedback and suggestions on how
  //      to improve or for alternative solutions
  //
  //   The way the code is digested before going through Yardoc is a secret kept
  //   in the docs repo (https://github.com/opal/docs/tree/master).

  var global_object = this, console;

  // Detect the global object
  if (typeof(global) !== 'undefined') { global_object = global; }
  if (typeof(window) !== 'undefined') { global_object = window; }

  // Setup a dummy console object if missing
  if (typeof(global_object.console) === 'object') {
    console = global_object.console;
  } else if (global_object.console == null) {
    console = global_object.console = {};
  } else {
    console = {};
  }

  if (!('log' in console)) { console.log = function () {}; }
  if (!('warn' in console)) { console.warn = console.log; }

  if (typeof(this.Opal) !== 'undefined') {
    console.warn('Opal already loaded. Loading twice can cause troubles, please fix your setup.');
    return this.Opal;
  }

  var nil;

  // The actual class for BasicObject
  var BasicObject;

  // The actual Object class.
  // The leading underscore is to avoid confusion with window.Object()
  var _Object;

  // The actual Module class
  var Module;

  // The actual Class class
  var Class;

  // Constructor for instances of BasicObject
  function BasicObject_alloc(){}

  // Constructor for instances of Object
  function Object_alloc(){}

  // Constructor for instances of Class
  function Class_alloc(){}

  // Constructor for instances of Module
  function Module_alloc(){}

  // Constructor for instances of NilClass (nil)
  function NilClass_alloc(){}

  // The Opal object that is exposed globally
  var Opal = this.Opal = {};

  // All bridged classes - keep track to donate methods from Object
  var BridgedClasses = {};

  // This is a useful reference to global object inside ruby files
  Opal.global = global_object;
  global_object.Opal = Opal;

  // Configure runtime behavior with regards to require and unsupported fearures
  Opal.config = {
    missing_require_severity: 'error',        // error, warning, ignore
    unsupported_features_severity: 'warning', // error, warning, ignore
    enable_stack_trace: true                  // true, false
  }

  // Minify common function calls
  var $hasOwn = Object.hasOwnProperty;
  var $slice  = Opal.slice = Array.prototype.slice;

  // Nil object id is always 4
  var nil_id = 4;

  // Generates even sequential numbers greater than 4
  // (nil_id) to serve as unique ids for ruby objects
  var unique_id = nil_id;

  // Return next unique id
  Opal.uid = function() {
    unique_id += 2;
    return unique_id;
  };

  // Retrieve or assign the id of an object
  Opal.id = function(obj) {
    if (obj.$$is_number) return (obj * 2)+1;
    return obj.$$id || (obj.$$id = Opal.uid());
  };

  // Globals table
  Opal.gvars = {};

  // Exit function, this should be replaced by platform specific implementation
  // (See nodejs and chrome for examples)
  Opal.exit = function(status) { if (Opal.gvars.DEBUG) console.log('Exited with status '+status); };

  // keeps track of exceptions for $!
  Opal.exceptions = [];

  // @private
  // Pops an exception from the stack and updates `$!`.
  Opal.pop_exception = function() {
    Opal.gvars["!"] = Opal.exceptions.pop() || nil;
  }

  // Inspect any kind of object, including non Ruby ones
  Opal.inspect = function(obj) {
    if (obj === undefined) {
      return "undefined";
    }
    else if (obj === null) {
      return "null";
    }
    else if (!obj.$$class) {
      return obj.toString();
    }
    else {
      return obj.$inspect();
    }
  }

  function $defineProperty(object, name, initialValue) {
    Object.defineProperty(object, name, {
      value: initialValue,
      enumerable: false,
      configurable: true
    });
  }

  Opal.defineProperty = $defineProperty;


  // Truth
  // -----

  Opal.truthy = function(val) {
    return (val !== nil && val != null && (!val.$$is_boolean || val == true));
  };

  Opal.falsy = function(val) {
    return (val === nil || val == null || (val.$$is_boolean && val == false))
  };


  // Constants
  // ---------
  //
  // For future reference:
  // - The Rails autoloading guide (http://guides.rubyonrails.org/v5.0/autoloading_and_reloading_constants.html)
  // - @ConradIrwin's 2012 post on “Everything you ever wanted to know about constant lookup in Ruby” (http://cirw.in/blog/constant-lookup.html)
  //
  // Legend of MRI concepts/names:
  // - constant reference (cref): the module/class that acts as a namespace
  // - nesting: the namespaces wrapping the current scope, e.g. nesting inside
  //            `module A; module B::C; end; end` is `[B::C, A]`

  // Get the constant in the scope of the current cref
  function const_get_name(cref, name) {
    if (cref) return cref.$$const[name];
  }

  // Walk up the nesting array looking for the constant
  function const_lookup_nesting(nesting, name) {
    var i, ii, result, constant;

    if (nesting.length === 0) return;

    // If the nesting is not empty the constant is looked up in its elements
    // and in order. The ancestors of those elements are ignored.
    for (i = 0, ii = nesting.length; i < ii; i++) {
      constant = nesting[i].$$const[name];
      if (constant != null) return constant;
    }
  }

  // Walk up the ancestors chain looking for the constant
  function const_lookup_ancestors(cref, name) {
    var i, ii, result, ancestors;

    if (cref == null) return;

    ancestors = Opal.ancestors(cref);

    for (i = 0, ii = ancestors.length; i < ii; i++) {
      if (ancestors[i].$$const && $hasOwn.call(ancestors[i].$$const, name)) {
        return ancestors[i].$$const[name];
      }
    }
  }

  // Walk up Object's ancestors chain looking for the constant,
  // but only if cref is missing or a module.
  function const_lookup_Object(cref, name) {
    if (cref == null || cref.$$is_module) {
      return const_lookup_ancestors(_Object, name);
    }
  }

  // Call const_missing if nothing else worked
  function const_missing(cref, name, skip_missing) {
    if (!skip_missing) {
      return (cref || _Object).$const_missing(name);
    }
  }

  // Look for the constant just in the current cref or call `#const_missing`
  Opal.const_get_local = function(cref, name, skip_missing) {
    var result;

    if (cref == null) return;

    if (cref === '::') cref = _Object;

    if (!cref.$$is_module && !cref.$$is_class) {
      throw new Opal.TypeError(cref.toString() + " is not a class/module");
    }

    result = const_get_name(cref, name);              if (result != null) return result;
    result = const_missing(cref, name, skip_missing); if (result != null) return result;
  }

  // Look for the constant relative to a cref or call `#const_missing` (when the
  // constant is prefixed by `::`).
  Opal.const_get_qualified = function(cref, name, skip_missing) {
    var result, cache, cached, current_version = Opal.const_cache_version;

    if (cref == null) return;

    if (cref === '::') cref = _Object;

    if (!cref.$$is_module && !cref.$$is_class) {
      throw new Opal.TypeError(cref.toString() + " is not a class/module");
    }

    if ((cache = cref.$$const_cache) == null) {
      cache = cref.$$const_cache = Object.create(null);
    }
    cached = cache[name];

    if (cached == null || cached[0] !== current_version) {
      ((result = const_get_name(cref, name))              != null) ||
      ((result = const_lookup_ancestors(cref, name))      != null);
      cache[name] = [current_version, result];
    } else {
      result = cached[1];
    }

    return result != null ? result : const_missing(cref, name, skip_missing);
  };

  // Initialize the top level constant cache generation counter
  Opal.const_cache_version = 1;

  // Look for the constant in the open using the current nesting and the nearest
  // cref ancestors or call `#const_missing` (when the constant has no :: prefix).
  Opal.const_get_relative = function(nesting, name, skip_missing) {
    var cref = nesting[0], result, current_version = Opal.const_cache_version, cache, cached;

    if ((cache = nesting.$$const_cache) == null) {
      cache = nesting.$$const_cache = Object.create(null);
    }
    cached = cache[name];

    if (cached == null || cached[0] !== current_version) {
      ((result = const_get_name(cref, name))              != null) ||
      ((result = const_lookup_nesting(nesting, name))     != null) ||
      ((result = const_lookup_ancestors(cref, name))      != null) ||
      ((result = const_lookup_Object(cref, name))         != null);

      cache[name] = [current_version, result];
    } else {
      result = cached[1];
    }

    return result != null ? result : const_missing(cref, name, skip_missing);
  };

  // Register the constant on a cref and opportunistically set the name of
  // unnamed classes/modules.
  Opal.const_set = function(cref, name, value) {
    if (cref == null || cref === '::') cref = _Object;

    if (value.$$is_class || value.$$is_module) {
      if (value.$$name == null || value.$$name === nil) value.$$name = name;
      if (value.$$base_module == null) value.$$base_module = cref;
    }

    cref.$$const = (cref.$$const || Object.create(null));
    cref.$$const[name] = value;

    // Add a short helper to navigate constants manually.
    // @example
    //   Opal.$$.Regexp.$$.IGNORECASE
    cref.$$ = cref.$$const;

    Opal.const_cache_version++;

    // Expose top level constants onto the Opal object
    if (cref === _Object) Opal[name] = value;

    return value;
  };

  // Get all the constants reachable from a given cref, by default will include
  // inherited constants.
  Opal.constants = function(cref, inherit) {
    if (inherit == null) inherit = true;

    var module, modules = [cref], module_constants, i, ii, constants = {}, constant;

    if (inherit) modules = modules.concat(Opal.ancestors(cref));
    if (inherit && cref.$$is_module) modules = modules.concat([Opal.Object]).concat(Opal.ancestors(Opal.Object));

    for (i = 0, ii = modules.length; i < ii; i++) {
      module = modules[i];

      // Don not show Objects constants unless we're querying Object itself
      if (cref !== _Object && module == _Object) break;

      for (constant in module.$$const) {
        constants[constant] = true;
      }
    }

    return Object.keys(constants);
  };

  // Remove a constant from a cref.
  Opal.const_remove = function(cref, name) {
    Opal.const_cache_version++;

    if (cref.$$const[name] != null) {
      var old = cref.$$const[name];
      delete cref.$$const[name];
      return old;
    }

    if (cref.$$autoload != null && cref.$$autoload[name] != null) {
      delete cref.$$autoload[name];
      return nil;
    }

    throw Opal.NameError.$new("constant "+cref+"::"+cref.$name()+" not defined");
  };


  // Modules & Classes
  // -----------------

  // A `class Foo; end` expression in ruby is compiled to call this runtime
  // method which either returns an existing class of the given name, or creates
  // a new class in the given `base` scope.
  //
  // If a constant with the given name exists, then we check to make sure that
  // it is a class and also that the superclasses match. If either of these
  // fail, then we raise a `TypeError`. Note, `superclass` may be null if one
  // was not specified in the ruby code.
  //
  // We pass a constructor to this method of the form `function ClassName() {}`
  // simply so that classes show up with nicely formatted names inside debuggers
  // in the web browser (or node/sprockets).
  //
  // The `base` is the current `self` value where the class is being created
  // from. We use this to get the scope for where the class should be created.
  // If `base` is an object (not a class/module), we simple get its class and
  // use that as the base instead.
  //
  // @param base        [Object] where the class is being created
  // @param superclass  [Class,null] superclass of the new class (may be null)
  // @param id          [String] the name of the class to be created
  // @param constructor [JS.Function] function to use as constructor
  //
  // @return new [Class]  or existing ruby class
  //
  Opal.klass = function(base, superclass, name, constructor) {
    var klass, bridged, alloc;

    if (base == null) {
      base = _Object;
    }

    // If base is an object, use its class
    if (!base.$$is_class && !base.$$is_module) {
      base = base.$$class;
    }

    // If the superclass is a function then we're bridging a native JS class
    if (typeof(superclass) === 'function') {
      bridged = superclass;
      superclass = _Object;
    }

    // Try to find the class in the current scope
    klass = const_get_name(base, name);

    // If the class exists in the scope, then we must use that
    if (klass) {
      // Make sure the existing constant is a class, or raise error
      if (!klass.$$is_class) {
        throw Opal.TypeError.$new(name + " is not a class");
      }

      // Make sure existing class has same superclass
      if (superclass && klass.$$super !== superclass) {
        throw Opal.TypeError.$new("superclass mismatch for class " + name);
      }

      return klass;
    }

    // Class doesnt exist, create a new one with given superclass...

    // Not specifying a superclass means we can assume it to be Object
    if (superclass == null) {
      superclass = _Object;
    }

    // If bridged the JS class will also be the alloc function
    alloc = bridged || Opal.boot_class_alloc(name, constructor, superclass);

    // Create the class object (instance of Class)
    klass = Opal.setup_class_object(name, alloc, superclass.$$name, superclass.constructor);

    // @property $$super the superclass, doesn't get changed by module inclusions
    klass.$$super = superclass;

    // @property $$parent direct parent class
    //                    starts with the superclass, after klass inclusion is
    //                    the last included klass
    klass.$$parent = superclass;

    klass.$$ancestors = [klass];

    Opal.const_set(base, name, klass);

    // Name new class directly onto current scope (Opal.Foo.Baz = klass)
    base[name] = klass;

    if (bridged) {
      Opal.bridge(klass, alloc);
    }
    else {
      // Call .inherited() hook with new class on the superclass
      if (superclass.$inherited) {
        superclass.$inherited(klass);
      }
    }

    return klass;
  };

  // Boot a base class (makes instances).
  //
  // @param name [String,null] the class name
  // @param constructor [JS.Function] the class' instances constructor/alloc function
  // @param superclass  [Class,null] the superclass object
  // @return [JS.Function] the consturctor holding the prototype for the class' instances
  Opal.boot_class_alloc = function(name, constructor, superclass) {
    if (name) {
      constructor.displayName = name+'_alloc';
    }

    if (superclass) {
      var alloc_proxy = function() {};
      alloc_proxy.prototype = superclass.$$proto || superclass.prototype;
      constructor.prototype = new alloc_proxy();
    }

    constructor.prototype.constructor = constructor;

    return constructor;
  };

  Opal.setup_module_or_class = function(module) {
    // @property $$id Each class/module is assigned a unique `id` that helps
    //                comparation and implementation of `#object_id`
    module.$$id = Opal.uid();

    // initialize the name with nil
    module.$$name = nil;

    // a list of class or module ancestors (like Object.ancestors)
    module.$$ancestors = [];
    module.$$included_modules = [];
    module.$$prepended_modules = [];

    // Initialize the constants table
    module.$$const = Object.create(null);

    // @property $$cvars class variables defined in the current module
    module.$$cvars = Object.create(null);
  }



  // Adds common/required properties to class object (as in `Class.new`)
  //
  // @param name  [String,null] The name of the class
  //
  // @param alloc [JS.Function] The constructor of the class' instances
  //
  // @param superclass_name [String,null]
  //   The name of the super class, this is
  //   usefule to build the `.displayName` of the singleton class
  //
  // @param superclass_alloc [JS.Function]
  //   The constructor of the superclass from which the singleton_class is
  //   derived.
  //
  // @return [Class]
  Opal.setup_class_object = function(name, alloc, superclass_name, superclass_alloc) {
    // Grab the superclass prototype and use it to build an intermediary object
    // in the prototype chain.
    var superclass_alloc_proxy = function() {};
        superclass_alloc_proxy.prototype = superclass_alloc.prototype;
        superclass_alloc_proxy.displayName = superclass_name;

    var singleton_class_alloc = function() {}
        singleton_class_alloc.prototype = new superclass_alloc_proxy();

    // The built class is the only instance of its singleton_class
    var klass = new singleton_class_alloc();

    Opal.setup_module_or_class(klass);

    // @property $$alloc This is the constructor of instances of the current
    //                   class. Its prototype will be used for method lookup
    klass.$$alloc = alloc;

    klass.$$name = name || nil;

    // Set a displayName for the singleton_class
    singleton_class_alloc.displayName = "#<Class:"+(name || ("#<Class:"+klass.$$id+">"))+">";

    // @property $$proto This is the prototype on which methods will be defined
    klass.$$proto = alloc.prototype;
    klass.$$proto.$$methods = [];

    // @property $$proto.$$class Make available to instances a reference to the
    //                           class they belong to.
    klass.$$proto.$$class = klass;

    // @property constructor keeps a ref to the constructor, but apparently the
    //                       constructor is already set on:
    //
    //                          `var klass = new constructor` is called.
    //
    //                       Maybe there are some browsers not abiding (IE6?)
    klass.constructor = singleton_class_alloc;

    // @property $$is_class Clearly mark this as a class
    klass.$$is_class = true;

    // @property $$class Classes are instances of the class Class
    klass.$$class    = Class;

    return klass;
  };

  // Define new module (or return existing module). The given `base` is basically
  // the current `self` value the `module` statement was defined in. If this is
  // a ruby module or class, then it is used, otherwise if the base is a ruby
  // object then that objects real ruby class is used (e.g. if the base is the
  // main object, then the top level `Object` class is used as the base).
  //
  // If a module of the given name is already defined in the base, then that
  // instance is just returned.
  //
  // If there is a class of the given name in the base, then an error is
  // generated instead (cannot have a class and module of same name in same base).
  //
  // Otherwise, a new module is created in the base with the given name, and that
  // new instance is returned back (to be referenced at runtime).
  //
  // @param  base [Module, Class] class or module this definition is inside
  // @param  id   [String] the name of the new (or existing) module
  //
  // @return [Module]
  Opal.module = function(base, name) {
    var module;

    if (base == null) {
      base = _Object;
    }

    if (!base.$$is_class && !base.$$is_module) {
      base = base.$$class;
    }

    module = const_get_name(base, name);
    if (module == null && base === _Object) module = const_lookup_ancestors(_Object, name);

    if (module) {
      if (!module.$$is_module && module !== _Object) {
        throw Opal.TypeError.$new(name + " is not a module");
      }
    }
    else {
      module = Opal.module_allocate(Module);
      Opal.const_set(base, name, module);
    }

    module.$$ancestors = [module];

    return module;
  };

  // The implementation for Module#initialize
  // @param module [Module]
  // @param block [Proc,nil]
  // @return nil
  Opal.module_initialize = function(module, block) {
    if (block !== nil) {
      var block_self = block.$$s;
      block.$$s = null;
      block.call(module);
      block.$$s = block_self;
    }
    return nil;
  };

  // Internal function to create a new module instance. This simply sets up
  // the prototype hierarchy and method tables.
  //
  Opal.module_allocate = function(superclass) {
    var mtor = function() {};
    mtor.prototype = superclass.$$alloc.prototype;

    var module_constructor = function() {};
    module_constructor.prototype = new mtor();

    var module = new module_constructor();
    var module_prototype = {};

    Opal.setup_module_or_class(module);

    // initialize dependency tracking
    module.$$included_in = [];

    // Set the display name of the singleton prototype holder
    module_constructor.displayName = "#<Class:#<Module:"+module.$$id+">>"

    // @property $$proto This is the prototype on which methods will be defined
    module.$$proto = module_prototype;
    module.$$proto.$$methods = [];

    // @property constructor
    //   keeps a ref to the constructor, but apparently the
    //   constructor is already set on:
    //
    //      `var module = new constructor` is called.
    //
    //   Maybe there are some browsers not abiding (IE6?)
    module.constructor = module_constructor;

    // @property $$is_module Clearly mark this as a module
    module.$$is_module = true;
    module.$$class     = Module;

    // @property $$super
    //   the superclass, doesn't get changed by module inclusions
    module.$$super = superclass;

    // @property $$parent
    //   direct parent class or module
    //   starts with the superclass, after module inclusion is
    //   the last included module
    // module.$$parent = superclass;

    return module;
  };

  // Return the singleton class for the passed object.
  //
  // If the given object alredy has a singleton class, then it will be stored on
  // the object as the `$$meta` property. If this exists, then it is simply
  // returned back.
  //
  // Otherwise, a new singleton object for the class or object is created, set on
  // the object at `$$meta` for future use, and then returned.
  //
  // @param object [Object] the ruby object
  // @return [Class] the singleton class for object
  Opal.get_singleton_class = function(object) {
    if (object.$$meta) {
      return object.$$meta;
    }

    if (object.$$is_class || object.$$is_module) {
      return Opal.build_class_singleton_class(object);
    }

    return Opal.build_object_singleton_class(object);
  };

  // Build the singleton class for an existing class. Class object are built
  // with their singleton class already in the prototype chain and inheriting
  // from their superclass object (up to `Class` itself).
  //
  // NOTE: Actually in MRI a class' singleton class inherits from its
  // superclass' singleton class which in turn inherits from Class.
  //
  // @param klass [Class]
  // @return [Class]
  Opal.build_class_singleton_class = function(object) {
    var alloc, superclass, klass;

    if (object.$$meta) {
      return object.$$meta;
    }

    // The constructor and prototype of the singleton_class instances is the
    // current class constructor and prototype.
    alloc = object.constructor;

    // The singleton_class superclass is the singleton_class of its superclass;
    // but BasicObject has no superclass (its `$$super` is null), thus we
    // fallback on `Class`.
    superclass = object === BasicObject ? Class : Opal.build_class_singleton_class(object.$$super);

    klass = Opal.setup_class_object(null, alloc, superclass.$$name, superclass.constructor);
    klass.$$super  = superclass;
    klass.$$parent = superclass;

    klass.$$is_singleton = true;
    klass.$$singleton_of = object;

    return object.$$meta = klass;
  };

  // Build the singleton class for a Ruby (non class) Object.
  //
  // @param object [Object]
  // @return [Class]
  Opal.build_object_singleton_class = function(object) {
    var superclass = object.$$class,
        name = "#<Class:#<" + superclass.$$name + ":" + superclass.$$id + ">>";

    var alloc = Opal.boot_class_alloc(name, function(){}, superclass)
    var klass = Opal.setup_class_object(name, alloc, superclass.$$name, superclass.constructor);

    klass.$$super  = superclass;
    klass.$$parent = superclass;
    klass.$$class  = superclass.$$class;
    klass.$$proto  = object;

    klass.$$is_singleton = true;
    klass.$$singleton_of = object;

    return object.$$meta = klass;
  };

  // Returns an object containing all pairs of names/values
  // for all class variables defined in provided +module+
  // and its ancestors.
  //
  // @param module [Module]
  // @return [Object]
  Opal.class_variables = function(module) {
    var ancestors = Opal.ancestors(module),
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

  // Sets class variable with specified +name+ to +value+
  // in provided +module+
  //
  // @param module [Module]
  // @param name [String]
  // @param value [Object]
  Opal.class_variable_set = function(module, name, value) {
    var ancestors = Opal.ancestors(module),
        i, length = ancestors.length;

    for (i = length - 2; i >= 0; i--) {
      var ancestor = ancestors[i];

      if ($hasOwn.call(ancestor.$$cvars, name)) {
        ancestor.$$cvars[name] = value;
        return value;
      }
    }

    module.$$cvars[name] = value;

    return value;
  }

  // Bridges a single method.
  //
  // @param target [JS::Function] the constructor of the bridged class
  // @param from [Module] the module/class we are importing the method from
  // @param name [String] the method name in JS land (i.e. starting with $)
  // @param body [JS::Function] the body of the method
  Opal.bridge_method = function(target_constructor, from, name, body) {
    var ancestors, i, ancestor, length;

    ancestors = target_constructor.$$bridge.$ancestors();

    // order important here, we have to check for method presence in
    // ancestors from the bridged class to the last ancestor
    for (i = 0, length = ancestors.length; i < length; i++) {
      ancestor = ancestors[i];

      if ($hasOwn.call(ancestor.$$proto, name) &&
          ancestor.$$proto[name] &&
          !ancestor.$$proto[name].$$donated &&
          !ancestor.$$proto[name].$$stub &&
          ancestor !== from) {
        break;
      }

      if (ancestor === from) {
        var method_name = name.slice(1);
        // console.log("Bridging method", method_name, "to", target_constructor, "instances");
        target_constructor.prototype.$$methods[method_name] = body;
        target_constructor.prototype[name] = body;
        break;
      }
    }
  };

  // Bridges from *donator* to a *target*.
  //
  // @param target [Module] the potentially associated with bridged classes module
  // @param donator [Module] the module/class source of the methods that should be bridged
  Opal.bridge_methods = function(target, donator) {
    var i,
        bridged = BridgedClasses[target.$__id__()],
        donator_id = donator.$__id__();

    if (bridged) {
      BridgedClasses[donator_id] = bridged.slice();

      for (i = bridged.length - 1; i >= 0; i--) {
        Opal_bridge_methods_to_constructor(bridged[i], donator)
      }
    }
  };

  // Actually bridge methods to the bridged (shared) prototype.
  function Opal_bridge_methods_to_constructor(target_constructor, donator) {
    var i,
        method,
        methods = donator.$instance_methods();

    for (i = methods.length - 1; i >= 0; i--) {
      method = '$' + methods[i];
      Opal.bridge_method(target_constructor, donator, method, donator.$$proto[method]);
    }
  }

  // Associate the target as a bridged class for the current "donator"
  function Opal_add_bridged_constructor(target_constructor, donator) {
    var donator_id = donator.$__id__();

    if (!BridgedClasses[donator_id]) {
      BridgedClasses[donator_id] = [];
    }
    BridgedClasses[donator_id].push(target_constructor);
  }

  // Walks the dependency tree detecting the presence of the base among its
  // own dependencies.
  //
  // @param [Integer] base_id The id of the base module (eg. the "includer")
  // @param [Array<Module>] deps The array of dependencies (eg. the included module, included.$$deps)
  // @param [String] prop The property that holds dependencies (eg. "$$deps")
  // @param [JS::Object] seen A JS object holding the cache of already visited objects
  // @return [Boolean] true if a cyclic dependency is present
  Opal.has_cyclic_dep = function has_cyclic_dep(base_id, deps, prop, seen) {
    // FIXME
    return false;

    var i, dep_id, dep;

    for (i = deps.length - 1; i >= 0; i--) {
      dep = deps[i];
      dep_id = dep.$$id;

      if (seen[dep_id]) {
        continue;
      }
      seen[dep_id] = true;

      if (dep_id === base_id) {
        return true;
      }

      if (has_cyclic_dep(base_id, dep[prop], prop, seen)) {
        return true;
      }
    }

    return false;
  }

  // The actual inclusion of a module into a class.
  //
  // ## Class `$$parent` and `iclass`
  //
  // To handle `super` calls, every class has a `$$parent`. This parent is
  // used to resolve the next class for a super call. A normal class would
  // have this point to its superclass. However, if a class includes a module
  // then this would need to take into account the module. The module would
  // also have to then point its `$$parent` to the actual superclass. We
  // cannot modify modules like this, because it might be included in more
  // then one class. To fix this, we actually insert an `iclass` as the class'
  // `$$parent` which can then point to the superclass. The `iclass` acts as
  // a proxy to the actual module, so the `super` chain can then search it for
  // the required method.
  //
  // @param module [Module] the module to include
  // @param includer [Module] the target class to include module into
  // @return [null]
  Opal.append_features = function(module, includer) {
    var iclass, donator, prototype, methods, id, i;

    // check if this module is already included in the class
    for (i = includer.$$ancestors.length; i >= 0; i--) {
      if (includer.$$included_modules[i] === module) {
        return;
      }
    }

    // Check that the base module is not also a dependency, classes can't be
    // dependencies so we have a special case for them.
    if (!includer.$$is_class && Opal.has_cyclic_dep(includer.$$id, [module], '$$inc', {})) {
      throw Opal.ArgumentError.$new('cyclic include detected')
    }

    Opal.const_cache_version++;
    includer.$$included_modules.push(module);
    module.$$included_in.push(includer);
    Opal.bridge_methods(includer, module);

    // iclass
    iclass = {
      $$name:   module.$$name,
      $$proto:  module.$$proto,
      $$parent: includer.$$parent,
      $$module: module,
      $$iclass: true
    };

    includer.$$parent = iclass;

    methods = module.$instance_methods();

    for (i = methods.length - 1; i >= 0; i--) {
      Opal.update_includer(module, includer, '$' + methods[i])
    }
  };

  // Table that holds all methods that have been defined on all objects
  // It is used for defining method stubs for new coming native classes
  Opal.stubs = {};

  // For performance, some core Ruby classes are toll-free bridged to their
  // native JavaScript counterparts (e.g. a Ruby Array is a JavaScript Array).
  //
  // This method is used to setup a native constructor (e.g. Array), to have
  // its prototype act like a normal Ruby class. Firstly, a new Ruby class is
  // created using the native constructor so that its prototype is set as the
  // target for th new class. Note: all bridged classes are set to inherit
  // from Object.
  //
  // Example:
  //
  //    Opal.bridge(self, Function);
  //
  // @param klass       [Class] the Ruby class to bridge
  // @param constructor [JS.Function] native JavaScript constructor to use
  // @return [Class] returns the passed Ruby class
  //
  Opal.bridge = function(klass, constructor) {
    if (constructor.$$bridge) {
      throw Opal.ArgumentError.$new("already bridged");
    }

    Opal.stub_subscribers.push(constructor.prototype);

    // Populate constructor with previously stored stubs
    for (var method_name in Opal.stubs) {
      if (!(method_name in constructor.prototype)) {
        constructor.prototype.$$methods[method_name] = Opal.stub_for(method_name);
        constructor.prototype[method_name] = Opal.stub_for(method_name);
      }
    }

    constructor.prototype.$$class = klass;
    constructor.$$bridge          = klass;

    var ancestors = klass.$ancestors();

    // order important here, we have to bridge from the last ancestor to the
    // bridged class
    for (var i = ancestors.length - 1; i >= 0; i--) {
      Opal_add_bridged_constructor(constructor, ancestors[i]);
      Opal_bridge_methods_to_constructor(constructor, ancestors[i]);
    }

    for (var name in BasicObject_alloc.prototype) {
      var method = BasicObject_alloc.prototype[method];

      if (method && method.$$stub && !(name in constructor.prototype)) {
        constructor.prototype[name] = method;
      }
    }

    return klass;
  };

  // Update `jsid` method cache of all classes / modules including `module`.
  Opal.update_includer = function(module, includer, jsid) {
    var dest, current, body,
        klass_includees, j, jj, current_owner_index, module_index;

    body    = module.$$proto[jsid];
    dest    = includer.$$proto;
    current = dest[jsid];

    if (dest.hasOwnProperty(jsid) && !current.$$donated && !current.$$stub) {
      // target class has already defined the same method name - do nothing
    }
    else if (dest.hasOwnProperty(jsid) && !current.$$stub) {
      // target class includes another module that has defined this method
      klass_includees = includer.$$included_modules;

      for (j = 0, jj = klass_includees.length; j < jj; j++) {
        if (klass_includees[j] === current.$$donated) {
          current_owner_index = j;
        }
        if (klass_includees[j] === module) {
          module_index = j;
        }
      }

      // only redefine method on class if the module was included AFTER
      // the module which defined the current method body. Also make sure
      // a module can overwrite a method it defined before
      if (current_owner_index <= module_index) {
        dest[jsid] = body;
        dest[jsid].$$donated = module;
        // console.log("inheriting", jsid, "from", module.$$name, "to", includer.$$name);
        dest.$$methods.push(jsid.slice(1));
      }
    }
    else {
      // neither a class, or module included by class, has defined method
      dest[jsid] = body;
      dest[jsid].$$donated = module;
      // console.log("inheriting", jsid, "from", module.$$name, "to", includer.$$name);
      dest.$$methods.push(jsid.slice(1));
    }

    // if the includer is a module, recursively update all of its includres.
    if (includer.$$included_in) {
      Opal.update_includers(includer, jsid);
    }
  };

  // Update `jsid` method cache of all classes / modules including `module`.
  Opal.update_includers = function(module, jsid) {
    var i, ii, includee, included_in;

    included_in = module.$$included_in;

    if (!included_in) {
      return;
    }

    for (i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];
      Opal.update_includer(module, includee, jsid);
    }
  };

  // The Array of ancestors for a given module/class
  Opal.ancestors = function(module_or_class) {
    var parent = module_or_class,
        result = [],
        modules, i, ii, j, jj;

    while (parent) {
      result.push(parent);
      for (i = parent.$$included_modules.length-1; i >= 0; i--) {
        modules = Opal.ancestors(parent.$$included_modules[i]);

        for(j = 0, jj = modules.length; j < jj; j++) {
          result.push(modules[j]);
        }
      }

      // only the actual singleton class gets included in its ancestry
      // after that, traverse the normal class hierarchy
      if (parent.$$is_singleton && parent.$$singleton_of.$$is_module) {
        parent = parent.$$singleton_of.$$super;
      }
      else {
        parent = parent.$$is_class ? parent.$$super : null;
      }
    }

    return result;
  };


  // Method Missing
  // --------------

  // Methods stubs are used to facilitate method_missing in opal. A stub is a
  // placeholder function which just calls `method_missing` on the receiver.
  // If no method with the given name is actually defined on an object, then it
  // is obvious to say that the stub will be called instead, and then in turn
  // method_missing will be called.
  //
  // When a file in ruby gets compiled to javascript, it includes a call to
  // this function which adds stubs for every method name in the compiled file.
  // It should then be safe to assume that method_missing will work for any
  // method call detected.
  //
  // Method stubs are added to the BasicObject prototype, which every other
  // ruby object inherits, so all objects should handle method missing. A stub
  // is only added if the given property name (method name) is not already
  // defined.
  //
  // Note: all ruby methods have a `$` prefix in javascript, so all stubs will
  // have this prefix as well (to make this method more performant).
  //
  //    Opal.add_stubs(["$foo", "$bar", "$baz="]);
  //
  // All stub functions will have a private `$$stub` property set to true so
  // that other internal methods can detect if a method is just a stub or not.
  // `Kernel#respond_to?` uses this property to detect a methods presence.
  //
  // @param stubs [Array] an array of method stubs to add
  // @return [undefined]
  Opal.add_stubs = function(stubs) {
    var subscriber, subscribers = Opal.stub_subscribers,
        i, ilength = stubs.length,
        j, jlength = subscribers.length,
        method_name, stub,
        opal_stubs = Opal.stubs;

    for (i = 0; i < ilength; i++) {
      method_name = stubs[i];

      if(!opal_stubs.hasOwnProperty(method_name)) {
        // Save method name to populate other subscribers with this stub
        opal_stubs[method_name] = true;
        stub = Opal.stub_for(method_name);

        for (j = 0; j < jlength; j++) {
          subscriber = subscribers[j];

          if (!(method_name in subscriber)) {
            subscriber[method_name] = stub;
          }
        }
      }
    }
  };

  // Keep a list of prototypes that want method_missing stubs to be added.
  //
  // @default [Prototype List] BasicObject_alloc.prototype
  //
  Opal.stub_subscribers = [BasicObject_alloc.prototype];

  // Add a method_missing stub function to the given prototype for the
  // given name.
  //
  // @param prototype [Prototype] the target prototype
  // @param stub [String] stub name to add (e.g. "$foo")
  // @return [undefined]
  Opal.add_stub_for = function(prototype, stub) {
    var method_missing_stub = Opal.stub_for(stub);
    prototype[stub] = method_missing_stub;
  };

  // Generate the method_missing stub for a given method name.
  //
  // @param method_name [String] The js-name of the method to stub (e.g. "$foo")
  // @return [undefined]
  Opal.stub_for = function(method_name) {
    function method_missing_stub() {
      // Copy any given block onto the method_missing dispatcher
      this.$method_missing.$$p = method_missing_stub.$$p;

      // Set block property to null ready for the next call (stop false-positives)
      method_missing_stub.$$p = null;

      // call method missing with correct args (remove '$' prefix on method name)
      var args_ary = new Array(arguments.length);
      for(var i = 0, l = args_ary.length; i < l; i++) { args_ary[i] = arguments[i]; }

      return this.$method_missing.apply(this, [method_name.slice(1)].concat(args_ary));
    }

    method_missing_stub.$$stub = true;

    return method_missing_stub;
  };


  // Methods
  // -------

  // Arity count error dispatcher for methods
  //
  // @param actual [Fixnum] number of arguments given to method
  // @param expected [Fixnum] expected number of arguments
  // @param object [Object] owner of the method +meth+
  // @param meth [String] method name that got wrong number of arguments
  // @raise [ArgumentError]
  Opal.ac = function(actual, expected, object, meth) {
    var inspect = '';
    if (object.$$is_class || object.$$is_module) {
      inspect += object.$$name + '.';
    }
    else {
      inspect += object.$$class.$$name + '#';
    }
    inspect += meth;

    throw Opal.ArgumentError.$new('[' + inspect + '] wrong number of arguments(' + actual + ' for ' + expected + ')');
  };

  // Arity count error dispatcher for blocks
  //
  // @param actual [Fixnum] number of arguments given to block
  // @param expected [Fixnum] expected number of arguments
  // @param context [Object] context of the block definition
  // @raise [ArgumentError]
  Opal.block_ac = function(actual, expected, context) {
    var inspect = "`block in " + context + "'";

    throw Opal.ArgumentError.$new(inspect + ': wrong number of arguments (' + actual + ' for ' + expected + ')');
  };

  // Super dispatcher
  Opal.find_super_dispatcher = function(obj, mid, current_func, defcheck, defs) {
    var dispatcher, super_method;

    if (defs) {
      if (obj.$$is_class || obj.$$is_module) {
        dispatcher = defs.$$super;
      }
      else {
        dispatcher = obj.$$class.$$proto;
      }
    }
    else {
      dispatcher = Opal.find_obj_super_dispatcher(obj, mid, current_func);
    }

    super_method = dispatcher['$' + mid];

    if (!defcheck && super_method.$$stub && Opal.Kernel.$method_missing === obj.$method_missing) {
      // method_missing hasn't been explicitly defined
      throw Opal.NoMethodError.$new('super: no superclass method `'+mid+"' for "+obj, mid);
    }

    return super_method;
  };

  // Iter dispatcher for super in a block
  Opal.find_iter_super_dispatcher = function(obj, jsid, current_func, defcheck, implicit) {
    var call_jsid = jsid;

    if (!current_func) {
      throw Opal.RuntimeError.$new("super called outside of method");
    }

    if (implicit && current_func.$$define_meth) {
      throw Opal.RuntimeError.$new("implicit argument passing of super from method defined by define_method() is not supported. Specify all arguments explicitly");
    }

    if (current_func.$$def) {
      call_jsid = current_func.$$jsid;
    }

    return Opal.find_super_dispatcher(obj, call_jsid, current_func, defcheck);
  };

  Opal.find_obj_super_dispatcher = function(obj, mid, current_func) {
    var klass = obj.$$meta || obj.$$class;

    // first we need to find the class/module current_func is located on
    klass = Opal.find_owning_class(klass, current_func);

    if (!klass) {
      throw new Error("could not find current class for super()");
    }

    return Opal.find_super_func(klass, '$' + mid, current_func);
  };

  Opal.find_owning_class = function(klass, current_func) {
    var owner = current_func.$$owner;

    while (klass) {
      // repeating for readability

      if (klass.$$iclass && klass.$$module === current_func.$$donated) {
        // this klass was the last one the module donated to
        // case is also hit with multiple module includes
        break;
      }
      else if (klass.$$iclass && klass.$$module === owner) {
        // module has donated to other classes but klass isn't one of those
        break;
      }
      else if (owner.$$is_singleton && klass === owner.$$singleton_of.$$class) {
        // cases like stdlib `Singleton::included` that use a singleton of a singleton
        break;
      }
      else if (klass === owner) {
        // no modules, pure class inheritance
        break;
      }

      klass = klass.$$parent;
    }

    return klass;
  };

  Opal.find_super_func = function(owning_klass, jsid, current_func) {
    var klass = owning_klass.$$parent;

    // now we can find the super
    while (klass) {
      var working = klass.$$proto[jsid];

      if (working && working !== current_func) {
        // ok
        break;
      }

      klass = klass.$$parent;
    }

    return klass.$$proto;
  };

  // Used to return as an expression. Sometimes, we can't simply return from
  // a javascript function as if we were a method, as the return is used as
  // an expression, or even inside a block which must "return" to the outer
  // method. This helper simply throws an error which is then caught by the
  // method. This approach is expensive, so it is only used when absolutely
  // needed.
  //
  Opal.ret = function(val) {
    Opal.returner.$v = val;
    throw Opal.returner;
  };

  // Used to break out of a block.
  Opal.brk = function(val, breaker) {
    breaker.$v = val;
    throw breaker;
  };

  // Builds a new unique breaker, this is to avoid multiple nested breaks to get
  // in the way of each other.
  Opal.new_brk = function() {
    return new Error('unexpected break');
  };

  // handles yield calls for 1 yielded arg
  Opal.yield1 = function(block, arg) {
    if (typeof(block) !== "function") {
      throw Opal.LocalJumpError.$new("no block given");
    }

    var has_mlhs = block.$$has_top_level_mlhs_arg,
        has_trailing_comma = block.$$has_trailing_comma_in_args;

    if (block.length > 1 || ((has_mlhs || has_trailing_comma) && block.length === 1)) {
      arg = Opal.to_ary(arg);
    }

    if ((block.length > 1 || (has_trailing_comma && block.length === 1)) && arg.$$is_array) {
      return block.apply(null, arg);
    }
    else {
      return block(arg);
    }
  };

  // handles yield for > 1 yielded arg
  Opal.yieldX = function(block, args) {
    if (typeof(block) !== "function") {
      throw Opal.LocalJumpError.$new("no block given");
    }

    if (block.length > 1 && args.length === 1) {
      if (args[0].$$is_array) {
        return block.apply(null, args[0]);
      }
    }

    if (!args.$$is_array) {
      var args_ary = new Array(args.length);
      for(var i = 0, l = args_ary.length; i < l; i++) { args_ary[i] = args[i]; }

      return block.apply(null, args_ary);
    }

    return block.apply(null, args);
  };

  // Finds the corresponding exception match in candidates.  Each candidate can
  // be a value, or an array of values.  Returns null if not found.
  Opal.rescue = function(exception, candidates) {
    for (var i = 0; i < candidates.length; i++) {
      var candidate = candidates[i];

      if (candidate.$$is_array) {
        var result = Opal.rescue(exception, candidate);

        if (result) {
          return result;
        }
      }
      else if (candidate === Opal.JS.Error) {
        return candidate;
      }
      else if (candidate['$==='](exception)) {
        return candidate;
      }
    }

    return null;
  };

  Opal.is_a = function(object, klass) {
    if (object.$$meta === klass || object.$$class === klass) {
      return true;
    }

    if (object.$$is_number && klass.$$is_number_class) {
      return true;
    }

    var i, length, ancestors = Opal.ancestors(object.$$is_class ? Opal.get_singleton_class(object) : (object.$$meta || object.$$class));

    for (i = 0, length = ancestors.length; i < length; i++) {
      if (ancestors[i] === klass) {
        return true;
      }
    }

    return false;
  };

  // Helpers for extracting kwsplats
  // Used for: { **h }
  Opal.to_hash = function(value) {
    if (value.$$is_hash) {
      return value;
    }
    else if (value['$respond_to?']('to_hash', true)) {
      var hash = value.$to_hash();
      if (hash.$$is_hash) {
        return hash;
      }
      else {
        throw Opal.TypeError.$new("Can't convert " + value.$$class +
          " to Hash (" + value.$$class + "#to_hash gives " + hash.$$class + ")");
      }
    }
    else {
      throw Opal.TypeError.$new("no implicit conversion of " + value.$$class + " into Hash");
    }
  };

  // Helpers for implementing multiple assignment
  // Our code for extracting the values and assigning them only works if the
  // return value is a JS array.
  // So if we get an Array subclass, extract the wrapped JS array from it

  // Used for: a, b = something (no splat)
  Opal.to_ary = function(value) {
    if (value.$$is_array) {
      return value;
    }
    else if (value['$respond_to?']('to_ary', true)) {
      var ary = value.$to_ary();
      if (ary === nil) {
        return [value];
      }
      else if (ary.$$is_array) {
        return ary;
      }
      else {
        throw Opal.TypeError.$new("Can't convert " + value.$$class +
          " to Array (" + value.$$class + "#to_ary gives " + ary.$$class + ")");
      }
    }
    else {
      return [value];
    }
  };

  // Used for: a, b = *something (with splat)
  Opal.to_a = function(value) {
    if (value.$$is_array) {
      // A splatted array must be copied
      return value.slice();
    }
    else if (value['$respond_to?']('to_a', true)) {
      var ary = value.$to_a();
      if (ary === nil) {
        return [value];
      }
      else if (ary.$$is_array) {
        return ary;
      }
      else {
        throw Opal.TypeError.$new("Can't convert " + value.$$class +
          " to Array (" + value.$$class + "#to_a gives " + ary.$$class + ")");
      }
    }
    else {
      return [value];
    }
  };

  // Used for extracting keyword arguments from arguments passed to
  // JS function. If provided +arguments+ list doesn't have a Hash
  // as a last item, returns a blank Hash.
  //
  // @param parameters [Array]
  // @return [Hash]
  //
  Opal.extract_kwargs = function(parameters) {
    var kwargs = parameters[parameters.length - 1];
    if (kwargs != null && kwargs['$respond_to?']('to_hash', true)) {
      Array.prototype.splice.call(parameters, parameters.length - 1, 1);
      return kwargs.$to_hash();
    }
    else {
      return Opal.hash2([], {});
    }
  }

  // Used to get a list of rest keyword arguments. Method takes the given
  // keyword args, i.e. the hash literal passed to the method containing all
  // keyword arguemnts passed to method, as well as the used args which are
  // the names of required and optional arguments defined. This method then
  // just returns all key/value pairs which have not been used, in a new
  // hash literal.
  //
  // @param given_args [Hash] all kwargs given to method
  // @param used_args [Object<String: true>] all keys used as named kwargs
  // @return [Hash]
  //
  Opal.kwrestargs = function(given_args, used_args) {
    var keys      = [],
        map       = {},
        key       = null,
        given_map = given_args.$$smap;

    for (key in given_map) {
      if (!used_args[key]) {
        keys.push(key);
        map[key] = given_map[key];
      }
    }

    return Opal.hash2(keys, map);
  };

  // Calls passed method on a ruby object with arguments and block:
  //
  // Can take a method or a method name.
  //
  // 1. When method name gets passed it invokes it by its name
  //    and calls 'method_missing' when object doesn't have this method.
  //    Used internally by Opal to invoke method that takes a block or a splat.
  // 2. When method (i.e. method body) gets passed, it doesn't trigger 'method_missing'
  //    because it doesn't know the name of the actual method.
  //    Used internally by Opal to invoke 'super'.
  //
  // @example
  //   var my_array = [1, 2, 3, 4]
  //   Opal.send(my_array, 'length')                    # => 4
  //   Opal.send(my_array, my_array.$length)            # => 4
  //
  //   Opal.send(my_array, 'reverse!')                  # => [4, 3, 2, 1]
  //   Opal.send(my_array, my_array['$reverse!']')      # => [4, 3, 2, 1]
  //
  // @param recv [Object] ruby object
  // @param method [Function, String] method body or name of the method
  // @param args [Array] arguments that will be passed to the method call
  // @param block [Function] ruby block
  // @return [Object] returning value of the method call
  Opal.send = function(recv, method, args, block) {
    var body = (typeof(method) === 'string') ? recv['$'+method] : method;

    if (body != null) {
      body.$$p = block;
      return body.apply(recv, args);
    }

    return recv.$method_missing.apply(recv, [method].concat(args));
  }

  Opal.lambda = function(block) {
    block.$$is_lambda = true;
    return block;
  }

  // Used to define methods on an object. This is a helper method, used by the
  // compiled source to define methods on special case objects when the compiler
  // can not determine the destination object, or the object is a Module
  // instance. This can get called by `Module#define_method` as well.
  //
  // ## Modules
  //
  // Any method defined on a module will come through this runtime helper.
  // The method is added to the module body, and the owner of the method is
  // set to be the module itself. This is used later when choosing which
  // method should show on a class if more than 1 included modules define
  // the same method. Finally, if the module is in `module_function` mode,
  // then the method is also defined onto the module itself.
  //
  // ## Classes
  //
  // This helper will only be called for classes when a method is being
  // defined indirectly; either through `Module#define_method`, or by a
  // literal `def` method inside an `instance_eval` or `class_eval` body. In
  // either case, the method is simply added to the class' prototype. A special
  // exception exists for `BasicObject` and `Object`. These two classes are
  // special because they are used in toll-free bridged classes. In each of
  // these two cases, extra work is required to define the methods on toll-free
  // bridged class' prototypes as well.
  //
  // ## Objects
  //
  // If a simple ruby object is the object, then the method is simply just
  // defined on the object as a singleton method. This would be the case when
  // a method is defined inside an `instance_eval` block.
  //
  // @param obj  [Object, Class] the actual obj to define method for
  // @param jsid [String] the JavaScript friendly method name (e.g. '$foo')
  // @param body [JS.Function] the literal JavaScript function used as method
  // @return [null]
  //
  Opal.def = function(obj, jsid, body) {
    // Special case for a method definition in the
    // top-level namespace
    if (obj === Opal.top) {
      Opal.defn(Opal.Object, jsid, body)
    }
    // if instance_eval is invoked on a module/class, it sets inst_eval_mod
    else if (!obj.$$eval && (obj.$$is_class || obj.$$is_module)) {
      Opal.defn(obj, jsid, body);
    }
    else {
      Opal.defs(obj, jsid, body);
    }
  };

  // Define method on a module or class (see Opal.def).
  Opal.defn = function(obj, jsid, body) {
    obj.$$proto[jsid] = body;
    // console.log("Defining method", jsid.slice(1), "on", obj.$$name);
    obj.$$proto.$$methods.push(jsid.slice(1));

    // for super dispatcher, etc.
    body.$$owner = obj;
    if (body.displayName == null) body.displayName = jsid.substr(1);

    // is it a module?
    if (obj.$$is_module) {
      Opal.update_includers(obj, jsid);

      if (obj.$$module_function) {
        Opal.defs(obj, jsid, body);
      }
    }

    // is it a bridged class?
    var bridged = obj.$__id__ && !obj.$__id__.$$stub && BridgedClasses[obj.$__id__()];
    if (bridged) {
      for (var i = bridged.length - 1; i >= 0; i--) {
        Opal.bridge_method(bridged[i], obj, jsid, body);
      }
    }

    // method_added/singleton_method_added hooks
    var singleton_of = obj.$$singleton_of;
    if (obj.$method_added && !obj.$method_added.$$stub && !singleton_of) {
      obj.$method_added(jsid.substr(1));
    }
    else if (singleton_of && singleton_of.$singleton_method_added && !singleton_of.$singleton_method_added.$$stub) {
      singleton_of.$singleton_method_added(jsid.substr(1));
    }

    return nil;
  };

  // Define a singleton method on the given object (see Opal.def).
  Opal.defs = function(obj, jsid, body) {
    Opal.defn(Opal.get_singleton_class(obj), jsid, body)
  };

  // Called from #remove_method.
  Opal.rdef = function(obj, jsid) {
    // TODO: remove from BridgedClasses as well

    if (!$hasOwn.call(obj.$$proto, jsid)) {
      throw Opal.NameError.$new("method '" + jsid.substr(1) + "' not defined in " + obj.$name());
    }

    delete obj.$$proto[jsid];

    if (obj.$$is_singleton) {
      if (obj.$$proto.$singleton_method_removed && !obj.$$proto.$singleton_method_removed.$$stub) {
        obj.$$proto.$singleton_method_removed(jsid.substr(1));
      }
    }
    else {
      if (obj.$method_removed && !obj.$method_removed.$$stub) {
        obj.$method_removed(jsid.substr(1));
      }
    }
  };

  // Called from #undef_method.
  Opal.udef = function(obj, jsid) {
    if (!obj.$$proto[jsid] || obj.$$proto[jsid].$$stub) {
      throw Opal.NameError.$new("method '" + jsid.substr(1) + "' not defined in " + obj.$name());
    }

    Opal.add_stub_for(obj.$$proto, jsid);

    if (obj.$$is_singleton) {
      if (obj.$$proto.$singleton_method_undefined && !obj.$$proto.$singleton_method_undefined.$$stub) {
        obj.$$proto.$singleton_method_undefined(jsid.substr(1));
      }
    }
    else {
      if (obj.$method_undefined && !obj.$method_undefined.$$stub) {
        obj.$method_undefined(jsid.substr(1));
      }
    }
  };

  Opal.alias = function(obj, name, old) {
    var id     = '$' + name,
        old_id = '$' + old,
        body   = obj.$$proto['$' + old],
        alias;

    // When running inside #instance_eval the alias refers to class methods.
    if (obj.$$eval) {
      return Opal.alias(Opal.get_singleton_class(obj), name, old);
    }

    if (typeof(body) !== "function" || body.$$stub) {
      var ancestor = obj.$$super;

      while (typeof(body) !== "function" && ancestor) {
        body     = ancestor[old_id];
        ancestor = ancestor.$$super;
      }

      if (typeof(body) !== "function" || body.$$stub) {
        throw Opal.NameError.$new("undefined method `" + old + "' for class `" + obj.$name() + "'")
      }
    }

    // If the body is itself an alias use the original body
    // to keep the max depth at 1.
    if (body.$$alias_of) body = body.$$alias_of;

    // We need a wrapper because otherwise method $$owner and other properties
    // would be ovrewritten on the original body.
    alias = function() {
      var block = alias.$$p, args, i, ii;

      args = new Array(arguments.length);
      for(i = 0, ii = arguments.length; i < ii; i++) {
        args[i] = arguments[i];
      }

      if (block != null) { alias.$$p = null }

      return Opal.send(this, body, args, block);
    };

    // Try to make the browser pick the right name
    alias.displayName       = name;
    alias.length            = body.length;
    alias.$$arity           = body.$$arity;
    alias.$$parameters      = body.$$parameters;
    alias.$$source_location = body.$$source_location;
    alias.$$alias_of        = body;
    alias.$$alias_name      = name;

    Opal.defn(obj, id, alias);

    return obj;
  };

  Opal.alias_native = function(obj, name, native_name) {
    var id   = '$' + name,
        body = obj.$$proto[native_name];

    if (typeof(body) !== "function" || body.$$stub) {
      throw Opal.NameError.$new("undefined native method `" + native_name + "' for class `" + obj.$name() + "'")
    }

    Opal.defn(obj, id, body);

    return obj;
  };


  // Hashes
  // ------

  Opal.hash_init = function(hash) {
    hash.$$smap = Object.create(null);
    hash.$$map  = Object.create(null);
    hash.$$keys = [];
  };

  Opal.hash_clone = function(from_hash, to_hash) {
    to_hash.$$none = from_hash.$$none;
    to_hash.$$proc = from_hash.$$proc;

    for (var i = 0, keys = from_hash.$$keys, smap = from_hash.$$smap, len = keys.length, key, value; i < len; i++) {
      key = keys[i];

      if (key.$$is_string) {
        value = smap[key];
      } else {
        value = key.value;
        key = key.key;
      }

      Opal.hash_put(to_hash, key, value);
    }
  };

  Opal.hash_put = function(hash, key, value) {
    if (key.$$is_string) {
      if (!$hasOwn.call(hash.$$smap, key)) {
        hash.$$keys.push(key);
      }
      hash.$$smap[key] = value;
      return;
    }

    var key_hash, bucket, last_bucket;
    key_hash = hash.$$by_identity ? Opal.id(key) : key.$hash();

    if (!$hasOwn.call(hash.$$map, key_hash)) {
      bucket = {key: key, key_hash: key_hash, value: value};
      hash.$$keys.push(bucket);
      hash.$$map[key_hash] = bucket;
      return;
    }

    bucket = hash.$$map[key_hash];

    while (bucket) {
      if (key === bucket.key || key['$eql?'](bucket.key)) {
        last_bucket = undefined;
        bucket.value = value;
        break;
      }
      last_bucket = bucket;
      bucket = bucket.next;
    }

    if (last_bucket) {
      bucket = {key: key, key_hash: key_hash, value: value};
      hash.$$keys.push(bucket);
      last_bucket.next = bucket;
    }
  };

  Opal.hash_get = function(hash, key) {
    if (key.$$is_string) {
      if ($hasOwn.call(hash.$$smap, key)) {
        return hash.$$smap[key];
      }
      return;
    }

    var key_hash, bucket;
    key_hash = hash.$$by_identity ? Opal.id(key) : key.$hash();

    if ($hasOwn.call(hash.$$map, key_hash)) {
      bucket = hash.$$map[key_hash];

      while (bucket) {
        if (key === bucket.key || key['$eql?'](bucket.key)) {
          return bucket.value;
        }
        bucket = bucket.next;
      }
    }
  };

  Opal.hash_delete = function(hash, key) {
    var i, keys = hash.$$keys, length = keys.length, value;

    if (key.$$is_string) {
      if (!$hasOwn.call(hash.$$smap, key)) {
        return;
      }

      for (i = 0; i < length; i++) {
        if (keys[i] === key) {
          keys.splice(i, 1);
          break;
        }
      }

      value = hash.$$smap[key];
      delete hash.$$smap[key];
      return value;
    }

    var key_hash = key.$hash();

    if (!$hasOwn.call(hash.$$map, key_hash)) {
      return;
    }

    var bucket = hash.$$map[key_hash], last_bucket;

    while (bucket) {
      if (key === bucket.key || key['$eql?'](bucket.key)) {
        value = bucket.value;

        for (i = 0; i < length; i++) {
          if (keys[i] === bucket) {
            keys.splice(i, 1);
            break;
          }
        }

        if (last_bucket && bucket.next) {
          last_bucket.next = bucket.next;
        }
        else if (last_bucket) {
          delete last_bucket.next;
        }
        else if (bucket.next) {
          hash.$$map[key_hash] = bucket.next;
        }
        else {
          delete hash.$$map[key_hash];
        }

        return value;
      }
      last_bucket = bucket;
      bucket = bucket.next;
    }
  };

  Opal.hash_rehash = function(hash) {
    for (var i = 0, length = hash.$$keys.length, key_hash, bucket, last_bucket; i < length; i++) {

      if (hash.$$keys[i].$$is_string) {
        continue;
      }

      key_hash = hash.$$keys[i].key.$hash();

      if (key_hash === hash.$$keys[i].key_hash) {
        continue;
      }

      bucket = hash.$$map[hash.$$keys[i].key_hash];
      last_bucket = undefined;

      while (bucket) {
        if (bucket === hash.$$keys[i]) {
          if (last_bucket && bucket.next) {
            last_bucket.next = bucket.next;
          }
          else if (last_bucket) {
            delete last_bucket.next;
          }
          else if (bucket.next) {
            hash.$$map[hash.$$keys[i].key_hash] = bucket.next;
          }
          else {
            delete hash.$$map[hash.$$keys[i].key_hash];
          }
          break;
        }
        last_bucket = bucket;
        bucket = bucket.next;
      }

      hash.$$keys[i].key_hash = key_hash;

      if (!$hasOwn.call(hash.$$map, key_hash)) {
        hash.$$map[key_hash] = hash.$$keys[i];
        continue;
      }

      bucket = hash.$$map[key_hash];
      last_bucket = undefined;

      while (bucket) {
        if (bucket === hash.$$keys[i]) {
          last_bucket = undefined;
          break;
        }
        last_bucket = bucket;
        bucket = bucket.next;
      }

      if (last_bucket) {
        last_bucket.next = hash.$$keys[i];
      }
    }
  };

  Opal.hash = function() {
    var arguments_length = arguments.length, args, hash, i, length, key, value;

    if (arguments_length === 1 && arguments[0].$$is_hash) {
      return arguments[0];
    }

    hash = new Opal.Hash.$$alloc();
    Opal.hash_init(hash);

    if (arguments_length === 1 && arguments[0].$$is_array) {
      args = arguments[0];
      length = args.length;

      for (i = 0; i < length; i++) {
        if (args[i].length !== 2) {
          throw Opal.ArgumentError.$new("value not of length 2: " + args[i].$inspect());
        }

        key = args[i][0];
        value = args[i][1];

        Opal.hash_put(hash, key, value);
      }

      return hash;
    }

    if (arguments_length === 1) {
      args = arguments[0];
      for (key in args) {
        if ($hasOwn.call(args, key)) {
          value = args[key];

          Opal.hash_put(hash, key, value);
        }
      }

      return hash;
    }

    if (arguments_length % 2 !== 0) {
      throw Opal.ArgumentError.$new("odd number of arguments for Hash");
    }

    for (i = 0; i < arguments_length; i += 2) {
      key = arguments[i];
      value = arguments[i + 1];

      Opal.hash_put(hash, key, value);
    }

    return hash;
  };

  // A faster Hash creator for hashes that just use symbols and
  // strings as keys. The map and keys array can be constructed at
  // compile time, so they are just added here by the constructor
  // function.
  //
  Opal.hash2 = function(keys, smap) {
    var hash = new Opal.Hash.$$alloc();

    hash.$$smap = smap;
    hash.$$map  = Object.create(null);
    hash.$$keys = keys;

    return hash;
  };

  // Create a new range instance with first and last values, and whether the
  // range excludes the last value.
  //
  Opal.range = function(first, last, exc) {
    var range         = new Opal.Range.$$alloc();
        range.begin   = first;
        range.end     = last;
        range.excl    = exc;

    return range;
  };

  // Get the ivar name for a given name.
  // Mostly adds a trailing $ to reserved names.
  //
  Opal.ivar = function(name) {
    if (
        // properties
        name === "constructor" ||
        name === "displayName" ||
        name === "__count__" ||
        name === "__noSuchMethod__" ||
        name === "__parent__" ||
        name === "__proto__" ||

        // methods
        name === "hasOwnProperty" ||
        name === "valueOf"
       )
    {
      return name + "$";
    }

    return name;
  };


  // Regexps
  // -------

  // Escape Regexp special chars letting the resulting string be used to build
  // a new Regexp.
  //
  Opal.escape_regexp = function(str) {
    return str.replace(/([-[\]\/{}()*+?.^$\\| ])/g, '\\$1')
              .replace(/[\n]/g, '\\n')
              .replace(/[\r]/g, '\\r')
              .replace(/[\f]/g, '\\f')
              .replace(/[\t]/g, '\\t');
  };

  // Create a global Regexp from a RegExp object and cache the result
  // on the object itself ($$g attribute).
  //
  Opal.global_regexp = function(pattern) {
    if (pattern.global) {
      return pattern; // RegExp already has the global flag
    }
    if (pattern.$$g == null) {
      pattern.$$g = new RegExp(pattern.source, (pattern.multiline ? 'gm' : 'g') + (pattern.ignoreCase ? 'i' : ''));
    } else {
      pattern.$$g.lastIndex = null; // reset lastIndex property
    }
    return pattern.$$g;
  };

  // Create a global multiline Regexp from a RegExp object and cache the result
  // on the object itself ($$gm or $$g attribute).
  //
  Opal.global_multiline_regexp = function(pattern) {
    var result;
    if (pattern.multiline) {
      if (pattern.global) {
        return pattern; // RegExp already has the global and multiline flag
      }
      // we are using the $$g attribute because the Regexp is already multiline
      if (pattern.$$g != null) {
        result = pattern.$$g;
      } else {
        result = pattern.$$g = new RegExp(pattern.source, 'gm' + (pattern.ignoreCase ? 'i' : ''));
      }
    } else if (pattern.$$gm != null) {
      result = pattern.$$gm;
    } else {
      result = pattern.$$gm = new RegExp(pattern.source, 'gm' + (pattern.ignoreCase ? 'i' : ''));
    }
    result.lastIndex = null; // reset lastIndex property
    return result;
  };

  // Require system
  // --------------

  Opal.modules         = {};
  Opal.loaded_features = ['corelib/runtime'];
  Opal.current_dir     = '.';
  Opal.require_table   = {'corelib/runtime': true};

  Opal.normalize = function(path) {
    var parts, part, new_parts = [], SEPARATOR = '/';

    if (Opal.current_dir !== '.') {
      path = Opal.current_dir.replace(/\/*$/, '/') + path;
    }

    path = path.replace(/^\.\//, '');
    path = path.replace(/\.(rb|opal|js)$/, '');
    parts = path.split(SEPARATOR);

    for (var i = 0, ii = parts.length; i < ii; i++) {
      part = parts[i];
      if (part === '') continue;
      (part === '..') ? new_parts.pop() : new_parts.push(part)
    }

    return new_parts.join(SEPARATOR);
  };

  Opal.loaded = function(paths) {
    var i, l, path;

    for (i = 0, l = paths.length; i < l; i++) {
      path = Opal.normalize(paths[i]);

      if (Opal.require_table[path]) {
        return;
      }

      Opal.loaded_features.push(path);
      Opal.require_table[path] = true;
    }
  };

  Opal.load = function(path) {
    path = Opal.normalize(path);

    Opal.loaded([path]);

    var module = Opal.modules[path];

    if (module) {
      module(Opal);
    }
    else {
      var severity = Opal.config.missing_require_severity;
      var message  = 'cannot load such file -- ' + path;

      if (severity === "error") {
        if (Opal.LoadError) {
          throw Opal.LoadError.$new(message)
        } else {
          throw message
        }
      }
      else if (severity === "warning") {
        console.warn('WARNING: LoadError: ' + message);
      }
    }

    return true;
  };

  Opal.require = function(path) {
    path = Opal.normalize(path);

    if (Opal.require_table[path]) {
      return false;
    }

    return Opal.load(path);
  };


  // Initialization
  // --------------

  // Constructors for *instances* of core objects
  Opal.boot_class_alloc('BasicObject', BasicObject_alloc);
  Opal.boot_class_alloc('Object',      Object_alloc,       BasicObject_alloc);
  Opal.boot_class_alloc('Module',      Module_alloc,       Object_alloc);
  Opal.boot_class_alloc('Class',       Class_alloc,        Module_alloc);

  // Constructors for *classes* of core objects
  Opal.BasicObject = BasicObject = Opal.setup_class_object('BasicObject', BasicObject_alloc, 'Class',       Class_alloc);
  Opal.Object      = _Object     = Opal.setup_class_object('Object',      Object_alloc,      'BasicObject', BasicObject.constructor);
  Opal.Module      = Module      = Opal.setup_class_object('Module',      Module_alloc,      'Object',      _Object.constructor);
  Opal.Class       = Class       = Opal.setup_class_object('Class',       Class_alloc,       'Module',      Module.constructor);

  // BasicObject can reach itself, avoid const_set to skip the $$base_module logic
  BasicObject.$$const["BasicObject"] = BasicObject;

  // Assign basic constants
  Opal.const_set(_Object, "BasicObject",  BasicObject);
  Opal.const_set(_Object, "Object",       _Object);
  Opal.const_set(_Object, "Module",       Module);
  Opal.const_set(_Object, "Class",        Class);


  // Fix booted classes to use their metaclass
  BasicObject.$$class = Class;
  _Object.$$class     = Class;
  Module.$$class      = Class;
  Class.$$class       = Class;

  // Fix superclasses of booted classes
  BasicObject.$$super = null;
  _Object.$$super     = BasicObject;
  Module.$$super      = _Object;
  Class.$$super       = Module;

  BasicObject.$$parent = null;
  _Object.$$parent     = BasicObject;
  Module.$$parent      = _Object;
  Class.$$parent       = Module;

  BasicObject.$$ancestors = [BasicObject];
  _Object.$$ancestors     = [_Object];
  Module.$$ancestors     = [Module];
  Class.$$ancestors     = [Class];

  // Forward .toString() to #to_s
  _Object.$$proto.toString = function() {
    var to_s = this.$to_s();
    if (to_s.$$is_string && typeof(to_s) === 'object') {
      // a string created using new String('string')
      return to_s.valueOf();
    } else {
      return to_s;
    }
  };

  // Make Kernel#require immediately available as it's needed to require all the
  // other corelib files.
  _Object.$$proto.$require = Opal.require;

  // Add a short helper to navigate constants manually.
  // @example
  //   Opal.$$.Regexp.$$.IGNORECASE
  Opal.$$ = _Object.$$;

  // Instantiate the main object
  Opal.top = new _Object.$$alloc();
  Opal.top.$to_s = Opal.top.$inspect = function() { return 'main' };

  // Nil
  Opal.klass(_Object, _Object, 'NilClass', NilClass_alloc);
  nil = Opal.nil = new NilClass_alloc();
  nil.$$id = nil_id;
  nil.call = nil.apply = function() { throw Opal.LocalJumpError.$new('no block given'); };

  // Errors
  Opal.breaker  = new Error('unexpected break (old)');
  Opal.returner = new Error('unexpected return');
  TypeError.$$super = Error;
}).call(this);
Opal.loaded(["corelib/runtime"]);
/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/helpers"] = function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $truthy = Opal.truthy;

  Opal.add_stubs(['$new', '$class', '$===', '$respond_to?', '$raise', '$type_error', '$__send__', '$coerce_to', '$nil?', '$<=>', '$coerce_to!', '$!=', '$[]', '$upcase']);
  return (function($base, $parent_nesting) {
    var $Opal, self = $Opal = $module($base, 'Opal');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_Opal_bridge_1, TMP_Opal_type_error_2, TMP_Opal_coerce_to_3, TMP_Opal_coerce_to$B_4, TMP_Opal_coerce_to$q_5, TMP_Opal_try_convert_6, TMP_Opal_compare_7, TMP_Opal_destructure_8, TMP_Opal_respond_to$q_9, TMP_Opal_inspect_obj_10, TMP_Opal_instance_variable_name$B_11, TMP_Opal_class_variable_name$B_12, TMP_Opal_const_name$B_13, TMP_Opal_pristine_14;

    
    Opal.defs(self, '$bridge', TMP_Opal_bridge_1 = function $$bridge(klass, constructor) {
      var self = this;

      return Opal.bridge(klass, constructor);
    }, TMP_Opal_bridge_1.$$arity = 2);
    Opal.defs(self, '$type_error', TMP_Opal_type_error_2 = function $$type_error(object, type, method, coerced) {
      var $a, self = this;

      if (method == null) {
        method = nil;
      }
      if (coerced == null) {
        coerced = nil;
      }
      if ($truthy(($truthy($a = method) ? coerced : $a))) {
        return $$($nesting, 'TypeError').$new("" + "can't convert " + (object.$class()) + " into " + (type) + " (" + (object.$class()) + "#" + (method) + " gives " + (coerced.$class()) + ")")
      } else {
        return $$($nesting, 'TypeError').$new("" + "no implicit conversion of " + (object.$class()) + " into " + (type))
      }
    }, TMP_Opal_type_error_2.$$arity = -3);
    Opal.defs(self, '$coerce_to', TMP_Opal_coerce_to_3 = function $$coerce_to(object, type, method) {
      var self = this;

      
      if ($truthy(type['$==='](object))) {
        return object};
      if ($truthy(object['$respond_to?'](method))) {
      } else {
        self.$raise(self.$type_error(object, type))
      };
      return object.$__send__(method);
    }, TMP_Opal_coerce_to_3.$$arity = 3);
    Opal.defs(self, '$coerce_to!', TMP_Opal_coerce_to$B_4 = function(object, type, method) {
      var self = this, coerced = nil;

      
      coerced = self.$coerce_to(object, type, method);
      if ($truthy(type['$==='](coerced))) {
      } else {
        self.$raise(self.$type_error(object, type, method, coerced))
      };
      return coerced;
    }, TMP_Opal_coerce_to$B_4.$$arity = 3);
    Opal.defs(self, '$coerce_to?', TMP_Opal_coerce_to$q_5 = function(object, type, method) {
      var self = this, coerced = nil;

      
      if ($truthy(object['$respond_to?'](method))) {
      } else {
        return nil
      };
      coerced = self.$coerce_to(object, type, method);
      if ($truthy(coerced['$nil?']())) {
        return nil};
      if ($truthy(type['$==='](coerced))) {
      } else {
        self.$raise(self.$type_error(object, type, method, coerced))
      };
      return coerced;
    }, TMP_Opal_coerce_to$q_5.$$arity = 3);
    Opal.defs(self, '$try_convert', TMP_Opal_try_convert_6 = function $$try_convert(object, type, method) {
      var self = this;

      
      if ($truthy(type['$==='](object))) {
        return object};
      if ($truthy(object['$respond_to?'](method))) {
        return object.$__send__(method)
      } else {
        return nil
      };
    }, TMP_Opal_try_convert_6.$$arity = 3);
    Opal.defs(self, '$compare', TMP_Opal_compare_7 = function $$compare(a, b) {
      var self = this, compare = nil;

      
      compare = a['$<=>'](b);
      if ($truthy(compare === nil)) {
        self.$raise($$($nesting, 'ArgumentError'), "" + "comparison of " + (a.$class()) + " with " + (b.$class()) + " failed")};
      return compare;
    }, TMP_Opal_compare_7.$$arity = 2);
    Opal.defs(self, '$destructure', TMP_Opal_destructure_8 = function $$destructure(args) {
      var self = this;

      
      if (args.length == 1) {
        return args[0];
      }
      else if (args.$$is_array) {
        return args;
      }
      else {
        var args_ary = new Array(args.length);
        for(var i = 0, l = args_ary.length; i < l; i++) { args_ary[i] = args[i]; }

        return args_ary;
      }
    
    }, TMP_Opal_destructure_8.$$arity = 1);
    Opal.defs(self, '$respond_to?', TMP_Opal_respond_to$q_9 = function(obj, method, include_all) {
      var self = this;

      if (include_all == null) {
        include_all = false;
      }
      
      
      if (obj == null || !obj.$$class) {
        return false;
      }
    ;
      return obj['$respond_to?'](method, include_all);
    }, TMP_Opal_respond_to$q_9.$$arity = -3);
    Opal.defs(self, '$inspect_obj', TMP_Opal_inspect_obj_10 = function $$inspect_obj(obj) {
      var self = this;

      return Opal.inspect(obj);
    }, TMP_Opal_inspect_obj_10.$$arity = 1);
    Opal.defs(self, '$instance_variable_name!', TMP_Opal_instance_variable_name$B_11 = function(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$coerce_to!'](name, $$($nesting, 'String'), "to_str");
      if ($truthy(/^@[a-zA-Z_][a-zA-Z0-9_]*?$/.test(name))) {
      } else {
        self.$raise($$($nesting, 'NameError').$new("" + "'" + (name) + "' is not allowed as an instance variable name", name))
      };
      return name;
    }, TMP_Opal_instance_variable_name$B_11.$$arity = 1);
    Opal.defs(self, '$class_variable_name!', TMP_Opal_class_variable_name$B_12 = function(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$coerce_to!'](name, $$($nesting, 'String'), "to_str");
      if ($truthy(name.length < 3 || name.slice(0,2) !== '@@')) {
        self.$raise($$($nesting, 'NameError').$new("" + "`" + (name) + "' is not allowed as a class variable name", name))};
      return name;
    }, TMP_Opal_class_variable_name$B_12.$$arity = 1);
    Opal.defs(self, '$const_name!', TMP_Opal_const_name$B_13 = function(const_name) {
      var self = this;

      
      const_name = $$($nesting, 'Opal')['$coerce_to!'](const_name, $$($nesting, 'String'), "to_str");
      if ($truthy(const_name['$[]'](0)['$!='](const_name['$[]'](0).$upcase()))) {
        self.$raise($$($nesting, 'NameError'), "" + "wrong constant name " + (const_name))};
      return const_name;
    }, TMP_Opal_const_name$B_13.$$arity = 1);
    Opal.defs(self, '$pristine', TMP_Opal_pristine_14 = function $$pristine(owner_class, $a_rest) {
      var self = this, method_names;

      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      method_names = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        method_names[$arg_idx - 1] = arguments[$arg_idx];
      }
      
      
      var method_name, method;
      for (var i = method_names.length - 1; i >= 0; i--) {
        method_name = method_names[i];
        method = owner_class.$$proto['$'+method_name];

        if (method && !method.$$stub) {
          method.$$pristine = true;
        }
      }
    ;
      return nil;
    }, TMP_Opal_pristine_14.$$arity = -2);
  })($nesting[0], $nesting)
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/module"] = function(Opal) {
  function $rb_lt(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs < rhs : lhs['$<'](rhs);
  }
  function $rb_gt(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs > rhs : lhs['$>'](rhs);
  }
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $klass = Opal.klass, $truthy = Opal.truthy, $send = Opal.send, $lambda = Opal.lambda, $range = Opal.range, $hash2 = Opal.hash2;

  Opal.add_stubs(['$===', '$raise', '$equal?', '$<', '$>', '$nil?', '$attr_reader', '$attr_writer', '$class_variable_name!', '$new', '$const_name!', '$=~', '$inject', '$split', '$const_get', '$==', '$!~', '$start_with?', '$to_proc', '$bind', '$call', '$class', '$append_features', '$included', '$name', '$cover?', '$size', '$merge', '$compile', '$proc', '$any?', '$to_s', '$__id__', '$constants', '$include?', '$copy_class_variables', '$copy_constants']);
  return (function($base, $super, $parent_nesting) {
    function $Module(){};
    var self = $Module = $klass($base, $super, 'Module', $Module);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_Module_allocate_1, TMP_Module_initialize_2, TMP_Module_$eq$eq$eq_3, TMP_Module_$lt_4, TMP_Module_$lt$eq_5, TMP_Module_$gt_6, TMP_Module_$gt$eq_7, TMP_Module_$lt$eq$gt_8, TMP_Module_alias_method_9, TMP_Module_alias_native_10, TMP_Module_ancestors_11, TMP_Module_append_features_12, TMP_Module_attr_accessor_13, TMP_Module_attr_reader_14, TMP_Module_attr_writer_15, TMP_Module_autoload_16, TMP_Module_class_variables_17, TMP_Module_class_variable_get_18, TMP_Module_class_variable_set_19, TMP_Module_class_variable_defined$q_20, TMP_Module_remove_class_variable_21, TMP_Module_constants_22, TMP_Module_constants_23, TMP_Module_nesting_24, TMP_Module_const_defined$q_25, TMP_Module_const_get_27, TMP_Module_const_missing_28, TMP_Module_const_set_29, TMP_Module_public_constant_30, TMP_Module_define_method_31, TMP_Module_remove_method_33, TMP_Module_singleton_class$q_34, TMP_Module_include_35, TMP_Module_included_modules_36, TMP_Module_include$q_37, TMP_Module_instance_method_38, TMP_Module_instance_methods_39, TMP_Module_included_40, TMP_Module_extended_41, TMP_Module_extend_object_42, TMP_Module_method_added_43, TMP_Module_method_removed_44, TMP_Module_method_undefined_45, TMP_Module_module_eval_46, TMP_Module_module_exec_48, TMP_Module_method_defined$q_49, TMP_Module_module_function_50, TMP_Module_name_51, TMP_Module_remove_const_52, TMP_Module_to_s_53, TMP_Module_undef_method_54, TMP_Module_instance_variables_55, TMP_Module_dup_56, TMP_Module_copy_class_variables_57, TMP_Module_copy_constants_58;

    
    Opal.defs(self, '$allocate', TMP_Module_allocate_1 = function $$allocate() {
      var self = this;

      
      var module;

      module = Opal.module_allocate(self);
      return module;
    
    }, TMP_Module_allocate_1.$$arity = 0);
    
    Opal.def(self, '$initialize', TMP_Module_initialize_2 = function $$initialize() {
      var self = this, $iter = TMP_Module_initialize_2.$$p, block = $iter || nil;

      if ($iter) TMP_Module_initialize_2.$$p = null;
      return Opal.module_initialize(self, block);
    }, TMP_Module_initialize_2.$$arity = 0);
    
    Opal.def(self, '$===', TMP_Module_$eq$eq$eq_3 = function(object) {
      var self = this;

      
      if ($truthy(object == null)) {
        return false};
      return Opal.is_a(object, self);;
    }, TMP_Module_$eq$eq$eq_3.$$arity = 1);
    
    Opal.def(self, '$<', TMP_Module_$lt_4 = function(other) {
      var self = this;

      
      if ($truthy($$($nesting, 'Module')['$==='](other))) {
      } else {
        self.$raise($$($nesting, 'TypeError'), "compared with non class/module")
      };
      
      var working = self,
          ancestors,
          i, length;

      if (working === other) {
        return false;
      }

      for (i = 0, ancestors = Opal.ancestors(self), length = ancestors.length; i < length; i++) {
        if (ancestors[i] === other) {
          return true;
        }
      }

      for (i = 0, ancestors = Opal.ancestors(other), length = ancestors.length; i < length; i++) {
        if (ancestors[i] === self) {
          return false;
        }
      }

      return nil;
    ;
    }, TMP_Module_$lt_4.$$arity = 1);
    
    Opal.def(self, '$<=', TMP_Module_$lt$eq_5 = function(other) {
      var $a, self = this;

      return ($truthy($a = self['$equal?'](other)) ? $a : $rb_lt(self, other))
    }, TMP_Module_$lt$eq_5.$$arity = 1);
    
    Opal.def(self, '$>', TMP_Module_$gt_6 = function(other) {
      var self = this;

      
      if ($truthy($$($nesting, 'Module')['$==='](other))) {
      } else {
        self.$raise($$($nesting, 'TypeError'), "compared with non class/module")
      };
      return $rb_lt(other, self);
    }, TMP_Module_$gt_6.$$arity = 1);
    
    Opal.def(self, '$>=', TMP_Module_$gt$eq_7 = function(other) {
      var $a, self = this;

      return ($truthy($a = self['$equal?'](other)) ? $a : $rb_gt(self, other))
    }, TMP_Module_$gt$eq_7.$$arity = 1);
    
    Opal.def(self, '$<=>', TMP_Module_$lt$eq$gt_8 = function(other) {
      var self = this, lt = nil;

      
      
      if (self === other) {
        return 0;
      }
    ;
      if ($truthy($$($nesting, 'Module')['$==='](other))) {
      } else {
        return nil
      };
      lt = $rb_lt(self, other);
      if ($truthy(lt['$nil?']())) {
        return nil};
      if ($truthy(lt)) {
        return -1
      } else {
        return 1
      };
    }, TMP_Module_$lt$eq$gt_8.$$arity = 1);
    
    Opal.def(self, '$alias_method', TMP_Module_alias_method_9 = function $$alias_method(newname, oldname) {
      var self = this;

      
      Opal.alias(self, newname, oldname);
      return self;
    }, TMP_Module_alias_method_9.$$arity = 2);
    
    Opal.def(self, '$alias_native', TMP_Module_alias_native_10 = function $$alias_native(mid, jsid) {
      var self = this;

      if (jsid == null) {
        jsid = mid;
      }
      
      Opal.alias_native(self, mid, jsid);
      return self;
    }, TMP_Module_alias_native_10.$$arity = -2);
    
    Opal.def(self, '$ancestors', TMP_Module_ancestors_11 = function $$ancestors() {
      var self = this;

      return Opal.ancestors(self);
    }, TMP_Module_ancestors_11.$$arity = 0);
    
    Opal.def(self, '$append_features', TMP_Module_append_features_12 = function $$append_features(includer) {
      var self = this;

      
      Opal.append_features(self, includer);
      return self;
    }, TMP_Module_append_features_12.$$arity = 1);
    
    Opal.def(self, '$attr_accessor', TMP_Module_attr_accessor_13 = function $$attr_accessor($a_rest) {
      var self = this, names;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      names = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        names[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      $send(self, 'attr_reader', Opal.to_a(names));
      return $send(self, 'attr_writer', Opal.to_a(names));
    }, TMP_Module_attr_accessor_13.$$arity = -1);
    Opal.alias(self, "attr", "attr_accessor");
    
    Opal.def(self, '$attr_reader', TMP_Module_attr_reader_14 = function $$attr_reader($a_rest) {
      var self = this, names;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      names = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        names[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      var proto = self.$$proto;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name,
            ivar = Opal.ivar(name);

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(ivar) {
          return function() {
            if (this[ivar] == null) {
              return nil;
            }
            else {
              return this[ivar];
            }
          };
        })(ivar);

        // initialize the instance variable as nil
        proto[ivar] = nil;

        body.$$parameters = [];
        body.$$arity = 0;

        if (self.$$is_singleton) {
          proto.constructor.prototype[id] = body;
        }
        else {
          Opal.defn(self, id, body);
        }
      }
    ;
      return nil;
    }, TMP_Module_attr_reader_14.$$arity = -1);
    
    Opal.def(self, '$attr_writer', TMP_Module_attr_writer_15 = function $$attr_writer($a_rest) {
      var self = this, names;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      names = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        names[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      var proto = self.$$proto;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name + '=',
            ivar = Opal.ivar(name);

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(ivar){
          return function(value) {
            return this[ivar] = value;
          }
        })(ivar);

        body.$$parameters = [['req']];
        body.$$arity = 1;

        // initialize the instance variable as nil
        proto[ivar] = nil;

        if (self.$$is_singleton) {
          proto.constructor.prototype[id] = body;
        }
        else {
          Opal.defn(self, id, body);
        }
      }
    ;
      return nil;
    }, TMP_Module_attr_writer_15.$$arity = -1);
    
    Opal.def(self, '$autoload', TMP_Module_autoload_16 = function $$autoload(const$, path) {
      var self = this;

      
      if (self.$$autoload == null) self.$$autoload = {};
      Opal.const_cache_version++;
      self.$$autoload[const$] = path;
      return nil;
    
    }, TMP_Module_autoload_16.$$arity = 2);
    
    Opal.def(self, '$class_variables', TMP_Module_class_variables_17 = function $$class_variables() {
      var self = this;

      return Object.keys(Opal.class_variables(self));
    }, TMP_Module_class_variables_17.$$arity = 0);
    
    Opal.def(self, '$class_variable_get', TMP_Module_class_variable_get_18 = function $$class_variable_get(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$class_variable_name!'](name);
      
      var value = Opal.class_variables(self)[name];
      if (value == null) {
        self.$raise($$($nesting, 'NameError').$new("" + "uninitialized class variable " + (name) + " in " + (self), name))
      }
      return value;
    ;
    }, TMP_Module_class_variable_get_18.$$arity = 1);
    
    Opal.def(self, '$class_variable_set', TMP_Module_class_variable_set_19 = function $$class_variable_set(name, value) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$class_variable_name!'](name);
      return Opal.class_variable_set(self, name, value);;
    }, TMP_Module_class_variable_set_19.$$arity = 2);
    
    Opal.def(self, '$class_variable_defined?', TMP_Module_class_variable_defined$q_20 = function(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$class_variable_name!'](name);
      return Opal.class_variables(self).hasOwnProperty(name);;
    }, TMP_Module_class_variable_defined$q_20.$$arity = 1);
    
    Opal.def(self, '$remove_class_variable', TMP_Module_remove_class_variable_21 = function $$remove_class_variable(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$class_variable_name!'](name);
      
      if (Opal.hasOwnProperty.call(self.$$cvars, name)) {
        var value = self.$$cvars[name];
        delete self.$$cvars[name];
        return value;
      } else {
        self.$raise($$($nesting, 'NameError'), "" + "cannot remove " + (name) + " for " + (self))
      }
    ;
    }, TMP_Module_remove_class_variable_21.$$arity = 1);
    
    Opal.def(self, '$constants', TMP_Module_constants_22 = function $$constants(inherit) {
      var self = this;

      if (inherit == null) {
        inherit = true;
      }
      return Opal.constants(self, inherit);
    }, TMP_Module_constants_22.$$arity = -1);
    Opal.defs(self, '$constants', TMP_Module_constants_23 = function $$constants(inherit) {
      var self = this;

      
      if (inherit == null) {
        var nesting = (self.$$nesting || []).concat(Opal.Object),
            constant, constants = {},
            i, ii;

        for(i = 0, ii = nesting.length; i < ii; i++) {
          for (constant in nesting[i].$$const) {
            constants[constant] = true;
          }
        }
        return Object.keys(constants);
      } else {
        return Opal.constants(self, inherit)
      }
    
    }, TMP_Module_constants_23.$$arity = -1);
    Opal.defs(self, '$nesting', TMP_Module_nesting_24 = function $$nesting() {
      var self = this;

      return self.$$nesting || [];
    }, TMP_Module_nesting_24.$$arity = 0);
    
    Opal.def(self, '$const_defined?', TMP_Module_const_defined$q_25 = function(name, inherit) {
      var self = this;

      if (inherit == null) {
        inherit = true;
      }
      
      name = $$($nesting, 'Opal')['$const_name!'](name);
      if ($truthy(name['$=~']($$$($$($nesting, 'Opal'), 'CONST_NAME_REGEXP')))) {
      } else {
        self.$raise($$($nesting, 'NameError').$new("" + "wrong constant name " + (name), name))
      };
      
      var module, modules = [self], module_constants, i, ii;

      // Add up ancestors if inherit is true
      if (inherit) {
        modules = modules.concat(Opal.ancestors(self));

        // Add Object's ancestors if it's a module – modules have no ancestors otherwise
        if (self.$$is_module) {
          modules = modules.concat([Opal.Object]).concat(Opal.ancestors(Opal.Object));
        }
      }

      for (i = 0, ii = modules.length; i < ii; i++) {
        module = modules[i];
        if (module.$$const[name] != null) {
          return true;
        }
      }

      return false;
    ;
    }, TMP_Module_const_defined$q_25.$$arity = -2);
    
    Opal.def(self, '$const_get', TMP_Module_const_get_27 = function $$const_get(name, inherit) {
      var TMP_26, self = this;

      if (inherit == null) {
        inherit = true;
      }
      
      name = $$($nesting, 'Opal')['$const_name!'](name);
      
      if (name.indexOf('::') === 0 && name !== '::'){
        name = name.slice(2);
      }
    ;
      if ($truthy(name.indexOf('::') != -1 && name != '::')) {
        return $send(name.$split("::"), 'inject', [self], (TMP_26 = function(o, c){var self = TMP_26.$$s || this;
if (o == null) o = nil;if (c == null) c = nil;
        return o.$const_get(c)}, TMP_26.$$s = self, TMP_26.$$arity = 2, TMP_26))};
      if ($truthy(name['$=~']($$$($$($nesting, 'Opal'), 'CONST_NAME_REGEXP')))) {
      } else {
        self.$raise($$($nesting, 'NameError').$new("" + "wrong constant name " + (name), name))
      };
      
      if (inherit) {
        return $$([self], name);
      } else {
        return Opal.const_get_local(self, name);
      }
    ;
    }, TMP_Module_const_get_27.$$arity = -2);
    
    Opal.def(self, '$const_missing', TMP_Module_const_missing_28 = function $$const_missing(name) {
      var self = this, full_const_name = nil;

      
      
      if (self.$$autoload) {
        var file = self.$$autoload[name];

        if (file) {
          self.$require(file);

          return self.$const_get(name);
        }
      }
    ;
      full_const_name = (function() {if (self['$==']($$($nesting, 'Object'))) {
        return name
      } else {
        return "" + (self) + "::" + (name)
      }; return nil; })();
      return self.$raise($$($nesting, 'NameError').$new("" + "uninitialized constant " + (full_const_name), name));
    }, TMP_Module_const_missing_28.$$arity = 1);
    
    Opal.def(self, '$const_set', TMP_Module_const_set_29 = function $$const_set(name, value) {
      var $a, self = this;

      
      name = $$($nesting, 'Opal')['$const_name!'](name);
      if ($truthy(($truthy($a = name['$!~']($$$($$($nesting, 'Opal'), 'CONST_NAME_REGEXP'))) ? $a : name['$start_with?']("::")))) {
        self.$raise($$($nesting, 'NameError').$new("" + "wrong constant name " + (name), name))};
      Opal.const_set(self, name, value);
      return value;
    }, TMP_Module_const_set_29.$$arity = 2);
    
    Opal.def(self, '$public_constant', TMP_Module_public_constant_30 = function $$public_constant(const_name) {
      var self = this;

      return nil
    }, TMP_Module_public_constant_30.$$arity = 1);
    
    Opal.def(self, '$define_method', TMP_Module_define_method_31 = function $$define_method(name, method) {
      var $a, TMP_32, self = this, $iter = TMP_Module_define_method_31.$$p, block = $iter || nil, $case = nil;

      if ($iter) TMP_Module_define_method_31.$$p = null;
      
      if ($truthy(method === undefined && block === nil)) {
        self.$raise($$($nesting, 'ArgumentError'), "tried to create a Proc object without a block")};
      block = ($truthy($a = block) ? $a : (function() {$case = method;
      if ($$($nesting, 'Proc')['$===']($case)) {return method}
      else if ($$($nesting, 'Method')['$===']($case)) {return method.$to_proc().$$unbound}
      else if ($$($nesting, 'UnboundMethod')['$===']($case)) {return $lambda((TMP_32 = function($b_rest){var self = TMP_32.$$s || this, args, bound = nil;

        var $args_len = arguments.length, $rest_len = $args_len - 0;
        if ($rest_len < 0) { $rest_len = 0; }
        args = new Array($rest_len);
        for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
          args[$arg_idx - 0] = arguments[$arg_idx];
        }
      
        bound = method.$bind(self);
        return $send(bound, 'call', Opal.to_a(args));}, TMP_32.$$s = self, TMP_32.$$arity = -1, TMP_32))}
      else {return self.$raise($$($nesting, 'TypeError'), "" + "wrong argument type " + (block.$class()) + " (expected Proc/Method)")}})());
      
      var id = '$' + name;

      block.$$jsid        = name;
      block.$$s           = null;
      block.$$def         = block;
      block.$$define_meth = true;

      Opal.defn(self, id, block);

      return name;
    ;
    }, TMP_Module_define_method_31.$$arity = -2);
    
    Opal.def(self, '$remove_method', TMP_Module_remove_method_33 = function $$remove_method($a_rest) {
      var self = this, names;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      names = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        names[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      for (var i = 0, length = names.length; i < length; i++) {
        Opal.rdef(self, "$" + names[i]);
      }
    ;
      return self;
    }, TMP_Module_remove_method_33.$$arity = -1);
    
    Opal.def(self, '$singleton_class?', TMP_Module_singleton_class$q_34 = function() {
      var self = this;

      return !!self.$$is_singleton;
    }, TMP_Module_singleton_class$q_34.$$arity = 0);
    
    Opal.def(self, '$include', TMP_Module_include_35 = function $$include($a_rest) {
      var self = this, mods;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      mods = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        mods[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          self.$raise($$($nesting, 'TypeError'), "" + "wrong argument type " + ((mod).$class()) + " (expected Module)");
        }

        (mod).$append_features(self);
        (mod).$included(self);
      }
    ;
      return self;
    }, TMP_Module_include_35.$$arity = -1);
    
    Opal.def(self, '$included_modules', TMP_Module_included_modules_36 = function $$included_modules() {
      var self = this;

      
      var results;

      var module_chain = function(klass) {
        var included = [];

        for (var i = 0, ii = klass.$$inc.length; i < ii; i++) {
          var mod_or_class = klass.$$inc[i];
          included.push(mod_or_class);
          included = included.concat(module_chain(mod_or_class));
        }

        return included;
      };

      results = module_chain(self);

      // need superclass's modules
      if (self.$$is_class) {
        for (var cls = self; cls; cls = cls.$$super) {
          results = results.concat(module_chain(cls));
        }
      }

      return results;
    
    }, TMP_Module_included_modules_36.$$arity = 0);
    
    Opal.def(self, '$include?', TMP_Module_include$q_37 = function(mod) {
      var self = this;

      
      if (!mod.$$is_module) {
        self.$raise($$($nesting, 'TypeError'), "" + "wrong argument type " + ((mod).$class()) + " (expected Module)");
      }

      var i, ii, mod2, ancestors = Opal.ancestors(self);

      for (i = 0, ii = ancestors.length; i < ii; i++) {
        mod2 = ancestors[i];
        if (mod2 === mod && mod2 !== self) {
          return true;
        }
      }

      return false;
    
    }, TMP_Module_include$q_37.$$arity = 1);
    
    Opal.def(self, '$instance_method', TMP_Module_instance_method_38 = function $$instance_method(name) {
      var self = this;

      
      var meth = self.$$proto['$' + name];

      if (!meth || meth.$$stub) {
        self.$raise($$($nesting, 'NameError').$new("" + "undefined method `" + (name) + "' for class `" + (self.$name()) + "'", name));
      }

      return $$($nesting, 'UnboundMethod').$new(self, meth.$$owner || self, meth, name);
    
    }, TMP_Module_instance_method_38.$$arity = 1);
    
    Opal.def(self, '$instance_methods', TMP_Module_instance_methods_39 = function $$instance_methods(include_super) {
      var self = this;

      if (include_super == null) {
        include_super = true;
      }
      
      var value,
          methods = [],
          proto   = self.$$proto;

      for (var prop in proto) {
        if (prop.charAt(0) !== '$' || prop.charAt(1) === '$') {
          continue;
        }

        value = proto[prop];

        if (typeof(value) !== "function") {
          continue;
        }

        if (value.$$stub) {
          continue;
        }

        if (!self.$$is_module) {
          if (self !== Opal.BasicObject && value === Opal.BasicObject.$$proto[prop]) {
            continue;
          }

          if (!include_super && !proto.hasOwnProperty(prop)) {
            continue;
          }

          if (!include_super && value.$$donated) {
            continue;
          }
        }

        methods.push(prop.substr(1));
      }

      return methods;
    
    }, TMP_Module_instance_methods_39.$$arity = -1);
    
    Opal.def(self, '$included', TMP_Module_included_40 = function $$included(mod) {
      var self = this;

      return nil
    }, TMP_Module_included_40.$$arity = 1);
    
    Opal.def(self, '$extended', TMP_Module_extended_41 = function $$extended(mod) {
      var self = this;

      return nil
    }, TMP_Module_extended_41.$$arity = 1);
    
    Opal.def(self, '$extend_object', TMP_Module_extend_object_42 = function $$extend_object(object) {
      var self = this;

      return nil
    }, TMP_Module_extend_object_42.$$arity = 1);
    
    Opal.def(self, '$method_added', TMP_Module_method_added_43 = function $$method_added($a_rest) {
      var self = this;

      return nil
    }, TMP_Module_method_added_43.$$arity = -1);
    
    Opal.def(self, '$method_removed', TMP_Module_method_removed_44 = function $$method_removed($a_rest) {
      var self = this;

      return nil
    }, TMP_Module_method_removed_44.$$arity = -1);
    
    Opal.def(self, '$method_undefined', TMP_Module_method_undefined_45 = function $$method_undefined($a_rest) {
      var self = this;

      return nil
    }, TMP_Module_method_undefined_45.$$arity = -1);
    
    Opal.def(self, '$module_eval', TMP_Module_module_eval_46 = function $$module_eval($a_rest) {
      var $b, TMP_47, self = this, args, $iter = TMP_Module_module_eval_46.$$p, block = $iter || nil, string = nil, file = nil, _lineno = nil, default_eval_options = nil, compiling_options = nil, compiled = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_Module_module_eval_46.$$p = null;
      
      if ($truthy(($truthy($b = block['$nil?']()) ? !!Opal.compile : $b))) {
        
        if ($truthy($range(1, 3, false)['$cover?'](args.$size()))) {
        } else {
          $$($nesting, 'Kernel').$raise($$($nesting, 'ArgumentError'), "wrong number of arguments (0 for 1..3)")
        };
        $b = [].concat(Opal.to_a(args)), (string = ($b[0] == null ? nil : $b[0])), (file = ($b[1] == null ? nil : $b[1])), (_lineno = ($b[2] == null ? nil : $b[2])), $b;
        default_eval_options = $hash2(["file", "eval"], {"file": ($truthy($b = file) ? $b : "(eval)"), "eval": true});
        compiling_options = Opal.hash({ arity_check: false }).$merge(default_eval_options);
        compiled = $$($nesting, 'Opal').$compile(string, compiling_options);
        block = $send($$($nesting, 'Kernel'), 'proc', [], (TMP_47 = function(){var self = TMP_47.$$s || this;

        
          return (function(self) {
            return eval(compiled);
          })(self)
        }, TMP_47.$$s = self, TMP_47.$$arity = 0, TMP_47));
      } else if ($truthy(args['$any?']())) {
        $$($nesting, 'Kernel').$raise($$($nesting, 'ArgumentError'), "" + ("" + "wrong number of arguments (" + (args.$size()) + " for 0)") + "\n\n  NOTE:If you want to enable passing a String argument please add \"require 'opal-parser'\" to your script\n")};
      
      var old = block.$$s,
          result;

      block.$$s = null;
      result = block.apply(self, [self]);
      block.$$s = old;

      return result;
    ;
    }, TMP_Module_module_eval_46.$$arity = -1);
    Opal.alias(self, "class_eval", "module_eval");
    
    Opal.def(self, '$module_exec', TMP_Module_module_exec_48 = function $$module_exec($a_rest) {
      var self = this, args, $iter = TMP_Module_module_exec_48.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_Module_module_exec_48.$$p = null;
      
      if (block === nil) {
        self.$raise($$($nesting, 'LocalJumpError'), "no block given")
      }

      var block_self = block.$$s, result;

      block.$$s = null;
      result = block.apply(self, args);
      block.$$s = block_self;

      return result;
    
    }, TMP_Module_module_exec_48.$$arity = -1);
    Opal.alias(self, "class_exec", "module_exec");
    
    Opal.def(self, '$method_defined?', TMP_Module_method_defined$q_49 = function(method) {
      var self = this;

      
      var body = self.$$proto['$' + method];
      return (!!body) && !body.$$stub;
    
    }, TMP_Module_method_defined$q_49.$$arity = 1);
    
    Opal.def(self, '$module_function', TMP_Module_module_function_50 = function $$module_function($a_rest) {
      var self = this, methods;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      methods = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        methods[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      if (methods.length === 0) {
        self.$$module_function = true;
      }
      else {
        for (var i = 0, length = methods.length; i < length; i++) {
          var meth = methods[i],
              id   = '$' + meth,
              func = self.$$proto[id];

          Opal.defs(self, id, func);
        }
      }

      return self;
    
    }, TMP_Module_module_function_50.$$arity = -1);
    
    Opal.def(self, '$name', TMP_Module_name_51 = function $$name() {
      var self = this;

      
      if (self.$$full_name) {
        return self.$$full_name;
      }

      var result = [], base = self;

      while (base) {
        // Give up if any of the ancestors is unnamed
        if (base.$$name === nil || base.$$name == null) return nil;

        result.unshift(base.$$name);

        base = base.$$base_module;

        if (base === Opal.Object) {
          break;
        }
      }

      if (result.length === 0) {
        return nil;
      }

      return self.$$full_name = result.join('::');
    
    }, TMP_Module_name_51.$$arity = 0);
    
    Opal.def(self, '$remove_const', TMP_Module_remove_const_52 = function $$remove_const(name) {
      var self = this;

      return Opal.const_remove(self, name);
    }, TMP_Module_remove_const_52.$$arity = 1);
    
    Opal.def(self, '$to_s', TMP_Module_to_s_53 = function $$to_s() {
      var $a, self = this;

      return ($truthy($a = Opal.Module.$name.call(self)) ? $a : "" + "#<" + (self.$$is_module ? 'Module' : 'Class') + ":0x" + (self.$__id__().$to_s(16)) + ">")
    }, TMP_Module_to_s_53.$$arity = 0);
    
    Opal.def(self, '$undef_method', TMP_Module_undef_method_54 = function $$undef_method($a_rest) {
      var self = this, names;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      names = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        names[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      for (var i = 0, length = names.length; i < length; i++) {
        Opal.udef(self, "$" + names[i]);
      }
    ;
      return self;
    }, TMP_Module_undef_method_54.$$arity = -1);
    
    Opal.def(self, '$instance_variables', TMP_Module_instance_variables_55 = function $$instance_variables() {
      var self = this, consts = nil;

      
      consts = (Opal.Module.$$nesting = $nesting, self.$constants());
      
      var result = [];

      for (var name in self) {
        if (self.hasOwnProperty(name) && name.charAt(0) !== '$' && name !== 'constructor' && !consts['$include?'](name)) {
          result.push('@' + name);
        }
      }

      return result;
    ;
    }, TMP_Module_instance_variables_55.$$arity = 0);
    
    Opal.def(self, '$dup', TMP_Module_dup_56 = function $$dup() {
      var self = this, $iter = TMP_Module_dup_56.$$p, $yield = $iter || nil, copy = nil, $zuper = nil, $zuper_i = nil, $zuper_ii = nil;

      if ($iter) TMP_Module_dup_56.$$p = null;
      // Prepare super implicit arguments
      for($zuper_i = 0, $zuper_ii = arguments.length, $zuper = new Array($zuper_ii); $zuper_i < $zuper_ii; $zuper_i++) {
        $zuper[$zuper_i] = arguments[$zuper_i];
      }
      
      copy = $send(self, Opal.find_super_dispatcher(self, 'dup', TMP_Module_dup_56, false), $zuper, $iter);
      copy.$copy_class_variables(self);
      copy.$copy_constants(self);
      return copy;
    }, TMP_Module_dup_56.$$arity = 0);
    
    Opal.def(self, '$copy_class_variables', TMP_Module_copy_class_variables_57 = function $$copy_class_variables(other) {
      var self = this;

      
      for (var name in other.$$cvars) {
        self.$$cvars[name] = other.$$cvars[name];
      }
    
    }, TMP_Module_copy_class_variables_57.$$arity = 1);
    return (Opal.def(self, '$copy_constants', TMP_Module_copy_constants_58 = function $$copy_constants(other) {
      var self = this;

      
      var name, other_constants = other.$$const;

      for (name in other_constants) {
        Opal.const_set(self, name, other_constants[name]);
      }
    
    }, TMP_Module_copy_constants_58.$$arity = 1), nil) && 'copy_constants';
  })($nesting[0], null, $nesting)
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/class"] = function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $klass = Opal.klass, $send = Opal.send;

  Opal.add_stubs(['$require', '$initialize_copy', '$allocate', '$name', '$to_s']);
  
  self.$require("corelib/module");
  return (function($base, $super, $parent_nesting) {
    function $Class(){};
    var self = $Class = $klass($base, $super, 'Class', $Class);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_Class_new_1, TMP_Class_allocate_2, TMP_Class_inherited_3, TMP_Class_initialize_dup_4, TMP_Class_new_5, TMP_Class_superclass_6, TMP_Class_to_s_7;

    
    Opal.defs(self, '$new', TMP_Class_new_1 = function(superclass) {
      var self = this, $iter = TMP_Class_new_1.$$p, block = $iter || nil;

      if (superclass == null) {
        superclass = $$($nesting, 'Object');
      }
      if ($iter) TMP_Class_new_1.$$p = null;
      
      if (!superclass.$$is_class) {
        throw Opal.TypeError.$new("superclass must be a Class");
      }

      var alloc = Opal.boot_class_alloc(null, function(){}, superclass);
      var klass = Opal.setup_class_object(null, alloc, superclass.$$name, superclass.constructor);

      klass.$$super  = superclass;
      klass.$$parent = superclass;

      superclass.$inherited(klass);
      Opal.module_initialize(klass, block);

      return klass;
    
    }, TMP_Class_new_1.$$arity = -1);
    
    Opal.def(self, '$allocate', TMP_Class_allocate_2 = function $$allocate() {
      var self = this;

      
      var obj = new self.$$alloc();
      obj.$$id = Opal.uid();
      return obj;
    
    }, TMP_Class_allocate_2.$$arity = 0);
    
    Opal.def(self, '$inherited', TMP_Class_inherited_3 = function $$inherited(cls) {
      var self = this;

      return nil
    }, TMP_Class_inherited_3.$$arity = 1);
    
    Opal.def(self, '$initialize_dup', TMP_Class_initialize_dup_4 = function $$initialize_dup(original) {
      var self = this;

      
      self.$initialize_copy(original);
      
      self.$$name = null;
      self.$$full_name = null;
    ;
    }, TMP_Class_initialize_dup_4.$$arity = 1);
    
    Opal.def(self, '$new', TMP_Class_new_5 = function($a_rest) {
      var self = this, args, $iter = TMP_Class_new_5.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_Class_new_5.$$p = null;
      
      var object = self.$allocate();
      Opal.send(object, object.$initialize, args, block);
      return object;
    
    }, TMP_Class_new_5.$$arity = -1);
    
    Opal.def(self, '$superclass', TMP_Class_superclass_6 = function $$superclass() {
      var self = this;

      return self.$$super || nil;
    }, TMP_Class_superclass_6.$$arity = 0);
    return (Opal.def(self, '$to_s', TMP_Class_to_s_7 = function $$to_s() {
      var self = this, $iter = TMP_Class_to_s_7.$$p, $yield = $iter || nil;

      if ($iter) TMP_Class_to_s_7.$$p = null;
      
      var singleton_of = self.$$singleton_of;

      if (singleton_of && (singleton_of.$$is_class || singleton_of.$$is_module)) {
        return "" + "#<Class:" + ((singleton_of).$name()) + ">";
      }
      else if (singleton_of) {
        // a singleton class created from an object
        return "" + "#<Class:#<" + ((singleton_of.$$class).$name()) + ":0x" + ((Opal.id(singleton_of)).$to_s(16)) + ">>";
      }
      return $send(self, Opal.find_super_dispatcher(self, 'to_s', TMP_Class_to_s_7, false), [], null);
    
    }, TMP_Class_to_s_7.$$arity = 0), nil) && 'to_s';
  })($nesting[0], null, $nesting);
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/basic_object"] = function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $klass = Opal.klass, $truthy = Opal.truthy, $range = Opal.range, $hash2 = Opal.hash2, $send = Opal.send;

  Opal.add_stubs(['$==', '$!', '$nil?', '$cover?', '$size', '$raise', '$merge', '$compile', '$proc', '$any?', '$inspect', '$new']);
  return (function($base, $super, $parent_nesting) {
    function $BasicObject(){};
    var self = $BasicObject = $klass($base, $super, 'BasicObject', $BasicObject);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_BasicObject_initialize_1, TMP_BasicObject_$eq$eq_2, TMP_BasicObject_eql$q_3, TMP_BasicObject___id___4, TMP_BasicObject___send___5, TMP_BasicObject_$B_6, TMP_BasicObject_$B$eq_7, TMP_BasicObject_instance_eval_8, TMP_BasicObject_instance_exec_10, TMP_BasicObject_singleton_method_added_11, TMP_BasicObject_singleton_method_removed_12, TMP_BasicObject_singleton_method_undefined_13, TMP_BasicObject_class_14, TMP_BasicObject_method_missing_15;

    
    
    Opal.def(self, '$initialize', TMP_BasicObject_initialize_1 = function $$initialize($a_rest) {
      var self = this;

      return nil
    }, TMP_BasicObject_initialize_1.$$arity = -1);
    
    Opal.def(self, '$==', TMP_BasicObject_$eq$eq_2 = function(other) {
      var self = this;

      return self === other;
    }, TMP_BasicObject_$eq$eq_2.$$arity = 1);
    
    Opal.def(self, '$eql?', TMP_BasicObject_eql$q_3 = function(other) {
      var self = this;

      return self['$=='](other)
    }, TMP_BasicObject_eql$q_3.$$arity = 1);
    Opal.alias(self, "equal?", "==");
    
    Opal.def(self, '$__id__', TMP_BasicObject___id___4 = function $$__id__() {
      var self = this;

      return self.$$id || (self.$$id = Opal.uid());
    }, TMP_BasicObject___id___4.$$arity = 0);
    
    Opal.def(self, '$__send__', TMP_BasicObject___send___5 = function $$__send__(symbol, $a_rest) {
      var self = this, args, $iter = TMP_BasicObject___send___5.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 1] = arguments[$arg_idx];
      }
      if ($iter) TMP_BasicObject___send___5.$$p = null;
      
      var func = self['$' + symbol]

      if (func) {
        if (block !== nil) {
          func.$$p = block;
        }

        return func.apply(self, args);
      }

      if (block !== nil) {
        self.$method_missing.$$p = block;
      }

      return self.$method_missing.apply(self, [symbol].concat(args));
    
    }, TMP_BasicObject___send___5.$$arity = -2);
    
    Opal.def(self, '$!', TMP_BasicObject_$B_6 = function() {
      var self = this;

      return false
    }, TMP_BasicObject_$B_6.$$arity = 0);
    
    Opal.def(self, '$!=', TMP_BasicObject_$B$eq_7 = function(other) {
      var self = this;

      return self['$=='](other)['$!']()
    }, TMP_BasicObject_$B$eq_7.$$arity = 1);
    
    Opal.def(self, '$instance_eval', TMP_BasicObject_instance_eval_8 = function $$instance_eval($a_rest) {
      var $b, TMP_9, self = this, args, $iter = TMP_BasicObject_instance_eval_8.$$p, block = $iter || nil, string = nil, file = nil, _lineno = nil, default_eval_options = nil, compiling_options = nil, compiled = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_BasicObject_instance_eval_8.$$p = null;
      
      if ($truthy(($truthy($b = block['$nil?']()) ? !!Opal.compile : $b))) {
        
        if ($truthy($range(1, 3, false)['$cover?'](args.$size()))) {
        } else {
          $$$('::', 'Kernel').$raise($$$('::', 'ArgumentError'), "wrong number of arguments (0 for 1..3)")
        };
        $b = [].concat(Opal.to_a(args)), (string = ($b[0] == null ? nil : $b[0])), (file = ($b[1] == null ? nil : $b[1])), (_lineno = ($b[2] == null ? nil : $b[2])), $b;
        default_eval_options = $hash2(["file", "eval"], {"file": ($truthy($b = file) ? $b : "(eval)"), "eval": true});
        compiling_options = Opal.hash({ arity_check: false }).$merge(default_eval_options);
        compiled = $$$('::', 'Opal').$compile(string, compiling_options);
        block = $send($$$('::', 'Kernel'), 'proc', [], (TMP_9 = function(){var self = TMP_9.$$s || this;

        
          return (function(self) {
            return eval(compiled);
          })(self)
        }, TMP_9.$$s = self, TMP_9.$$arity = 0, TMP_9));
      } else if ($truthy(args['$any?']())) {
        $$$('::', 'Kernel').$raise($$$('::', 'ArgumentError'), "" + "wrong number of arguments (" + (args.$size()) + " for 0)")};
      
      var old = block.$$s,
          result;

      block.$$s = null;

      // Need to pass $$eval so that method definitions know if this is
      // being done on a class/module. Cannot be compiler driven since
      // send(:instance_eval) needs to work.
      if (self.$$is_class || self.$$is_module) {
        self.$$eval = true;
        try {
          result = block.call(self, self);
        }
        finally {
          self.$$eval = false;
        }
      }
      else {
        result = block.call(self, self);
      }

      block.$$s = old;

      return result;
    ;
    }, TMP_BasicObject_instance_eval_8.$$arity = -1);
    
    Opal.def(self, '$instance_exec', TMP_BasicObject_instance_exec_10 = function $$instance_exec($a_rest) {
      var self = this, args, $iter = TMP_BasicObject_instance_exec_10.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_BasicObject_instance_exec_10.$$p = null;
      
      if ($truthy(block)) {
      } else {
        $$$('::', 'Kernel').$raise($$$('::', 'ArgumentError'), "no block given")
      };
      
      var block_self = block.$$s,
          result;

      block.$$s = null;

      if (self.$$is_class || self.$$is_module) {
        self.$$eval = true;
        try {
          result = block.apply(self, args);
        }
        finally {
          self.$$eval = false;
        }
      }
      else {
        result = block.apply(self, args);
      }

      block.$$s = block_self;

      return result;
    ;
    }, TMP_BasicObject_instance_exec_10.$$arity = -1);
    
    Opal.def(self, '$singleton_method_added', TMP_BasicObject_singleton_method_added_11 = function $$singleton_method_added($a_rest) {
      var self = this;

      return nil
    }, TMP_BasicObject_singleton_method_added_11.$$arity = -1);
    
    Opal.def(self, '$singleton_method_removed', TMP_BasicObject_singleton_method_removed_12 = function $$singleton_method_removed($a_rest) {
      var self = this;

      return nil
    }, TMP_BasicObject_singleton_method_removed_12.$$arity = -1);
    
    Opal.def(self, '$singleton_method_undefined', TMP_BasicObject_singleton_method_undefined_13 = function $$singleton_method_undefined($a_rest) {
      var self = this;

      return nil
    }, TMP_BasicObject_singleton_method_undefined_13.$$arity = -1);
    
    Opal.def(self, '$class', TMP_BasicObject_class_14 = function() {
      var self = this;

      return self.$$class;
    }, TMP_BasicObject_class_14.$$arity = 0);
    return (Opal.def(self, '$method_missing', TMP_BasicObject_method_missing_15 = function $$method_missing(symbol, $a_rest) {
      var self = this, args, $iter = TMP_BasicObject_method_missing_15.$$p, block = $iter || nil, message = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 1] = arguments[$arg_idx];
      }
      if ($iter) TMP_BasicObject_method_missing_15.$$p = null;
      
      message = (function() {if ($truthy(self.$inspect && !self.$inspect.$$stub)) {
        return "" + "undefined method `" + (symbol) + "' for " + (self.$inspect()) + ":" + (self.$$class)
      } else {
        return "" + "undefined method `" + (symbol) + "' for " + (self.$$class)
      }; return nil; })();
      return $$$('::', 'Kernel').$raise($$$('::', 'NoMethodError').$new(message, symbol));
    }, TMP_BasicObject_method_missing_15.$$arity = -2), nil) && 'method_missing';
  })($nesting[0], null, $nesting)
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/kernel"] = function(Opal) {
  function $rb_le(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs <= rhs : lhs['$<='](rhs);
  }
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $truthy = Opal.truthy, $gvars = Opal.gvars, $hash2 = Opal.hash2, $send = Opal.send, $klass = Opal.klass;

  Opal.add_stubs(['$raise', '$new', '$inspect', '$!', '$=~', '$==', '$object_id', '$class', '$coerce_to?', '$<<', '$allocate', '$copy_instance_variables', '$copy_singleton_methods', '$initialize_clone', '$initialize_copy', '$define_method', '$singleton_class', '$to_proc', '$initialize_dup', '$for', '$empty?', '$pop', '$call', '$append_features', '$extend_object', '$extended', '$length', '$respond_to?', '$[]', '$nil?', '$to_a', '$to_int', '$fetch', '$Integer', '$Float', '$to_ary', '$to_str', '$coerce_to', '$to_s', '$__id__', '$instance_variable_name!', '$coerce_to!', '$===', '$enum_for', '$result', '$any?', '$print', '$format', '$puts', '$each', '$<=', '$exception', '$is_a?', '$rand', '$respond_to_missing?', '$try_convert!', '$expand_path', '$join', '$start_with?', '$srand', '$new_seed', '$sym', '$arg', '$open', '$include']);
  
  (function($base, $parent_nesting) {
    var $Kernel, self = $Kernel = $module($base, 'Kernel');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_Kernel_method_missing_1, TMP_Kernel_$eq$_2, TMP_Kernel_$B$_3, TMP_Kernel_$eq$eq$eq_4, TMP_Kernel_$lt$eq$gt_5, TMP_Kernel_method_6, TMP_Kernel_methods_7, TMP_Kernel_Array_8, TMP_Kernel_at_exit_9, TMP_Kernel_caller_10, TMP_Kernel_class_11, TMP_Kernel_copy_instance_variables_12, TMP_Kernel_copy_singleton_methods_13, TMP_Kernel_clone_14, TMP_Kernel_initialize_clone_15, TMP_Kernel_define_singleton_method_16, TMP_Kernel_dup_17, TMP_Kernel_initialize_dup_18, TMP_Kernel_enum_for_19, TMP_Kernel_equal$q_20, TMP_Kernel_exit_21, TMP_Kernel_extend_22, TMP_Kernel_format_23, TMP_Kernel_hash_24, TMP_Kernel_initialize_copy_25, TMP_Kernel_inspect_26, TMP_Kernel_instance_of$q_27, TMP_Kernel_instance_variable_defined$q_28, TMP_Kernel_instance_variable_get_29, TMP_Kernel_instance_variable_set_30, TMP_Kernel_remove_instance_variable_31, TMP_Kernel_instance_variables_32, TMP_Kernel_Integer_33, TMP_Kernel_Float_34, TMP_Kernel_Hash_35, TMP_Kernel_is_a$q_36, TMP_Kernel_itself_37, TMP_Kernel_lambda_38, TMP_Kernel_load_39, TMP_Kernel_loop_40, TMP_Kernel_nil$q_42, TMP_Kernel_printf_43, TMP_Kernel_proc_44, TMP_Kernel_puts_45, TMP_Kernel_p_47, TMP_Kernel_print_48, TMP_Kernel_warn_49, TMP_Kernel_raise_50, TMP_Kernel_rand_51, TMP_Kernel_respond_to$q_52, TMP_Kernel_respond_to_missing$q_53, TMP_Kernel_require_54, TMP_Kernel_require_relative_55, TMP_Kernel_require_tree_56, TMP_Kernel_singleton_class_57, TMP_Kernel_sleep_58, TMP_Kernel_srand_59, TMP_Kernel_String_60, TMP_Kernel_tap_61, TMP_Kernel_to_proc_62, TMP_Kernel_to_s_63, TMP_Kernel_catch_64, TMP_Kernel_throw_65, TMP_Kernel_open_66, TMP_Kernel_yield_self_67;

    
    
    Opal.def(self, '$method_missing', TMP_Kernel_method_missing_1 = function $$method_missing(symbol, $a_rest) {
      var self = this, args, $iter = TMP_Kernel_method_missing_1.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 1] = arguments[$arg_idx];
      }
      if ($iter) TMP_Kernel_method_missing_1.$$p = null;
      return self.$raise($$($nesting, 'NoMethodError').$new("" + "undefined method `" + (symbol) + "' for " + (self.$inspect()), symbol, args))
    }, TMP_Kernel_method_missing_1.$$arity = -2);
    
    Opal.def(self, '$=~', TMP_Kernel_$eq$_2 = function(obj) {
      var self = this;

      return false
    }, TMP_Kernel_$eq$_2.$$arity = 1);
    
    Opal.def(self, '$!~', TMP_Kernel_$B$_3 = function(obj) {
      var self = this;

      return self['$=~'](obj)['$!']()
    }, TMP_Kernel_$B$_3.$$arity = 1);
    
    Opal.def(self, '$===', TMP_Kernel_$eq$eq$eq_4 = function(other) {
      var $a, self = this;

      return ($truthy($a = self.$object_id()['$=='](other.$object_id())) ? $a : self['$=='](other))
    }, TMP_Kernel_$eq$eq$eq_4.$$arity = 1);
    
    Opal.def(self, '$<=>', TMP_Kernel_$lt$eq$gt_5 = function(other) {
      var self = this;

      
      // set guard for infinite recursion
      self.$$comparable = true;

      var x = self['$=='](other);

      if (x && x !== nil) {
        return 0;
      }

      return nil;
    
    }, TMP_Kernel_$lt$eq$gt_5.$$arity = 1);
    
    Opal.def(self, '$method', TMP_Kernel_method_6 = function $$method(name) {
      var self = this;

      
      var meth = self['$' + name];

      if (!meth || meth.$$stub) {
        self.$raise($$($nesting, 'NameError').$new("" + "undefined method `" + (name) + "' for class `" + (self.$class()) + "'", name));
      }

      return $$($nesting, 'Method').$new(self, meth.$$owner || self.$class(), meth, name);
    
    }, TMP_Kernel_method_6.$$arity = 1);
    
    Opal.def(self, '$methods', TMP_Kernel_methods_7 = function $$methods(all) {
      var self = this;

      if (all == null) {
        all = true;
      }
      
      var methods = [];

      for (var key in self) {
        if (key[0] == "$" && typeof(self[key]) === "function") {
          if (all == false || all === nil) {
            if (!Opal.hasOwnProperty.call(self, key)) {
              continue;
            }
          }
          if (self[key].$$stub === undefined) {
            methods.push(key.substr(1));
          }
        }
      }

      return methods;
    
    }, TMP_Kernel_methods_7.$$arity = -1);
    Opal.alias(self, "public_methods", "methods");
    
    Opal.def(self, '$Array', TMP_Kernel_Array_8 = function $$Array(object) {
      var self = this;

      
      var coerced;

      if (object === nil) {
        return [];
      }

      if (object.$$is_array) {
        return object;
      }

      coerced = $$($nesting, 'Opal')['$coerce_to?'](object, $$($nesting, 'Array'), "to_ary");
      if (coerced !== nil) { return coerced; }

      coerced = $$($nesting, 'Opal')['$coerce_to?'](object, $$($nesting, 'Array'), "to_a");
      if (coerced !== nil) { return coerced; }

      return [object];
    
    }, TMP_Kernel_Array_8.$$arity = 1);
    
    Opal.def(self, '$at_exit', TMP_Kernel_at_exit_9 = function $$at_exit() {
      var $a, self = this, $iter = TMP_Kernel_at_exit_9.$$p, block = $iter || nil;
      if ($gvars.__at_exit__ == null) $gvars.__at_exit__ = nil;

      if ($iter) TMP_Kernel_at_exit_9.$$p = null;
      
      $gvars.__at_exit__ = ($truthy($a = $gvars.__at_exit__) ? $a : []);
      return $gvars.__at_exit__['$<<'](block);
    }, TMP_Kernel_at_exit_9.$$arity = 0);
    
    Opal.def(self, '$caller', TMP_Kernel_caller_10 = function $$caller($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      return []
    }, TMP_Kernel_caller_10.$$arity = -1);
    
    Opal.def(self, '$class', TMP_Kernel_class_11 = function() {
      var self = this;

      return self.$$class;
    }, TMP_Kernel_class_11.$$arity = 0);
    
    Opal.def(self, '$copy_instance_variables', TMP_Kernel_copy_instance_variables_12 = function $$copy_instance_variables(other) {
      var self = this;

      
      var keys = Object.keys(other), i, ii, name;
      for (i = 0, ii = keys.length; i < ii; i++) {
        name = keys[i];
        if (name.charAt(0) !== '$' && other.hasOwnProperty(name)) {
          self[name] = other[name];
        }
      }
    
    }, TMP_Kernel_copy_instance_variables_12.$$arity = 1);
    
    Opal.def(self, '$copy_singleton_methods', TMP_Kernel_copy_singleton_methods_13 = function $$copy_singleton_methods(other) {
      var self = this;

      
      var name;

      if (other.hasOwnProperty('$$meta')) {
        var other_singleton_class_proto = Opal.get_singleton_class(other).$$proto;
        var self_singleton_class_proto = Opal.get_singleton_class(self).$$proto;

        for (name in other_singleton_class_proto) {
          if (name.charAt(0) === '$' && other_singleton_class_proto.hasOwnProperty(name)) {
            self_singleton_class_proto[name] = other_singleton_class_proto[name];
          }
        }
      }

      for (name in other) {
        if (name.charAt(0) === '$' && name.charAt(1) !== '$' && other.hasOwnProperty(name)) {
          self[name] = other[name];
        }
      }
    
    }, TMP_Kernel_copy_singleton_methods_13.$$arity = 1);
    
    Opal.def(self, '$clone', TMP_Kernel_clone_14 = function $$clone($kwargs) {
      var self = this, freeze, copy = nil;

      if ($kwargs == null || !$kwargs.$$is_hash) {
        if ($kwargs == null) {
          $kwargs = $hash2([], {});
        } else {
          throw Opal.ArgumentError.$new('expected kwargs');
        }
      }
      freeze = $kwargs.$$smap["freeze"];
      if (freeze == null) {
        freeze = true
      }
      
      copy = self.$class().$allocate();
      copy.$copy_instance_variables(self);
      copy.$copy_singleton_methods(self);
      copy.$initialize_clone(self);
      return copy;
    }, TMP_Kernel_clone_14.$$arity = -1);
    
    Opal.def(self, '$initialize_clone', TMP_Kernel_initialize_clone_15 = function $$initialize_clone(other) {
      var self = this;

      return self.$initialize_copy(other)
    }, TMP_Kernel_initialize_clone_15.$$arity = 1);
    
    Opal.def(self, '$define_singleton_method', TMP_Kernel_define_singleton_method_16 = function $$define_singleton_method(name, method) {
      var self = this, $iter = TMP_Kernel_define_singleton_method_16.$$p, block = $iter || nil;

      if ($iter) TMP_Kernel_define_singleton_method_16.$$p = null;
      return $send(self.$singleton_class(), 'define_method', [name, method], block.$to_proc())
    }, TMP_Kernel_define_singleton_method_16.$$arity = -2);
    
    Opal.def(self, '$dup', TMP_Kernel_dup_17 = function $$dup() {
      var self = this, copy = nil;

      
      copy = self.$class().$allocate();
      copy.$copy_instance_variables(self);
      copy.$initialize_dup(self);
      return copy;
    }, TMP_Kernel_dup_17.$$arity = 0);
    
    Opal.def(self, '$initialize_dup', TMP_Kernel_initialize_dup_18 = function $$initialize_dup(other) {
      var self = this;

      return self.$initialize_copy(other)
    }, TMP_Kernel_initialize_dup_18.$$arity = 1);
    
    Opal.def(self, '$enum_for', TMP_Kernel_enum_for_19 = function $$enum_for(method, $a_rest) {
      var self = this, args, $iter = TMP_Kernel_enum_for_19.$$p, block = $iter || nil;

      if (method == null) {
        method = "each";
      }
      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 1] = arguments[$arg_idx];
      }
      if ($iter) TMP_Kernel_enum_for_19.$$p = null;
      return $send($$($nesting, 'Enumerator'), 'for', [self, method].concat(Opal.to_a(args)), block.$to_proc())
    }, TMP_Kernel_enum_for_19.$$arity = -1);
    Opal.alias(self, "to_enum", "enum_for");
    
    Opal.def(self, '$equal?', TMP_Kernel_equal$q_20 = function(other) {
      var self = this;

      return self === other;
    }, TMP_Kernel_equal$q_20.$$arity = 1);
    
    Opal.def(self, '$exit', TMP_Kernel_exit_21 = function $$exit(status) {
      var $a, self = this, block = nil;
      if ($gvars.__at_exit__ == null) $gvars.__at_exit__ = nil;

      if (status == null) {
        status = true;
      }
      
      $gvars.__at_exit__ = ($truthy($a = $gvars.__at_exit__) ? $a : []);
      while (!($truthy($gvars.__at_exit__['$empty?']()))) {
        
        block = $gvars.__at_exit__.$pop();
        block.$call();
      };
      
      if (status == null) {
        status = 0
      } else if (status.$$is_boolean) {
        status = status ? 0 : 1;
      } else if (status.$$is_number) {
        status = status.$to_i();
      } else {
        status = 0
      }

      Opal.exit(status);
    ;
      return nil;
    }, TMP_Kernel_exit_21.$$arity = -1);
    
    Opal.def(self, '$extend', TMP_Kernel_extend_22 = function $$extend($a_rest) {
      var self = this, mods;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      mods = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        mods[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      
      var singleton = self.$singleton_class();

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          self.$raise($$($nesting, 'TypeError'), "" + "wrong argument type " + ((mod).$class()) + " (expected Module)");
        }

        (mod).$append_features(singleton);
        (mod).$extend_object(self);
        (mod).$extended(self);
      }
    ;
      return self;
    }, TMP_Kernel_extend_22.$$arity = -1);
    
    Opal.def(self, '$format', TMP_Kernel_format_23 = function $$format(format_string, $a_rest) {
      var $b, self = this, args, ary = nil;
      if ($gvars.DEBUG == null) $gvars.DEBUG = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 1;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 1; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 1] = arguments[$arg_idx];
      }
      
      if ($truthy((($b = args.$length()['$=='](1)) ? args['$[]'](0)['$respond_to?']("to_ary") : args.$length()['$=='](1)))) {
        
        ary = $$($nesting, 'Opal')['$coerce_to?'](args['$[]'](0), $$($nesting, 'Array'), "to_ary");
        if ($truthy(ary['$nil?']())) {
        } else {
          args = ary.$to_a()
        };};
      
      var result = '',
          //used for slicing:
          begin_slice = 0,
          end_slice,
          //used for iterating over the format string:
          i,
          len = format_string.length,
          //used for processing field values:
          arg,
          str,
          //used for processing %g and %G fields:
          exponent,
          //used for keeping track of width and precision:
          width,
          precision,
          //used for holding temporary values:
          tmp_num,
          //used for processing %{} and %<> fileds:
          hash_parameter_key,
          closing_brace_char,
          //used for processing %b, %B, %o, %x, and %X fields:
          base_number,
          base_prefix,
          base_neg_zero_regex,
          base_neg_zero_digit,
          //used for processing arguments:
          next_arg,
          seq_arg_num = 1,
          pos_arg_num = 0,
          //used for keeping track of flags:
          flags,
          FNONE  = 0,
          FSHARP = 1,
          FMINUS = 2,
          FPLUS  = 4,
          FZERO  = 8,
          FSPACE = 16,
          FWIDTH = 32,
          FPREC  = 64,
          FPREC0 = 128;

      function CHECK_FOR_FLAGS() {
        if (flags&FWIDTH) { self.$raise($$($nesting, 'ArgumentError'), "flag after width") }
        if (flags&FPREC0) { self.$raise($$($nesting, 'ArgumentError'), "flag after precision") }
      }

      function CHECK_FOR_WIDTH() {
        if (flags&FWIDTH) { self.$raise($$($nesting, 'ArgumentError'), "width given twice") }
        if (flags&FPREC0) { self.$raise($$($nesting, 'ArgumentError'), "width after precision") }
      }

      function GET_NTH_ARG(num) {
        if (num >= args.length) { self.$raise($$($nesting, 'ArgumentError'), "too few arguments") }
        return args[num];
      }

      function GET_NEXT_ARG() {
        switch (pos_arg_num) {
        case -1: self.$raise($$($nesting, 'ArgumentError'), "" + "unnumbered(" + (seq_arg_num) + ") mixed with numbered")
        case -2: self.$raise($$($nesting, 'ArgumentError'), "" + "unnumbered(" + (seq_arg_num) + ") mixed with named")
        }
        pos_arg_num = seq_arg_num++;
        return GET_NTH_ARG(pos_arg_num - 1);
      }

      function GET_POS_ARG(num) {
        if (pos_arg_num > 0) {
          self.$raise($$($nesting, 'ArgumentError'), "" + "numbered(" + (num) + ") after unnumbered(" + (pos_arg_num) + ")")
        }
        if (pos_arg_num === -2) {
          self.$raise($$($nesting, 'ArgumentError'), "" + "numbered(" + (num) + ") after named")
        }
        if (num < 1) {
          self.$raise($$($nesting, 'ArgumentError'), "" + "invalid index - " + (num) + "$")
        }
        pos_arg_num = -1;
        return GET_NTH_ARG(num - 1);
      }

      function GET_ARG() {
        return (next_arg === undefined ? GET_NEXT_ARG() : next_arg);
      }

      function READ_NUM(label) {
        var num, str = '';
        for (;; i++) {
          if (i === len) {
            self.$raise($$($nesting, 'ArgumentError'), "malformed format string - %*[0-9]")
          }
          if (format_string.charCodeAt(i) < 48 || format_string.charCodeAt(i) > 57) {
            i--;
            num = parseInt(str, 10) || 0;
            if (num > 2147483647) {
              self.$raise($$($nesting, 'ArgumentError'), "" + (label) + " too big")
            }
            return num;
          }
          str += format_string.charAt(i);
        }
      }

      function READ_NUM_AFTER_ASTER(label) {
        var arg, num = READ_NUM(label);
        if (format_string.charAt(i + 1) === '$') {
          i++;
          arg = GET_POS_ARG(num);
        } else {
          arg = GET_NEXT_ARG();
        }
        return (arg).$to_int();
      }

      for (i = format_string.indexOf('%'); i !== -1; i = format_string.indexOf('%', i)) {
        str = undefined;

        flags = FNONE;
        width = -1;
        precision = -1;
        next_arg = undefined;

        end_slice = i;

        i++;

        switch (format_string.charAt(i)) {
        case '%':
          begin_slice = i;
        case '':
        case '\n':
        case '\0':
          i++;
          continue;
        }

        format_sequence: for (; i < len; i++) {
          switch (format_string.charAt(i)) {

          case ' ':
            CHECK_FOR_FLAGS();
            flags |= FSPACE;
            continue format_sequence;

          case '#':
            CHECK_FOR_FLAGS();
            flags |= FSHARP;
            continue format_sequence;

          case '+':
            CHECK_FOR_FLAGS();
            flags |= FPLUS;
            continue format_sequence;

          case '-':
            CHECK_FOR_FLAGS();
            flags |= FMINUS;
            continue format_sequence;

          case '0':
            CHECK_FOR_FLAGS();
            flags |= FZERO;
            continue format_sequence;

          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
            tmp_num = READ_NUM('width');
            if (format_string.charAt(i + 1) === '$') {
              if (i + 2 === len) {
                str = '%';
                i++;
                break format_sequence;
              }
              if (next_arg !== undefined) {
                self.$raise($$($nesting, 'ArgumentError'), "" + "value given twice - %" + (tmp_num) + "$")
              }
              next_arg = GET_POS_ARG(tmp_num);
              i++;
            } else {
              CHECK_FOR_WIDTH();
              flags |= FWIDTH;
              width = tmp_num;
            }
            continue format_sequence;

          case '<':
          case '\{':
            closing_brace_char = (format_string.charAt(i) === '<' ? '>' : '\}');
            hash_parameter_key = '';

            i++;

            for (;; i++) {
              if (i === len) {
                self.$raise($$($nesting, 'ArgumentError'), "malformed name - unmatched parenthesis")
              }
              if (format_string.charAt(i) === closing_brace_char) {

                if (pos_arg_num > 0) {
                  self.$raise($$($nesting, 'ArgumentError'), "" + "named " + (hash_parameter_key) + " after unnumbered(" + (pos_arg_num) + ")")
                }
                if (pos_arg_num === -1) {
                  self.$raise($$($nesting, 'ArgumentError'), "" + "named " + (hash_parameter_key) + " after numbered")
                }
                pos_arg_num = -2;

                if (args[0] === undefined || !args[0].$$is_hash) {
                  self.$raise($$($nesting, 'ArgumentError'), "one hash required")
                }

                next_arg = (args[0]).$fetch(hash_parameter_key);

                if (closing_brace_char === '>') {
                  continue format_sequence;
                } else {
                  str = next_arg.toString();
                  if (precision !== -1) { str = str.slice(0, precision); }
                  if (flags&FMINUS) {
                    while (str.length < width) { str = str + ' '; }
                  } else {
                    while (str.length < width) { str = ' ' + str; }
                  }
                  break format_sequence;
                }
              }
              hash_parameter_key += format_string.charAt(i);
            }

          case '*':
            i++;
            CHECK_FOR_WIDTH();
            flags |= FWIDTH;
            width = READ_NUM_AFTER_ASTER('width');
            if (width < 0) {
              flags |= FMINUS;
              width = -width;
            }
            continue format_sequence;

          case '.':
            if (flags&FPREC0) {
              self.$raise($$($nesting, 'ArgumentError'), "precision given twice")
            }
            flags |= FPREC|FPREC0;
            precision = 0;
            i++;
            if (format_string.charAt(i) === '*') {
              i++;
              precision = READ_NUM_AFTER_ASTER('precision');
              if (precision < 0) {
                flags &= ~FPREC;
              }
              continue format_sequence;
            }
            precision = READ_NUM('precision');
            continue format_sequence;

          case 'd':
          case 'i':
          case 'u':
            arg = self.$Integer(GET_ARG());
            if (arg >= 0) {
              str = arg.toString();
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0)) { str = '0' + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              str = (-arg).toString();
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                str = '-' + str;
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - 1) { str = '0' + str; }
                  str = '-' + str;
                } else {
                  str = '-' + str;
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            }
            break format_sequence;

          case 'b':
          case 'B':
          case 'o':
          case 'x':
          case 'X':
            switch (format_string.charAt(i)) {
            case 'b':
            case 'B':
              base_number = 2;
              base_prefix = '0b';
              base_neg_zero_regex = /^1+/;
              base_neg_zero_digit = '1';
              break;
            case 'o':
              base_number = 8;
              base_prefix = '0';
              base_neg_zero_regex = /^3?7+/;
              base_neg_zero_digit = '7';
              break;
            case 'x':
            case 'X':
              base_number = 16;
              base_prefix = '0x';
              base_neg_zero_regex = /^f+/;
              base_neg_zero_digit = 'f';
              break;
            }
            arg = self.$Integer(GET_ARG());
            if (arg >= 0) {
              str = arg.toString(base_number);
              while (str.length < precision) { str = '0' + str; }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && precision === -1) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0) - ((flags&FSHARP && arg !== 0) ? base_prefix.length : 0)) { str = '0' + str; }
                  if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FSHARP && arg !== 0) { str = base_prefix + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              if (flags&FPLUS || flags&FSPACE) {
                str = (-arg).toString(base_number);
                while (str.length < precision) { str = '0' + str; }
                if (flags&FMINUS) {
                  if (flags&FSHARP) { str = base_prefix + str; }
                  str = '-' + str;
                  while (str.length < width) { str = str + ' '; }
                } else {
                  if (flags&FZERO && precision === -1) {
                    while (str.length < width - 1 - (flags&FSHARP ? 2 : 0)) { str = '0' + str; }
                    if (flags&FSHARP) { str = base_prefix + str; }
                    str = '-' + str;
                  } else {
                    if (flags&FSHARP) { str = base_prefix + str; }
                    str = '-' + str;
                    while (str.length < width) { str = ' ' + str; }
                  }
                }
              } else {
                str = (arg >>> 0).toString(base_number).replace(base_neg_zero_regex, base_neg_zero_digit);
                while (str.length < precision - 2) { str = base_neg_zero_digit + str; }
                if (flags&FMINUS) {
                  str = '..' + str;
                  if (flags&FSHARP) { str = base_prefix + str; }
                  while (str.length < width) { str = str + ' '; }
                } else {
                  if (flags&FZERO && precision === -1) {
                    while (str.length < width - 2 - (flags&FSHARP ? base_prefix.length : 0)) { str = base_neg_zero_digit + str; }
                    str = '..' + str;
                    if (flags&FSHARP) { str = base_prefix + str; }
                  } else {
                    str = '..' + str;
                    if (flags&FSHARP) { str = base_prefix + str; }
                    while (str.length < width) { str = ' ' + str; }
                  }
                }
              }
            }
            if (format_string.charAt(i) === format_string.charAt(i).toUpperCase()) {
              str = str.toUpperCase();
            }
            break format_sequence;

          case 'f':
          case 'e':
          case 'E':
          case 'g':
          case 'G':
            arg = self.$Float(GET_ARG());
            if (arg >= 0 || isNaN(arg)) {
              if (arg === Infinity) {
                str = 'Inf';
              } else {
                switch (format_string.charAt(i)) {
                case 'f':
                  str = arg.toFixed(precision === -1 ? 6 : precision);
                  break;
                case 'e':
                case 'E':
                  str = arg.toExponential(precision === -1 ? 6 : precision);
                  break;
                case 'g':
                case 'G':
                  str = arg.toExponential();
                  exponent = parseInt(str.split('e')[1], 10);
                  if (!(exponent < -4 || exponent >= (precision === -1 ? 6 : precision))) {
                    str = arg.toPrecision(precision === -1 ? (flags&FSHARP ? 6 : undefined) : precision);
                  }
                  break;
                }
              }
              if (flags&FMINUS) {
                if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && arg !== Infinity && !isNaN(arg)) {
                  while (str.length < width - ((flags&FPLUS || flags&FSPACE) ? 1 : 0)) { str = '0' + str; }
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                } else {
                  if (flags&FPLUS || flags&FSPACE) { str = (flags&FPLUS ? '+' : ' ') + str; }
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            } else {
              if (arg === -Infinity) {
                str = 'Inf';
              } else {
                switch (format_string.charAt(i)) {
                case 'f':
                  str = (-arg).toFixed(precision === -1 ? 6 : precision);
                  break;
                case 'e':
                case 'E':
                  str = (-arg).toExponential(precision === -1 ? 6 : precision);
                  break;
                case 'g':
                case 'G':
                  str = (-arg).toExponential();
                  exponent = parseInt(str.split('e')[1], 10);
                  if (!(exponent < -4 || exponent >= (precision === -1 ? 6 : precision))) {
                    str = (-arg).toPrecision(precision === -1 ? (flags&FSHARP ? 6 : undefined) : precision);
                  }
                  break;
                }
              }
              if (flags&FMINUS) {
                str = '-' + str;
                while (str.length < width) { str = str + ' '; }
              } else {
                if (flags&FZERO && arg !== -Infinity) {
                  while (str.length < width - 1) { str = '0' + str; }
                  str = '-' + str;
                } else {
                  str = '-' + str;
                  while (str.length < width) { str = ' ' + str; }
                }
              }
            }
            if (format_string.charAt(i) === format_string.charAt(i).toUpperCase() && arg !== Infinity && arg !== -Infinity && !isNaN(arg)) {
              str = str.toUpperCase();
            }
            str = str.replace(/([eE][-+]?)([0-9])$/, '$10$2');
            break format_sequence;

          case 'a':
          case 'A':
            // Not implemented because there are no specs for this field type.
            self.$raise($$($nesting, 'NotImplementedError'), "`A` and `a` format field types are not implemented in Opal yet")

          case 'c':
            arg = GET_ARG();
            if ((arg)['$respond_to?']("to_ary")) { arg = (arg).$to_ary()[0]; }
            if ((arg)['$respond_to?']("to_str")) {
              str = (arg).$to_str();
            } else {
              str = String.fromCharCode($$($nesting, 'Opal').$coerce_to(arg, $$($nesting, 'Integer'), "to_int"));
            }
            if (str.length !== 1) {
              self.$raise($$($nesting, 'ArgumentError'), "%c requires a character")
            }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          case 'p':
            str = (GET_ARG()).$inspect();
            if (precision !== -1) { str = str.slice(0, precision); }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          case 's':
            str = (GET_ARG()).$to_s();
            if (precision !== -1) { str = str.slice(0, precision); }
            if (flags&FMINUS) {
              while (str.length < width) { str = str + ' '; }
            } else {
              while (str.length < width) { str = ' ' + str; }
            }
            break format_sequence;

          default:
            self.$raise($$($nesting, 'ArgumentError'), "" + "malformed format string - %" + (format_string.charAt(i)))
          }
        }

        if (str === undefined) {
          self.$raise($$($nesting, 'ArgumentError'), "malformed format string - %")
        }

        result += format_string.slice(begin_slice, end_slice) + str;
        begin_slice = i + 1;
      }

      if ($gvars.DEBUG && pos_arg_num >= 0 && seq_arg_num < args.length) {
        self.$raise($$($nesting, 'ArgumentError'), "too many arguments for format string")
      }

      return result + format_string.slice(begin_slice);
    ;
    }, TMP_Kernel_format_23.$$arity = -2);
    
    Opal.def(self, '$hash', TMP_Kernel_hash_24 = function $$hash() {
      var self = this;

      return self.$__id__()
    }, TMP_Kernel_hash_24.$$arity = 0);
    
    Opal.def(self, '$initialize_copy', TMP_Kernel_initialize_copy_25 = function $$initialize_copy(other) {
      var self = this;

      return nil
    }, TMP_Kernel_initialize_copy_25.$$arity = 1);
    
    Opal.def(self, '$inspect', TMP_Kernel_inspect_26 = function $$inspect() {
      var self = this;

      return self.$to_s()
    }, TMP_Kernel_inspect_26.$$arity = 0);
    
    Opal.def(self, '$instance_of?', TMP_Kernel_instance_of$q_27 = function(klass) {
      var self = this;

      
      if (!klass.$$is_class && !klass.$$is_module) {
        self.$raise($$($nesting, 'TypeError'), "class or module required");
      }

      return self.$$class === klass;
    
    }, TMP_Kernel_instance_of$q_27.$$arity = 1);
    
    Opal.def(self, '$instance_variable_defined?', TMP_Kernel_instance_variable_defined$q_28 = function(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$instance_variable_name!'](name);
      return Opal.hasOwnProperty.call(self, name.substr(1));;
    }, TMP_Kernel_instance_variable_defined$q_28.$$arity = 1);
    
    Opal.def(self, '$instance_variable_get', TMP_Kernel_instance_variable_get_29 = function $$instance_variable_get(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$instance_variable_name!'](name);
      
      var ivar = self[Opal.ivar(name.substr(1))];

      return ivar == null ? nil : ivar;
    ;
    }, TMP_Kernel_instance_variable_get_29.$$arity = 1);
    
    Opal.def(self, '$instance_variable_set', TMP_Kernel_instance_variable_set_30 = function $$instance_variable_set(name, value) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$instance_variable_name!'](name);
      return self[Opal.ivar(name.substr(1))] = value;;
    }, TMP_Kernel_instance_variable_set_30.$$arity = 2);
    
    Opal.def(self, '$remove_instance_variable', TMP_Kernel_remove_instance_variable_31 = function $$remove_instance_variable(name) {
      var self = this;

      
      name = $$($nesting, 'Opal')['$instance_variable_name!'](name);
      
      var key = Opal.ivar(name.substr(1)),
          val;
      if (self.hasOwnProperty(key)) {
        val = self[key];
        delete self[key];
        return val;
      }
    ;
      return self.$raise($$($nesting, 'NameError'), "" + "instance variable " + (name) + " not defined");
    }, TMP_Kernel_remove_instance_variable_31.$$arity = 1);
    
    Opal.def(self, '$instance_variables', TMP_Kernel_instance_variables_32 = function $$instance_variables() {
      var self = this;

      
      var result = [], ivar;

      for (var name in self) {
        if (self.hasOwnProperty(name) && name.charAt(0) !== '$') {
          if (name.substr(-1) === '$') {
            ivar = name.slice(0, name.length - 1);
          } else {
            ivar = name;
          }
          result.push('@' + ivar);
        }
      }

      return result;
    
    }, TMP_Kernel_instance_variables_32.$$arity = 0);
    
    Opal.def(self, '$Integer', TMP_Kernel_Integer_33 = function $$Integer(value, base) {
      var self = this;

      
      var i, str, base_digits;

      if (!value.$$is_string) {
        if (base !== undefined) {
          self.$raise($$($nesting, 'ArgumentError'), "base specified for non string value")
        }
        if (value === nil) {
          self.$raise($$($nesting, 'TypeError'), "can't convert nil into Integer")
        }
        if (value.$$is_number) {
          if (value === Infinity || value === -Infinity || isNaN(value)) {
            self.$raise($$($nesting, 'FloatDomainError'), value)
          }
          return Math.floor(value);
        }
        if (value['$respond_to?']("to_int")) {
          i = value.$to_int();
          if (i !== nil) {
            return i;
          }
        }
        return $$($nesting, 'Opal')['$coerce_to!'](value, $$($nesting, 'Integer'), "to_i");
      }

      if (value === "0") {
        return 0;
      }

      if (base === undefined) {
        base = 0;
      } else {
        base = $$($nesting, 'Opal').$coerce_to(base, $$($nesting, 'Integer'), "to_int");
        if (base === 1 || base < 0 || base > 36) {
          self.$raise($$($nesting, 'ArgumentError'), "" + "invalid radix " + (base))
        }
      }

      str = value.toLowerCase();

      str = str.replace(/(\d)_(?=\d)/g, '$1');

      str = str.replace(/^(\s*[+-]?)(0[bodx]?)/, function (_, head, flag) {
        switch (flag) {
        case '0b':
          if (base === 0 || base === 2) {
            base = 2;
            return head;
          }
        case '0':
        case '0o':
          if (base === 0 || base === 8) {
            base = 8;
            return head;
          }
        case '0d':
          if (base === 0 || base === 10) {
            base = 10;
            return head;
          }
        case '0x':
          if (base === 0 || base === 16) {
            base = 16;
            return head;
          }
        }
        self.$raise($$($nesting, 'ArgumentError'), "" + "invalid value for Integer(): \"" + (value) + "\"")
      });

      base = (base === 0 ? 10 : base);

      base_digits = '0-' + (base <= 10 ? base - 1 : '9a-' + String.fromCharCode(97 + (base - 11)));

      if (!(new RegExp('^\\s*[+-]?[' + base_digits + ']+\\s*$')).test(str)) {
        self.$raise($$($nesting, 'ArgumentError'), "" + "invalid value for Integer(): \"" + (value) + "\"")
      }

      i = parseInt(str, base);

      if (isNaN(i)) {
        self.$raise($$($nesting, 'ArgumentError'), "" + "invalid value for Integer(): \"" + (value) + "\"")
      }

      return i;
    
    }, TMP_Kernel_Integer_33.$$arity = -2);
    
    Opal.def(self, '$Float', TMP_Kernel_Float_34 = function $$Float(value) {
      var self = this;

      
      var str;

      if (value === nil) {
        self.$raise($$($nesting, 'TypeError'), "can't convert nil into Float")
      }

      if (value.$$is_string) {
        str = value.toString();

        str = str.replace(/(\d)_(?=\d)/g, '$1');

        //Special case for hex strings only:
        if (/^\s*[-+]?0[xX][0-9a-fA-F]+\s*$/.test(str)) {
          return self.$Integer(str);
        }

        if (!/^\s*[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?\s*$/.test(str)) {
          self.$raise($$($nesting, 'ArgumentError'), "" + "invalid value for Float(): \"" + (value) + "\"")
        }

        return parseFloat(str);
      }

      return $$($nesting, 'Opal')['$coerce_to!'](value, $$($nesting, 'Float'), "to_f");
    
    }, TMP_Kernel_Float_34.$$arity = 1);
    
    Opal.def(self, '$Hash', TMP_Kernel_Hash_35 = function $$Hash(arg) {
      var $a, self = this;

      
      if ($truthy(($truthy($a = arg['$nil?']()) ? $a : arg['$==']([])))) {
        return $hash2([], {})};
      if ($truthy($$($nesting, 'Hash')['$==='](arg))) {
        return arg};
      return $$($nesting, 'Opal')['$coerce_to!'](arg, $$($nesting, 'Hash'), "to_hash");
    }, TMP_Kernel_Hash_35.$$arity = 1);
    
    Opal.def(self, '$is_a?', TMP_Kernel_is_a$q_36 = function(klass) {
      var self = this;

      
      if (!klass.$$is_class && !klass.$$is_module) {
        self.$raise($$($nesting, 'TypeError'), "class or module required");
      }

      return Opal.is_a(self, klass);
    
    }, TMP_Kernel_is_a$q_36.$$arity = 1);
    
    Opal.def(self, '$itself', TMP_Kernel_itself_37 = function $$itself() {
      var self = this;

      return self
    }, TMP_Kernel_itself_37.$$arity = 0);
    Opal.alias(self, "kind_of?", "is_a?");
    
    Opal.def(self, '$lambda', TMP_Kernel_lambda_38 = function $$lambda() {
      var self = this, $iter = TMP_Kernel_lambda_38.$$p, block = $iter || nil;

      if ($iter) TMP_Kernel_lambda_38.$$p = null;
      return Opal.lambda(block);
    }, TMP_Kernel_lambda_38.$$arity = 0);
    
    Opal.def(self, '$load', TMP_Kernel_load_39 = function $$load(file) {
      var self = this;

      
      file = $$($nesting, 'Opal')['$coerce_to!'](file, $$($nesting, 'String'), "to_str");
      return Opal.load(file);
    }, TMP_Kernel_load_39.$$arity = 1);
    
    Opal.def(self, '$loop', TMP_Kernel_loop_40 = function $$loop() {
      var TMP_41, $a, self = this, $iter = TMP_Kernel_loop_40.$$p, $yield = $iter || nil, e = nil;

      if ($iter) TMP_Kernel_loop_40.$$p = null;
      
      if (($yield !== nil)) {
      } else {
        return $send(self, 'enum_for', ["loop"], (TMP_41 = function(){var self = TMP_41.$$s || this;

        return $$$($$($nesting, 'Float'), 'INFINITY')}, TMP_41.$$s = self, TMP_41.$$arity = 0, TMP_41))
      };
      while ($truthy(true)) {
        
        try {
          Opal.yieldX($yield, [])
        } catch ($err) {
          if (Opal.rescue($err, [$$($nesting, 'StopIteration')])) {e = $err;
            try {
              return e.$result()
            } finally { Opal.pop_exception() }
          } else { throw $err; }
        };
      };
      return self;
    }, TMP_Kernel_loop_40.$$arity = 0);
    
    Opal.def(self, '$nil?', TMP_Kernel_nil$q_42 = function() {
      var self = this;

      return false
    }, TMP_Kernel_nil$q_42.$$arity = 0);
    Opal.alias(self, "object_id", "__id__");
    
    Opal.def(self, '$printf', TMP_Kernel_printf_43 = function $$printf($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      if ($truthy(args['$any?']())) {
        self.$print($send(self, 'format', Opal.to_a(args)))};
      return nil;
    }, TMP_Kernel_printf_43.$$arity = -1);
    
    Opal.def(self, '$proc', TMP_Kernel_proc_44 = function $$proc() {
      var self = this, $iter = TMP_Kernel_proc_44.$$p, block = $iter || nil;

      if ($iter) TMP_Kernel_proc_44.$$p = null;
      
      if ($truthy(block)) {
      } else {
        self.$raise($$($nesting, 'ArgumentError'), "tried to create Proc object without a block")
      };
      block.$$is_lambda = false;
      return block;
    }, TMP_Kernel_proc_44.$$arity = 0);
    
    Opal.def(self, '$puts', TMP_Kernel_puts_45 = function $$puts($a_rest) {
      var self = this, strs;
      if ($gvars.stdout == null) $gvars.stdout = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      strs = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        strs[$arg_idx - 0] = arguments[$arg_idx];
      }
      return $send($gvars.stdout, 'puts', Opal.to_a(strs))
    }, TMP_Kernel_puts_45.$$arity = -1);
    
    Opal.def(self, '$p', TMP_Kernel_p_47 = function $$p($a_rest) {
      var TMP_46, self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      $send(args, 'each', [], (TMP_46 = function(obj){var self = TMP_46.$$s || this;
        if ($gvars.stdout == null) $gvars.stdout = nil;
if (obj == null) obj = nil;
      return $gvars.stdout.$puts(obj.$inspect())}, TMP_46.$$s = self, TMP_46.$$arity = 1, TMP_46));
      if ($truthy($rb_le(args.$length(), 1))) {
        return args['$[]'](0)
      } else {
        return args
      };
    }, TMP_Kernel_p_47.$$arity = -1);
    
    Opal.def(self, '$print', TMP_Kernel_print_48 = function $$print($a_rest) {
      var self = this, strs;
      if ($gvars.stdout == null) $gvars.stdout = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      strs = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        strs[$arg_idx - 0] = arguments[$arg_idx];
      }
      return $send($gvars.stdout, 'print', Opal.to_a(strs))
    }, TMP_Kernel_print_48.$$arity = -1);
    
    Opal.def(self, '$warn', TMP_Kernel_warn_49 = function $$warn($a_rest) {
      var $b, self = this, strs;
      if ($gvars.VERBOSE == null) $gvars.VERBOSE = nil;
      if ($gvars.stderr == null) $gvars.stderr = nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      strs = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        strs[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($truthy(($truthy($b = $gvars.VERBOSE['$nil?']()) ? $b : strs['$empty?']()))) {
        return nil
      } else {
        return $send($gvars.stderr, 'puts', Opal.to_a(strs))
      }
    }, TMP_Kernel_warn_49.$$arity = -1);
    
    Opal.def(self, '$raise', TMP_Kernel_raise_50 = function $$raise(exception, string, _backtrace) {
      var self = this;
      if ($gvars["!"] == null) $gvars["!"] = nil;

      if (string == null) {
        string = nil;
      }
      if (_backtrace == null) {
        _backtrace = nil;
      }
      
      if (exception == null && $gvars["!"] !== nil) {
        throw $gvars["!"];
      }
      if (exception == null) {
        exception = $$($nesting, 'RuntimeError').$new();
      }
      else if (exception.$$is_string) {
        exception = $$($nesting, 'RuntimeError').$new(exception);
      }
      // using respond_to? and not an undefined check to avoid method_missing matching as true
      else if (exception.$$is_class && exception['$respond_to?']("exception")) {
        exception = exception.$exception(string);
      }
      else if (exception['$is_a?']($$($nesting, 'Exception'))) {
        // exception is fine
      }
      else {
        exception = $$($nesting, 'TypeError').$new("exception class/object expected");
      }

      if ($gvars["!"] !== nil) {
        Opal.exceptions.push($gvars["!"]);
      }

      $gvars["!"] = exception;

      throw exception;
    
    }, TMP_Kernel_raise_50.$$arity = -1);
    Opal.alias(self, "fail", "raise");
    
    Opal.def(self, '$rand', TMP_Kernel_rand_51 = function $$rand(max) {
      var self = this;

      
      
      if (max === undefined) {
        return $$$($$($nesting, 'Random'), 'DEFAULT').$rand();
      }

      if (max.$$is_number) {
        if (max < 0) {
          max = Math.abs(max);
        }

        if (max % 1 !== 0) {
          max = max.$to_i();
        }

        if (max === 0) {
          max = undefined;
        }
      }
    ;
      return $$$($$($nesting, 'Random'), 'DEFAULT').$rand(max);
    }, TMP_Kernel_rand_51.$$arity = -1);
    
    Opal.def(self, '$respond_to?', TMP_Kernel_respond_to$q_52 = function(name, include_all) {
      var self = this;

      if (include_all == null) {
        include_all = false;
      }
      
      if ($truthy(self['$respond_to_missing?'](name, include_all))) {
        return true};
      
      var body = self['$' + name];

      if (typeof(body) === "function" && !body.$$stub) {
        return true;
      }
    ;
      return false;
    }, TMP_Kernel_respond_to$q_52.$$arity = -2);
    
    Opal.def(self, '$respond_to_missing?', TMP_Kernel_respond_to_missing$q_53 = function(method_name, include_all) {
      var self = this;

      if (include_all == null) {
        include_all = false;
      }
      return false
    }, TMP_Kernel_respond_to_missing$q_53.$$arity = -2);
    
    Opal.def(self, '$require', TMP_Kernel_require_54 = function $$require(file) {
      var self = this;

      
      file = $$($nesting, 'Opal')['$coerce_to!'](file, $$($nesting, 'String'), "to_str");
      return Opal.require(file);
    }, TMP_Kernel_require_54.$$arity = 1);
    
    Opal.def(self, '$require_relative', TMP_Kernel_require_relative_55 = function $$require_relative(file) {
      var self = this;

      
      $$($nesting, 'Opal')['$try_convert!'](file, $$($nesting, 'String'), "to_str");
      file = $$($nesting, 'File').$expand_path($$($nesting, 'File').$join(Opal.current_file, "..", file));
      return Opal.require(file);
    }, TMP_Kernel_require_relative_55.$$arity = 1);
    
    Opal.def(self, '$require_tree', TMP_Kernel_require_tree_56 = function $$require_tree(path) {
      var self = this;

      
      var result = [];

      path = $$($nesting, 'File').$expand_path(path)
      path = Opal.normalize(path);
      if (path === '.') path = '';
      for (var name in Opal.modules) {
        if ((name)['$start_with?'](path)) {
          result.push([name, Opal.require(name)]);
        }
      }

      return result;
    
    }, TMP_Kernel_require_tree_56.$$arity = 1);
    Opal.alias(self, "send", "__send__");
    Opal.alias(self, "public_send", "__send__");
    
    Opal.def(self, '$singleton_class', TMP_Kernel_singleton_class_57 = function $$singleton_class() {
      var self = this;

      return Opal.get_singleton_class(self);
    }, TMP_Kernel_singleton_class_57.$$arity = 0);
    
    Opal.def(self, '$sleep', TMP_Kernel_sleep_58 = function $$sleep(seconds) {
      var self = this;

      if (seconds == null) {
        seconds = nil;
      }
      
      if (seconds === nil) {
        self.$raise($$($nesting, 'TypeError'), "can't convert NilClass into time interval")
      }
      if (!seconds.$$is_number) {
        self.$raise($$($nesting, 'TypeError'), "" + "can't convert " + (seconds.$class()) + " into time interval")
      }
      if (seconds < 0) {
        self.$raise($$($nesting, 'ArgumentError'), "time interval must be positive")
      }
      var get_time = Opal.global.performance ?
        function() {return performance.now()} :
        function() {return new Date()}

      var t = get_time();
      while (get_time() - t <= seconds * 1000);
      return seconds;
    
    }, TMP_Kernel_sleep_58.$$arity = -1);
    Opal.alias(self, "sprintf", "format");
    
    Opal.def(self, '$srand', TMP_Kernel_srand_59 = function $$srand(seed) {
      var self = this;

      if (seed == null) {
        seed = $$($nesting, 'Random').$new_seed();
      }
      return $$($nesting, 'Random').$srand(seed)
    }, TMP_Kernel_srand_59.$$arity = -1);
    
    Opal.def(self, '$String', TMP_Kernel_String_60 = function $$String(str) {
      var $a, self = this;

      return ($truthy($a = $$($nesting, 'Opal')['$coerce_to?'](str, $$($nesting, 'String'), "to_str")) ? $a : $$($nesting, 'Opal')['$coerce_to!'](str, $$($nesting, 'String'), "to_s"))
    }, TMP_Kernel_String_60.$$arity = 1);
    
    Opal.def(self, '$tap', TMP_Kernel_tap_61 = function $$tap() {
      var self = this, $iter = TMP_Kernel_tap_61.$$p, block = $iter || nil;

      if ($iter) TMP_Kernel_tap_61.$$p = null;
      
      Opal.yield1(block, self);
      return self;
    }, TMP_Kernel_tap_61.$$arity = 0);
    
    Opal.def(self, '$to_proc', TMP_Kernel_to_proc_62 = function $$to_proc() {
      var self = this;

      return self
    }, TMP_Kernel_to_proc_62.$$arity = 0);
    
    Opal.def(self, '$to_s', TMP_Kernel_to_s_63 = function $$to_s() {
      var self = this;

      return "" + "#<" + (self.$class()) + ":0x" + (self.$__id__().$to_s(16)) + ">"
    }, TMP_Kernel_to_s_63.$$arity = 0);
    
    Opal.def(self, '$catch', TMP_Kernel_catch_64 = function(sym) {
      var self = this, $iter = TMP_Kernel_catch_64.$$p, $yield = $iter || nil, e = nil;

      if ($iter) TMP_Kernel_catch_64.$$p = null;
      try {
        return Opal.yieldX($yield, []);
      } catch ($err) {
        if (Opal.rescue($err, [$$($nesting, 'UncaughtThrowError')])) {e = $err;
          try {
            
            if (e.$sym()['$=='](sym)) {
              return e.$arg()};
            return self.$raise();
          } finally { Opal.pop_exception() }
        } else { throw $err; }
      }
    }, TMP_Kernel_catch_64.$$arity = 1);
    
    Opal.def(self, '$throw', TMP_Kernel_throw_65 = function($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      return self.$raise($$($nesting, 'UncaughtThrowError'), args)
    }, TMP_Kernel_throw_65.$$arity = -1);
    
    Opal.def(self, '$open', TMP_Kernel_open_66 = function $$open($a_rest) {
      var self = this, args, $iter = TMP_Kernel_open_66.$$p, block = $iter || nil;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      if ($iter) TMP_Kernel_open_66.$$p = null;
      return $send($$($nesting, 'File'), 'open', Opal.to_a(args), block.$to_proc())
    }, TMP_Kernel_open_66.$$arity = -1);
    
    Opal.def(self, '$yield_self', TMP_Kernel_yield_self_67 = function $$yield_self() {
      var TMP_68, self = this, $iter = TMP_Kernel_yield_self_67.$$p, $yield = $iter || nil;

      if ($iter) TMP_Kernel_yield_self_67.$$p = null;
      
      if (($yield !== nil)) {
      } else {
        return $send(self, 'enum_for', ["yield_self"], (TMP_68 = function(){var self = TMP_68.$$s || this;

        return 1}, TMP_68.$$s = self, TMP_68.$$arity = 0, TMP_68))
      };
      return Opal.yield1($yield, self);;
    }, TMP_Kernel_yield_self_67.$$arity = 0);
  })($nesting[0], $nesting);
  return (function($base, $super, $parent_nesting) {
    function $Object(){};
    var self = $Object = $klass($base, $super, 'Object', $Object);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return self.$include($$($nesting, 'Kernel'))
  })($nesting[0], null, $nesting);
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/error"] = function(Opal) {
  function $rb_plus(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs + rhs : lhs['$+'](rhs);
  }
  function $rb_gt(lhs, rhs) {
    return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs > rhs : lhs['$>'](rhs);
  }
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $klass = Opal.klass, $send = Opal.send, $truthy = Opal.truthy, $module = Opal.module, $hash2 = Opal.hash2;

  Opal.add_stubs(['$new', '$clone', '$to_s', '$empty?', '$class', '$+', '$attr_reader', '$[]', '$>', '$length', '$inspect', '$raise']);
  
  (function($base, $super, $parent_nesting) {
    function $Exception(){};
    var self = $Exception = $klass($base, $super, 'Exception', $Exception);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_Exception_new_1, TMP_Exception_exception_2, TMP_Exception_initialize_3, TMP_Exception_backtrace_4, TMP_Exception_exception_5, TMP_Exception_message_6, TMP_Exception_inspect_7, TMP_Exception_to_s_8;

    def.message = nil;
    
    var stack_trace_limit;
    Opal.defs(self, '$new', TMP_Exception_new_1 = function($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      
      var message   = (args.length > 0) ? args[0] : nil;
      var error     = new self.$$alloc(message);
      error.name    = self.$$name;
      error.message = message;
      Opal.send(error, error.$initialize, args);

      // Error.captureStackTrace() will use .name and .toString to build the
      // first line of the stack trace so it must be called after the error
      // has been initialized.
      // https://nodejs.org/dist/latest-v6.x/docs/api/errors.html
      if (Opal.config.enable_stack_trace && Error.captureStackTrace) {
        // Passing Kernel.raise will cut the stack trace from that point above
        Error.captureStackTrace(error, stack_trace_limit);
      }

      return error;
    
    }, TMP_Exception_new_1.$$arity = -1);
    stack_trace_limit = self.$new;
    Opal.defs(self, '$exception', TMP_Exception_exception_2 = function $$exception($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      return $send(self, 'new', Opal.to_a(args))
    }, TMP_Exception_exception_2.$$arity = -1);
    
    Opal.def(self, '$initialize', TMP_Exception_initialize_3 = function $$initialize($a_rest) {
      var self = this, args;

      var $args_len = arguments.length, $rest_len = $args_len - 0;
      if ($rest_len < 0) { $rest_len = 0; }
      args = new Array($rest_len);
      for (var $arg_idx = 0; $arg_idx < $args_len; $arg_idx++) {
        args[$arg_idx - 0] = arguments[$arg_idx];
      }
      return self.message = (args.length > 0) ? args[0] : nil;
    }, TMP_Exception_initialize_3.$$arity = -1);
    
    Opal.def(self, '$backtrace', TMP_Exception_backtrace_4 = function $$backtrace() {
      var self = this;

      
      var backtrace = self.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\n").slice(0, 15);
      }
      else if (backtrace) {
        return backtrace.slice(0, 15);
      }

      return [];
    
    }, TMP_Exception_backtrace_4.$$arity = 0);
    
    Opal.def(self, '$exception', TMP_Exception_exception_5 = function $$exception(str) {
      var self = this;

      if (str == null) {
        str = nil;
      }
      
      if (str === nil || self === str) {
        return self;
      }

      var cloned = self.$clone();
      cloned.message = str;
      return cloned;
    
    }, TMP_Exception_exception_5.$$arity = -1);
    
    Opal.def(self, '$message', TMP_Exception_message_6 = function $$message() {
      var self = this;

      return self.$to_s()
    }, TMP_Exception_message_6.$$arity = 0);
    
    Opal.def(self, '$inspect', TMP_Exception_inspect_7 = function $$inspect() {
      var self = this, as_str = nil;

      
      as_str = self.$to_s();
      if ($truthy(as_str['$empty?']())) {
        return self.$class().$to_s()
      } else {
        return "" + "#<" + (self.$class().$to_s()) + ": " + (self.$to_s()) + ">"
      };
    }, TMP_Exception_inspect_7.$$arity = 0);
    return (Opal.def(self, '$to_s', TMP_Exception_to_s_8 = function $$to_s() {
      var $a, $b, self = this;

      return ($truthy($a = ($truthy($b = self.message) ? self.message.$to_s() : $b)) ? $a : self.$class().$to_s())
    }, TMP_Exception_to_s_8.$$arity = 0), nil) && 'to_s';
  })($nesting[0], Error, $nesting);
  (function($base, $super, $parent_nesting) {
    function $ScriptError(){};
    var self = $ScriptError = $klass($base, $super, 'ScriptError', $ScriptError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $SyntaxError(){};
    var self = $SyntaxError = $klass($base, $super, 'SyntaxError', $SyntaxError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'ScriptError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $LoadError(){};
    var self = $LoadError = $klass($base, $super, 'LoadError', $LoadError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'ScriptError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $NotImplementedError(){};
    var self = $NotImplementedError = $klass($base, $super, 'NotImplementedError', $NotImplementedError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'ScriptError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $SystemExit(){};
    var self = $SystemExit = $klass($base, $super, 'SystemExit', $SystemExit);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $NoMemoryError(){};
    var self = $NoMemoryError = $klass($base, $super, 'NoMemoryError', $NoMemoryError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $SignalException(){};
    var self = $SignalException = $klass($base, $super, 'SignalException', $SignalException);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $Interrupt(){};
    var self = $Interrupt = $klass($base, $super, 'Interrupt', $Interrupt);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $SecurityError(){};
    var self = $SecurityError = $klass($base, $super, 'SecurityError', $SecurityError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $StandardError(){};
    var self = $StandardError = $klass($base, $super, 'StandardError', $StandardError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $EncodingError(){};
    var self = $EncodingError = $klass($base, $super, 'EncodingError', $EncodingError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $ZeroDivisionError(){};
    var self = $ZeroDivisionError = $klass($base, $super, 'ZeroDivisionError', $ZeroDivisionError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $NameError(){};
    var self = $NameError = $klass($base, $super, 'NameError', $NameError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $NoMethodError(){};
    var self = $NoMethodError = $klass($base, $super, 'NoMethodError', $NoMethodError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'NameError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $RuntimeError(){};
    var self = $RuntimeError = $klass($base, $super, 'RuntimeError', $RuntimeError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $FrozenError(){};
    var self = $FrozenError = $klass($base, $super, 'FrozenError', $FrozenError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'RuntimeError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $LocalJumpError(){};
    var self = $LocalJumpError = $klass($base, $super, 'LocalJumpError', $LocalJumpError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $TypeError(){};
    var self = $TypeError = $klass($base, $super, 'TypeError', $TypeError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $ArgumentError(){};
    var self = $ArgumentError = $klass($base, $super, 'ArgumentError', $ArgumentError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $IndexError(){};
    var self = $IndexError = $klass($base, $super, 'IndexError', $IndexError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $StopIteration(){};
    var self = $StopIteration = $klass($base, $super, 'StopIteration', $StopIteration);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'IndexError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $KeyError(){};
    var self = $KeyError = $klass($base, $super, 'KeyError', $KeyError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'IndexError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $RangeError(){};
    var self = $RangeError = $klass($base, $super, 'RangeError', $RangeError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $FloatDomainError(){};
    var self = $FloatDomainError = $klass($base, $super, 'FloatDomainError', $FloatDomainError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'RangeError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $IOError(){};
    var self = $IOError = $klass($base, $super, 'IOError', $IOError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $SystemCallError(){};
    var self = $SystemCallError = $klass($base, $super, 'SystemCallError', $SystemCallError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$($nesting, 'StandardError'), $nesting);
  (function($base, $parent_nesting) {
    var $Errno, self = $Errno = $module($base, 'Errno');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    (function($base, $super, $parent_nesting) {
      function $EINVAL(){};
      var self = $EINVAL = $klass($base, $super, 'EINVAL', $EINVAL);

      var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_EINVAL_new_9;

      return (Opal.defs(self, '$new', TMP_EINVAL_new_9 = function(name) {
        var self = this, $iter = TMP_EINVAL_new_9.$$p, $yield = $iter || nil, message = nil;

        if (name == null) {
          name = nil;
        }
        if ($iter) TMP_EINVAL_new_9.$$p = null;
        
        message = "Invalid argument";
        if ($truthy(name)) {
          message = $rb_plus(message, "" + " - " + (name))};
        return $send(self, Opal.find_super_dispatcher(self, 'new', TMP_EINVAL_new_9, false, $EINVAL), [message], null);
      }, TMP_EINVAL_new_9.$$arity = -1), nil) && 'new'
    })($nesting[0], $$($nesting, 'SystemCallError'), $nesting)
  })($nesting[0], $nesting);
  (function($base, $super, $parent_nesting) {
    function $UncaughtThrowError(){};
    var self = $UncaughtThrowError = $klass($base, $super, 'UncaughtThrowError', $UncaughtThrowError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_UncaughtThrowError_initialize_10;

    def.sym = nil;
    
    self.$attr_reader("sym", "arg");
    return (Opal.def(self, '$initialize', TMP_UncaughtThrowError_initialize_10 = function $$initialize(args) {
      var self = this, $iter = TMP_UncaughtThrowError_initialize_10.$$p, $yield = $iter || nil;

      if ($iter) TMP_UncaughtThrowError_initialize_10.$$p = null;
      
      self.sym = args['$[]'](0);
      if ($truthy($rb_gt(args.$length(), 1))) {
        self.arg = args['$[]'](1)};
      return $send(self, Opal.find_super_dispatcher(self, 'initialize', TMP_UncaughtThrowError_initialize_10, false), ["" + "uncaught throw " + (self.sym.$inspect())], null);
    }, TMP_UncaughtThrowError_initialize_10.$$arity = 1), nil) && 'initialize';
  })($nesting[0], $$($nesting, 'ArgumentError'), $nesting);
  (function($base, $super, $parent_nesting) {
    function $NameError(){};
    var self = $NameError = $klass($base, $super, 'NameError', $NameError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_NameError_initialize_11;

    
    self.$attr_reader("name");
    return (Opal.def(self, '$initialize', TMP_NameError_initialize_11 = function $$initialize(message, name) {
      var self = this, $iter = TMP_NameError_initialize_11.$$p, $yield = $iter || nil;

      if (name == null) {
        name = nil;
      }
      if ($iter) TMP_NameError_initialize_11.$$p = null;
      
      $send(self, Opal.find_super_dispatcher(self, 'initialize', TMP_NameError_initialize_11, false), [message], null);
      return (self.name = name);
    }, TMP_NameError_initialize_11.$$arity = -2), nil) && 'initialize';
  })($nesting[0], null, $nesting);
  (function($base, $super, $parent_nesting) {
    function $NoMethodError(){};
    var self = $NoMethodError = $klass($base, $super, 'NoMethodError', $NoMethodError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_NoMethodError_initialize_12;

    
    self.$attr_reader("args");
    return (Opal.def(self, '$initialize', TMP_NoMethodError_initialize_12 = function $$initialize(message, name, args) {
      var self = this, $iter = TMP_NoMethodError_initialize_12.$$p, $yield = $iter || nil;

      if (name == null) {
        name = nil;
      }
      if (args == null) {
        args = [];
      }
      if ($iter) TMP_NoMethodError_initialize_12.$$p = null;
      
      $send(self, Opal.find_super_dispatcher(self, 'initialize', TMP_NoMethodError_initialize_12, false), [message, name], null);
      return (self.args = args);
    }, TMP_NoMethodError_initialize_12.$$arity = -2), nil) && 'initialize';
  })($nesting[0], null, $nesting);
  (function($base, $super, $parent_nesting) {
    function $StopIteration(){};
    var self = $StopIteration = $klass($base, $super, 'StopIteration', $StopIteration);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    return self.$attr_reader("result")
  })($nesting[0], null, $nesting);
  (function($base, $super, $parent_nesting) {
    function $KeyError(){};
    var self = $KeyError = $klass($base, $super, 'KeyError', $KeyError);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_KeyError_initialize_13, TMP_KeyError_receiver_14, TMP_KeyError_key_15;

    def.receiver = def.key = nil;
    
    
    Opal.def(self, '$initialize', TMP_KeyError_initialize_13 = function $$initialize(message, $kwargs) {
      var self = this, receiver, key, $iter = TMP_KeyError_initialize_13.$$p, $yield = $iter || nil;

      if ($kwargs == null || !$kwargs.$$is_hash) {
        if ($kwargs == null) {
          $kwargs = $hash2([], {});
        } else {
          throw Opal.ArgumentError.$new('expected kwargs');
        }
      }
      receiver = $kwargs.$$smap["receiver"];
      if (receiver == null) {
        receiver = nil
      }
      key = $kwargs.$$smap["key"];
      if (key == null) {
        key = nil
      }
      if ($iter) TMP_KeyError_initialize_13.$$p = null;
      
      $send(self, Opal.find_super_dispatcher(self, 'initialize', TMP_KeyError_initialize_13, false), [message], null);
      self.receiver = receiver;
      return (self.key = key);
    }, TMP_KeyError_initialize_13.$$arity = -2);
    
    Opal.def(self, '$receiver', TMP_KeyError_receiver_14 = function $$receiver() {
      var $a, self = this;

      return ($truthy($a = self.receiver) ? $a : self.$raise($$($nesting, 'ArgumentError'), "no receiver is available"))
    }, TMP_KeyError_receiver_14.$$arity = 0);
    return (Opal.def(self, '$key', TMP_KeyError_key_15 = function $$key() {
      var $a, self = this;

      return ($truthy($a = self.key) ? $a : self.$raise($$($nesting, 'ArgumentError'), "no key is available"))
    }, TMP_KeyError_key_15.$$arity = 0), nil) && 'key';
  })($nesting[0], null, $nesting);
  return (function($base, $parent_nesting) {
    var $JS, self = $JS = $module($base, 'JS');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting);

    (function($base, $super, $parent_nesting) {
      function $Error(){};
      var self = $Error = $klass($base, $super, 'Error', $Error);

      var def = self.$$proto, $nesting = [self].concat($parent_nesting);

      return nil
    })($nesting[0], null, $nesting)
  })($nesting[0], $nesting);
};

/* Generated by Opal 0.11.1.dev */
Opal.modules["corelib/constants"] = function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice;

  
  Opal.const_set($nesting[0], 'RUBY_PLATFORM', "opal");
  Opal.const_set($nesting[0], 'RUBY_ENGINE', "opal");
  Opal.const_set($nesting[0], 'RUBY_VERSION', "2.5.0");
  Opal.const_set($nesting[0], 'RUBY_ENGINE_VERSION', "0.11.1.dev");
  Opal.const_set($nesting[0], 'RUBY_RELEASE_DATE', "2018-03-06");
  Opal.const_set($nesting[0], 'RUBY_PATCHLEVEL', 0);
  Opal.const_set($nesting[0], 'RUBY_REVISION', 0);
  Opal.const_set($nesting[0], 'RUBY_COPYRIGHT', "opal - Copyright (C) 2013-2015 Adam Beynon");
  return Opal.const_set($nesting[0], 'RUBY_DESCRIPTION', "" + "opal " + ($$($nesting, 'RUBY_ENGINE_VERSION')) + " (" + ($$($nesting, 'RUBY_RELEASE_DATE')) + " revision " + ($$($nesting, 'RUBY_REVISION')) + ")");
};

/* Generated by Opal 0.11.1.dev */
(function(Opal) {
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.const_get_qualified, $$ = Opal.const_get_relative, $breaker = Opal.breaker, $slice = Opal.slice, $module = Opal.module, $klass = Opal.klass;

  Opal.add_stubs(['$require', '$include']);
  
  
  self.$require("corelib/runtime");
  self.$require("corelib/helpers");
  self.$require("corelib/module");
  self.$require("corelib/class");
  self.$require("corelib/basic_object");
  self.$require("corelib/kernel");
  self.$require("corelib/error");
  self.$require("corelib/constants");;
  (function($base, $parent_nesting) {
    var $M1, self = $M1 = $module($base, 'M1');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_M1_from_included_module_1;

    
    Opal.def(self, '$from_included_module', TMP_M1_from_included_module_1 = function $$from_included_module() {
      var self = this;

      return nil
    }, TMP_M1_from_included_module_1.$$arity = 0)
  })($nesting[0], $nesting);
  (function($base, $super, $parent_nesting) {
    function $BasicObject(){};
    var self = $BasicObject = $klass($base, $super, 'BasicObject', $BasicObject);

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_BasicObject_basic_object_2;

    
    self.$include($$$('::', 'M1'));
    return (Opal.def(self, '$basic_object', TMP_BasicObject_basic_object_2 = function $$basic_object() {
      var self = this;

      return nil
    }, TMP_BasicObject_basic_object_2.$$arity = 0), nil) && 'basic_object';
  })($nesting[0], null, $nesting);
  (function($base, $parent_nesting) {
    var $M1, self = $M1 = $module($base, 'M1');

    var def = self.$$proto, $nesting = [self].concat($parent_nesting), TMP_M1_from_included_module2_3;

    
    Opal.def(self, '$from_included_module2', TMP_M1_from_included_module2_3 = function $$from_included_module2() {
      var self = this;

      return nil
    }, TMP_M1_from_included_module2_3.$$arity = 0)
  })($nesting[0], $nesting);
  
  console.log("Opal:");
  return console.log(Opal.BasicObject.$$proto.$$methods.sort());;;
})(Opal);
