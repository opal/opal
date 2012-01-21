var opal = this.opal = {};
opal.global = this;

// Minify common function calls
var hasOwnProperty  = Object.prototype.hasOwnProperty,
    $slice          = Array.prototype.slice;

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
opal.jump = function(value, func) {
  throw new Error(null, 'jump return');
};

// Get constant with given id
opal.const_get = function(const_table, id) {
  if (const_table[id]) {
    return const_table[id];
  }

  throw RubyNameError.$new(null, 'uninitialized constant ' + id);
};

// Table holds all class variables
opal.cvars = {};

// Array of all procs to be called at_exit
var end_procs = [];

// Call exit blocks in reverse order
opal.do_at_exit = function() {
  var proc;

  while (proc = end_procs.pop()) {
    proc.call(proc.$S);
  }
};

// Globals table
opal.gvars = {};

// Define a method alias
opal.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$proto[old_name];

  if (!body) {
    throw RubyNameError.$new(null, "undefined method `" + old_name + "' for class `" + klass.o$name + "'");
  }

  define_method(klass, new_name, body);
  return nil;
};

// method missing yielder - used in debug mode to call method_missing.
opal.mm = function(jsid) {
  var mid = jsid_to_mid(jsid);
  return function() {
    var args = $slice.call(arguments, 1);
    args.unshift(mid);
    args.unshift(null);
    return this.$method_missing.apply(this, args);
  };
}

// Actually define methods
var define_method = opal.defn = function(klass, id, body) {
  // If an object, make sure to use its class
  if (klass.o$flags & T_OBJECT) {
    klass = klass.o$klass;
  }

  klass.$allocator.prototype[id] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_method(includee, id, body);
    }
  }

  if (klass.$bridge_prototype) {
    klass.$bridge_prototype[id] = body;
  }


  return nil;
}

function define_module(base, id) {
  var module;

  module             = boot_module();
  module.o$name = (base === RubyObject ? id : base.o$name + '::' + id)

  make_metaclass(module, RubyModule);

  module.o$flags           = T_MODULE;
  module.$included_in = [];

  var const_alloc   = function() {};
  var const_scope   = const_alloc.prototype = new base.$const.alloc();
  module.$const     = const_scope;
  const_scope.alloc = const_alloc;

  base.$const[id]    = module;

  return module;
}

// opal define class. 0: regular, 1: module, 2: shift class.
opal.klass = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    case 0:
      if (base.o$flags & T_OBJECT) {
        base = class_real(base.o$klass);
      }

      if (superklass === nil) {
        superklass = RubyObject;
      }

      if (hasOwnProperty.call(base.$const, id)) {
        klass = base.$const[id];
      }
      else {
        klass = define_class(base, id, superklass);
      }

      break;

    case 1:
      if (base.o$flags & T_OBJECT) {
        base = class_real(base.o$klass);
      }

      if (hasOwnProperty.call(base.$const, id)) {
        klass = base.$const[id];
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

opal.slice = $slice;

opal.defs = function(base, id, body) {
  return define_method(base.$singleton_class(), id, body);
};

// Undefine one or more methods
opal.undef = function(klass) {
  var args = $slice.call(arguments, 1);

  for (var i = 0, length = args.length; i < length; i++) {
    var mid = args[i], id = mid_to_jsid[mid];

    delete klass.$m_tbl[id];
  }
};

// Calls a super method.
opal.zuper = function(callee, jsid, self, args) {
  var func = find_super(self.o$klass, callee, jsid);

  if (!func) {
    throw RubyNoMethodError.$new(null, "super: no superclass method `" +
            jsid_to_mid(jsid) + "'" + " for " + self.$inspect());
  }

  args.unshift(null); // block, this needs to be removed really

  return func.apply(self, args);
};

// dynamic super (inside block)
opal.dsuper = function(scopes, defn, jsid, self, args) {
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
    return opal.zuper(method, jsid, self, args);
  }
  else if (defn) {
    // blocks not define_method'd, but they were enclosed by a real method
    return opal.zuper(defn, jsid, self, args);
  }

  // if we get here then we were inside a nest of just blocks, and none have
  // been defined as a method
  throw RubyNoMethodError.$new(null, "super: cannot call super when not in method");
}

// Find function body for the super call
function find_super(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.$proto.hasOwnProperty(mid)) {
      if (klass.$proto[mid] === callee) {
        cur_method = klass.$proto[mid];
        break;
      }
    }
    klass = klass.$s;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.$s;

  while (klass) {
    if (klass.$proto.hasOwnProperty(mid)) {
      // make sure our found method isnt the same - this can happen if this
      // newly found method is from a module and we are now looking at the
      // module it came from.
      if (klass.$proto[mid] !== callee) {
        return klass.$proto[mid];
      }
    }

    klass = klass.$s;
  }
}

