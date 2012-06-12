/**
  The Opal object gets exposed globally (on window) and contains the
  useful runtime methods available to all ruby files, as well as all
  the top level ruby classes, modules and constants.
*/
var Opal = this.Opal = {};

/**
  TopScope is a constructor to hold the prototype that all top level
  Opal constants are defined on.
*/
var TopScope = function(){};

/**
  To make things simple, we alias the top scope prototype to the
  global Opal object.
*/
TopScope.prototype = Opal;

Opal.alloc  = TopScope; 
Opal.global = this;

// Minify common function calls
var __hasOwn = Object.prototype.hasOwnProperty;
var __slice  = Opal.slice = Array.prototype.slice;

// Generates unique id for every ruby object
var unique_id = 0;

// Table holds all class variables
Opal.cvars = {};

// Globals table
Opal.gvars = {};

/**
  Runtime method used to either define a new class, or re-open an old
  class. The base may be an object (rather than a class), which is
  always the case when defining classes in the top level as the top
  level is just the 'main' Object instance.

  The given ruby code:

      class Foo
        42
      end

      class Bar < Foo
        3.142
      end

  Would be compiled to something like:

      var __klass = Opal.klass;

      __klass(this, null, 'Foo', function() {
        return 42;
      });

      __klass(this, __scope.Foo, 'Bar', function() {
        return 3.142;
      });

  @param [RubyObject] base the scope in which to define the class
  @param [RubyClass] superklass the superklass, may be null
  @param [String] id the name for the class
  @param [Function] body the class body
  @return returns last value from running body
*/
Opal.klass = function(base, superklass, id, body) {
  var klass;
  if (base._isObject) {
    base = base._real;
  }

  if (superklass === null) {
    superklass = RubyObject;
  }

  if (__hasOwn.call(base._scope, id)) {
    klass = base._scope[id];
  }
  else {
    if (!superklass._klass || !superklass._proto) {
      var bridged = superklass;
      superklass = RubyObject;
    }

    klass = boot_class(superklass);
    klass._name = (base === RubyObject ? id : base._name + '::' + id);

    make_metaclass(klass, superklass._klass);

    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base._scope.alloc();
    klass._scope      = const_scope;
    const_scope.alloc = const_alloc;

    base[id] = base._scope[id] = klass;

    if (superklass.$inherited) {
      superklass.$inherited(klass);
    }

    if (bridged) {
      bridge_class(klass, bridged);
    }
  }

  return body.call(klass);
};

Opal.sklass = function(shift, body) {
  var klass = shift.$singleton_class();
  return body.call(klass);
}

Opal.module = function(base, id, body) {
  var klass;
  if (base._isObject) {
    base = base._real;
  }

  if (__hasOwn.call(base._scope, id)) {
    klass = base._scope[id];
  }
  else {
    klass = boot_module();
    klass._name = (base === RubyObject ? id : base._name + '::' + id);

    make_metaclass(klass, RubyModule);

    klass._isModule = true;
    klass.$included_in = [];

    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base._scope.alloc();
    klass._scope      = const_scope;
    const_scope.alloc = const_alloc;

    base[id] = base._scope[id]    = klass;
  }

  return body.call(klass);
}

