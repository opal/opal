(function(undefined) {
  // The Opal object that is exposed globally
  var Opal = this.Opal = {};

  // Very root class
  function BasicObject(){}

  // Core Object class
  function Object(){}

  // Class' class
  function Class(){}

  // Module's class
  function Module(){}

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
  var $hasOwn = Opal.hasOwnProperty;
  var $slice  = Opal.slice = Array.prototype.slice;

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

  Opal.klass = function(base, superklass, id, constructor) {
    var klass;

    if (!base._isClass) {
      base = base._klass;
    }

    if (superklass === null) {
      superklass = ObjectClass;
    }

    if ($hasOwn.call(base._scope, id)) {
      klass = base._scope[id];

      if (!klass._isClass) {
        throw Opal.TypeError.$new(id + " is not a class");
      }

      if (superklass !== klass._super && superklass !== ObjectClass) {
        throw Opal.TypeError.$new("superclass mismatch for class " + id);
      }
    }
    else {
      klass = boot_class(superklass, constructor);

      klass._name = (base === ObjectClass ? id : base._name + '::' + id);

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

    if ($hasOwn.call(base._scope, id)) {
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
        ctor.prototype = superklass._proto;

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

    return constructor;
  };

  var bridge_class = function(name, constructor) {
    var klass = boot_class(ObjectClass, constructor);
    var i, length, m;

    constructor.prototype.constructor = constructor;

    constructor._super        = Object;
    constructor.constructor   = Class;
    constructor._methods      = [];

    bridged_classes.push(klass);

    var table = ObjectClass._proto, methods = ObjectClass._methods;

    for (i = 0, length = methods.length; i < length; i++) {
      m = methods[i];
      constructor.prototype[m] = table[m];
    }

    klass._name = name;
    create_scope(Opal, klass, name);

    return klass;
  };

  Opal.puts = function(a) { console.log(a); };

  Opal.add_stubs = function(stubs) {
    for (var i = 0, length = stubs.length; i < length; i++) {
      var stub = stubs[i];

      if (!BasicObject.prototype[stub]) {
        BasicObject.prototype[stub] = true;
        add_stub_for(BasicObject.prototype, stub);
      }
    }
  };

  function add_stub_for(prototype, stub) {
    function method_missing_stub() {
      this.$method_missing._p = method_missing_stub._p;
      method_missing_stub._p = null;

      return this.$method_missing.apply(this, [stub.slice(1)].concat($slice.call(arguments)));
    }

    method_missing_stub.rb_stub = true;
    prototype[stub] = method_missing_stub;
  }

  Opal.add_stub_for = add_stub_for;

  // Method missing dispatcher
  Opal.mm = function(mid) {
    var dispatcher = function() {
      var args = $slice.call(arguments);

      if (!this.$method_missing) {
        throw new Error("cannot set " + mid + " on " + this);
      }

      this.$method_missing._p = dispatcher._p;
      return this.$method_missing.apply(this, [mid].concat(args));
    };

    return dispatcher;
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

  // Super dispatcher
  Opal.dispatch_super = function(obj, jsid, args, defs) {
    var dispatcher;

    if (defs) {
      dispatcher = obj._isClass ? defs._super : obj._klass._proto;
    }
    else {
      dispatcher = obj._isClass ? obj._klass : obj._klass._super._proto;
    }

    return dispatcher['$' + jsid].apply(obj, args);
  };

  // return helper
  Opal.$return = function(val) {
    Opal.returner.$v = val;
    throw Opal.returner;
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
    var args = $slice.call(arguments, 2),
        func = recv['$' + mid];

    if (func) {
      return func.apply(recv, args);
    }

    return recv.$method_missing.apply(recv, [mid].concat(args));
  };

  Opal.block_send = function(recv, mid, block) {
    var args = $slice.call(arguments, 3),
        func = recv['$' + mid];

    if (func) {
      func._p = block;
      return func.apply(recv, args);
    }

    return recv.$method_missing.apply(recv, [mid].concat(args));
  };

  /**
   * Donate methods for a class/module
   */
  Opal.donate = function(klass, defined, indirect) {
    var methods = klass._methods, included_in = klass._included_in;

    // if (!indirect) {
      klass._methods = methods.concat(defined);
    // }

    if (included_in) {
      for (var i = 0, length = included_in.length; i < length; i++) {
        var includee = included_in[i];
        var dest = includee._proto;

        for (var j = 0, jj = defined.length; j < jj; j++) {
          var method = defined[j];
          dest[method] = klass._proto[method];
        }

        if (includee._included_in) {
          Opal.donate(includee, defined, true);
        }
      }
    }
  };

  // Initialization
  // --------------

  // Constructors for *instances* of core objects
  boot_defclass('BasicObject', BasicObject);
  boot_defclass('Object', Object, BasicObject);
  boot_defclass('Module', Module, Object);
  boot_defclass('Class', Class, Module);

  // Constructors for *classes* of core objects
  var BasicObjectClass = boot_makemeta('BasicObject', BasicObject, Class);
  var ObjectClass      = boot_makemeta('Object', Object, BasicObjectClass.constructor);
  var ModuleClass      = boot_makemeta('Module', Module, ObjectClass.constructor);
  var ClassClass       = boot_makemeta('Class', Class, ModuleClass.constructor);

  // Fix booted classes to use their metaclass
  BasicObjectClass._klass = ClassClass;
  ObjectClass._klass = ClassClass;
  ModuleClass._klass = ClassClass;
  ClassClass._klass = ClassClass;

  // Fix superclasses of booted classes
  BasicObjectClass._super = null;
  ObjectClass._super = BasicObjectClass;
  ModuleClass._super = ObjectClass;
  ClassClass._super = ModuleClass;

  // Defines methods onto Object (which are then donated to bridged classes)
  ObjectClass._defn = function (mid, body) {
    this._proto[mid] = body;
    Opal.donate(this, [mid]);
  };

  var bridged_classes = ObjectClass._included_in = [];

  Opal.base = ObjectClass;
  BasicObjectClass._scope = ObjectClass._scope = Opal;
  Opal.Kernel = ObjectClass;

  create_scope(Opal, ModuleClass);
  create_scope(Opal, ClassClass);

  ObjectClass._proto.toString = function() {
    return this.$to_s();
  };

  ClassClass._proto._defn = function(mid, body) { this._proto[mid] = body; };

  Opal.top = new ObjectClass._alloc();

  Opal.klass(ObjectClass, ObjectClass, 'NilClass', NilClass);

  var nil = Opal.nil = new NilClass;
  nil.call = nil.apply = function() { throw Opal.LocalJumpError.$new('no block given'); };

  Opal.breaker  = new Error('unexpected break');
  Opal.returner = new Error('unexpected return');

  bridge_class('Array', Array);
  bridge_class('Boolean', Boolean);
  bridge_class('Numeric', Number);
  bridge_class('String', String);
  bridge_class('Proc', Function);
  bridge_class('Exception', Error);
  bridge_class('Regexp', RegExp);
  bridge_class('Time', Date);

  TypeError._super = Error;
}).call(this);