var mid_to_jsid = opal.mid_to_jsid = function(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return '$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

var jsid_to_mid = opal.jsid_to_mid = function(jsid) {
  if (reverse_method_names[jsid]) {
    return reverse_method_names[jsid];
  }

  jsid = jsid.substr(1); // remove '$'

  return jsid.replace('$b', '!').replace('$p', '?').replace('$e', '=');
}

opal.arg_error = function(given, expected) {
  throw RubyArgError.$new(null, 'wrong number of arguments(' + given + ' for ' + expected + ')');
};

// Boot a base class (makes instances).
function boot_defclass(superklass) {
  var cls = function() {
    this.o$id = unique_id++;

    return this;
  };

  if (superklass) {
    var ctor           = function() {};
        ctor.prototype = superklass.prototype;

    cls.prototype = new ctor();
  }

  cls.prototype.constructor = cls;
  cls.prototype.o$flags          = T_OBJECT;

  return cls;
}

// Boot actual (meta classes) of core objects.
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.o$id = unique_id++;

    return this;
  };

  var ctor           = function() {};
      ctor.prototype = superklass.prototype;

  meta.prototype = new ctor();

  var proto              = meta.prototype;
      proto.$included_in = [];
      proto.$allocator   = klass;
      proto.o$flags       = T_CLASS;
      proto.o$name  = id;
      proto.$s           = superklass;
      proto.constructor  = meta;

  var result = new meta();
  klass.prototype.o$klass = result;
  result.$proto = klass.prototype;

  return result;
}

// Create generic class with given superclass.
function boot_class(superklass) {
  // instances
  var cls = function() {
    this.o$id = unique_id++;

    return this;
  };

  var ctor = function() {};
      ctor.prototype = superklass.$allocator.prototype;

  cls.prototype = new ctor();

  var proto             = cls.prototype;
      proto.constructor = cls;
      proto.o$flags          = T_OBJECT;

  // class itself
  var meta = function() {
    this.o$id = unique_id++;

    return this;
  };

  var mtor = function() {};
      mtor.prototype = superklass.constructor.prototype;

  meta.prototype = new mtor();

  proto                            = meta.prototype;
  proto.$allocator                 = cls;
  proto.o$flags                     = T_CLASS;
  proto.constructor                = meta;
  proto.$s                         = superklass;

  var result = new meta();
  cls.prototype.o$klass = result;

  result.$proto = cls.prototype;

  return result;
}

function boot_module() {
  // where module "instance" methods go. will never be instantiated so it
  // can be a regular object
  var module_cons = function(){};
  var module_inst = module_cons.prototype;

  // Module itself
  var meta = function() {
    this.o$id = unique_id++;
    return this;
  };

  var mtor = function(){};
  mtor.prototype = RubyModule.constructor.prototype;
  meta.prototype = new mtor();

  var proto = meta.prototype;
  proto.$allocator  = module_cons;
  proto.o$flags      = T_MODULE;
  proto.constructor = meta;
  proto.$s          = null;

  var module          = new meta();
  module.$proto       = module_inst;

  return module;
}

// Get actual class ignoring singleton classes and iclasses.
function class_real(klass) {
  while (klass.o$flags & FL_SINGLETON) {
    klass = klass.$s;
  }

  return klass;
}

// Make metaclass for the given class
function make_metaclass(klass, superklass) {
  if (klass.o$flags & T_CLASS) {
    if ((klass.o$flags & T_CLASS) && (klass.o$flags & FL_SINGLETON)) {
      throw RubyException.$new(null, 'too much meta: return klass?');
    }
    else {
      var class_id = "#<Class:" + klass.o$name + ">",
          meta     = boot_class(superklass);

      meta.o$name = class_id;
      meta.$allocator.prototype = klass.constructor.prototype;
      meta.$proto = meta.$allocator.prototype;
      meta.o$flags |= FL_SINGLETON;
      meta.o$klass = RubyClass;

      klass.o$klass = meta;

      meta.$const = klass.$const;
      meta.__attached__ = klass;

      return meta;
    }
  }
  else {
    return make_singleton_class(klass);
  }
}

function make_singleton_class(obj) {
  var orig_class = obj.o$klass,
      class_id   = "#<Class:#<" + orig_class.o$name + ":" + orig_class.o$id + ">>";

  klass             = boot_class(orig_class);
  klass.o$name = class_id;

  klass.o$flags                |= FL_SINGLETON;
  klass.$bridge_prototype  = obj;

  obj.o$klass = klass;

  klass.__attached__ = obj;

  klass.o$klass = class_real(orig_class).o$klass;

  return klass;
}

function bridge_class(constructor, flags, id) {
  var klass     = define_class(RubyObject, id, RubyObject),
      prototype = constructor.prototype;

  klass.$allocator = constructor;
  klass.$proto = prototype;

  bridged_classes.push(klass);

  prototype.o$klass = klass;
  prototype.o$flags = flags;

  return klass;
}

