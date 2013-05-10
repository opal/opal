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
  Opal.alloc  = TopScope;

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

  Opal.klass = function(base, superklass, id, constructor) {
    var klass;
    if (base._isObject) {
      base = base._klass;
    }

    if (superklass === null) {
      superklass = Object;
    }

    if (__hasOwn.call(base._scope, id)) {
      klass = base._scope[id];
    }
    else {
      if (!superklass._methods) {
        var bridged = superklass;
        superklass  = Object;
        klass       = bridge_class(bridged);
      }
      else {
        klass = boot_class(superklass, constructor);
      }

      klass._name = (base === Object ? id : base._name + '::' + id);

      var const_alloc   = function() {};
      var const_scope   = const_alloc.prototype = new base._scope.alloc();
      klass._scope      = const_scope;
      const_scope.base  = klass;
      const_scope.alloc = const_alloc;

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
    if (base._isObject) {
      base = base._klass;
    }

    if (__hasOwn.call(base._scope, id)) {
      klass = base._scope[id];
    }
    else {
      klass = boot_class(Class, constructor);
      klass._name = (base === Object ? id : base._name + '::' + id);

      klass.$included_in = [];

      var const_alloc   = function() {};
      var const_scope   = const_alloc.prototype = new base._scope.alloc();
      klass._scope      = const_scope;
      const_scope.alloc = const_alloc;

      base[id] = base._scope[id]    = klass;
    }

    return klass;
  }

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
    prototype._isObject   = true;
    prototype._klass      = constructor;

    constructor._inherited    = [];
    constructor._included_in  = [];
    constructor._isClass      = true;
    constructor._name         = id;
    constructor._super        = superklass;
    constructor._methods      = [];
    constructor._smethods     = [];
    constructor._isObject     = false;

    constructor._donate = __donate;
    constructor._defs = __defs;

    constructor['$==='] = module_eqq;
    constructor.$to_s = module_to_s;
    constructor.toString = module_to_s;

    Opal[id] = constructor;

    return constructor;
  };

  // Create generic class with given superclass.
  var boot_class = Opal.boot = function(superklass, constructor) {
    var ctor = function() {};
        ctor.prototype = superklass.prototype;

    constructor.prototype = new ctor();
    var prototype = constructor.prototype;

    prototype._klass      = constructor;
    prototype.constructor = constructor;

    constructor._inherited    = [];
    constructor._included_in  = [];
    constructor._isClass      = true;
    constructor._super        = superklass;
    constructor._methods      = [];
    constructor._isObject     = false;
    constructor._klass        = Class;
    constructor._donate       = __donate
    constructor._defs = __defs;

    constructor['$==='] = module_eqq;
    constructor.$to_s = module_to_s;
    constructor.toString = module_to_s;

    constructor['$[]'] = undefined;
    constructor['$call'] = undefined;

    var smethods;

    smethods = superklass._smethods.slice();

    constructor._smethods = smethods;
    for (var i = 0, length = smethods.length; i < length; i++) {
      var m = smethods[i];
      constructor[m] = superklass[m];
    }

    superklass._inherited.push(constructor);

    return constructor;
  };

  var bridge_class = function(constructor) {
    constructor.prototype._klass = constructor;

    constructor._inherited    = [];
    constructor._included_in  = [];
    constructor._isClass      = true;
    constructor._super        = Object;
    constructor._klass        = Class;
    constructor._methods      = [];
    constructor._smethods     = [];
    constructor._isObject     = false;

    constructor._donate = function(){};
    constructor._defs = __defs;

    constructor['$==='] = module_eqq;
    constructor.$to_s = module_to_s;
    constructor.toString = module_to_s;

    var smethods = constructor._smethods = Class._methods.slice();
    for (var i = 0, length = smethods.length; i < length; i++) {
      var m = smethods[i];
      constructor[m] = Object[m];
    }

    bridged_classes.push(constructor);

    var table = Object.prototype, methods = Object._methods;

    for (var i = 0, length = methods.length; i < length; i++) {
      var m = methods[i];
      constructor.prototype[m] = table[m];
    }

    constructor._smethods.push('$allocate');

    return constructor;
  };

  Opal.puts = function(a) { console.log(a); };

  // Method missing dispatcher
  Opal.mm = function(mid) {
    var dispatcher = function() {
      var args = __slice.call(arguments);

      if (this.$method_missing) {
        this.$method_missing._p = dispatcher._p;
        return this.$method_missing.apply(this, [mid].concat(args));
      }
      else {
        return native_send(this, mid, args);
      }
    };

    return dispatcher;
  };

  // send a method to a native object
  var native_send = function(obj, mid, args) {
    var prop, block = native_send._p;
    native_send._p = null;

    if (prop = native_methods[mid]) {
      return prop(obj, args, block);
    }

    prop = obj[mid];

    if (typeof(prop) === "function") {
      prop = prop.apply(obj, args.$to_native());
    }
    else if (mid.charAt(mid.length - 1) === "=") {
      prop = mid.slice(0, mid.length - 1);
      return obj[prop] = args[0];
    }

    if (prop != null) {
      return prop;
    }

    return nil;
  };

  var native_methods = {
    "==": function(obj, args) {
      return obj === args[0];
    },

    "[]": function(obj, args) {
      var prop = obj[args[0]];

      if (prop != null) {
        return prop;
      }

      return nil;
    },

    "respond_to?": function(obj, args) {
      return obj[args[0]] != null;
    },

    "each": function(obj, args, block) {
      for (var key in obj) {
        var prop = obj[key];

        if (prop == null) {
          prop = nil;
        }

        block(key, prop);
      }

      return obj;
    },

    "to_a": function(obj, args) {
      var result = [];

      for (var i = 0, length = obj.length; i < length; i++) {
        result.push(obj[i]);
      }

      return result;
    }
  };

  // Const missing dispatcher
  Opal.cm = function(name) {
    return this.base.$const_missing(name);
  };

  // Arity count error dispatcher
  Opal.ac = function(actual, expected, object, meth) {
    var inspect = (object._isObject ? object._klass._name + '#' : object._name + '.') + meth;
    var msg = '[' + inspect + '] wrong number of arguments(' + actual + ' for ' + expected + ')'
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

  // Initialization
  // --------------

  boot_defclass('BasicObject', BasicObject)
  boot_defclass('Object', Object, BasicObject);
  boot_defclass('Class', Class, Object);

  Class.prototype = Function.prototype;

  BasicObject._klass = Object._klass = Class._klass = Class;

  // Implementation of Class#===
  function module_eqq(object) {
    if (object == null) {
      return false;
    }

    var search = object._klass;

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

  // Donator for all 'normal' classes and modules
  function __donate(defined, indirect) {
    var methods = this._methods, included_in = this.$included_in;

    // if (!indirect) {
      this._methods = methods.concat(defined);
    // }

    if (included_in) {
      for (var i = 0, length = included_in.length; i < length; i++) {
        var includee = included_in[i];
        var dest = includee.prototype;

        for (var j = 0, jj = defined.length; j < jj; j++) {
          var method = defined[j];
          dest[method] = this.prototype[method];
        }

        if (includee.$included_in) {
          includee._donate(defined, true);
        }
      }

    }
  }

  // Define a singleton method on a class
  function __defs(mid, body) {
    this._smethods.push(mid);
    this[mid] = body;

    var inherited = this._inherited;
    if (inherited.length) {
      for (var i = 0, length = inherited.length, subclass; i < length; i++) {
        subclass = inherited[i];
        if (!subclass[mid]) {
          subclass._defs(mid, body);
        }
      }
    }
  }

  // Defines methods onto Object (which are then donated to bridged classes)
  Object._defn = function (mid, body) {
    this.prototype[mid] = body;
    this._donate([mid]);
  };

  var bridged_classes = Object.$included_in = [];

  Opal.base = Object;
  BasicObject._scope = Object._scope = Opal;
  Opal.Module = Opal.Class;
  Opal.Kernel = Object;

  var class_const_alloc = function(){};
  var class_const_scope = new TopScope();
  class_const_scope.alloc = class_const_alloc;
  Class._scope = class_const_scope;

  Object.prototype.toString = function() {
    return this.$to_s();
  };

  Opal.top = new Object;

  Opal.klass(Object, Object, 'NilClass', NilClass)
  var nil = Opal.nil = new NilClass;
  nil.call = nil.apply = function() { throw Opal.LocalJumpError.$new('no block given'); };

  Opal.breaker  = new Error('unexpected break');
}).call(this);
