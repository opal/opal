(function(undefined) {
  // The Opal object that is exposed globally
  var Opal = this.Opal = {};

  // Very root class
  function BasicObject(){}

  // Core Object class
  function Object(){}

  // Class' class
  function Class(){}

  // the class of nil
  function NilClass(){}

  // TopScope is used for inheriting constants from the top scope
  var TopScope = function(){};

  // Opal just acts as the top scope
  TopScope.prototype = Opal;

  // To inherit scopes
  Opal.constructor  = TopScope;

  // This is a useful reference to global object inside ruby files
  Opal.global = this;

  // Minify common function calls
  var __hasOwn = Opal.hasOwnProperty;
  var __slice  = Opal.slice = Array.prototype.slice;

  // Generates unique id for every ruby object
  var unique_id = 0;

  // Return next unique id
  Opal.uid = function() {
    return unique_id++;
  };

  // Table holds all class variables
  Opal.cvars = {};

  // Globals table
  Opal.gvars = {};

  /*
   * Create a new constants scope for the given class with the given
   * base. Constants are looked up through their parents, so the base
   * scope will be the outer scope of the new klass.
   */
  function create_scope(base, klass, id) {
    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base.constructor();
    klass._scope      = const_scope;
    const_scope.base  = klass;
    const_scope.constructor = const_alloc;

    if (id) {
      base[id] = base.constructor[id] = klass;
    }
  }

  /*
    Define a bridged class. Bridged classes will always be in the top level
    scope, and will always be a subclass of Object.
  */
  Opal.bridge = function(name, constructor) {
    var klass = bridge_class(constructor);

    klass._name = name;

    create_scope(Opal, klass, name);

    return klass;
  };

  Opal.klass = function(base, superklass, id, constructor) {
    var klass;

//if (typeof(base) !== 'function') {
//      base = base.constructor;
//    }

    if (!base._isClass) {
      base = base._klass;
    }

    if (superklass === null) {
      superklass = ObjectClass;
    }

    if (__hasOwn.call(base._scope, id)) {
      klass = base._scope[id];

      // if (typeof klass !== 'function') {
      if (!klass._isClass) {
        throw Opal.TypeError.$new(id + " is not a class");
      }

      if (superklass !== klass._super && superklass !== ObjectClass) {
        throw Opal.TypeError.$new("superclass mismatch for class " + id);
      }
    }
    else {
      klass = boot_class(superklass, constructor);

      klass._name = (base === Object ? id : base._name + '::' + id);

      create_scope(base._scope, klass);

      base[id] = base._scope[id] = klass;

      if (superklass.$inherited) {
        superklass.$inherited(klass);
      }
    }

    return klass;
  };

  // Define new module (or return existing module)
  Opal.module = function(base, id, constructor) {
    var klass;

    if (!base._isClass) {
      base = base._klass;
    }
    //if (typeof(base) !== 'function') {
      //base = base.constructor;
    //}

    if (__hasOwn.call(base._scope, id)) {
      klass = base._scope[id];

      if (!klass._mod$ && klass !== ObjectClass) {
        throw Opal.TypeError.$new(id + " is not a module")
      }
    }
    else {
      klass = boot_class(ClassClass, constructor);
      klass._name = (base === ObjectClass ? id : base._name + '::' + id);
      klass._mod$ = true;

      klass._included_in = [];

      create_scope(base._scope, klass, id);
    }

    return klass;
  };

  // Utility function to raise a "no block given" error
  var no_block_given = function() {
    throw new Error('no block given');
  };

  // Boot a base class (makes instances).
  var boot_defclass = function(id, constructor, superklass) {
    if (superklass) {
      var ctor           = function() {};
          ctor.prototype = superklass.prototype;

      constructor.prototype = new ctor();
    }

    var prototype = constructor.prototype;

    prototype.constructor = constructor;

    // START REMOVE
    /*
    constructor._name         = id;
    constructor._super        = superklass;
    constructor._methods      = [];
    constructor._smethods     = [];

    constructor['$==='] = module_eqq;
    constructor.$to_s = module_to_s;
    constructor.toString = module_to_s;

    Opal[id] = constructor;
    */
    // END REMOVE

    return constructor;
  };

  // Boot the actual (meta?) classes of core classes
  var boot_makemeta = function(id, klass, superklass) {
    function RubyClass() {
      this._id = unique_id++;
    };

    var ctor            = function() {};
        ctor.prototype  = superklass.prototype;

    RubyClass.prototype = new ctor();

    var prototype         = RubyClass.prototype;
    prototype._isBoot = true;
    prototype._alloc      = klass;
    prototype._isClass    = true;
    prototype._name       = id;
    prototype._super      = superklass;
    prototype.constructor = RubyClass;
    prototype._methods    = [];
    prototype._smethods   = [];

    var result = new RubyClass();
    klass.prototype._klass = result;
    result._proto = klass.prototype;

    Opal[id] = result;

    return result;
  };

  // Create generic class with given superclass.
  var boot_class = Opal.boot = function(superklass, constructor) {
    // instances
    var ctor = function() {};
        ctor.prototype = superklass.prototype;

    constructor.prototype = new ctor();
    var prototype = constructor.prototype;

    prototype.constructor = constructor;

    // class itself
    function OpalClass() {
      this._id = unique_id++;
    };

    var mtor = function() {};
        mtor.prototype = superklass.constructor.prototype;

    OpalClass.prototype = new mtor();

    prototype = OpalClass.prototype;
    prototype._alloc = constructor;
    prototype._isClass = true;
    prototype.constructor = OpalClass;
    prototype._super = superklass;
    prototype._methods = [];

    var result = new OpalClass();
    constructor.prototype._klass = result;

    result._proto = constructor.prototype;

    return result;
    /*
    constructor._super        = superklass;
    constructor._methods      = [];
    constructor.constructor   = Class;

    constructor['$===']  = module_eqq;
    constructor.$to_s    = module_to_s;
    constructor.toString = module_to_s;

    constructor['$[]'] = undefined;
    constructor.$call  = undefined;

    var smethods;

    smethods = superklass._smethods.slice();

    constructor._smethods = smethods;
    for (var i = 0, length = smethods.length; i < length; i++) {
      var m = smethods[i];
      constructor[m] = superklass[m];
    }

    var inherited = superklass._inherited;

    if (!inherited) {
      inherited = superklass._inherited = [];
    }

    inherited.push(constructor);
    */

    return constructor;
  };

  var bridge_class = function(constructor) {
    var klass = boot_class(ObjectClass, constructor);
    var i, length, m;

    constructor.prototype.constructor = constructor;

    constructor._super        = Object;
    constructor.constructor   = Class;
    constructor._methods      = [];
    constructor._smethods     = [];

    constructor['$===']  = module_eqq;
    constructor.$to_s    = module_to_s;
    constructor.toString = module_to_s;

    //var smethods = constructor._smethods = Class._methods.slice();
    //for (i = 0, length = smethods.length; i < length; i++) {
    //  m = smethods[i];
    //  constructor[m] = Object[m];
    //}

    bridged_classes.push(constructor);

    //var table = Object.prototype, methods = Object._methods;

    //for (i = 0, length = methods.length; i < length; i++) {
    //  m = methods[i];
    //  constructor.prototype[m] = table[m];
    //}

    //constructor._smethods.push('$allocate');

    return klass;
  };

  Opal.puts = function(a) { console.log(a); };

  var native_singleton = {
    _scope: Opal,
    prototype: null
  };

  // Singleton class
  Opal.singleton = function(obj) {
    if (obj == null) {
      return Opal.NilClass;
    }
    else if (obj.$singleton_class) {
      return obj.$singleton_class();
    }
    else {
      native_singleton.prototype = obj;
      return native_singleton;
    }
  };

  // Method missing dispatcher
  Opal.mm = function(mid) {
    var dispatcher = function() {
      var args = __slice.call(arguments);

      if (this.$method_missing) {
        this.$method_missing._p = dispatcher._p;
        return this.$method_missing.apply(this, [mid].concat(args));
      }
      else {
        native_send._p = dispatcher._p;
        return native_send(this, mid, args);
      }
    };

    return dispatcher;
  };

  // send a method to a native object
  var native_send = function(obj, mid, args) {
    var prop, block = native_send._p;
    native_send._p = null;

    if ( (prop = native_methods[mid]) ) {
      return prop(obj, args, block);
    }

    prop = obj[mid];

    if (typeof(prop) === "function") {
      prop = prop.apply(obj, args.$to_n());
    }
    else if (mid.charAt(mid.length - 1) === "=") {
      prop = mid.slice(0, mid.length - 1);

      if (args[0] === nil) {
        obj[prop] = null;
        return nil;
      }

      return obj[prop] = args[0];
    }

    if (prop == null) {
      return nil;
    }

    return prop;
  };

  var native_methods = {
    "==": function(obj, args) {
      return obj === args[0];
    },

    "[]": function(obj, args) {
      var prop = obj[args[0]];

      if (prop == null) {
        return nil;
      }

      return prop;
    },

    "[]=": function(obj, args) {
      var value = args[1];

      if (value === nil) {
        value = null;
      }

      return obj[args[0]] = value;
    },

    "inspect": function(obj) {
      return obj.toString();
    },

    "to_s": function(obj) {
      return obj.toString();
    },

    "respond_to?": function(obj, args) {
      return obj[args[0]] != null;
    },

    "each": function(obj, args, block) {
      var prop;

      if (obj.length === +obj.length) {
        for (var i = 0, len = obj.length; i < len; i++) {
          prop = obj[i];

          if (prop == null) {
            prop = nil;
          }

          block(prop);
        }
      }
      else {
        for (var key in obj) {
          prop = obj[key];

          if (prop == null) {
            prop = nil;
          }

          block(key, prop);
        }
      }

      return obj;
    },

    "to_a": function(obj, args) {
      var result = [];

      for (var i = 0, length = obj.length; i < length; i++) {
        result.push(obj[i]);
      }

      return result;
    },

    "to_h": function(obj) {
      var keys = [], values = {}, value;

      for (var key in obj) {
        value = obj[key];
        keys.push(key);

        if (value == null) {
          value = nil;
        }

        values[key] = value;
      }

      return Opal.hash2(keys, values);
    }
  };

  // Const missing dispatcher
  Opal.cm = function(name) {
    return this.base.$const_missing(name);
  };

  // Arity count error dispatcher
  Opal.ac = function(actual, expected, object, meth) {
    var inspect = ((typeof(object) !== 'function') ? object.constructor._name + '#' : object._name + '.') + meth;
    var msg = '[' + inspect + '] wrong number of arguments(' + actual + ' for ' + expected + ')';
    throw Opal.ArgumentError.$new(msg);
  };

  /*
    Call a ruby method on a ruby object with some arguments:

      var my_array = [1, 2, 3, 4]
      Opal.send(my_array, 'length')     # => 4
      Opal.send(my_array, 'reverse!')   # => [4, 3, 2, 1]

    A missing method will be forwarded to the object via
    method_missing.

    The result of either call with be returned.

    @param [Object] recv the ruby object
    @param [String] mid ruby method to call
  */
  Opal.send = function(recv, mid) {
    var args = __slice.call(arguments, 2),
        func = recv['$' + mid];

    if (func) {
      return func.apply(recv, args);
    }

    return recv.$method_missing.apply(recv, [mid].concat(args));
  };

  Opal.block_send = function(recv, mid, block) {
    var args = __slice.call(arguments, 3),
        func = recv['$' + mid];

    if (func) {
      func._p = block;
      return func.apply(recv, args);
    }

    return recv.$method_missing.apply(recv, [mid].concat(args));
  };

  // Implementation of Class#===
  function module_eqq(object) {
    if (object == null) {
      return false;
    }

    var search = object.constructor;

    while (search) {
      if (search === this) {
        return true;
      }

      search = search._super;
    }

    return false;
  }

  // Implementation of Class#to_s
  function module_to_s() {
    return this._name;
  }

  /**
   * Donate methods for a class/module
   */
  Opal.donate = function(klass, defined, indirect) {
    // FIXME
    return;
    var methods = klass._methods, included_in = klass._included_in;

    // if (!indirect) {
      klass._methods = methods.concat(defined);
    // }

    if (included_in) {
      for (var i = 0, length = included_in.length; i < length; i++) {
        var includee = included_in[i];
        var dest = includee.prototype;

        for (var j = 0, jj = defined.length; j < jj; j++) {
          var method = defined[j];
          dest[method] = klass.prototype[method];
        }

        if (includee._included_in) {
          Opal.donate(includee, defined, true);
        }
      }
    }
  };

  /*
    Define a singleton method on the given klass

        Opal.defs(Array, '$foo', function() {})

    @param [Function] klass
    @param [String] mid the method_id
    @param [Function] body function body
  */
  Opal.defs = function(klass, mid, body) {
    klass._smethods.push(mid);
    klass[mid] = body;

    var inherited = klass._inherited;
    if (inherited && inherited.length) {
      for (var i = 0, length = inherited.length, subclass; i < length; i++) {
        subclass = inherited[i];
        if (!subclass[mid]) {
          Opal.defs(subclass, mid, body);
        }
      }
    }
  };

  // Defines methods onto Object (which are then donated to bridged classes)
  Object._defn = function (mid, body) {
    this.prototype[mid] = body;
    Opal.donate(this, [mid]);
  };

  // Initialization
  // --------------

  // Constructors for *instances* of core objects
  boot_defclass('BasicObject', BasicObject);
  boot_defclass('Object', Object, BasicObject);
  boot_defclass('Class', Class, Object);

  // Constructors for *classes* of core objects
  var BasicObjectClass = boot_makemeta('BasicObject', BasicObject, Class);
  var ObjectClass      = boot_makemeta('Object', Object, BasicObjectClass.constructor);
  var ClassClass       = boot_makemeta('Class', Class, ObjectClass.constructor);

  // Fix booted classes to use their metaclass
  BasicObjectClass._klass = ClassClass;
  ObjectClass._klass = ClassClass;
  ClassClass._klass = ClassClass;

  // Fix superclasses of booted classes
  BasicObjectClass._super = null;
  ObjectClass._super = BasicObjectClass;
  ClassClass._super = ObjectClass;

  var bridged_classes = Object._included_in = [];

  Opal.base = Object;
  BasicObjectClass._scope = ObjectClass._scope = Opal;
  Opal.Module = Opal.Class;
  Opal.Kernel = ObjectClass;

  create_scope(Opal, Class);

  ObjectClass._proto.toString = function() {
    return this.$to_s();
  };

  Opal.top = new ObjectClass._alloc();

  Opal.klass(ObjectClass, ObjectClass, 'NilClass', NilClass);

  var nil = Opal.nil = new NilClass;
  nil.call = nil.apply = function() { throw Opal.LocalJumpError.$new('no block given'); };

  Opal.breaker  = new Error('unexpected break');

  Opal.bridge('Array', Array);
  Opal.bridge('Boolean', Boolean);
  Opal.bridge('Numeric', Number);
  Opal.bridge('String', String);
  Opal.bridge('Proc', Function);
  Opal.bridge('Exception', Error);
  Opal.bridge('Regexp', RegExp);
  Opal.bridge('Time', Date);

  TypeError._super = Error;
}).call(this);
