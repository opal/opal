var Opal = this.Opal = {};

Opal.global = this;

// Minify common function calls
var __hasOwn = Object.prototype.hasOwnProperty,
    __slice  = Array.prototype.slice;

// Types - also added to bridged objects
var T_CLASS      = 0x0001,
    T_MODULE     = 0x0002,
    T_OBJECT     = 0x0004,
    T_BOOLEAN    = 0x0008,
    T_STRING     = 0x0010,
    T_ARRAY      = 0x0020,
    T_NUMBER     = 0x0040,
    T_PROC       = 0x0080,
    T_HASH       = 0x0100,
    T_RANGE      = 0x0200,
    T_ICLASS     = 0x0400,
    FL_SINGLETON = 0x0800;

// Generates unique id for every ruby object
var unique_id = 0;

// Jump return - return in proc body
Opal.jump = function(value, func) {
  throw new Error('jump return');
};

// Get constant with given id
Opal.const_get = function(const_table, id) {
  if (const_table[id]) {
    return const_table[id];
  }

  throw RubyNameError.$new('uninitialized constant ' + id);
};

// Table holds all class variables
Opal.cvars = {};

// Globals table
Opal.gvars = {};

// Define a method alias
Opal.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass._proto[old_name];

  if (!body) {
    // throw RubyNameError.$new(null, "undefined method `" + old_name + "' for class `" + klass._name + "'");
    throw new Error("undefined method `" + old_name + "' for class `" + klass._name + "'");
  }

  define_method(klass, new_name, body);
  return null;
};

// Actually define methods
var define_method = Opal.defn = function(klass, id, body) {
  // If an object, make sure to use its class
  if (klass._flags & T_OBJECT) {
    klass = klass._klass;
  }

  klass._alloc.prototype[id] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_method(includee, id, body);
    }
  }

  if (klass._bridge) {
    klass._bridge[id] = body;
  }


  return null;
}

function define_module(base, id) {
  var module;

  module             = boot_module();
  module._name = (base === RubyObject ? id : base._name + '::' + id)

  make_metaclass(module, RubyModule);

  module._flags           = T_MODULE;
  module.$included_in = [];

  var const_alloc   = function() {};
  var const_scope   = const_alloc.prototype = new base._scope.alloc();
  module._scope     = const_scope;
  const_scope.alloc = const_alloc;

  base._scope[id]    = module;

  return module;
}

// Opal define class. 0: regular, 1: module, 2: shift class.
Opal.klass = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    case 0:
      if (base._flags & T_OBJECT) {
        base = class_real(base._klass);
      }

      if (superklass === null) {
        superklass = RubyObject;
      }

      if (__hasOwn.call(base._scope, id)) {
        klass = base._scope[id];
      }
      else {
        klass = define_class(base, id, superklass);
      }

      break;

    case 1:
      if (base._flags & T_OBJECT) {
        base = class_real(base._klass);
      }

      if (__hasOwn.call(base._scope, id)) {
        klass = base._scope[id];
      }
      else {
        klass = define_module(base, id);
      }

      break;

    case 2:
      klass = base.$singleton_class();
      break;
  }

  return body.call(klass);
};

Opal.slice = __slice;

Opal.defs = function(base, id, body) {
  return define_method(base.$singleton_class(), id, body);
};

// Undefine one or more methods
Opal.undef = function(klass) {
  var args = __slice.call(arguments, 1);

  for (var i = 0, length = args.length; i < length; i++) {
    var mid = args[i], id = mid_to_jsid[mid];

    delete klass.$m_tbl[id];
  }
};

// Calls a super method.
Opal.zuper = function(callee, jsid, self, args) {
  var func = find_super(self._klass, callee, jsid);

  if (!func) {
    throw RubyNoMethodError.$new(null, "super: no superclass method `" +
            jsid_to_mid(jsid) + "'" + " for " + self.$inspect());
  }

  return func.apply(self, args);
};

// dynamic super (inside block)
Opal.dsuper = function(scopes, defn, jsid, self, args) {
  var method, scope = scopes[0];

  for (var i = 0, length = scopes.length; i < length; i++) {
    if (scope.o$jsid) {
      jsid = scope.o$jsid;
      method = scope;
      break;
    }
  }

  if (method) {
    // one of the nested blocks was define_method'd
    return Opal.zuper(method, jsid, self, args);
  }
  else if (defn) {
    // blocks not define_method'd, but they were enclosed by a real method
    return Opal.zuper(defn, jsid, self, args);
  }

  // if we get here then we were inside a nest of just blocks, and none have
  // been defined as a method
  throw RubyNoMethodError.$new(null, "super: cannot call super when not in method");
}

