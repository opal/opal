// Top level Object scope (used by object and top_self).
var top_const_alloc     = function(){};
var top_const_scope     = top_const_alloc.prototype;
top_const_scope.alloc   = top_const_alloc; 

var Opal = this.Opal = top_const_scope;

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

// Actually define methods
Opal.defn = function(klass, jsid, body) {
  // If an object, make sure to use its class
  if (klass._isObject) klass = klass._klass;

  klass._alloc.prototype[jsid] = body;
  Opal.donate(klass, [jsid]);

  // FIXME: will this method ever be called with singleton metaclass?
  // if (klass._bridge) {
  //   klass._bridge[id] = body;
  // }
};

Opal.klass = function(base, superklass, id, body) {
  var klass;
  if (base._isObject) {
    base = class_real(base._klass);
  }

  if (superklass === null) {
    superklass = RubyObject;
  }

  if (__hasOwn.call(base._scope, id)) {
    klass = base._scope[id];
  }
  else if (!superklass._klass || !superklass._proto) {
    klass = bridge_class(superklass, id);
  }
  else {
    klass = define_class(base, id, superklass);
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
    base = class_real(base._klass);
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

    base._scope[id]    = klass;
  }

  return body.call(klass);
}

/**
  Define a singleton method on the given base object. This will
  get the singleton class of the base object and do a normal method
  definition on that class.

  @param [RubyObject] base the object/class/module to define metho on
  @param [String] id the method name (jsid) to define
  @param [Function] body the method implementation
*/
Opal.defs = function(base, id, body) {
  base = base.$singleton_class();
  base._alloc.prototype[id] = body;
  Opal.donate(base, [id]);

  // singleton (meta) classes must also donate to their bridge
  if (base._bridge) {
    base._bridge[id] = body;
  }
};

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

var mid_to_jsid = Opal.mid_to_jsid = function(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return '$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
};

var jsid_to_mid = Opal.jsid_to_mid = function(jsid) {
  if (reverse_method_names[jsid]) {
    return reverse_method_names[jsid];
  }

  jsid = jsid.substr(1); // remove '$'

  return jsid.replace('$b', '!').replace('$p', '?').replace('$e', '=');
};

var no_block_given = function() {
  throw new Error('no block given');
};

// Boot a base class (makes instances).
function boot_defclass(superklass) {
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
}

// Boot actual (meta classes) of core objects.
function boot_makemeta(id, klass, superklass) {
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
  result._proto = klass.prototype;

  top_const_scope[id] = result;

  return result;
}

// Create generic class with given superclass.
function boot_class(superklass) {
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

  result._proto = cls.prototype;

  return result;
}

function boot_module() {
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
}

// Get actual class ignoring singleton classes and iclasses.
function class_real(klass) {
  while (klass._isSingleton) {
    klass = klass._super;
  }

  return klass;
}

// Make metaclass for the given class
function make_metaclass(klass, superklass) {
  if (klass._isClass) {
    if (klass._isSingleton) {
      throw RubyException.$new('too much meta: return klass?');
    }
    else {
      var class_id = "#<Class:" + klass._name + ">",
          meta     = boot_class(superklass);

      meta._name = class_id;
      meta._alloc.prototype = klass.constructor.prototype;
      meta._proto = meta._alloc.prototype;
      meta._isSingleton = true;
      meta._klass = RubyClass;

      klass._klass = meta;

      meta._scope = klass._scope;
      meta.__attached__ = klass;

      return meta;
    }
  }
  else {
    var orig_class = klass._klass,
        class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

    var meta   = boot_class(orig_class);
    meta._name = class_id;

    meta._isSingleton = true;
    meta._bridge = klass;
    klass._klass = meta;
    meta.__attached__ = klass;
    meta._klass = class_real(orig_class)._klass;

    return meta;
  }
}