// Define new ruby class
function define_class(base, id, superklass) {
  var klass;

  var class_id = (base === RubyObject ? id : base.o$name + '::' + id);

  klass             = boot_class(superklass);
  klass.o$name = class_id;

  make_metaclass(klass, superklass.o$klass);

  var const_alloc   = function() {};
  var const_scope   = const_alloc.prototype = new base.$const.alloc();
  klass.$const      = const_scope;
  const_scope.alloc = const_alloc;

  base.$const[id] = klass;

  if (superklass.$inherited) {
    superklass.$inherited(null, klass);
  }

  return klass;
}

function define_iclass(klass, module) {
  var sup = klass.$s;

  var iclass = {};
  iclass.$proto = module.$proto;
  iclass.$s = sup;
  iclass.o$flags = T_ICLASS;
  iclass.o$klass = module;
  iclass.o$name  = module.o$name;

  klass.$s = iclass;

  return iclass;
}

opal.main = function(id) {
  opal.gvars.$0 = find_lib(id);
  top_self.$require(null, id);
  opal.do_at_exit();
};

/**
 * Register a standard file. This can be used to register non-lib files.
 * For example, specs can be registered here so they are available.
 *
 * NOTE: Files should be registered as a 'relative' path without an
 * extension
 *
 * Usage:
 *
 *    opal.file('browser', function() { ... });
 *    opal.file('spec/foo', function() { ... });
 */
opal.file = function(file, factory) {
  FACTORIES['/' + file + '.rb'] = factory;
};

var FACTORIES    = {},
    FEATURES     = [],
    LOADER_PATHS = ['', '/lib'],
    LOADER_CACHE = {};

function find_lib(id) {
  var path;

  // require 'foo'
  // require 'foo/bar'
  if (FACTORIES[path = '/' + id + '.rb']) return path;

  // require '/foo'
  // require '/foo/bar'
  if (FACTORIES[path = id + '.rb']) return path;

  // require '/foo.rb'
  // require '/foo/bar.rb'
  if (FACTORIES[id]) return id;
};

// Current working directory
var FS_CWD = '/';

// Turns a glob string into a regexp

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
RubyObject.o$klass = RubyClass;
RubyModule.o$klass = RubyClass;
RubyClass.o$klass = RubyClass;

// fix superclasses
RubyObject.$s = null;
RubyModule.$s = RubyObject;
RubyClass.$s = RubyModule;

opal.Object = RubyObject;
opal.Module = RubyModule;
opal.Class  = RubyClass;

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

RubyObject.$const = opal.constants = top_const_scope;

var module_const_alloc = function(){};
var module_const_scope = new top_const_alloc();
module_const_scope.alloc = module_const_alloc;
RubyModule.$const = module_const_scope;

var class_const_alloc = function(){};
var class_const_scope = new top_const_alloc();
class_const_scope.alloc = class_const_alloc;
RubyClass.$const = class_const_scope;

RubyObject.$const.BasicObject = RubyObject;
RubyObject.$const.Object = RubyObject;
RubyObject.$const.Module = RubyModule;
RubyObject.$const.Class = RubyClass;

// Every ruby object (except natives) will have their #to_s method aliased
// to the native .toString() function so that accessing ruby objects from
// javascript will return a nicer string format. This is also used when
// interpolating objects into strings as the js engine will call toString
// which in turn calls #to_s.
//
// This is also used as the hashing function. In ruby, #hash should return
// an integer. This is not possible in opal as strings cannot be mutable
// and can not therefore have unique integer hashes. Seeing as strings or
// symbols are used more often as hash keys, this role is changed in opal
// so that hash values should be strings, and this function makes the #to_s
// value for an object the default.
RubyObject.$proto.toString = function() {
  return this.$to_s();
};

var top_self = opal.top = new RubyObject.$allocator();

var RubyNilClass  = define_class(RubyObject, 'NilClass', RubyObject);
var nil = opal.nil = new RubyNilClass.$allocator();

// Make `nil` act like a function. This is used when a method is not
// given a block. The block value becomes `nil`, so yielding to it will
// call this function which simply raises the usual `'no block given'`
// error.
nil.call = nil.apply = function() {
  throw RubyLocalJumpError.$new(null, 'no block given');
};

bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');
bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');

bridge_class(String, T_OBJECT | T_STRING, 'String');
bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
bridge_class(RegExp, T_OBJECT, 'Regexp');

var RubyMatch     = define_class(RubyObject, 'MatchData', RubyObject);
var RubyRange     = define_class(RubyObject, 'Range', RubyObject);
RubyRange.$proto.o$flags = T_OBJECT | T_RANGE;

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

RubyException.$allocator.prototype.toString = function() {
  return this.o$klass.o$name + ': ' + this.message;
};

var breaker = opal.breaker  = new Error('unexpected break');
    breaker.o$klass              = RubyLocalJumpError;
    breaker.$t              = function() { throw this; };

