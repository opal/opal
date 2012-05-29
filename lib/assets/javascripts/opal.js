/*!
 * Opal v0.3.18
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT License
 */
(function(undefined) {
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

    delete klass._proto[id];
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


var method_names = {'==': '$eq$', '===': '$eqq$', '[]': '$aref$', '[]=': '$aset$', '~': '$tild$', '<=>': '$cmp$', '=~': '$match$', '+': '$plus$', '-': '$minus$', '/': '$div$', '*': '$mul$', '<': '$lt$', '<=': '$le$', '>': '$gt$', '>=': '$ge$', '<<': '$lshft$', '>>': '$rshft$', '|': '$or$', '&': '$and$', '^': '$xor$', '+@': '$uplus$', '-@': '$uminus$', '%': '$mod$', '**': '$pow$'},
reverse_method_names = {};
for (var id in method_names) {
reverse_method_names[method_names[id]] = id;
}
(function() {
var __scope = Opal.constants, nil = Opal.nil, __breaker = Opal.breaker, __klass = Opal.klass, __const_get = Opal.const_get, __slice = Opal.slice, __gvars = Opal.gvars, __alias = Opal.alias, __defs = Opal.defs;

  __gvars["$~"] = nil;
  __gvars["$/"] = "\n";
  __scope.RUBY_ENGINE = "opal";
  __scope.RUBY_PLATFORM = "opal";
  __scope.RUBY_VERSION = "1.9.2";
  __klass(this, null, "Module", function() {
    var __scope = this._scope, def = this._proto; 
    def.$eqq$ = function(object) {
      
      
      var search = object._klass;

      while (search) {
        if (search === this) {
          return true;
        }

        search = search._super;
      }

      return false;
    
    };
    def.$alias_method = function(newname, oldname) {
      
      opal.alias(this, newname, oldname);
      return this;
    };
    def.$ancestors = function() {
      
      
      var parent = this,
          result = [];

      while (parent) {
        if (parent._flags & FL_SINGLETON) {
          continue;
        }
        else if (parent._flags & T_ICLASS)
          result.push(parent._klass);
        else {
          result.push(parent);
        }

        parent = parent._super;
      }

      return result;
    
    };
    def.$append_features = function(klass) {
      
      
      var module = this;

      if (!klass.$included_modules) {
        klass.$included_modules = [];
      }

      if (klass.$included_modules.indexOf(module) != -1) {
        return;
      }

      klass.$included_modules.push(module);

      if (!module.$included_in) {
        module.$included_in = [];
      }

      module.$included_in.push(klass);

      var donator   = module._alloc.prototype,
          prototype = klass._proto,
          methods   = [];

      for (var method in donator) {
        if (hasOwnProperty.call(donator, method)) {
          if (!prototype.hasOwnProperty(method)) {
            prototype[method] = donator[method];
            methods.push(method);
          }
        }
      }

      if (klass.$included_in) {
        klass.$donate(methods);
      }
    
      return this;
    };
    
    function define_attr(klass, name, getter, setter) {
      if (getter) {
        define_method(klass, mid_to_jsid(name), function() {
          var res = this[name];

          return res == null ? null : res;
        });
      }

      if (setter) {
        define_method(klass, mid_to_jsid(name + '='), function(val) {
          return this[name] = val;
        });
      }
    }
  
    def.$attr_accessor = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return null;
    
    };
    def.$attr_reader = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return null;
    
    };
    def.$attr_writer = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return null;
    
    };
    def.$attr = function(name, setter) {
      if (setter == null) {
        setter = false;
      }
      define_attr(this, name, true, setter);
      return this;
    };
    def.$define_method = $TMP_1 = function(name) {
      var __context = nil, body = nil; 
      if (body = $TMP_1._p) {
        __context = body._s;
        $TMP_1._p = null;
      }
      
      if (body === null) {
        throw RubyLocalJumpError.$new('no block given');
      }

      var jsid = mid_to_jsid(name);

      body.o$jsid = jsid;
      define_method(this, jsid, body);

      return null;
    
    };
    def.$donate = function(methods) {
      
      
      var included_in = this.$included_in, includee, method, table = this._proto, dest;

      if (included_in) {
        for (var i = 0, length = included_in.length; i < length; i++) {
          includee = included_in[i];
          dest = includee._proto;
          for (var j = 0, jj = methods.length; j < jj; j++) {
            method = methods[j];
            // if (!dest[method]) {
              dest[method] = table[method];
            // }
          }
          // if our includee is itself included in another module/class then it
          // should also donate its new methods
          if (includee.$included_in) {
            includee.$donate(methods);
          }
        }
      }
    
    };
    def.$include = function(mods) {
      var mod = nil; mods = __slice.call(arguments, 0);
      
      var i = mods.length - 1, mod;
      while (i >= 0) {
        mod = mods[i];

        define_iclass(this, mod);

        mod.$append_features(this);
        mod.$included(this);

        i--;
      }

      return this;
    
    };
    def.$instance_methods = function() {
      
      return [];
    };
    def.$included = function(mod) {
      
      return nil;
    };
    def.$module_eval = $TMP_2 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_2._p) {
        __context = block._s;
        $TMP_2._p = null;
      }
      
      if (block === null) {
        throw RubyLocalJumpError.$new('no block given');
      }

      return block.call(this, null);
    
    };
    __alias(this, "class_eval", "module_eval");
    def.$name = function() {
      
      return this._name;
    };
    __alias(this, "public_instance_methods", "instance_methods");
    return __alias(this, "to_s", "name");
  }, 0);
  __klass(this, null, "Kernel", function() {
    var __scope = this._scope, def = this._proto; 
    def.$match$ = function(obj) {
      
      return false;
    };
    def.$eqq$ = function(other) {
      
      return this == other;
    };
    def.$Array = function(object) {
      var __a; 
      if ((__a = object) !== false && __a !== nil) {

        } else {
        return []
      };
      
      if (object.$to_ary) {
        return object.$to_ary();
      }
      else if (object.$to_a) {
        return object.$to_a();
      }

      var length = object.length || 0,
          result = [];

      while (length--) {
        result[length] = object[length];
      }

      return result;
    
    };
    def.$at_exit = $TMP_3 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_3._p) {
        __context = block._s;
        $TMP_3._p = null;
      }
      
      if (block === null) {
        throw RubyArgError.$new('called without a block');
      }

      end_procs.push(block);

      return block;
    
    };
    def.$class = function() {
      
      return class_real(this._klass);
    };
    def.$define_singleton_method = $TMP_4 = function(name) {
      var __context = nil, body = nil; 
      if (body = $TMP_4._p) {
        __context = body._s;
        $TMP_4._p = null;
      }
      
      if (body === null) {
        throw RubyLocalJumpError.$new('no block given');
      }

      opal.defs(this, mid_to_jsid(name), body);

      return this;
    
    };
    def.$equal$p = function(other) {
      
      return this === other;
    };
    def.$extend = function(mods) {
      mods = __slice.call(arguments, 0);
      
      for (var i = 0, length = mods.length; i < length; i++) {
        include_module(singleton_class(this), mods[i]);
      }

      return this;
    
    };
    def.$format = function(string, arguments) {
      arguments = __slice.call(arguments, 1);
      return this.$raise(__scope.NotImplementedError);
    };
    def.$hash = function() {
      
      return this._id;
    };
    def.$inspect = function() {
      
      return this.$to_s();
    };
    def.$instance_of$p = function(klass) {
      
      return this._klass === klass;
    };
    def.$instance_variable_defined$p = function(name) {
      
      return hasOwnProperty.call(this, name.substr(1));
    };
    def.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == undefined ? null : ivar;
    
    };
    def.$instance_variable_set = function(name, value) {
      
      return this[name.substr(1)] = value;
    };
    def.$instance_variables = function() {
      
      
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    
    };
    def.$is_a$p = function(klass) {
      
      
      var search = this._klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search._super;
      }

      return false;
    
    };
    __alias(this, "kind_of?", "is_a?");
    def.$lambda = $TMP_5 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_5._p) {
        __context = block._s;
        $TMP_5._p = null;
      }
      return block;
    };
    def.$loop = $TMP_6 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_6._p) {
        __context = block._s;
        $TMP_6._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("loop")
      };
      
      while (true) {
        if (block.call(__context) === breaker) {
          return breaker.$v;
        }
      }

      return this;
    
    };
    def.$nil$p = function() {
      
      return false;
    };
    def.$object_id = function() {
      
      return this._id || (this._id = unique_id++);
    };
    def.$print = function(strs) {
      strs = __slice.call(arguments, 0);
      return this.$puts.apply(this, strs);
    };
    def.$private = function() {
      
      return nil;
    };
    def.$proc = $TMP_7 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_7._p) {
        __context = block._s;
        $TMP_7._p = null;
      }
      return block;
    };
    def.$protected = function() {
      
      return nil;
    };
    def.$public = function() {
      
      return nil;
    };
    def.$puts = function(strs) {
      strs = __slice.call(arguments, 0);
      
      for (var i = 0; i < strs.length; i++) {
        var obj = strs[i];
        console.log(obj == null ? "nil" : obj.$to_s());
      }
    
    };
    __alias(this, "sprintf", "format");
    def.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = (RubyRuntimeError).$new(exception);
      }
      else if (!exception.$is_a$p(RubyException)) {
        exception = (exception).$new(string);
      }

      throw exception;
    
    };
    def.$rand = function(max) {
      
      return max === undefined ? Math.random() : Math.floor(Math.random() * max);
    };
    def.$require = function(path) {
      
      require_handler(path);
    };
    def.$respond_to$p = function(name) {
      
      return !!this[mid_to_jsid(name)];
    };
    def.$singleton_class = function() {
      
      
      var obj = this, klass;

      if (obj._flags & T_OBJECT) {
        if ((obj._flags & T_NUMBER) || (obj._flags & T_STRING)) {
          throw RubyTypeError.$new("can't define singleton");
        }
      }

      if ((obj._klass._flags & FL_SINGLETON) && obj._klass.__attached__ == obj) {
        klass = obj._klass;
      }
      else {
        var class_id = obj._klass._name;

        klass = make_metaclass(obj, obj._klass);
      }

      return klass;
    
    };
    def.$tap = $TMP_8 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_8._p) {
        __context = block._s;
        $TMP_8._p = null;
      }
      
      if (block === null) {
        throw RubyLocalJumpError.$new('no block given');
      }

      if (block.call(__context, this) === __breaker) {
        return __breaker.$v;
      }

      return this;
    
    };
    def.$to_s = function() {
      
      return "#<" + class_real(this._klass)._name + ":0x" + (this._id * 400487).toString(16) + ">";
    };
    ;this.$donate(["$match$", "$eqq$", "$Array", "$at_exit", "$class", "$define_singleton_method", "$equal$p", "$extend", "$format", "$hash", "$inspect", "$instance_of$p", "$instance_variable_defined$p", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a$p", "$lambda", "$loop", "$nil$p", "$object_id", "$print", "$private", "$proc", "$protected", "$public", "$puts", "$raise", "$rand", "$require", "$respond_to$p", "$singleton_class", "$tap", "$to_s"]);
  }, 1);
  __klass(this, null, "BasicObject", function() {
    var __scope = this._scope, def = this._proto; 
    def.$initialize = function() {
      
      return nil;
    };
    def.$eq$ = function(other) {
      
      return this === other;
    };
    def.$__send__ = $TMP_9 = function(symbol, args) {
      var __context = nil, block = nil; 
      if (block = $TMP_9._p) {
        __context = block._s;
        $TMP_9._p = null;
      }args = __slice.call(arguments, 1);
      
      var meth = this[mid_to_jsid(symbol)] || opal.mm(mid_to_jsid(symbol));
      args.unshift(block);

      return meth.apply(this, args);
    
    };
    __alias(this, "send", "__send__");
    __alias(this, "eql?", "==");
    __alias(this, "equal?", "==");
    def.$instance_eval = $TMP_10 = function(string) {
      var __context = nil, block = nil; 
      if (block = $TMP_10._p) {
        __context = block._s;
        $TMP_10._p = null;
      }
      
      if (block == null) {
        throw RubyArgError.$new('block not supplied');
      }

      return block.call(this, null, this);
    
    };
    def.$instance_exec = $TMP_11 = function(args) {
      var __context = nil, block = nil; 
      if (block = $TMP_11._p) {
        __context = block._s;
        $TMP_11._p = null;
      }args = __slice.call(arguments, 0);
      
      if (block == null) {
        throw RubyArgError.$new('block not supplied');
      }

      return block.apply(this, args);
    
    };
    def.$method_missing = function(symbol, args) {
      args = __slice.call(arguments, 1);
      throw RubyNoMethodError.$new(null, 'undefined method `' + symbol + '` for ' + this.$inspect());
      return this;
    };
    def.$singleton_method_added = function(symbol) {
      
      return nil;
    };
    def.$singleton_method_removed = function(symbol) {
      
      return nil;
    };
    def.$singleton_method_undefined = function(symbol) {
      
      return nil;
    };
;this.$donate(["$initialize", "$eq$", "$__send__", "$instance_eval", "$instance_exec", "$method_missing", "$singleton_method_added", "$singleton_method_removed", "$singleton_method_undefined"]);
  }, 0);
  __klass(this, null, "Object", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Kernel);
    def.$methods = function() {
      
      return [];
    };
    __alias(this, "private_methods", "methods");
    __alias(this, "protected_methods", "methods");
    __alias(this, "public_methods", "methods");
    def.$singleton_methods = function() {
      
      return [];
    };