/**
  This function serves two purposes. The first is to allow methods
  defined in modules to be included into classes that have included
  them. This is done at the end of a module body by calling this
  method will all the defined methods. They are then passed onto
  the includee classes.

  The second purpose is to store an array of all the methods defined
  directly in this class or module. This makes features such as
  #methods and #instance_methods work. It is also used internally to
  create subclasses of Arrays, as an annoyance with javascript is that
  arrays cannot be subclassed (or they can't without problems arrising
  with tracking the array length). Therefore, when a new instance of a
  subclass is created, behind the scenes we copy all the methods from
  the subclass onto an array prototype.

  If the includee is also included into other modules or classes, then
  this method will also set up donations for that module. If this is
  the case, then 'indirect' will be set to true as we don't want those
  modules/classes to think they had that method set on themselves. This
  stops `Object` thinking it defines `#sprintf` when it is actually
  `Kernel` that defines that method. Indirect is false by default when
  called by generated code in the compiler output.

  @param [RubyClass] klass the class or module that defined methods
  @param [Array<String>] methods an array of jsid method names defined
  @param [Boolean] indirect whether this is an indirect method define
*/
Opal.donate = function(klass, methods, indirect) {
  var included_in = klass.$included_in, includee, method,
      table = klass._proto, dest;

  if (!indirect) {
    klass._methods = klass._methods.concat(methods);
  }

  if (included_in) {
    for (var i = 0, length = included_in.length; i < length; i++) {
      includee = included_in[i];
      dest = includee._proto;

      for (var j = 0, jj = methods.length; j < jj; j++) {
        method = methods[j];
          dest[method] = table[method];
      }

      if (includee.$included_in) {
        Opal.donate(includee, methods, true);
      }
    }
  }
};

var mid_to_jsid = function(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return '$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
};

var no_block_given = function() {
  throw new Error('no block given');
};

// Boot a base class (makes instances).
var boot_defclass = function(superklass) {
  var cls = function() {
    this._id = unique_id++;
  };

  if (superklass) {
    var ctor           = function() {};
        ctor.prototype = superklass.prototype;

    cls.prototype = new ctor();
  }

  cls.prototype.constructor = cls;
  cls.prototype._isObject   = true;

  return cls;
};

// Boot actual (meta classes) of core objects.
var boot_makemeta = function(id, klass, superklass) {
  var meta = function() {
    this._id = unique_id++;
  };

  var ctor           = function() {};
      ctor.prototype = superklass.prototype;

  meta.prototype = new ctor();

  var proto              = meta.prototype;
      proto.$included_in = [];
      proto._alloc       = klass;
      proto._isClass     = true;
      proto._name        = id;
      proto._super       = superklass;
      proto.constructor  = meta;
      proto._methods     = [];
      proto._isObject    = false;

  var result = new meta();
  klass.prototype._klass = result;
  klass.prototype._real  = result;

  result._proto = klass.prototype;

  Opal[id] = result;

  return result;
};

// Create generic class with given superclass.
var boot_class = function(superklass) {
  // instances
  var cls = function() {
    this._id = unique_id++;
  };

  var ctor = function() {};
      ctor.prototype = superklass._alloc.prototype;

  cls.prototype = new ctor();

  var proto             = cls.prototype;
      proto.constructor = cls;
      proto._isObject   = true;

  // class itself
  var meta = function() {
    this._id = unique_id++;
  };

  var mtor = function() {};
      mtor.prototype = superklass.constructor.prototype;

  meta.prototype = new mtor();

  proto             = meta.prototype;
  proto._alloc      = cls;
  proto._isClass    = true;
  proto.constructor = meta;
  proto._super      = superklass;
  proto._methods    = [];

  var result = new meta();
  cls.prototype._klass = result;
  cls.prototype._real  = result;

  result._proto = cls.prototype;

  return result;
};

var boot_module = function() {
  // where module "instance" methods go. will never be instantiated so it
  // can be a regular object
  var module_cons = function(){};
  var module_inst = module_cons.prototype;

  // Module itself
  var meta = function() {
    this._id = unique_id++;
  };

  var mtor = function(){};
  mtor.prototype = RubyModule.constructor.prototype;
  meta.prototype = new mtor();

  var proto = meta.prototype;

  proto._alloc      = module_cons;
  proto._isModule   = true;
  proto.constructor = meta;
  proto._super      = null;
  proto._methods    = [];

  var module        = new meta();
  module._proto     = module_inst;

  return module;
};

// Make metaclass for the given class
var make_metaclass = function(klass, superklass) {
  var class_id = "#<Class:" + klass._name + ">",
      meta     = boot_class(superklass);

  meta._name = class_id;
  meta._alloc.prototype = klass.constructor.prototype;
  meta._proto = meta._alloc.prototype;
  meta._isSingleton = true;
  meta._klass = RubyClass;
  meta._real  = RubyClass;

  klass._klass = meta;

  meta._scope = klass._scope;
  meta.__attached__ = klass;

  return meta;
};

