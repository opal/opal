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
  var bridges = {};

  // TopScope is used for inheriting constants from the top scope
  var TopScope = function(){};

  // Opal just acts as the top scope
  TopScope.prototype = Opal;

  // To inherit scopes
  Opal.constructor = TopScope;

  // List top scope constants
  Opal.constants = [];

  // This is a useful reference to global object inside ruby files
  Opal.global = global_object;
  global_object.Opal = Opal;

  // Configure runtime behavior with regards to require and unsupported fearures
  Opal.config = {
    missing_require_severity: 'error', // error, warning, ignore
    unsupported_features_severity: 'warning' // error, warning, ignore
  }

  // Minify common function calls
  var $hasOwn = Opal.hasOwnProperty;
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
    return obj.$$id || (obj.$$id = Opal.uid());
  };

  // Table holds all class variables
  Opal.cvars = {};

  // Globals table
  Opal.gvars = {};

  // Exit function, this should be replaced by platform specific implementation
  // (See nodejs and phantom for examples)
  Opal.exit = function(status) { if (Opal.gvars.DEBUG) console.log('Exited with status '+status); };

  // keeps track of exceptions for $!
  Opal.exceptions = [];

  // @private
  // Pops an exception from the stack and updates `$!`.
  Opal.pop_exception = function() {
    Opal.gvars["!"] = Opal.exceptions.pop() || nil;
  }


  // Constants
  // ---------

  // Get a constant on the given scope. Every class and module in Opal has a
  // scope used to store, and inherit, constants. For example, the top level
  // `Object` in ruby has a scope accessible as `Opal.Object.$$scope`.
  //
  // To get the `Array` class using this scope, you could use:
  //
  //     Opal.Object.$$scope.get("Array")
  //
  // If a constant with the given name cannot be found, then a dispatch to the
  // class/module's `#const_missing` is called, which by default will raise an
  // error.
  //
  // @param name [String] the name of the constant to lookup
  // @return [Object]
  //
  Opal.get = function(const_name) {
    return Opal.const_get([this], const_name, true, true);
  }

  function constGetSingle(scope, const_name, inherit) {
    var scopes = [scope],
        module = scope.base;

    if (inherit || module == Opal.Object) {
      var parent = module.$$super;

      while (parent !== Opal.BasicObject && parent !== Opal.Object) {
        scopes.push(parent.$$scope);

        parent = parent.$$super;
      }
    }

    for (var i = 0, length = scopes.length; i < length; i++) {
      if (scopes[i].hasOwnProperty(const_name)) {
        return scopes[i][const_name];
      }
    }
  }

  function constGetTopLevel(const_name) {
    var global_scope = Opal.Object.$$scope;

    if (global_scope.hasOwnProperty(const_name)) {
      return global_scope[const_name];
    }
  }

  function constGetMultiple(scopes, const_name, inherit) {
    var length = scopes.length,
        last_scope = scopes[length - 1],
        i, scope, result;

    for (i = length - 1; i >= 0; i--) {
      var scope_or_singleton_class = scopes[i];

      if (scope_or_singleton_class.$$is_singleton) {
        scope = scope_or_singleton_class.$$scope;

        if (scope_or_singleton_class === last_scope) {
          // If we perform a constant lookup directly in the metaclass
          // then we should look into its ancestors (inherit = true)
          inherit = true;
        } else {
          // Otherwise we are looking for a constant declared in the
          // normal scope (class/module) which was declared in the metaclass
          // @example
          //   class << obj
          //     module M
          //       CONST
          //     end
          //   end
          // In this case we shouldn't look into metaclass ancestors
          inherit = false;
        }
      } else {
        // We are in the regular class/module scope
        scope = scope_or_singleton_class;
        // Leaving requested inherit value from parameters
      }

      if (scope.hasOwnProperty(const_name)) {
        result = scope[const_name];
      }

      if (result != null) {
        return result;
      }

      result = constGetSingle(scope, const_name, inherit);

      if (result != null) {
        return result;
      }
    }
  }

  // Finds and returns a constant in the provided list of scopes.
  // When you open a class/module/singleton class, Opal collects
  // scopes in the $scopes array. When you try to resolve
  // a constant Opal.const_get is used to get it.
  //
  // To simply find a constant directly in the single scope:
  //
  //     Opal.const_get([scope], const_name)
  //
  // To search in parents:
  //
  //     Opal.const_get(scopes, const_name, true)
  //
  // To throw an error if nothing was found:
  //
  //     Opal.const_get(scopes, const_name, inherit, true)
  //
  // @param scopes [Array<$$scope>] a list of scopes
  // @param const_name [String] the name of the constant
  // @param inherit [Boolean] flag to perform a search in the parents
  // @param raise [Boolean] flag to trigger "const_missing" if nothing was found
  // @return [Object]
  Opal.const_get = function(scopes, const_name, inherit, raise) {
    var result = constGetMultiple(scopes, const_name, inherit);

    if (result != null) {
      return result;
    }

    if (inherit) {
      result = constGetTopLevel(const_name);
    }

    if (result != null) {
      return result;
    }

    if (raise) {
      var last_scope_base = scopes[scopes.length - 1].base;

      if (last_scope_base.$$is_a_module) {
        return last_scope_base.$const_missing(const_name);
      }
    }
  }

  // Create a new constants scope for the given class with the given
  // base. Constants are looked up through their parents, so the base
  // scope will be the outer scope of the new klass.
  //
  // @param base_scope [$$scope] the scope in which the new scope should be created
  // @param klass      [Class]
  // @param id         [String, null] the name of the newly created scope
  //
  Opal.create_scope = function(base_scope, klass, id) {
    var const_alloc = function() {};
    var const_scope = const_alloc.prototype = new base_scope.constructor();

    klass.$$scope       = const_scope;
    klass.$$base_module = base_scope.base;

    const_scope.base        = klass;
    const_scope.constructor = const_alloc;
    const_scope.constants   = [];

    if (id) {
      Opal.cdecl(base_scope, id, klass);
      const_alloc.displayName = id+"_scope_alloc";
    }
  };

  // Constant assignment, see also `Opal.cdecl`
  //
  // @param base_module [Module, Class] the constant namespace
  // @param name        [String] the name of the constant
  // @param value       [Object] the value of the constant
  //
  // @example Assigning a namespaced constant
  //   self::FOO = 'bar'
  //
  // @example Assigning with Module#const_set
  //   Foo.const_set :BAR, 123
  //
  Opal.casgn = function(base_module, name, value) {
    function update(klass, name) {
      klass.$$name = name;

      for (name in klass.$$scope) {
        var value = klass.$$scope[name];

        if (value.$$name === nil && (value.$$is_class || value.$$is_module)) {
          update(value, name)
        }
      }
    }

    var scope = base_module.$$scope;

    if (value.$$is_class || value.$$is_module) {
      // Only checking _Object prevents setting a const on an anonymous class
      // that has a superclass that's not Object
      if (value.$$is_class || value.$$base_module === _Object) {
        value.$$base_module = base_module;
      }

      if (value.$$name === nil && value.$$base_module.$$name !== nil) {
        update(value, name);
      }
    }

    scope.constants.push(name);
    scope[name] = value;

    // If we dynamically declare a constant in a module,
    // we should populate all the classes that include this module
    // with the same constant
    if (base_module.$$is_module && base_module.$$included_in) {
      for (var i = 0; i < base_module.$$included_in.length; i++) {
        var dep = base_module.$$included_in[i];
        Opal.casgn(dep, name, value);
      }
    }

    return value;
  };

  // Constant declaration
  //
  // @example
  //   FOO = :bar
  //
  // @param base_scope [$$scope] the current scope
  // @param name       [String] the name of the constant
  // @param value      [Object] the value of the constant
  Opal.cdecl = function(base_scope, name, value) {
    if ((value.$$is_class || value.$$is_module) && value.$$orig_scope == null) {
      value.$$name = name;
      value.$$orig_scope = base_scope;
      // Here we should explicitly set a base module
      // (a module where the constant was initially defined)
      value.$$base_module = base_scope.base;
      base_scope.constructor[name] = value;
    }

    base_scope.constants.push(name);
    return base_scope[name] = value;
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
    klass = base.$$scope[name];

    // If the class exists in the scope, then we must use that
    if (klass && klass.$$orig_scope === base.$$scope) {
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

    // Every class gets its own constant scope, inherited from current scope
    Opal.create_scope(base.$$scope, klass, name);

    // Name new class directly onto current scope (Opal.Foo.Baz = klass)
    base[name] = klass;

    if (bridged) {
      Opal.bridge(klass, alloc);
    }
    else {
      // Copy all parent constants to child, unless parent is Object
      if (superclass !== _Object && superclass !== BasicObject) {
        Opal.donate_constants(superclass, klass);
      }

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
    if (superclass) {
      var alloc_proxy = function() {};
      alloc_proxy.prototype = superclass.$$proto || superclass.prototype;
      constructor.prototype = new alloc_proxy();
    }

    if (name) {
      constructor.displayName = name+'_alloc';
    }

    constructor.prototype.constructor = constructor;

    return constructor;
  };

  Opal.setup_module_or_class = function(module) {
    // @property $$id Each class/module is assigned a unique `id` that helps
    //                comparation and implementation of `#object_id`
    module.$$id = Opal.uid();

    // @property $$is_a_module Will be true for Module and its subclasses
    //                         instances (namely: Class).
    module.$$is_a_module = true;

    // @property $$inc included modules
    module.$$inc = [];

    // initialize the name with nil
    module.$$name = nil;

    // @property $$cvars class variables defined in the current module
    module.$$cvars = {};
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

    if (!base.$$is_class && !base.$$is_module) {
      base = base.$$class;
    }

    if ($hasOwn.call(base.$$scope, name)) {
      module = base.$$scope[name];

      if (!module.$$is_module && module !== _Object) {
        throw Opal.TypeError.$new(name + " is not a module");
      }
    }
    else {
      module = Opal.module_allocate(Module);
      Opal.create_scope(base.$$scope, module, name);
    }

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

    function module_constructor() {}
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
    module.$$parent = superclass;

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

    // The singleton_class retains the same scope as the original class
    Opal.create_scope(object.$$scope, klass);

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
    klass.$$scope  = superclass.$$scope;
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

      if (ancestor.$$cvars.hasOwnProperty(name)) {
        ancestor.$$cvars[name] = value;
        return value;
      }
    }

    module.$$cvars[name] = value;

    return value;
  }

  // Bridges a single method.
  Opal.bridge_method = function(target, from, name, body) {
    var ancestors, i, ancestor, length;

    ancestors = target.$$bridge.$ancestors();

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
        target.prototype[name] = body
        break;
      }
    }

  };

  // Bridges from *donator* to a *target*.
  Opal._bridge = function(target, donator) {
    var id, methods, method, i, bridged;

    if (typeof(target) === "function") {
      id      = donator.$__id__();
      methods = donator.$instance_methods();

      for (i = methods.length - 1; i >= 0; i--) {
        method = '$' + methods[i];

        Opal.bridge_method(target, donator, method, donator.$$proto[method]);
      }

      if (!bridges[id]) {
        bridges[id] = [];
      }

      bridges[id].push(target);
    }
    else {
      bridged = bridges[target.$__id__()];

      if (bridged) {
        for (i = bridged.length - 1; i >= 0; i--) {
          Opal._bridge(bridged[i], donator);
        }

        bridges[donator.$__id__()] = bridged.slice();
      }
    }
  };

  // Walks the dependency tree detecting the presence of the base among its
  // own dependencies.
  //
  // @param [Integer] base_id The id of the base module (eg. the "includer")
  // @param [Array<Module>] deps The array of dependencies (eg. the included module, included.$$deps)
  // @param [String] prop The property that holds dependencies (eg. "$$deps")
  // @param [JS::Object] seen A JS object holding the cache of already visited objects
  // @return [Boolean] true if a cyclic dependency is present
  Opal.has_cyclic_dep = function has_cyclic_dep(base_id, deps, prop, seen) {
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
  // @param klass  [Class] the target class to include module into
  // @return [null]
  Opal.append_features = function(module, klass) {
    var iclass, donator, prototype, methods, id, i;

    // check if this module is already included in the class
    for (i = klass.$$inc.length - 1; i >= 0; i--) {
      if (klass.$$inc[i] === module) {
        return;
      }
    }

    // Check that the base module is not also a dependency, classes can't be
    // dependencies so we have a special case for them.
    if (!klass.$$is_class && Opal.has_cyclic_dep(klass.$$id, [module], '$$inc', {})) {
      throw Opal.ArgumentError.$new('cyclic include detected')
    }

    klass.$$inc.push(module);
    module.$$included_in.push(klass);
    Opal._bridge(klass, module);

    // iclass
    iclass = {
      $$name:   module.$$name,
      $$proto:  module.$$proto,
      $$parent: klass.$$parent,
      $$module: module,
      $$iclass: true
    };

    klass.$$parent = iclass;

    methods = module.$instance_methods();

    for (i = methods.length - 1; i >= 0; i--) {
      Opal.update_includer(module, klass, '$' + methods[i])
    }

    Opal.donate_constants(module, klass);
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
        constructor.prototype[method_name] = Opal.stub_for(method_name);
      }
    }

    constructor.prototype.$$class = klass;
    constructor.$$bridge          = klass;

    var ancestors = klass.$ancestors();

    // order important here, we have to bridge from the last ancestor to the
    // bridged class
    for (var i = ancestors.length - 1; i >= 0; i--) {
      Opal._bridge(constructor, ancestors[i]);
    }

    for (var name in BasicObject_alloc.prototype) {
      var method = BasicObject_alloc.prototype[method];

      if (method && method.$$stub && !(name in constructor.prototype)) {
        constructor.prototype[name] = method;
      }
    }

    return klass;
  };

  // When a source module is included into the target module, we must also copy
  // its constants to the target.
  //
  Opal.donate_constants = function(source_mod, target_mod) {
    var source_constants = source_mod.$$scope.constants,
        target_scope     = target_mod.$$scope,
        target_constants = target_scope.constants;

    for (var i = 0, length = source_constants.length; i < length; i++) {
      target_constants.push(source_constants[i]);
      target_scope[source_constants[i]] = source_mod.$$scope[source_constants[i]];
    }
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
      klass_includees = includer.$$inc;

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
      }
    }
    else {
      // neither a class, or module included by class, has defined method
      dest[jsid] = body;
      dest[jsid].$$donated = module;
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
        modules;

    while (parent) {
      result.push(parent);
      for (var i=0; i < parent.$$inc.length; i++) {
        modules = Opal.ancestors(parent.$$inc[i]);

        for(var j = 0; j < modules.length; j++) {
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
        method_name, stub;

    for (i = 0; i < ilength; i++) {
      method_name = stubs[i];
      // Save method name to populate other subscribers with this stub
      Opal.stubs[method_name] = true;
      stub = Opal.stub_for(method_name);

      for (j = 0; j < jlength; j++) {
        subscriber = subscribers[j];

        if (!(method_name in subscriber)) {
          subscriber[method_name] = stub;
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
  }

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
    if (object.$$meta === klass) {
      return true;
    }

    var i, length, ancestors = Opal.ancestors(object.$$class);

    for (i = 0, length = ancestors.length; i < length; i++) {
      if (ancestors[i] === klass) {
        return true;
      }
    }

    ancestors = Opal.ancestors(object.$$meta);

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
    if (typeof(method) === 'string') {
      var method_name = method;
      method = recv['$' + method_name];

      if (method) {
        method.$$p = block;
        return method.apply(recv, args);
      }

      return recv.$method_missing.apply(recv, [method_name].concat(args));
    } else if (typeof(method) === 'function') {
      method.$$p = block;
      return method.apply(recv, args);
    }
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
    // if instance_eval is invoked on a module/class, it sets inst_eval_mod
    if (!obj.$$eval && (obj.$$is_class || obj.$$is_module)) {
      Opal.defn(obj, jsid, body);
    }
    else {
      Opal.defs(obj, jsid, body);
    }
  };

  // Define method on a module or class (see Opal.def).
  Opal.defn = function(obj, jsid, body) {
    obj.$$proto[jsid] = body;
    // for super dispatcher, etc.
    body.$$owner = obj;

    // is it a module?
    if (obj.$$is_module) {
      Opal.update_includers(obj, jsid);

      if (obj.$$module_function) {
        Opal.defs(obj, jsid, body);
      }
    }

    // is it a bridged class?
    var bridged = obj.$__id__ && !obj.$__id__.$$stub && bridges[obj.$__id__()];
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
    // TODO: remove from bridges as well

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
        body   = obj.$$proto['$' + old];

    // instance_eval is being run on a class/module, so that need to alias class methods
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

    Opal.defn(obj, id, body);

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
    hash.$$smap = {};
    hash.$$map  = {};
    hash.$$keys = [];
  };

  Opal.hash_clone = function(from_hash, to_hash) {
    to_hash.$$none = from_hash.$$none;
    to_hash.$$proc = from_hash.$$proc;

    for (var i = 0, keys = from_hash.$$keys, length = keys.length, key, value; i < length; i++) {
      key = from_hash.$$keys[i];

      if (key.$$is_string) {
        value = from_hash.$$smap[key];
      } else {
        value = key.value;
        key = key.key;
      }

      Opal.hash_put(to_hash, key, value);
    }
  };

  Opal.hash_put = function(hash, key, value) {
    if (key.$$is_string) {
      if (!hash.$$smap.hasOwnProperty(key)) {
        hash.$$keys.push(key);
      }
      hash.$$smap[key] = value;
      return;
    }

    var key_hash = key.$hash(), bucket, last_bucket;

    if (!hash.$$map.hasOwnProperty(key_hash)) {
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
      if (hash.$$smap.hasOwnProperty(key)) {
        return hash.$$smap[key];
      }
      return;
    }

    var key_hash = key.$hash(), bucket;

    if (hash.$$map.hasOwnProperty(key_hash)) {
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
      if (!hash.$$smap.hasOwnProperty(key)) {
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

    if (!hash.$$map.hasOwnProperty(key_hash)) {
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

      if (!hash.$$map.hasOwnProperty(key_hash)) {
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
        if (args.hasOwnProperty(key)) {
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

  // hash2 is a faster creator for hashes that just use symbols and
  // strings as keys. The map and keys array can be constructed at
  // compile time, so they are just added here by the constructor
  // function
  //
  Opal.hash2 = function(keys, smap) {
    var hash = new Opal.Hash.$$alloc();

    hash.$$smap = smap;
    hash.$$map  = {};
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
        range.exclude = exc;

    return range;
  };

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


  // Require system
  // --------------

  Opal.modules         = {};
  Opal.loaded_features = ['corelib/runtime'];
  Opal.current_dir     = '.'
  Opal.require_table   = {'corelib/runtime': true};

  Opal.normalize = function(path) {
    var parts, part, new_parts = [], SEPARATOR = '/';

    if (Opal.current_dir !== '.') {
      path = Opal.current_dir.replace(/\/*$/, '/') + path;
    }

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
        Opal.LoadError ? Opal.LoadError.$new(message) : function(){throw message}();
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

  Opal.constants.push("BasicObject");
  Opal.constants.push("Object");
  Opal.constants.push("Module");
  Opal.constants.push("Class");

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

  Opal.base                = _Object;
  BasicObject.$$scope      = _Object.$$scope = Opal;
  BasicObject.$$orig_scope = _Object.$$orig_scope = Opal;

  Module.$$scope      = _Object.$$scope;
  Module.$$orig_scope = _Object.$$orig_scope;
  Class.$$scope       = _Object.$$scope;
  Class.$$orig_scope  = _Object.$$orig_scope;

  // Forward .toString() to #to_s
  _Object.$$proto.toString = function() {
    return this.$to_s();
  };

  // Make Kernel#require immediately available as it's needed to require all the
  // other corelib files.
  _Object.$$proto.$require = Opal.require;

  // Instantiate the top object
  Opal.top = new _Object.$$alloc();

  // Nil
  Opal.klass(_Object, _Object, 'NilClass', NilClass_alloc);
  nil = Opal.nil = new NilClass_alloc();
  nil.$$id = nil_id;
  nil.call = nil.apply = function() { throw Opal.LocalJumpError.$new('no block given'); };
  Opal.breaker  = new Error('unexpected break (old)');
  Opal.returner = new Error('unexpected return');

  TypeError.$$super = Error;
}).call(this);