// Find function body for the super call
function find_super(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass._proto.hasOwnProperty(mid)) {
      if (klass._proto[mid] === callee) {
        cur_method = klass._proto[mid];
        break;
      }
    }
    klass = klass._super;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass._super;

  while (klass) {
    if (klass._proto.hasOwnProperty(mid)) {
      // make sure our found method isnt the same - this can happen if this
      // newly found method is from a module and we are now looking at the
      // module it came from.
      if (klass._proto[mid] !== callee) {
        return klass._proto[mid];
      }
    }

    klass = klass._super;
  }
}

var mid_to_jsid = Opal.mid_to_jsid = function(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return '$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

var jsid_to_mid = Opal.jsid_to_mid = function(jsid) {
  if (reverse_method_names[jsid]) {
    return reverse_method_names[jsid];
  }

  jsid = jsid.substr(1); // remove '$'

  return jsid.replace('$b', '!').replace('$p', '?').replace('$e', '=');
}

Opal.arg_error = function(given, expected) {
  throw RubyArgError.$new(null, 'wrong number of arguments(' + given + ' for ' + expected + ')');
};

// Boot a base class (makes instances).
function boot_defclass(superklass) {
  var cls = function() {
    this._id = unique_id++;

    return this;
  };

  if (superklass) {
    var ctor           = function() {};
        ctor.prototype = superklass.prototype;

    cls.prototype = new ctor();
  }

  cls.prototype.constructor = cls;
  cls.prototype._flags          = T_OBJECT;

  return cls;
}

// Boot actual (meta classes) of core objects.
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this._id = unique_id++;

    return this;
  };

  var ctor           = function() {};
      ctor.prototype = superklass.prototype;

  meta.prototype = new ctor();

  var proto              = meta.prototype;
      proto.$included_in = [];
      proto._alloc   = klass;
      proto._flags       = T_CLASS;
      proto._name  = id;
      proto._super           = superklass;
      proto.constructor  = meta;

  var result = new meta();
  klass.prototype._klass = result;
  result._proto = klass.prototype;

  return result;
}

// Create generic class with given superclass.
function boot_class(superklass) {
  // instances
  var cls = function() {
    this._id = unique_id++;

    return this;
  };

  var ctor = function() {};
      ctor.prototype = superklass._alloc.prototype;

  cls.prototype = new ctor();

  var proto             = cls.prototype;
      proto.constructor = cls;
      proto._flags          = T_OBJECT;

  // class itself
  var meta = function() {
    this._id = unique_id++;

    return this;
  };

  var mtor = function() {};
      mtor.prototype = superklass.constructor.prototype;

  meta.prototype = new mtor();

  proto                            = meta.prototype;
  proto._alloc                 = cls;
  proto._flags                     = T_CLASS;
  proto.constructor                = meta;
  proto._super                         = superklass;

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
    return this;
  };

  var mtor = function(){};
  mtor.prototype = RubyModule.constructor.prototype;
  meta.prototype = new mtor();

  var proto = meta.prototype;
  proto._alloc  = module_cons;
  proto._flags      = T_MODULE;
  proto.constructor = meta;
  proto._super          = null;

  var module          = new meta();
  module._proto       = module_inst;

  return module;
}

// Get actual class ignoring singleton classes and iclasses.
function class_real(klass) {
  while (klass._flags & FL_SINGLETON) {
    klass = klass._super;
  }

  return klass;
}

// Make metaclass for the given class
function make_metaclass(klass, superklass) {
  if (klass._flags & T_CLASS) {
    if ((klass._flags & T_CLASS) && (klass._flags & FL_SINGLETON)) {
      throw RubyException.$new('too much meta: return klass?');
    }
    else {
      var class_id = "#<Class:" + klass._name + ">",
          meta     = boot_class(superklass);

      meta._name = class_id;
      meta._alloc.prototype = klass.constructor.prototype;
      meta._proto = meta._alloc.prototype;
      meta._flags |= FL_SINGLETON;
      meta._klass = RubyClass;

      klass._klass = meta;

      meta._scope = klass._scope;
      meta.__attached__ = klass;

      return meta;
    }
  }
  else {
    return make_singleton_class(klass);
  }
}

function make_singleton_class(obj) {
  var orig_class = obj._klass,
      class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

  klass             = boot_class(orig_class);
  klass._name = class_id;

  klass._flags                |= FL_SINGLETON;
  klass._bridge  = obj;

  obj._klass = klass;

  klass.__attached__ = obj;

  klass._klass = class_real(orig_class)._klass;

  return klass;
}

function bridge_class(constructor, flags, id) {
  var klass     = define_class(RubyObject, id, RubyObject),
      prototype = constructor.prototype;

  klass._alloc = constructor;
  klass._proto = prototype;

  bridged_classes.push(klass);

  prototype._klass = klass;
  prototype._flags = flags;

  return klass;
}