var bridge_class = function(klass, constructor) {
  var prototype = constructor.prototype;

  klass._alloc = constructor;
  klass._proto = prototype;

  bridged_classes.push(klass);

  prototype._klass    = klass;
  prototype._real     = klass;
  prototype._isObject = true;

  var allocator = function(initializer) {
    var result, kls = this, methods = kls._methods, proto = kls._proto;

    if (initializer == null) {
      result = new constructor
    }
    else {
      result = new constructor(initializer);
    }

    if (kls === klass) {
      return result;
    }

    result._klass = kls;
    result._real  = kls;

    for (var i = 0, length = methods.length; i < length; i++) {
      var method = methods[i];
      result[method] = proto[method];
    }

    return result;
  };

  klass.constructor.prototype.$allocate = allocator;

  var donator = RubyObject, table, methods;

  while (donator) {
    table = donator._proto;
    methods = donator._methods;

    for (var i = 0, length = methods.length; i < length; i++) {
      var method = methods[i];
      prototype[method] = table[method];
    }

    donator = donator._super;
  }

  return klass;
};

/**
  An IClass is a fake class created when a module is included into a
  class or another module. It is a "copy" of the module that is then
  injected into the hierarchy so it appears internally that the iclass
  is the super of the class instead of the old super class. This is
  actually hidden from the ruby side of things, but allows internal
  features such as super() etc to work. All useful properties from the
  module are copied onto this iclass.

  @param [RubyClass] klass the klass which is including the module
  @param [RubyModule] module the module which is being included
  @return [RubyIClass] returns newly created iclass
*/
var define_iclass = function(klass, module) {
  var iclass = {
    _proto:     module._proto,
    _super:     klass._super,
    _isIClass:  true,
    _klass:     module,
    _name:      module._name,
    _methods:   module._methods
  };

  klass._super = iclass;

  return iclass;
};

// Initialization
// --------------

// The *instances* of core objects
var BootBasicObject = boot_defclass();
var BootObject      = boot_defclass(BootBasicObject);
var BootModule      = boot_defclass(BootObject);
var BootClass       = boot_defclass(BootModule);

// The *classes' of core objects
var RubyBasicObject = boot_makemeta('BasicObject', BootBasicObject, BootClass); 
var RubyObject      = boot_makemeta('Object', BootObject, RubyBasicObject.constructor);
var RubyModule      = boot_makemeta('Module', BootModule, RubyObject.constructor);
var RubyClass       = boot_makemeta('Class', BootClass, RubyModule.constructor);

// Fix boot classes to use meta class
RubyBasicObject._klass = RubyClass;
RubyObject._klass = RubyClass;
RubyModule._klass = RubyClass;
RubyClass._klass = RubyClass;

// fix superclasses
RubyBasicObject._super = null;
RubyObject._super = RubyBasicObject;
RubyModule._super = RubyObject;
RubyClass._super = RubyModule;

var bridged_classes = RubyObject.$included_in = [];
RubyBasicObject.$included_in = bridged_classes;

RubyObject._scope = RubyBasicObject._scope = Opal;

var module_const_alloc = function(){};
var module_const_scope = new TopScope();
module_const_scope.alloc = module_const_alloc;
RubyModule._scope = module_const_scope;

var class_const_alloc = function(){};
var class_const_scope = new TopScope();
class_const_scope.alloc = class_const_alloc;
RubyClass._scope = class_const_scope;

RubyObject._proto.toString = function() {
  return this.$to_s();
};

Opal.top = new RubyObject._alloc();

Opal.klass(RubyObject, RubyObject, 'NilClass', function(){});
Opal.nil = new Opal.NilClass._alloc();
Opal.nil.call = Opal.nil.apply = no_block_given;

var breaker = Opal.breaker  = new Error('unexpected break');
    breaker.$t              = function() { throw this; };