function bridge_class(constructor, id) {
  var klass     = define_class(RubyObject, id, RubyObject),
      prototype = constructor.prototype;

  klass._alloc = constructor;
  klass._proto = prototype;

  bridged_classes.push(klass);

  prototype._klass    = klass;
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
}

/**
  Actually define a new class with the name `id`. The superklass is
  required, and Object is currently the root class. The base is the
  parent scope of this class. For example, defining a root `Foo`
  class would have `Object` as the parent. Defining `Foo::Bar` would
  use `Foo` as the parent.

  @param [RubyClass] base the base class/module for this new class
  @param [String] id the name for this class
  @param [RubyClass] superklass the super class
  @return [RubyClass] returns new class with given attributes
*/
function define_class(base, id, superklass) {
  var klass   = boot_class(superklass);
  klass._name = (base === RubyObject ? id : base._name + '::' + id);

  make_metaclass(klass, superklass._klass);

  var const_alloc   = function() {};
  var const_scope   = const_alloc.prototype = new base._scope.alloc();
  klass._scope      = const_scope;
  const_scope.alloc = const_alloc;

  base._scope[id] = klass;

  if (superklass.$inherited) {
    superklass.$inherited(klass);
  }

  return klass;
}

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
function define_iclass(klass, module) {
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
}

/**
  This is a map of all file ids to their bodies. The file id is the
  id used to require a file, and it does not have an extension name.

  @type { String: Function }
*/
var factories = Opal.factories = {};

/**
  This holds the name of the current file being executed by opal. This
  gets set in require() below and it allows the file to get the
  __FILE__ variable. This should never be accessed manually.

  @type {String}
*/
Opal.file = "";

/**
  Register the body for the given file id name. This will then allow
  the file to be loaded with require().

  @param [String] id the file id
  @param [Function] body the body representing the file
*/
Opal.define = function(id, body) {
  factories[id] = body;
};

/**
  Require a specific file by id.

  @param [String] id file id to require
  @return [Boolean] if file has already been required
*/
Opal.require = function(id) {
  var body = factories[id];

  if (!body) {
    throw new Error("No file: '" + id + "'");
  }

  if (body._loaded) {
    return false;
  }

  Opal.file = id;

  body._loaded = true;
  body.call(Opal.top);

  return true;
};

// Initialization
// --------------

// The *instances* of core objects
var BootObject = boot_defclass();
var BootModule = boot_defclass(BootObject);
var BootClass  = boot_defclass(BootModule);

// The *classes' of core objects
var RubyObject = boot_makemeta('Object', BootObject, BootClass);
var RubyModule = boot_makemeta('Module', BootModule, RubyObject.constructor);
var RubyClass = boot_makemeta('Class', BootClass, RubyModule.constructor);

// Fix boot classes to use meta class
RubyObject._klass = RubyClass;
RubyModule._klass = RubyClass;
RubyClass._klass = RubyClass;

// fix superclasses
RubyObject._super = null;
RubyModule._super = RubyObject;
RubyClass._super = RubyModule;

var bridged_classes = RubyObject.$included_in = [];

RubyObject._scope = top_const_scope;

var module_const_alloc = function(){};
var module_const_scope = new top_const_alloc();
module_const_scope.alloc = module_const_alloc;
RubyModule._scope = module_const_scope;

var class_const_alloc = function(){};
var class_const_scope = new top_const_alloc();
class_const_scope.alloc = class_const_alloc;
RubyClass._scope = class_const_scope;

top_const_scope.BasicObject = RubyObject;

RubyObject._proto.toString = function() {
  return this.$to_s();
};

Opal.top = new RubyObject._alloc();

var RubyNilClass  = define_class(RubyObject, 'NilClass', RubyObject);
Opal.nil = new RubyNilClass._alloc();
Opal.nil.call = Opal.nil.apply = no_block_given;

var breaker = Opal.breaker  = new Error('unexpected break');
    breaker.$t              = function() { throw this; };