// Define new ruby class
function define_class(base, id, superklass) {
  var klass;

  var class_id = (base === RubyObject ? id : base._name + '::' + id);

  klass             = boot_class(superklass);
  klass._name = class_id;

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

function define_iclass(klass, module) {
  var sup = klass._super;

  var iclass = {};
  iclass._proto = module._proto;
  iclass._super = sup;
  iclass._flags = T_ICLASS;
  iclass._klass = module;
  iclass._name  = module._name;

  klass._super = iclass;

  return iclass;
}

// Handling requires
function require_handler(path) {
  throw new Error('Cannot require ' + path);
}

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

Opal.Object = RubyObject;
Opal.Module = RubyModule;
Opal.Class  = RubyClass;

// Make object act like a module. Internally, `Object` gets included
// into all the bridged classes. This is because the native prototypes
// for these bridged classes need to get all the `Object` methods as
// well. This allows `Object` to just donate its instance methods to
// the bridged classes using the exact same method that modules use.
var bridged_classes = RubyObject.$included_in = [];

// Top level Object scope (used by object and top_self).
var top_const_alloc     = function(){};
var top_const_scope     = top_const_alloc.prototype;
top_const_scope.alloc   = top_const_alloc; 

RubyObject._scope = Opal.constants = top_const_scope;

var module_const_alloc = function(){};
var module_const_scope = new top_const_alloc();
module_const_scope.alloc = module_const_alloc;
RubyModule._scope = module_const_scope;

var class_const_alloc = function(){};
var class_const_scope = new top_const_alloc();
class_const_scope.alloc = class_const_alloc;
RubyClass._scope = class_const_scope;

RubyObject._scope.BasicObject = RubyObject;
RubyObject._scope.Object = RubyObject;
RubyObject._scope.Module = RubyModule;
RubyObject._scope.Class = RubyClass;

// Every ruby object (except natives) will have their #to_s method aliased
// to the native .toString() function so that accessing ruby objects from
// javascript will return a nicer string format. This is also used when
// interpolating objects into strings as the js engine will call toString
// which in turn calls #to_s.
//
// This is also used as the hashing function. In ruby, #hash should return
// an integer. This is not possible in Opal as strings cannot be mutable
// and can not therefore have unique integer hashes. Seeing as strings or
// symbols are used more often as hash keys, this role is changed in Opal
// so that hash values should be strings, and this function makes the #to_s
// value for an object the default.
RubyObject._proto.toString = function() {
  return this.$to_s();
};

var top_self = Opal.top = new RubyObject._alloc();

var RubyNilClass  = define_class(RubyObject, 'NilClass', RubyObject);
Opal.nil = new RubyNilClass._alloc();

bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');
bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');

bridge_class(String, T_OBJECT | T_STRING, 'String');
bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
bridge_class(RegExp, T_OBJECT, 'Regexp');

var RubyMatch     = define_class(RubyObject, 'MatchData', RubyObject);
var RubyRange     = define_class(RubyObject, 'Range', RubyObject);
RubyRange._proto._flags = T_OBJECT | T_RANGE;

var RubyException      = bridge_class(Error, T_OBJECT, 'Exception');
var RubyStandardError  = define_class(RubyObject, 'StandardError', RubyException);
var RubyRuntimeError   = define_class(RubyObject, 'RuntimeError', RubyException);
var RubyLocalJumpError = define_class(RubyObject, 'LocalJumpError', RubyStandardError);
var RubyTypeError      = define_class(RubyObject, 'TypeError', RubyStandardError);
var RubyNameError      = define_class(RubyObject, 'NameError', RubyStandardError);
var RubyNoMethodError  = define_class(RubyObject, 'NoMethodError', RubyNameError);
var RubyArgError       = define_class(RubyObject, 'ArgumentError', RubyStandardError);
var RubyScriptError    = define_class(RubyObject, 'ScriptError', RubyException);
var RubyLoadError      = define_class(RubyObject, 'LoadError', RubyScriptError);
var RubyIndexError     = define_class(RubyObject, 'IndexError', RubyStandardError);
var RubyKeyError       = define_class(RubyObject, 'KeyError', RubyIndexError);
var RubyRangeError     = define_class(RubyObject, 'RangeError', RubyStandardError);
var RubyNotImplError   = define_class(RubyObject, 'NotImplementedError', RubyException);

RubyException._alloc.prototype.toString = function() {
  return this._klass._name + ': ' + this.message;
};

var breaker = Opal.breaker  = new Error('unexpected break');
    breaker._klass              = RubyLocalJumpError;
    breaker.$t              = function() { throw this; };