;this.$donate(["$methods", "$singleton_methods"]);
  }, 0);
  __defs(this, '$to_s', function() {
    
    return "main"
  });
  __defs(this, '$include', function(mod) {
    
    return __scope.Object.$include(mod)
  });
  __klass(this, null, "Class", function() {
    var __scope = this._scope, def = this._proto; 
    __defs(this, '$new', $TMP_12 = function(sup) {
      var __context = nil, block = nil; 
      if (block = $TMP_12._p) {
        __context = block._s;
        $TMP_12._p = null;
      }if (sup == null) {
        sup = __scope.Object;
      }
      
      var klass        = boot_class(sup);
          klass._name = "AnonClass";

      make_metaclass(klass, sup._klass);

      sup.$inherited(klass);

      if (block !== null) {
        block.call(klass, null);
      }

      return klass;
    
    });
    def.$bridge_class = function(constructor) {
      
      
      var prototype = constructor.prototype,
          klass     = this;

      klass._alloc = constructor;
      klass._proto     = prototype;

      bridged_classes.push(klass);

      prototype._klass = klass;
      prototype._flags  = T_OBJECT;

      var donator = RubyObject._proto;
      for (var method in donator) {
        if (donator.hasOwnProperty(method)) {
          if (!prototype[method]) {
            prototype[method] = donator[method];
          }
        }
      }

      return klass;
    
    };
    def.$allocate = function() {
      
      return new this._alloc();
    };
    def.$new = $TMP_13 = function(args) {
      var obj = nil, __context = nil, block = nil, __a, __b; 
      if (block = $TMP_13._p) {
        __context = block._s;
        $TMP_13._p = null;
      }args = __slice.call(arguments, 0);
      obj = this.$allocate();
      (((__a = (__b = obj).$initialize)._p = (block || function(){}))._s = this, __a).apply(__b, args);
      return obj;
    };
    def.$inherited = function(cls) {
      
      return nil;
    };
    return def.$superclass = function() {
      
      
      var sup = this._super;

      if (!sup) {
        if (this === RubyObject) {
          return null;
        }

        throw RubyRuntimeError.$new('uninitialized class');
      }

      while (sup && (sup._flags & T_ICLASS)) {
        sup = sup._super;
      }

      if (!sup) {
        return null;
      }

      return sup;
    
    };
  }, 0);
  __klass(this, null, "Boolean", function() {
    var __scope = this._scope, def = this._proto; 
    def.$and$ = function(other) {
      
      return (this == true) ? (other !== false && other !== nil) : false;
    };
    def.$or$ = function(other) {
      
      return (this == true) ? true : (other !== false && other !== nil);
    };
    def.$xor$ = function(other) {
      
      return (this == true) ? (other === false || other === nil) : (other !== false && other !== nil);
    };
    def.$eq$ = function(other) {
      
      return (this == true) === other.valueOf();
    };
    def.$class = function() {
      
      return (this == true) ? __scope.TrueClass : __scope.FalseClass;
    };
    __alias(this, "singleton_class", "class");
    return def.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };
  }, 0);
  __klass(this, null, "TrueClass", function() {
    var __scope = this._scope, def = this._proto; 
    return __defs(this, '$eqq$', function(obj) {
      
      return obj === true;
    })
  }, 0);
  __klass(this, null, "FalseClass", function() {
    var __scope = this._scope, def = this._proto; 
    return __defs(this, '$eqq$', function(obj) {
      
      return obj === false;
    })
  }, 0);
  __scope.TRUE = true;
  __scope.FALSE = false;
  __klass(this, null, "NilClass", function() {
    var __scope = this._scope, def = this._proto; 
    def.$and$ = function(other) {
      
      return false;
    };
    def.$or$ = function(other) {
      
      return other !== false && other !== nil;
    };
    def.$xor$ = function(other) {
      
      return other !== false && other !== nil;
    };
    def.$eq$ = function(other) {
      
      return other === nil;
    };
    def.$inspect = function() {
      
      return "nil";
    };
    def.$nil$p = function() {
      
      return true;
    };
    def.$singleton_class = function() {
      
      return __scope.NilClass;
    };
    def.$to_a = function() {
      
      return [];
    };
    def.$to_i = function() {
      
      return 0;
    };
    __alias(this, "to_f", "to_i");
    return def.$to_s = function() {
      
      return "";
    };
  }, 0);
  __scope.NIL = nil;
  __klass(this, null, "Enumerable", function() {
    var __scope = this._scope, def = this._proto; 
    def.$all$p = $TMP_14 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_14._p) {
        __context = block._s;
        $TMP_14._p = null;
      }
      
      var result = true, proc;

      if (block) {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value === false || value === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj === false || obj === nil) {
            result = false;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    
    };
    def.$any$p = $TMP_15 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_15._p) {
        __context = block._s;
        $TMP_15._p = null;
      }
      
      var result = false, proc;

      if (block) {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result       = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }
      else {
        proc = function(obj) {
          if (obj !== false && obj !== nil) {
            result      = true;
            __breaker.$v = nil;

            return __breaker;
          }
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    
    };
    def.$collect = $TMP_16 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_16._p) {
        __context = block._s;
        $TMP_16._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("collect")
      };
      
      var result = [];

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      };

      this.$each._p = proc;
      this.$each();

      return result;
    
    };
    def.$count = $TMP_17 = function(object) {
      var __context = nil, block = nil; 
      if (block = $TMP_17._p) {
        __context = block._s;
        $TMP_17._p = null;
      }
      
      var result = 0;

      if (!block) {
        if (object == null) {
          block = function() { return true; };
        }
        else {
          block = function(obj) { return (obj).$eq$(object); };
        }
      }

      var proc = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result++;
        }
      }

      this.$each._p = proc;
      this.$each();

      return result;
    
    };
    def.$detect = $TMP_18 = function(ifnone) {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_18._p) {
        __context = block._s;
        $TMP_18._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("detect", ifnone)
      };
      
      var result = nil;

      this.$each(function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          $breaker.$v = nil;

          return $breaker;
        }
      });

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return ifnone.$call();
      }

      return ifnone === undefined ? nil : ifnone;
    
    };
    def.$drop = function(number) {
      
      this.$raise(__scope.NotImplementedError);
      
      var result  = [],
          current = 0;

      this.$each(function(y, obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      });

      return result;
    
    };
    def.$drop_while = $TMP_19 = function() {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_19._p) {
        __context = block._s;
        $TMP_19._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("drop_while")
      };
      
      var result = [];

      this.$each.$P = function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(obj);
        }
        else {
          return $breaker;
        }
      };

      this.$each();

      return result;
    
    };
    def.$each_with_index = $TMP_20 = function() {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_20._p) {
        __context = block._s;
        $TMP_20._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("each_with_index")
      };
      
      var index = 0;

      this.$each(function(y, obj) {
        var value;

        if ((value = $yield.call($context, null, obj, index)) === $breaker) {
          return $breaker.$v;
        }

        index++;
      });

      return nil;
    
    };
    def.$entries = function() {
      var result = nil, __a, __b; 
      result = [];
      (((__a = (__b = this).$each)._p = function(args) {

        var __a; 
        args = __slice.call(arguments, 0);
        return result.$push((function() { if ((__a = args.$length().$eq$(1)) !== false && __a !== nil) {
          return args.$first()
          } else {
          return args
        }; return nil; }).call(this))
      })._s = this, __a).call(__b);
      return result;
    };
    __alias(this, "find", "detect");
    def.$find_index = $TMP_21 = function(object) {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_21._p) {
        __context = block._s;
        $TMP_21._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("find_index", object)
      };
      
      if (object !== undefined) {
        $yield = function (y, obj) { return obj.$eq$(null, object); };
      }

      var result = nil;

      this.$each_with_index(function(y, obj, index) {
        var value;

        if ((value = $yield.call($context, null, obj)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== nil) {
          result     = obj;
          breaker.$v = index;

          return $breaker;
        }
      });

      return result;
    
    };
    def.$first = function(number) {
      
      
      var result = [],
          current = 0;

      this.$each(number === undefined
        ? function(y, obj) {
            result = obj; return $breaker;
          }
        : function(y, obj) {
            if (number <= current) {
              return $breaker;
            }

            result.push(obj);

            current++;
          });

      return result;
    
    };
    def.$grep = $TMP_22 = function(pattern) {
      var __context = nil, block = nil; 
      if (block = $TMP_22._p) {
        __context = block._s;
        $TMP_22._p = null;
      }
      
      var result = [];

      this.$each(block !== nil
        ? function(y, obj) {
            var value = pattern.$eqq$(null, obj);

            if (value !== false && value !== nil) {
              if ((value = $yield.call($context, null, obj)) === $breaker) {
                return $breaker.$v;
              }

              result.push(obj);
            }
          }
        : function(y, obj) {
            var value = pattern.$eqq$(null, obj);

            if (value !== false && value !== nil) {
              ary.push(obj);
            }
          });

      return result;
    
    };
    __alias(this, "take", "first");
    __alias(this, "to_a", "entries");
    ;this.$donate(["$all$p", "$any$p", "$collect", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$entries", "$find_index", "$first", "$grep"]);
  }, 1);
  __klass(this, null, "Enumerator", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    __klass(this, null, "Yielder", function() {
      var __scope = this._scope, def = this._proto; 
      def.$initialize = function(block) {
        
        return this.block = block;
      };
      def.$call = function(block) {
        if (this.block == null) this.block = nil;

        this.call = block;
        return this.block.$call();
      };
      def.$yield = function(value) {
        if (this.call == null) this.call = nil;

        return this.call.$call(value);
      };
      return __alias(this, "<<", "yield");
    }, 0);
    __klass(this, null, "Generator", function() {
      var __scope = this._scope, def = this._proto; 
      this.$attr_reader("enumerator");
      def.$initialize = function(block) {
        
        return this.yielder = __scope.Yielder.$new(block);
      };
      return def.$each = $TMP_23 = function() {
        var __context = nil, block = nil; if (this.yielder == null) this.yielder = nil;

        if (block = $TMP_23._p) {
          __context = block._s;
          $TMP_23._p = null;
        }
        return this.yielder.$call(block);
      };
    }, 0);
    def.$initialize = $TMP_24 = function(object, method, args) {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_24._p) {
        __context = block._s;
        $TMP_24._p = null;
      }if (object == null) {
        object = nil;
      }if (method == null) {
        method = "each";
      }args = __slice.call(arguments, 2);
      if (!!block) {
        this.object = __scope.Generator.$new(block)
      };
      if ((__a = object) !== false && __a !== nil) {

        } else {
        this.$raise(__scope.ArgumentError, "wrong number of argument (0 for 1+)")
      };
      this.object = object;
      this.method = method;
      return this.args = args;
    };
    def.$next = function() {
      var result = nil, __a, __b; if (this.cache == null) this.cache = nil;
if (this.current == null) this.current = nil;

      this.$_init_cache();
      (__a = result = this.cache.$aref$(this.current), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
      this.current = (__a = this.current, __b = 1, typeof(__a) === 'number' ? __a + __b : __a.$plus$(__b));
      return result;
    };
    def.$next_values = function() {
      var result = nil, __a; 
      result = this.$next();
      if ((__a = result.$is_a$p(__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };
    def.$peek = function() {
      var __a; if (this.cache == null) this.cache = nil;
if (this.current == null) this.current = nil;

      this.$_init_cache();
      return (__a = this.cache.$aref$(this.current), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
    };
    def.$peel_values = function() {
      var result = nil, __a; 
      result = this.$peek();
      if ((__a = result.$is_a$p(__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };
    def.$rewind = function() {
      
      return this.$_clear_cache();
    };
    def.$each = $TMP_25 = function() {
      var __context = nil, block = nil, __a, __b; if (this.object == null) this.object = nil;
if (this.method == null) this.method = nil;
if (this.args == null) this.args = nil;

      if (block = $TMP_25._p) {
        __context = block._s;
        $TMP_25._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this
      };
      return (((__a = (__b = this.object).$__send__)._p = (block || function(){}))._s = this, __a).apply(__b, [this.method].concat(this.args));
    };
    def.$each_with_index = $TMP_26 = function() {
      var __context = nil, block = nil, __a, __b; 
      if (block = $TMP_26._p) {
        __context = block._s;
        $TMP_26._p = null;
      }
      return (((__a = (__b = this).$with_index)._p = (block || function(){}))._s = this, __a).call(__b);
    };
    def.$with_index = $TMP_27 = function(offset) {
      var current = nil, __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_27._p) {
        __context = __yield._s;
        $TMP_27._p = null;
      }if (offset == null) {
        offset = 0;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("with_index", offset)
      };
      current = 0;
      return (((__a = (__b = this).$each)._p = function(args) {

        var __a, __b; 
        args = __slice.call(arguments, 0);
        if ((__a = current, __b = offset, typeof(__a) === 'number' ? __a >= __b : __a.$ge$(__b))) {

          } else {
          return nil;
        };
        __yield.apply(__context, args.concat([["current"]]));
        return current = (__b = current, __a = 1, typeof(__b) === 'number' ? __b + __a : __b.$plus$(__a));
      })._s = this, __a).call(__b);
    };
    def.$with_object = $TMP_28 = function(object) {
      var __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_28._p) {
        __context = __yield._s;
        $TMP_28._p = null;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("with_object", object)
      };
      return (((__a = (__b = this).$each)._p = function(args) {

        
        args = __slice.call(arguments, 0);
        return __yield.apply(__context, args.concat([["object"]]))
      })._s = this, __a).call(__b);
    };
    def.$_init_cache = function() {
      var __a; if (this.current == null) this.current = nil;
if (this.cache == null) this.cache = nil;

      (__a = this.current, __a !== false && __a !== nil ? __a : this.current = 0);
      return (__a = this.cache, __a !== false && __a !== nil ? __a : this.cache = this.$to_a());
    };
    return def.$_clear_cache = function() {
      
      this.cache = nil;
      return this.current = nil;
    };
  }, 0);
  __klass(this, null, "Kernel", function() {
    var __scope = this._scope, def = this._proto; 
    def.$enum_for = function(method, args) {
      var __a; if (method == null) {
        method = "each";
      }args = __slice.call(arguments, 1);
      return (__a = __scope.Enumerator).$new.apply(__a, [this, method].concat(args));
    };
    __alias(this, "to_enum", "enum_for");
    ;this.$donate(["$enum_for"]);
  }, 1);
  __klass(this, null, "Comparable", function() {
    var __scope = this._scope, def = this._proto; 
    def.$lt$ = function(other) {
      
      return this.$cmp$(other).$eq$(-1);
    };
    def.$le$ = function(other) {
      var __a, __b; 
      return (__a = this.$cmp$(other), __b = 0, typeof(__a) === 'number' ? __a <= __b : __a.$le$(__b));
    };
    def.$eq$ = function(other) {
      
      return this.$cmp$(other).$eq$(0);
    };
    def.$gt$ = function(other) {
      
      return this.$cmp$(other).$eq$(1);
    };
    def.$ge$ = function(other) {
      var __a, __b; 
      return (__a = this.$cmp$(other), __b = 0, typeof(__a) === 'number' ? __a >= __b : __a.$ge$(__b));
    };
    def.$between$p = function(min, max) {
      var __a, __b, __c; 
      return (__a = (__b = this, __c = min, typeof(__b) === 'number' ? __b > __c : __b.$gt$(__c)) ? (__c = this, __b = max, typeof(__c) === 'number' ? __c < __b : __c.$lt$(__b)) : __a);
    };
    ;this.$donate(["$lt$", "$le$", "$eq$", "$gt$", "$ge$", "$between$p"]);
  }, 1);
  __klass(this, null, "Array", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    __defs(this, '$aref$', function(objects) {
      objects = __slice.call(arguments, 0);
      
      var result = this.$allocate();

      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    
    });
    __defs(this, '$allocate', function() {
      
      
      var array         = [];
          array._klass = this;

      return array;
    
    });
    __defs(this, '$new', function(a) {
      a = __slice.call(arguments, 0);
      return [];
    });
    def.$and$ = function(other) {
      
      
      var result = [],
          seen   = {};

      for (var i = 0, length = this.length; i < length; i++) {
        var item = this[i],
            hash = item;

        if (!seen[hash]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j],
                hash2 = item2;

            if ((hash === hash2) && !seen[hash]) {
              seen[hash] = true;

              result.push(item);
            }
          }
        }
      }

      return result;
    
    };
    def.$mul$ = function(other) {
      
      
      if (typeof(other) === 'string') {
        return this.join(other);
      }

      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result = result.concat(this);
      }

      return result;
    
    };
    def.$plus$ = function(other) {
      
      return this.slice(0).concat(other.slice(0));
    };
    def.$lshft$ = function(object) {
      
      this.push(object);
      return this;
    };
    def.$cmp$ = function(other) {
      
      
      if (this.$hash() === other.$hash()) {
        return 0;
      }

      if (this.length != other.length) {
        return (this.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = this.length, tmp; i < length; i++) {
        if ((tmp = (this[i]).$cmp$(other[i])) !== 0) {
          return tmp;
        }
      }

      return 0;
    
    };
    def.$eq$ = function(other) {
      
      
      if (!other || (this.length !== other.length)) {
        return false;
      }

      for (var i = 0, length = this.length; i < length; i++) {
        if (!(this[i]).$eq$(other[i])) {
          return false;
        }
      }

      return true;
    
    };
    def.$aref$ = function(index, length) {
      
      
      var size = this.length;

      if (typeof index !== 'number') {
        if (index._flags & T_RANGE) {
          var exclude = index.exclude;
          length      = index.end;
          index       = index.begin;

          if (index > size) {
            return nil;
          }

          if (length < 0) {
            length += size;
          }

          if (!exclude) length += 1;
          return this.slice(index, length);
        }
        else {
          throw RubyException.$new('bad arg for Array#[]');
        }
      }

      if (index < 0) {
        index += size;
      }

      if (length !== undefined) {
        if (length < 0 || index > size || index < 0) {
          return nil;
        }

        return this.slice(index, index + length);
      }
      else {
        if (index >= size || index < 0) {
          return nil;
        }

        return this[index];
      }
    
    };
    def.$aset$ = function(index, value) {
      
      
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    
    };
    def.$assoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && (item[0]).$eq$(object)) {
          return item;
        }
      }

      return nil;
    
    };
    def.$at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    
    };
    def.$clear = function() {
      
      this.splice(0);
      return this;
    };
    def.$clone = function() {
      
      return this.slice();
    };
    def.$collect = $TMP_29 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_29._p) {
        __context = block._s;
        $TMP_29._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("collect")
      };
      
      var result = [];

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      }

      return result;
    
    };
    def.$collect$b = $TMP_30 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_30._p) {
        __context = block._s;
        $TMP_30._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("collect!")
      };
      
      for (var i = 0, length = this.length, val; i < length; i++) {
        if ((val = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        this[i] = val;
      }
    
      return this;
    };
    def.$compact = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };
    def.$compact$b = function() {
      
      
      var original = this.length;

      for (var i = 0, length = this.length; i < length; i++) {
        if (this[i] === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    
    };
    def.$concat = function(other) {
      
      
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    
      return this;
    };
    def.$count = function(object) {
      
      
      if (object === undefined) {
        return this.length;
      }

      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i]).$eq$(object)) {
          result++;
        }
      }

      return result;
    
    };
    def.$delete = function(object) {
      
      
      var original = this.length;

      for (var i = 0, length = original; i < length; i++) {
        if ((this[i]).$eq$(object)) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : object;
    
    };
    def.$delete_at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      var result = this[index];

      this.splice(index, 1);

      return result;
    
    };
    def.$delete_if = $TMP_31 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_31._p) {
        __context = block._s;
        $TMP_31._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("delete_if")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }
    
      return this;
    };
    def.$drop = function(number) {
      
      return this.slice(number);
    };
    def.$drop_while = $TMP_32 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_32._p) {
        __context = block._s;
        $TMP_32._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("drop_while")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          return this.slice(i);
        }
      }

      return [];
    
    };
    __alias(this, "dup", "clone");
    def.$each = $TMP_33 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_33._p) {
        __context = block._s;
        $TMP_33._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (block.call(__context, this[i]) === __breaker) {
          return __breaker.$v;
        }
      }
    
      return this;
    };
    def.$each_index = $TMP_34 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_34._p) {
        __context = block._s;
        $TMP_34._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each_index")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }
    
      return this;
    };
    def.$each_with_index = $TMP_35 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_35._p) {
        __context = block._s;
        $TMP_35._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each_with_index")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (block.call(__context, this[i], i) === __breaker) {
          return __breaker.$v;
        }
      }
    
      return this;
    };
    def.$empty$p = function() {
      
      return this.length === 0;
    };
    def.$fetch = $TMP_36 = function(index, defaults) {
      var __context = nil, block = nil; 
      if (block = $TMP_36._p) {
        __context = block._s;
        $TMP_36._p = null;
      }
      
      var original = index;

      if (index < 0) {
        index += this.length;
      }

      if (index >= 0 && index < this.length) {
        return this[index];
      }

      if (defaults !== undefined) {
        return defaults;
      }

      if (block !== null) {
        return block.call($context, nil, original);
      }

      throw RubyIndexError.$new('Array#fetch');
    
    };
    def.$first = function(count) {
      
      
      if (count !== undefined) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    
    };
    def.$flatten = function(level) {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (item._flags & T_ARRAY) {
          if (level === undefined) {
            result = result.concat((item).$flatten());
          }
          else if (level === 0) {
            result.push(item);
          }
          else {
            result = result.concat((item).$flatten(level - 1));
          }
        }
        else {
          result.push(item);
        }
      }

      return result;
    
    };
    def.$flatten$b = function(level) {
      
      
      var size = this.length;
      this.$replace(this.$flatten(level));

      return size === this.length ? nil : this;
    
    };
    def.$grep = function(pattern) {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (pattern.$eqq$(item)) {
          result.push(item);
        }
      }

      return result;
    
    };
    def.$hash = function() {
      
      return this._id || (this._id = unique_id++);
    };
    def.$include$p = function(member) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i]).$eq$(member)) {
          return true;
        }
      }

      return false;
    
    };
    def.$index = $TMP_37 = function(object) {
      var __context = nil, block = nil, __a, __b; 
      if (block = $TMP_37._p) {
        __context = block._s;
        $TMP_37._p = null;
      }
      if ((__a = (__b = !!block ? object.$eq$(this.$undefined()) : __b)) !== false && __a !== nil) {

        } else {
        return this.$enum_for("index")
      };
      
      if (block !== null) {
        for (var i = 0, length = this.length, value; i < length; i++) {
          if ((value = block.call($context, null, this[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== null) {
            return i;
          }
        }
      }
      else {
        for (var i = 0, length = this.length; i < length; i++) {
          if ((this[i]).$eq$(object)) {
            return i;
          }
        }
      }

      return null
    
    };
    def.$inject = $TMP_38 = function(initial) {
      var __context = nil, block = nil; 
      if (block = $TMP_38._p) {
        __context = block._s;
        $TMP_38._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("inject")
      };
      
      var result, i;

      if (initial === undefined) {
        result = this[0];
        i      = 1;
      }
      else {
        result = initial;
        i      = 0;
      }

      for (var length = this.length, value; i < length; i++) {
        if ((value = block.call($context, null, result, this[i])) === $breaker) {
          return $breaker.$v;
        }

        result = value;
      }

      return result;
    
    };
    def.$insert = function(index, objects) {
      objects = __slice.call(arguments, 1);
      
      if (objects.length > 0) {
        if (index < 0) {
          index += this.length + 1;

          if (index < 0) {
            throw RubyIndexError.$new(index + ' is out of bounds');
          }
        }
        if (index > this.length) {
          for (var i = this.length; i < index; i++) {
            this.push(nil);
          }
        }

        this.splice.apply(this, [index, 0].concat(objects));
      }
    
      return this;
    };
    def.$inspect = function() {
      
      
      var inspect = [];

      for (var i = 0, length = this.length; i < length; i++) {
        inspect.push((this[i]).$inspect());
      }

      return '[' + inspect.join(', ') + ']';
    
    };
    def.$join = function(sep) {
      if (sep == null) {
        sep = "";
      }
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_s());
      }

      return result.join(sep);
    
    };
    def.$keep_if = $TMP_39 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_39._p) {
        __context = block._s;
        $TMP_39._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("keep_if")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call($context, null, this[i])) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === null) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }
    
      return this;
    };
    def.$last = function(count) {
      
      
      var length = this.length;

      if (count === undefined) {
        return length === 0 ? nil : this[length - 1];
      }
      else if (count < 0) {
        throw RubyArgError.$new('negative count given');
      }

      if (count > length) {
        count = length;
      }

      return this.slice(length - count, length);
    
    };
    def.$length = function() {
      
      return this.length;
    };
    __alias(this, "map", "collect");
    __alias(this, "map!", "collect!");
    def.$pop = function(count) {
      
      
      var length = this.length;

      if (count === undefined) {
        return length === 0 ? nil : this.pop();
      }

      if (count < 0) {
        throw RubyArgError.$new('negative count given');
      }

      return count > length ? this.splice(0) : this.splice(length - count, length);
    
    };
    def.$push = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    
      return this;
    };
    def.$rassoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (item.length && item[1] !== undefined) {
          if ((item[1]).$eq$(object)) {
            return item;
          }
        }
      }

      return nil;
    
    };
    def.$reject = $TMP_40 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_40._p) {
        __context = block._s;
        $TMP_40._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("reject")
      };
      
      var result = [];

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          result.push(this[i]);
        }
      }
      return result;
    
    };
    def.$reject$b = $TMP_41 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_41._p) {
        __context = block._s;
        $TMP_41._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("reject!")
      };
      
      var original = this.length;

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return original === this.length ? nil : this;
    
    };
    def.$replace = function(other) {
      
      
      this.splice(0);
      this.push.apply(this, other);
      return this;
    
    };
    def.$reverse = function() {
      
      return this.reverse();
    };
    def.$reverse$b = function() {
      
      
      this.splice(0);
      this.push.apply(this, this.$reverse());
      return this;
    
    };
    def.$reverse_each = $TMP_42 = function() {
      var __context = nil, block = nil, __a, __b; 
      if (block = $TMP_42._p) {
        __context = block._s;
        $TMP_42._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("reverse_each")
      };
      (((__a = (__b = this.$reverse()).$each)._p = (block || function(){}))._s = this, __a).call(__b);
      return this;
    };
    def.$rindex = $TMP_43 = function(object) {
      var __context = nil, block = nil, __a, __b; 
      if (block = $TMP_43._p) {
        __context = block._s;
        $TMP_43._p = null;
      }
      if ((__a = (__b = !!block ? object.$eq$(this.$undefined()) : __b)) !== false && __a !== nil) {

        } else {
        return this.$enum_for("rindex")
      };
      
      if (block !== null) {
        for (var i = this.length - 1, value; i >= 0; i--) {
          if ((value = block.call($context, null, this[i])) === $breaker) {
            return $breaker.$v;
          }

          if (value !== false && value !== null) {
            return i;
          }
        }
      }
      else {
        for (var i = this.length - 1; i >= 0; i--) {
          if ((this[i]).$eq$(object)) {
            return i;
          }
        }
      }

      return null;
    
    };
    def.$select = $TMP_44 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_44._p) {
        __context = block._s;
        $TMP_44._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("select")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call($context, null, item)) === $breaker) {
          return $breaker.$v;
        }

        if (value !== false && value !== null) {
          result.push(item);
        }
      }

      return result;
    
    };
    def.$select$b = $TMP_45 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_45._p) {
        __context = block._s;
        $TMP_45._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("select!")
      };
      
      var original = this.length;

      for (var i = 0, length = original, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call($context, null, item)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === null) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? null : this;
    
    };
    def.$shift = function(count) {
      
      return count === undefined ? this.shift() : this.splice(0, count);
    };
    __alias(this, "size", "length");
    __alias(this, "slice", "[]");
    def.$slice$b = function(index, length) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return null;
      }

      if (length !== undefined) {
        return this.splice(index, index + length);
      }

      return this.splice(index, 1)[0];
    
    };
    def.$take = function(count) {
      
      return this.slice(0, count);
    };
    def.$take_while = $TMP_46 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_46._p) {
        __context = block._s;
        $TMP_46._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("take_while")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call($context, null, item)) === $breaker) {
          return $breaker.$v;
        }

        if (value === false || value === null) {
          return result;
        }

        result.push(item);
      }

      return result;
    
    };
    def.$to_a = function() {
      
      return this;
    };
    __alias(this, "to_ary", "to_a");
    __alias(this, "to_s", "inspect");
    def.$uniq = function() {
      
      
      var result = [],
          seen   = {};

      for (var i = 0, length = this.length, item, hash; i < length; i++) {
        item = this[i];
        hash = item.$hash();

        if (!seen[hash]) {
          seen[hash] = true;

          result.push(item);
        }
      }

      return result;
    
    };
    def.$uniq$b = function() {
      
      
      var original = this.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = this[i];
        hash = item.$hash();;

        if (!seen[hash]) {
          seen[hash] = true;
        }
        else {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    
    };
    def.$unshift = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.unshift(objects[i]);
      }

      return this;
    
    };
    return def.$zip = $TMP_47 = function(others) {
      var __context = nil, block = nil; 
      if (block = $TMP_47._p) {
        __context = block._s;
        $TMP_47._p = null;
      }others = __slice.call(arguments, 0);
      
      var result = [], size = this.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [this[i]];

        for (var j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o === undefined) {
            o = nil;
          }

          part[j + 1] = o;
        }

        result[i] = part;
      }

      if (block) {
        for (var i = 0; i < size; i++) {
          block.call(__context, result[i]);
        }

        return nil;
      }

      return result;
    
    };
  }, 0);
  __klass(this, null, "Hash", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    
    var hash_class = this;

    Opal.hash = function() {
      var hash    = new hash_class._alloc(),
          args    = __slice.call(arguments),
          assocs  = {};

      hash.map    = assocs;
      hash.none   = nil;
      hash.proc   = nil;

      if (args.length == 1 && args[0]._flags & T_ARRAY) {
        args = args[0];

        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i][0];

          assocs[key] = [key, args[i][1]];
        }
      }
      else if (arguments.length % 2 == 0) {
        for (var i = 0, length = args.length, key; i < length; i++) {
          key = args[i];

          assocs[key] = [key, args[++i]];
        }
      }
      else {
        throw RubyArgError.$new('odd number of arguments for Hash');
      }

      return hash;
    };
  
    __defs(this, '$aref$', function(objs) {
      objs = __slice.call(arguments, 0);
      return $opal.hash.apply(null, objs);
    });
    __defs(this, '$allocate', function() {
      
      return Opal.hash();
    });
    __defs(this, '$new', $TMP_48 = function(defaults) {
      var __context = nil, block = nil; 
      if (block = $TMP_48._p) {
        __context = block._s;
        $TMP_48._p = null;
      }
      
      var hash = Opal.hash();

      if (defaults != undefined) {
        hash.none = defaults;
      }
      else if (block != null) {
        hash.proc = block;
      }

      return hash;
    
    });
    def.$eq$ = function(other) {
      
      
      if (this === other) {
        return true;
      }

      if (!other.map) {
        return false;
      }

      var map  = this.map,
          map2 = other.map;

      for (var assoc in map) {
        if (!map2[assoc]) {
          return false;
        }

        var obj  = map[assoc][1],
            obj2 = map2[assoc][1];

        if (!(obj).$eq$(obj2)) {
          return false;
        }
      }

      return true;
    
    };
    def.$aref$ = function(key) {
      
      
      var bucket;

      if (bucket = this.map[key]) {
        return bucket[1];
      }

      return this.none;
    
    };
    def.$aset$ = function(key, value) {
      
      
      this.map[key] = [key, value];

      return value;
    
    };
    def.$assoc = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if ((bucket[0]).$eq$(object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };
    def.$clear = function() {
      
      
      this.map = {};

      return this;
    
    };
    def.$clone = function() {
      
      
      var result = Opal.hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = [map[assoc][0], map[assoc][1]];
      }

      return result;
    
    };
    def.$default = function() {
      
      return this.none;
    };
    def.$default$e = function(object) {
      
      return this.none = object;
    };
    def.$default_proc = function() {
      
      return this.proc;
    };
    def.$default_proc$e = function(proc) {
      
      return this.proc = proc;
    };
    def.$delete = function(key) {
      
      
      var map  = this.map, result;

      if (result = map[key]) {
        result = bucket[1];

        delete map[key];
      }

      return result;
    
    };
    def.$delete_if = $TMP_49 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_49._p) {
        __context = block._s;
        $TMP_49._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("delete_if")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          delete map[assoc];
        }
      }

      return this;
    
    };
    def.$each = $TMP_50 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_50._p) {
        __context = block._s;
        $TMP_50._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call($context, null, bucket[0], bucket[1]) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    
    };
    def.$each_key = $TMP_51 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_51._p) {
        __context = block._s;
        $TMP_51._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each_key")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call($context, null, bucket[0]) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    
    };
    __alias(this, "each_pair", "each");
    def.$each_value = $TMP_52 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_52._p) {
        __context = block._s;
        $TMP_52._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("each_value")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call($context, null, bucket[1]) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    
    };
    def.$empty$p = function() {
      
      
      for (var assoc in this.map) {
        return false;
      }

      return true;
    
    };
    __alias(this, "eql?", "==");
    def.$fetch = $TMP_53 = function(key, defaults) {
      var __context = nil, block = nil; 
      if (block = $TMP_53._p) {
        __context = block._s;
        $TMP_53._p = null;
      }
      
      var bucket = this.map[key];

      if (block !== null) {
        var value;

        if ((value = block.call($context, null, key)) === $breaker) {
          return $breaker.$v;
        }

        return value;
      }

      if (defaults !== undefined) {
        return defaults;
      }

      throw RubyKeyError.$new('key not found');
    
    };
    def.$flatten = function(level) {
      var __a, __b; 
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc],
            key    = bucket[0],
            value  = bucket[1];

        result.push(key);

        if (value._flags & T_ARRAY) {
          if (level === undefined || level === 1) {
            result.push(value);
          }
          else {
            result = result.concat((value).$flatten((__a = level, __b = 1, typeof(__a) === 'number' ? __a - __b : __a.$minus$(__b))));
          }
        }
        else {
          result.push(value);
        }
      }

      return result;
    
    };
    def.$has_key$p = function(key) {
      
      return !!this.map[key];
    };
    def.$has_value$p = function(value) {
      
      
      for (var assoc in this.map) {
        if ((this.map[assoc][1]).$eq$(value)) {
          return true;
        }
      }

      return false;
    
    };
    def.$hash = function() {
      
      return this._id;
    };
    def.$inspect = function() {
      
      
      var inspect = [],
          map     = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push((bucket[0]).$inspect() + '=>' + (bucket[1]).$inspect());
      }
      return '{' + inspect.join(', ') + '}';
    
    };
    def.$invert = function() {
      
      
      var result = $opal.hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[bucket[1]] = [bucket[0], bucket[1]];
      }

      return result;
    
    };
    def.$key = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (object.$eq$(bucket[1])) {
          return bucket[0];
        }
      }

      return null;
    
    };
    __alias(this, "key?", "has_key?");
    def.$keys = function() {
      
      
      var result = [];

      for (var assoc in this.map) {
        result.push(this.map[assoc][0]);
      }

      return result;
    
    };
    def.$length = function() {
      
      
      var result = 0;

      for (var assoc in this.map) {
        result++;
      }

      return result;
    
    };
    __alias(this, "member?", "has_key?");
    def.$merge = $TMP_54 = function(other) {
      var __context = nil, block = nil; 
      if (block = $TMP_54._p) {
        __context = block._s;
        $TMP_54._p = null;
      }
      
      var result = Opal.hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[assoc] = [bucket[0], bucket[1]];
      }

      map = other.map;

      if (block === null) {
        for (var assoc in map) {
          var bucket = map[assoc];

          map2[assoc] = [bucket[0], bucket[1]];
        }
      }
      else {
        for (var assoc in map) {
          var bucket = map[assoc], key = bucket[0], val = bucket[1];

          if (map2.hasOwnProperty(assoc)) {
            val = block.call(__context, key, map2[assoc][1], val);
          }

          map2[assoc] = [key, val];
        }
      }

      return result;
    
    };
    def.$merge$b = $TMP_55 = function(other) {
      var __context = nil, block = nil; 
      if (block = $TMP_55._p) {
        __context = block._s;
        $TMP_55._p = null;
      }
      
      var map  = this.map,
          map2 = other.map;

      if (block == null || block === nil) {
        for (var assoc in map2) {
          var bucket = map2[assoc];

          map[assoc] = [bucket[0], bucket[1]];
        }
      }
      else {
        for (var assoc in map2) {
          var bucket = map2[assoc], key = bucket[0], val = bucket[1];

          if (map.hasOwnProperty(assoc)) {
            val = block.call(__context, key, map[assoc][1], val);
          }

          map[assoc] = [key, val];
        }
      }

      return this;
    
    };
    def.$rassoc = function(object) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((bucket[1]).$eq$(object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return null;
    
    };
    def.$replace = function(other) {
      
      
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[assoc] = [bucket[0], bucket[1]];
      }

      return this;
    
    };
    __alias(this, "size", "length");
    def.$to_a = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    
    };
    def.$to_hash = function() {
      
      return this;
    };
    __alias(this, "to_s", "inspect");
    __alias(this, "update", "merge!");
    return def.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    
    };
  }, 0);
  __klass(this, null, "String", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Comparable);
    __defs(this, '$try_convert', function(what) {
      
      return (function() { try {
what.$to_str()
} catch ($err) {
if (true) {
nil}
else { throw $err; }
} }).call(this)
    });
    __defs(this, '$new', function(str) {
      if (str == null) {
        str = "";
      }
      return str.$to_s()
    });
    def.$mod$ = function(data) {
      
      return this.$sprintf(this, data);
    };
    def.$mul$ = function(count) {
      
      
      if (count < 1) {
        return '';
      }

      var result  = '',
          pattern = this.valueOf();

      while (count > 0) {
        if (count & 1) {
          result += pattern;
        }

        count >>= 1, pattern += pattern;
      }

      return result;
    
    };
    def.$plus$ = function(other) {
      
      return this + other;
    };
    def.$cmp$ = function(other) {
      
      
      if (typeof other !== 'string') {
        return null;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    
    };
    def.$lt$ = function(other) {
      
      return this < other;
    };
    def.$le$ = function(other) {
      
      return this <= other;
    };
    def.$gt$ = function(other) {
      
      return this > other;
    };
    def.$ge$ = function(other) {
      
      return this >= other;
    };
    def.$eq$ = function(other) {
      
      return this == other;
    };
    __alias(this, "===", "==");
    def.$match$ = function(other) {
      
      
      if (typeof other === 'string') {
        throw RubyTypeError.$new(null, 'string given');
      }

      return other.$match$(this);
    
    };
    def.$aref$ = function(index, length) {
      
      return this.substr(index, length);
    };
    def.$capitalize = function() {
      
      return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
    };
    def.$casecmp = function(other) {
      
      
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    
    };
    def.$chars = $TMP_56 = function() {
      var __context = nil, __yield = nil; 
      if (__yield = $TMP_56._p) {
        __context = __yield._s;
        $TMP_56._p = null;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("chars")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        __yield.call(__context, this.charAt(i))
      }
    
    };
    def.$chomp = function(separator) {
      var __a; if (separator == null) {
        separator = __gvars["$/"];
      }
      if ((__a = separator.$eq$("\n")) !== false && __a !== nil) {
        return this.$sub(/(\n|\r|\r\n)$/, "")
        } else {
        return this.$sub((new RegExp("" + __scope.Regexp.$escape(separator) + "$")), "")
      };
    };
    def.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };
    def.$chr = function() {
      
      return this.charAt(0);
    };
    def.$count = function(sets) {
      sets = __slice.call(arguments, 0);
      return this.$raise(__scope.NotImplementedError);
    };
    def.$crypt = function() {
      
      return this.$raise(__scope.NotImplementedError);
    };
    def.$delete = function(sets) {
      sets = __slice.call(arguments, 0);
      return this.$raise(__scope.NotImplementedErrois);
    };
    def.$downcase = function() {
      
      return this.toLowerCase();
    };
    __alias(this, "each_char", "chars");
    def.$each_line = $TMP_57 = function(separator) {
      var __context = nil, __yield = nil; 
      if (__yield = $TMP_57._p) {
        __context = __yield._s;
        $TMP_57._p = null;
      }if (separator == null) {
        separator = __gvars["$/"];
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("each_line", separator)
      };
      
      var splitted = this.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        __yield.call(__context, splitted[i] + separator)
      }
    
    };
    def.$empty$p = function() {
      
      return this.length === 0;
    };
    def.$end_with$p = function(suffixes) {
      suffixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (this.lastIndexOf(suffix) === this.length - suffix.length) {
          return true;
        }
      }

      return false;
    
    };
    __alias(this, "eql?", "==");
    def.$getbyte = function(index) {
      
      return this.charCodeAt(index);
    };
    def.$gsub = $TMP_58 = function(pattern, replace) {
      var __context = nil, block = nil, __a, __b; 
      if (block = $TMP_58._p) {
        __context = block._s;
        $TMP_58._p = null;
      }
      if ((__a = ((__b = !block, __b !== false && __b !== nil) ? pattern === undefined : __b)) !== false && __a !== nil) {
        return this.$enum_for("gsub", pattern, replace)
      };
      if ((__a = pattern.$is_a$p(__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return (((__a = (__b = this).$sub)._p = (block || function(){}))._s = this, __a).call(__b, new RegExp(regexp, options), replace);
    
    };
    def.$hash = function() {
      
      return this.toString();
    };
    def.$hex = function() {
      
      return this.$to_i(16);
    };
    def.$include$p = function(other) {
      
      return this.indexOf(other) !== -1;
    };
    def.$index = function(what, offset) {
      var __a, __b; 
      if ((__a = (__b = __scope.String.$eqq$(what), __b !== false && __b !== nil ? __b : __scope.Regexp.$eqq$(what))) !== false && __a !== nil) {

        } else {
        this.$raise(__scope.TypeError, "type mismatch: " + what.$class() + " given")
      };
      
      var result = -1;

      if (offset !== undefined) {
        if (offset < 0) {
          offset = this.length - offset;
        }

        if (what.$is_a$p(__scope.Regexp)) {
          result = (__a = what.$match$(this.substr(offset)), __a !== false && __a !== nil ? __a : -1)
        }
        else {
          result = this.substr(offset).indexOf(substr);
        }

        if (result !== -1) {
          result += offset;
        }
      }
      else {
        if (what.$is_a$p(__scope.Regexp)) {
          result = (__a = what.$match$(this), __a !== false && __a !== nil ? __a : -1)
        }
        else {
          result = this.indexOf(substr);
        }
      }

      return result === -1 ? null : result;
    
    };
    def.$inspect = function() {
      
      
      var escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
          meta      = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
          };

      escapable.lastIndex = 0;

      return escapable.test(this) ? '"' + this.replace(escapable, function(a) {
        var c = meta[a];

        return typeof c === 'string' ? c :
          '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + this + '"';
  
    };
    def.$intern = function() {
      
      return this;
    };
    __alias(this, "lines", "each_line");
    def.$length = function() {
      
      return this.length;
    };
    def.$ljust = function(integer, padstr) {
      if (padstr == null) {
        padstr = " ";
      }
      return this.$raise(__scope.NotImplementedError);
    };
    def.$lstrip = function() {
      
      return this.replace(/^s*/, '');
    };
    def.$match = $TMP_59 = function(pattern, pos) {
      var __context = nil, block = nil, __a, __b, __c; 
      if (block = $TMP_59._p) {
        __context = block._s;
        $TMP_59._p = null;
      }
      return (((__a = (__b = (function() { if ((__c = pattern.$is_a$p(__scope.Regexp)) !== false && __c !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this)).$match)._p = (block || function(){}))._s = this, __a).call(__b, this, pos);
    };
    def.$next = function() {
      
      return String.fromCharCode(this.charCodeAt(0) + 1);
    };
    def.$oct = function() {
      
      return this.$to_i(8);
    };
    def.$ord = function() {
      
      return this.charCodeAt(0);
    };
    def.$partition = function(what) {
      
      
      var result = this.split(what);

      return [result[0], what.toString(), result.slice(1).join(what.toString())];
    
    };
    def.$reverse = function() {
      
      return this.split('').reverse().join('');
    };
    def.$rpartition = function(what) {
      
      return this.$raise(__scope.NotImplementedError);
    };
    def.$rstrip = function() {
      
      return this.replace(/s*$/, '');
    };
    def.$scan = $TMP_60 = function(pattern) {
      var result = nil, original = nil, __context = nil, __yield = nil, __a; 
      if (__yield = $TMP_60._p) {
        __context = __yield._s;
        $TMP_60._p = null;
      }
      if ((__a = pattern.$is_a$p(__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      result = [];
      original = pattern;
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      var matches = this.match(pattern);

      for (var i = 0, length = matches.length; i < length; i++) {
        var current = matches[i].match(/^\(|[^\\]\(/) ? matches[i] : matches[i].match(original);

        if (!!__yield) {
          __yield.call(__context, this.$current());
        }
        else {
          result.push(current);
        }
      }
    
      if (!!__yield) {
        return this
        } else {
        return result
      };
    };
    __alias(this, "size", "length");
    __alias(this, "slice", "[]");
    def.$split = function(pattern, limit) {
      var __a; if (pattern == null) {
        pattern = (__a = __gvars["$;"], __a !== false && __a !== nil ? __a : " ");
      }
      return this.split(pattern === ' ' ? strip : this, limit);
    };
    def.$squeeze = function(sets) {
      sets = __slice.call(arguments, 0);
      return this.$raise(__scope.NotImplementedError);
    };
    def.$start_with$p = function(prefixes) {
      prefixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    
    };
    def.$strip = function() {
      
      return this.$lstrip().$rstrip();
    };
    def.$sub = $TMP_61 = function(pattern, replace) {
      var __context = nil, block = nil; 
      if (block = $TMP_61._p) {
        __context = block._s;
        $TMP_61._p = null;
      }
      
      if (block !== null) {
        return this.replace(pattern, function(str) {
          $opal.match_data = arguments

          return $yielder.call($context, null, str);
        });
      }
      else if (__scope.Object.$eqq$(replace)) {
        if (replace.$is_a$p(__scope.Hash)) {
          return this.replace(pattern, function(str) {
            var value = replace.$aref$(this.$str());

            return (value === null) ? undefined : this.$value().$to_s();
          });
        }
        else {
          replace = __scope.String.$try_convert(replace);

          if (replace === null) {
            this.$raise(__scope.TypeError, "can't convert " + replace.$class() + " into String");
          }

          return this.replace(pattern, replace);
        }
      }
      else {
        return this.replace(pattern, replace.toString());
      }
    
    };
    __alias(this, "succ", "next");
    def.$sum = function(n) {
      if (n == null) {
        n = 16;
      }
      
      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        result += this.charCodeAt(i) % ((1 << n) - 1);
      }

      return result;
    
    };
    def.$swapcase = function() {
      
      
      return this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });
    
    };
    def.$to_f = function() {
      
      return parseFloat(this);
    };
    def.$to_i = function(base) {
      if (base == null) {
        base = 10;
      }
      
      var result = parseInt(this, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    
    };
    def.$to_proc = function() {
      
      
      var self = this;

      return function(iter, arg) { return arg[mid_to_jsid(self)](); };
    
    };
    def.$to_s = function() {
      
      return this.toString();
    };
    __alias(this, "to_str", "to_s");
    __alias(this, "to_sym", "intern");
    def.$tr = function(from, to) {
      
      return this.$raise(__scope.NotImplementedError);
    };
    def.$tr_s = function(from, to) {
      
      return this.$raise(__scope.NotImplementedError);
    };
    def.$unpack = function(format) {
      
      return this.$raise(__scope.NotImplementedError);
    };
    def.$upcase = function() {
      
      return this.toUpperCase();
    };
    return def.$upto = $TMP_62 = function(other, exclusive) {
      var current = nil, __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_62._p) {
        __context = __yield._s;
        $TMP_62._p = null;
      }if (exclusive == null) {
        exclusive = false;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("upto", other, exclusive)
      };
      current = this;
      while (!((__b = current.$eq$(other)) !== false && __b !== nil)) {__yield.call(__context, current);
      current = current.$next();};
      if ((__a = exclusive) !== false && __a !== nil) {

        } else {
        __yield.call(__context, current)
      };
      return this;
    };
  }, 0);
  __scope.Symbol = __scope.String;
  __klass(this, null, "Numeric", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Comparable);
    def.$plus$ = function(other) {
      
      return this + other;
    };
    def.$minus$ = function(other) {
      
      return this - other;
    };
    def.$mul$ = function(other) {
      
      return this * other;
    };
    def.$div$ = function(other) {
      
      return this / other;
    };
    def.$mod$ = function(other) {
      
      return this % other;
    };
    def.$and$ = function(other) {
      
      return this & other;
    };
    def.$or$ = function(other) {
      
      return this | other;
    };
    def.$xor$ = function(other) {
      
      return this ^ other;
    };
    def.$lt$ = function(other) {
      
      return this < other;
    };
    def.$le$ = function(other) {
      
      return this <= other;
    };
    def.$gt$ = function(other) {
      
      return this > other;
    };
    def.$ge$ = function(other) {
      
      return this >= other;
    };
    def.$lshft$ = function(count) {
      
      return this << count;
    };
    def.$rshft$ = function(count) {
      
      return this >> count;
    };
    def.$uplus$ = function() {
      
      return +this;
    };
    def.$uminus$ = function() {
      
      return -this;
    };
    def.$tild$ = function() {
      
      return ~this;
    };
    def.$pow$ = function(other) {
      
      return Math.pow(this, other);
    };
    def.$eq$ = function(other) {
      
      return this == other;
    };
    def.$cmp$ = function(other) {
      
      
      if (typeof(other) !== 'number') {
        return null;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    
    };
    def.$abs = function() {
      
      return Math.abs(this);
    };
    def.$ceil = function() {
      
      return Math.ceil(this);
    };
    def.$chr = function() {
      
      return String.fromCharCode(this);
    };
    def.$downto = $TMP_63 = function(finish) {
      var __context = nil, block = nil; 
      if (block = $TMP_63._p) {
        __context = block._s;
        $TMP_63._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("downto", finish)
      };
      
      for (var i = this; i >= finish; i--) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };
    def.$even$p = function() {
      
      return this % 2 === 0;
    };
    def.$floor = function() {
      
      return Math.floor(this);
    };
    def.$hash = function() {
      
      return this.toString();
    };
    def.$integer$p = function() {
      
      return this % 1 === 0;
    };
    __alias(this, "magnitude", "abs");
    __alias(this, "modulo", "%");
    def.$next = function() {
      
      return this + 1;
    };
    def.$nonzero$p = function() {
      
      return this.valueOf() === 0 ? null : this;
    };
    def.$odd$p = function() {
      
      return this % 2 !== 0;
    };
    def.$ord = function() {
      
      return this;
    };
    def.$pred = function() {
      
      return this - 1;
    };
    __alias(this, "succ", "next");
    def.$times = $TMP_64 = function() {
      var __context = nil, block = nil, __a; 
      if (block = $TMP_64._p) {
        __context = block._s;
        $TMP_64._p = null;
      }
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("times")
      };
      
      for (var i = 0; i <= this; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };
    def.$to_f = function() {
      
      return parseFloat(this);
    };
    def.$to_i = function() {
      
      return parseInt(this);
    };
    def.$to_s = function(base) {
      if (base == null) {
        base = 10;
      }
      return this.toString();
    };
    def.$upto = $TMP_65 = function(finish) {
      var __context = nil, block = nil; 
      if (block = $TMP_65._p) {
        __context = block._s;
        $TMP_65._p = null;
      }
      if (!!block) {

        } else {
        return this.$enum_for("upto", finish)
      };
      
      for (var i = 0; i <= finish; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };
    return def.$zero$p = function() {
      
      return this.valueOf() === 0;
    };
  }, 0);
  __klass(this, null, "Integer", function() {
    var __scope = this._scope, def = this._proto; 
    return __defs(this, '$eqq$', function(obj) {
      
      
      if (typeof(obj) !== 'number') {
        return false;
      }

      return other % 1 === 0;
    
    })
  }, 0);
  __klass(this, null, "Float", function() {
    var __scope = this._scope, def = this._proto; 
    return __defs(this, '$eqq$', function(obj) {
      
      
      if (typeof(obj) !== 'number') {
        return false;
      }

      return obj % 1 !== 0;
    
    })
  }, 0);
  __klass(this, null, "Proc", function() {
    var __scope = this._scope, def = this._proto; 
    __defs(this, '$new', $TMP_66 = function() {
      var __context = nil, block = nil; 
      if (block = $TMP_66._p) {
        __context = block._s;
        $TMP_66._p = null;
      }
      if (!!block) {

        } else {
        this.$raise(__scope.ArgumentError, "tried to create Proc object without a block")
      };
      return block;
    });
    def.$to_proc = function() {
      
      return this;
    };
    def.$call = function(args) {
      args = __slice.call(arguments, 0);
      return this.apply(this._s, args);
    };
    def.$to_proc = function() {
      
      return this;
    };
    def.$to_s = function() {
      
      return "#<Proc:0x0000000>";
    };
    def.$lambda$p = function() {
      
      return !!this.$lambda;
    };
    return def.$arity = function() {
      
      return this.length - 1;
    };
  }, 0);
  
  Opal.range = function(beg, end, exc) {
    var range         = new RubyRange._alloc();
        range.begin   = beg;
        range.end     = end;
        range.exclude = exc;

    return range;
  };

  __klass(this, null, "Range", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    def.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false;
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };
    def.$eq$ = function(other) {
      var __a, __b; 
      if ((__a = __scope.Range.$eqq$(other)) !== false && __a !== nil) {

        } else {
        return false
      };
      return ((__a = ((__b = this.$exclude_end$p().$eq$(other.$exclude_end$p()), __b !== false && __b !== nil) ? (this.begin).$eq$(other.$begin()) : __b), __a !== false && __a !== nil) ? (this.end).$eq$(other.$end()) : __a);
    };
    def.$eqq$ = function(obj) {
      
      return obj >= this.begin && obj <= this.end;
    };
    def.$begin = function() {
      
      return this.begin;
    };
    def.$cover$p = function(value) {
      var __a, __b, __c, __d, __e; 
      return (__a = (__b = this.begin, __c = value, typeof(__b) === 'number' ? __b <= __c : __b.$le$(__c)) ? (__c = value, __b = (function() { if ((__d = this.$exclude_end$p()) !== false && __d !== nil) {
        return (__d = this.end, __e = 1, typeof(__d) === 'number' ? __d - __e : __d.$minus$(__e))
        } else {
        return this.end;
      }; return nil; }).call(this), typeof(__c) === 'number' ? __c <= __b : __c.$le$(__b)) : __a);
    };
    def.$each = $TMP_67 = function() {
      var current = nil, __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_67._p) {
        __context = __yield._s;
        $TMP_67._p = null;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("each")
      };
      current = this.$min();
      while ((__b = !current.$eq$(this.$max())) !== false && __b !== nil){__yield.call(__context, current);
      current = current.$succ();};
      if ((__a = this.$exclude_end$p()) !== false && __a !== nil) {

        } else {
        __yield.call(__context, current)
      };
      return this;
    };
    def.$end = function() {
      
      return this.end;
    };
    def.$eql$p = function(other) {
      var __a, __b; 
      if ((__a = __scope.Range.$eqq$(other)) !== false && __a !== nil) {

        } else {
        return false
      };
      return ((__a = ((__b = this.$exclude_end$p().$eq$(other.$exclude_end$p()), __b !== false && __b !== nil) ? (this.begin).$eql$p(other.$begin()) : __b), __a !== false && __a !== nil) ? (this.end).$eql$p(other.$end()) : __a);
    };
    def.$exclude_end$p = function() {
      
      return this.exclude;
    };
    def.$include$p = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };
    def.$max = $TMP_68 = function() {
      var __context = nil, __yield = nil; 
      if (__yield = $TMP_68._p) {
        __context = __yield._s;
        $TMP_68._p = null;
      }
      if (!!__yield) {
        return this.$raise(__scope.NotImplementedError)
        } else {
        return this.end;
      };
    };
    def.$min = $TMP_69 = function() {
      var __context = nil, __yield = nil; 
      if (__yield = $TMP_69._p) {
        __context = __yield._s;
        $TMP_69._p = null;
      }
      if (!!__yield) {
        return this.$raise(__scope.NotImplementedError)
        } else {
        return this.begin;
      };
    };
    __alias(this, "member?", "include?");
    def.$step = $TMP_70 = function(n) {
      var __context = nil, __yield = nil; 
      if (__yield = $TMP_70._p) {
        __context = __yield._s;
        $TMP_70._p = null;
      }if (n == null) {
        n = 1;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("step", n)
      };
      return this.$raise(__scope.NotImplementedError);
    };
    def.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
    return def.$inspect = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
  }, 0);
  __klass(this, null, "Exception", function() {
    var __scope = this._scope, def = this._proto; 
    def.$initialize = function(message) {
      if (message == null) {
        message = "";
      }
      
      if (Error.captureStackTrace) {
        Error.captureStackTrace(this);
      }

      this.message = message;
    
    };
    def.$backtrace = function() {
      
      
      if (this._bt !== undefined) {
        return this._bt;
      }

      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return this._bt = backtrace.split("\n");
      }
      else if (backtrace) {
        this._bt = backtrace;
      }

      return this._bt = ["No backtrace available"];
    
    };
    def.$inspect = function() {
      
      return "#<" + this.$class() + ": '" + this.$message() + "'>";
    };
    def.$message = function() {
      
      return this.message;
    };
    return __alias(this, "to_s", "message");
  }, 0);
  __klass(this, null, "Regexp", function() {
    var __scope = this._scope, def = this._proto; 
    __defs(this, '$escape', function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    });
    __defs(this, '$new', function(string, options) {
      
      return new RegExp(string, options);
    });
    def.$eq$ = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };
    def.$eqq$ = function(obj) {
      
      return this.test(obj);
    };
    def.$match$ = function(string) {
      
      
      var result = this.exec(string);

      if (result) {
        var match       = new RubyMatch._alloc();
            match.$data = result;

        __gvars["$~"] = match;
      }
      else {
        __gvars["$~"] = nil;
      }

      return result ? result.index : nil;
    
    };
    __alias(this, "eql?", "==");
    def.$inspect = function() {
      
      return this.toString();
    };
    def.$match = function(pattern) {
      
      
      var result  = this.exec(pattern);

      if (result) {
        var match   = new RubyMatch._alloc();
        match.$data = result;

        return __gvars["$~"] = match;
      }
      else {
        return __gvars["$~"] = nil;
      }
    
    };
    return def.$to_s = function() {
      
      return this.source;
    };
  }, 0);
  __klass(this, null, "MatchData", function() {
    var __scope = this._scope, def = this._proto; 
    def.$aref$ = function(index) {
      
      
      var length = this.$data.length;

      if (index < 0) {
        index += length;
      }

      if (index >= length || index < 0) {
        return null;
      }

      return this.$data[index];
    
    };
    def.$length = function() {
      
      return this.$data.length;
    };
    def.$inspect = function() {
      
      return "#<MatchData " + this.$aref$(0).$inspect() + ">";
    };
    __alias(this, "size", "length");
    def.$to_a = function() {
      
      return __slice.call(this.$data);
    };
    return def.$to_s = function() {
      
      return this.$data[0];
    };
  }, 0);
  __klass(this, null, "Time", function() {
    var __scope = this._scope, def = this._proto; 
    this.$include(__scope.Comparable);
    __defs(this, '$at', function(seconds, frac) {
      var result = nil; if (frac == null) {
        frac = 0;
      }
      result = this.$allocate();
      result.time = new Date(seconds * 1000 + frac);
      return result;
    });
    __defs(this, '$now', function() {
      var result = nil; 
      result = this.$allocate();
      result.time = new Date();
      return result;
    });
    def.$initialize = function() {
      
      return this.time = new Date();
    };
    def.$plus$ = function(other) {
      var __a, __b; 
      
      var res = __scope.Time.$allocate();
      res.time = new Date((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a + __b : __a.$plus$(__b)));
      return res;
    
    };
    def.$minus$ = function(other) {
      var __a, __b; 
      
      var res = __scope.Time.$allocate();
      res.time = new Date((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a - __b : __a.$minus$(__b)));
      return res;
    
    };
    def.$cmp$ = function(other) {
      
      return this.$to_f().$cmp$(other.$to_f());
    };
    def.$day = function() {
      
      return this.time.getDate();
    };
    def.$eql$p = function(other) {
      var __a; 
      return ((__a = other.$is_a$p(__scope.Time), __a !== false && __a !== nil) ? this.$cmp$(other).$zero$p() : __a);
    };
    def.$friday$p = function() {
      
      return this.time.getDay() === 5;
    };
    def.$hour = function() {
      
      return this.time.getHours();
    };
    __alias(this, "mday", "day");
    def.$min = function() {
      
      return this.time.getMinutes();
    };
    def.$mon = function() {
      
      return this.time.getMonth() + 1;
    };
    def.$monday$p = function() {
      
      return this.time.getDay() === 1;
    };
    __alias(this, "month", "mon");
    def.$saturday$p = function() {
      
      return this.time.getDay() === 6;
    };
    def.$sec = function() {
      
      return this.time.getSeconds();
    };
    def.$sunday$p = function() {
      
      return this.time.getDay() === 0;
    };
    def.$thursday$p = function() {
      
      return this.time.getDay() === 4;
    };
    def.$to_f = function() {
      
      return this.time.getTime() / 1000;
    };
    def.$to_i = function() {
      
      return parseInt(this.time.getTime() / 1000);
    };
    def.$tuesday$p = function() {
      
      return this.time.getDay() === 2;
    };
    def.$wday = function() {
      
      return this.time.getDay();
    };
    def.$wednesday$p = function() {
      
      return this.time.getDay() === 3;
    };
    return def.$year = function() {
      
      return this.time.getFullYear();
    };
  }, 0);
  return __klass(this, null, "Struct", function() {
    var __scope = this._scope, def = this._proto; 
    __defs(this, '$new', $TMP_71 = function(name, args) {
      var __a, __b; args = __slice.call(arguments, 1);
      if ((__a = this.$eq$(__scope.Struct)) !== false && __a !== nil) {

        } else {
        return Opal.zuper($TMP_71, '$new', this, __slice.call(arguments))
      };
      if ((__a = name.$is_a$p(__scope.String)) !== false && __a !== nil) {
        return __scope.Struct.$const_set(name, this.$new.apply(this, args))
        } else {
        args.$unshift(name);
        return (((__a = (__b = __scope.Class).$new)._p = function() {

          var __a, __b; 
          
          return (((__a = (__b = args).$each)._p = function(name) {

            
            if (name == null) name = nil;

            return this.$define_struct_attribute(name)
          })._s = this, __a).call(__b)
        })._s = this, __a).call(__b, this);
      };
    });
    __defs(this, '$define_struct_attribute', function(name) {
      var __a, __b; 
      this.$members().$lshft$(name);
      (((__a = (__b = this).$define_method)._p = function() {

        
        
        return this.$instance_variable_get("@" + name)
      })._s = this, __a).call(__b, name);
      return (((__a = (__b = this).$define_method)._p = function(value) {

        
        if (value == null) value = nil;

        return this.$instance_variable_set("@" + name, value)
      })._s = this, __a).call(__b, "" + name + "=");
    });
    __defs(this, '$members', function() {
      var __a; if (this.members == null) this.members = nil;

      return (__a = this.members, __a !== false && __a !== nil ? __a : this.members = [])
    });
    this.$include(__scope.Enumerable);
    def.$initialize = function(args) {
      var __a, __b; args = __slice.call(arguments, 0);
      return (((__a = (__b = this.$members()).$each_with_index)._p = function(name, index) {

        
        if (name == null) name = nil;
if (index == null) index = nil;

        return this.$instance_variable_set("@" + name, args.$aref$(index))
      })._s = this, __a).call(__b);
    };
    def.$members = function() {
      
      return this.$class().$members();
    };
    def.$aref$ = function(name) {
      var __a, __b; 
      if ((__a = name.$is_a$p(__scope.Integer)) !== false && __a !== nil) {
        if ((__a = name, __b = this.$members().$size(), typeof(__a) === 'number' ? __a >= __b : __a.$ge$(__b))) {
          this.$raise(__scope.IndexError, "offset " + name + " too large for struct(size:" + this.$members().$size() + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__b = this.$members().$include$p(name.$to_sym())) !== false && __b !== nil) {

          } else {
          this.$raise(__scope.NameError, "no member '" + name + "' in struct")
        }
      };
      return this.$instance_variable_get("@" + name);
    };
    def.$aset$ = function(name, value) {
      var __a, __b; 
      if ((__a = name.$is_a$p(__scope.Integer)) !== false && __a !== nil) {
        if ((__a = name, __b = this.$members().$size(), typeof(__a) === 'number' ? __a >= __b : __a.$ge$(__b))) {
          this.$raise(__scope.IndexError, "offset " + name + " too large for struct(size:" + this.$members().$size() + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__b = this.$members().$include$p(name.$to_sym())) !== false && __b !== nil) {

          } else {
          this.$raise(__scope.NameError, "no member '" + name + "' in struct")
        }
      };
      return this.$instance_variable_set("@" + name, value);
    };
    def.$each = $TMP_72 = function() {
      var __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_72._p) {
        __context = __yield._s;
        $TMP_72._p = null;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("each")
      };
      return (((__a = (__b = this.$members()).$each)._p = function(name) {

        
        if (name == null) name = nil;

        return __yield.call(__context, this.$aref$(name))
      })._s = this, __a).call(__b);
    };
    def.$each_pair = $TMP_73 = function() {
      var __context = nil, __yield = nil, __a, __b; 
      if (__yield = $TMP_73._p) {
        __context = __yield._s;
        $TMP_73._p = null;
      }
      if (!!__yield) {

        } else {
        return this.$enum_for("each_pair")
      };
      return (((__a = (__b = this.$members()).$each)._p = function(name) {

        
        if (name == null) name = nil;

        return __yield.call(__context, name, this.$aref$(name))
      })._s = this, __a).call(__b);
    };
    def.$eql$p = function(other) {
      var __a, __b, __c; 
      return (__a = this.$hash().$eq$(other.$hash()), __a !== false && __a !== nil ? __a : (((__b = (__c = other.$each_with_index()).$all$p)._p = function(object, index) {

        
        if (object == null) object = nil;
if (index == null) index = nil;

        return this.$aref$(this.$members().$aref$(index)).$eq$(object)
      })._s = this, __b).call(__c));
    };
    def.$length = function() {
      
      return this.$members().$length();
    };
    __alias(this, "size", "length");
    def.$to_a = function() {
      var __a, __b; 
      return (((__a = (__b = this.$members()).$map)._p = function(name) {

        
        if (name == null) name = nil;

        return this.$aref$(name)
      })._s = this, __a).call(__b);
    };
    return __alias(this, "values", "to_a");
  }, 0);;var $TMP_1, $TMP_2, $TMP_3, $TMP_4, $TMP_5, $TMP_6, $TMP_7, $TMP_8, $TMP_9, $TMP_10, $TMP_11, $TMP_12, $TMP_13, $TMP_14, $TMP_15, $TMP_16, $TMP_17, $TMP_18, $TMP_19, $TMP_20, $TMP_21, $TMP_22, $TMP_23, $TMP_24, $TMP_25, $TMP_26, $TMP_27, $TMP_28, $TMP_29, $TMP_30, $TMP_31, $TMP_32, $TMP_33, $TMP_34, $TMP_35, $TMP_36, $TMP_37, $TMP_38, $TMP_39, $TMP_40, $TMP_41, $TMP_42, $TMP_43, $TMP_44, $TMP_45, $TMP_46, $TMP_47, $TMP_48, $TMP_49, $TMP_50, $TMP_51, $TMP_52, $TMP_53, $TMP_54, $TMP_55, $TMP_56, $TMP_57, $TMP_58, $TMP_59, $TMP_60, $TMP_61, $TMP_62, $TMP_63, $TMP_64, $TMP_65, $TMP_66, $TMP_67, $TMP_68, $TMP_69, $TMP_70, $TMP_71, $TMP_72, $TMP_73;
}).call(Opal.top);

}).call(this);
