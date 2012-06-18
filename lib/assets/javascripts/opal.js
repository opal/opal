/*!
 * Opal v0.3.19
 * http://opalrb.org
 *
 * Copyright 2012, Adam Beynon
 * Released under the MIT License
 */
(function(undefined) {
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

    base._scope[id]    = klass;
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
  klass.prototype._real  = result;

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
  cls.prototype._real  = result;

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
      meta._real  = RubyClass;

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
    meta._proto  = klass;
    // FIXME: this should be removed. _proto should always point to this.
    meta._alloc.prototype = klass;
    klass._klass = meta;
    meta.__attached__ = klass;
    meta._klass = orig_class._real._klass

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

RubyObject._scope = RubyBasicObject._scope = top_const_scope;

var module_const_alloc = function(){};
var module_const_scope = new top_const_alloc();
module_const_scope.alloc = module_const_alloc;
RubyModule._scope = module_const_scope;

var class_const_alloc = function(){};
var class_const_scope = new top_const_alloc();
class_const_scope.alloc = class_const_alloc;
RubyClass._scope = class_const_scope;

RubyObject._proto.toString = function() {
  return this.$to_s();
};

Opal.top = new RubyObject._alloc();

var RubyNilClass  = define_class(RubyObject, 'NilClass', RubyObject);
Opal.nil = new RubyNilClass._alloc();
Opal.nil.call = Opal.nil.apply = no_block_given;

var breaker = Opal.breaker  = new Error('unexpected break');
    breaker.$t              = function() { throw this; };

var method_names = {'==': '$eq$', '===': '$eqq$', '[]': '$aref$', '[]=': '$aset$', '~': '$tild$', '<=>': '$cmp$', '=~': '$match$', '+': '$plus$', '-': '$minus$', '/': '$div$', '*': '$mul$', '<': '$lt$', '<=': '$le$', '>': '$gt$', '>=': '$ge$', '<<': '$lshft$', '>>': '$rshft$', '|': '$or$', '&': '$and$', '^': '$xor$', '+@': '$uplus$', '-@': '$uminus$', '%': '$mod$', '**': '$pow$'},
reverse_method_names = {};
for (var id in method_names) {
reverse_method_names[method_names[id]] = id;
}
(function() {
var __opal = Opal, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __gvars = __opal.gvars, __donate = __opal.donate, __klass = __opal.klass, __alias = __opal.alias, __module = __opal.module;

  __gvars["$~"] = nil;
  __gvars["$/"] = "\n";
  __scope.RUBY_ENGINE = "opal";
  __scope.RUBY_PLATFORM = "opal";
  __scope.RUBY_VERSION = "1.9.2";
  __klass(this, null, "BasicObject", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    def.$initialize = function() {
      
      return nil;
    };
    def.$eq$ = function(other) {
      
      return this === other;
    };
    def.$__send__ = TMP_1 = function(symbol, args) {
      var __context, block; 
      block = TMP_1._p || nil;
      __context = block._s;
      TMP_1._p = null;
      args = __slice.call(arguments, 1);
      
      var meth = this[mid_to_jsid(symbol)];

      return meth.apply(this, args);
    
    };
    def.$send = def.$__send__;
    def.$eql$p = def.$eq$;
    def.$equal$p = def.$eq$;
    def.$instance_eval = TMP_2 = function(string) {
      var __context, block; 
      block = TMP_2._p || nil;
      __context = block._s;
      TMP_2._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this, null, this);
    
    };
    def.$instance_exec = TMP_3 = function(args) {
      var __context, block; 
      block = TMP_3._p || nil;
      __context = block._s;
      TMP_3._p = null;
      args = __slice.call(arguments, 0);
      
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    
    };
    def.$method_missing = function(symbol, args) {
      args = __slice.call(arguments, 1);
      return this.$raise(__scope.NoMethodError, "undefined method `" + symbol + "` for " + this.$inspect());
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
    ;__donate(this, ["$initialize", "$eq$", "$__send__", "$send", "$eql$p", "$equal$p", "$instance_eval", "$instance_exec", "$method_missing", "$singleton_method_added", "$singleton_method_removed", "$singleton_method_undefined"]);
  });
  __klass(this, null, "Module", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    def.$eqq$ = function(object) {
      
      

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
    
    };
    def.$alias_method = function(newname, oldname) {
      
      this._proto[mid_to_jsid(newname)] = this._proto[mid_to_jsid(oldname)];
      return this;
    };
    def.$ancestors = function() {
      
      
      var parent = this,
          result = [];

      while (parent) {
        if (parent._isSingleton) {
          continue;
        }
        else if (parent._isIClass)
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
          methods   = module._methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];
        prototype[method] = donator[method];
      }

      if (klass.$included_in) {
        __donate(klass, methods.slice(), true);
      }
    
      return this;
    };
    
    function define_attr(klass, name, getter, setter) {
      if (getter) {
        var get_jsid = mid_to_jsid(name);

        klass._alloc.prototype[get_jsid] = function() {
          var res = this[name];
          return res == null ? nil : res;
        };

        __donate(klass, [get_jsid]);
      }

      if (setter) {
        var set_jsid = mid_to_jsid(name + '=');

        klass._alloc.prototype[set_jsid] = function(val) {
          return this[name] = val;
        };

        __donate(klass, [set_jsid]);
      }
    }
  
    def.$attr_accessor = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return nil;
    
    };
    def.$attr_reader = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return nil;
    
    };
    def.$attr_writer = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return nil;
    
    };
    def.$attr = function(name, setter) {
      if (setter == null) {
        setter = false;
      }
      define_attr(this, name, true, setter);
      return this;
    };
    def.$define_method = TMP_4 = function(name) {
      var __context, block; 
      block = TMP_4._p || nil;
      __context = block._s;
      TMP_4._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      var jsid = mid_to_jsid(name);
      block._jsid = jsid;

      this._alloc.prototype[jsid] = block;
      __donate(this, [jsid]);

      return nil;
    
    };
    def.$include = function(mods) {
      mods = __slice.call(arguments, 0);
      
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
    def.$module_eval = TMP_5 = function() {
      var __context, block; 
      block = TMP_5._p || nil;
      __context = block._s;
      TMP_5._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };
    def.$class_eval = def.$module_eval;
    def.$name = function() {
      
      return this._name;
    };
    def.$public_instance_methods = def.$instance_methods;
    def.$to_s = def.$name;
    ;__donate(this, ["$eqq$", "$alias_method", "$ancestors", "$append_features", "$attr_accessor", "$attr_reader", "$attr_writer", "$attr", "$define_method", "$include", "$instance_methods", "$included", "$module_eval", "$class_eval", "$name", "$public_instance_methods", "$to_s"]);
  });
  __module(this, "Kernel", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
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
    def.$class = function() {
      
      return this._real;
    };
    def.$define_singleton_method = TMP_6 = function(name) {
      var __context, body; 
      body = TMP_6._p || nil;
      __context = body._s;
      TMP_6._p = null;
      
      
      if (body === nil) {
        no_block_given();
      }

      // FIXME: need to donate()
      this.$singleton_class()._proto[mid_to_jsid(name)] = body;

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
      
      return __hasOwn.call(this, name.substr(1));
    };
    def.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == null ? nil : ivar;
    
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
    def.$kind_of$p = def.$is_a$p;
    def.$lambda = TMP_7 = function() {
      var __context, block; 
      block = TMP_7._p || nil;
      __context = block._s;
      TMP_7._p = null;
      
      return block;
    };
    def.$loop = TMP_8 = function() {
      var __context, block; 
      block = TMP_8._p || nil;
      __context = block._s;
      TMP_8._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("loop")
      };
      
      while (true) {
        if (block.call(__context) === __breaker) {
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
      return this.$puts.apply(this, [].concat(strs));
    };
    def.$private = function() {
      
      return nil;
    };
    def.$proc = TMP_9 = function() {
      var __context, block; 
      block = TMP_9._p || nil;
      __context = block._s;
      TMP_9._p = null;
      
      
      if (block === nil) {
        no_block_given();
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
        console.log((obj).$to_s());
      }
    
      return nil;
    };
    def.$sprintf = def.$format;
    def.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = __scope.RuntimeError.$new(exception);
      }
      else if (!exception.$is_a$p(__scope.Exception)) {
        exception = (exception).$new(string);
      }

      throw exception;
    
    };
    def.$rand = function(max) {
      
      return max === undefined ? Math.random() : Math.floor(Math.random() * max);
    };
    def.$require = function(path) {
      
      return Opal.require(path);
    };
    def.$respond_to$p = function(name) {
      
      return !!this[mid_to_jsid(name)];
    };
    def.$singleton_class = function() {
      
      
      var obj = this, klass;

      if (obj._isObject) {
        if (obj._isNumber || obj._isString) {
          throw RubyTypeError.$new("can't define singleton");
        }
      }

      if ((obj._klass._isSingleton) && obj._klass.__attached__ == obj) {
        klass = obj._klass;
      }
      else {
        var class_id = obj._klass._name;
        klass = make_metaclass(obj, obj._klass);
      }

      return klass;
    
    };
    def.$tap = TMP_10 = function() {
      var __context, block; 
      block = TMP_10._p || nil;
      __context = block._s;
      TMP_10._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      if (block.call(__context, this) === __breaker) {
        return __breaker.$v;
      }

      return this;
    
    };
    def.$to_proc = function() {
      
      return this;
    };
    def.$to_s = function() {
      
      return "#<" + this._klass._real._name + ":0x" + (this._id * 400487).toString(16) + ">";
    };
        ;__donate(this, ["$match$", "$eqq$", "$Array", "$class", "$define_singleton_method", "$equal$p", "$extend", "$format", "$hash", "$inspect", "$instance_of$p", "$instance_variable_defined$p", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a$p", "$kind_of$p", "$lambda", "$loop", "$nil$p", "$object_id", "$print", "$private", "$proc", "$protected", "$public", "$puts", "$sprintf", "$raise", "$rand", "$require", "$respond_to$p", "$singleton_class", "$tap", "$to_proc", "$to_s"]);
  });
  __klass(this, null, "Object", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$include(__scope.Kernel);
    def.$methods = function() {
      
      return [];
    };
    def.$private_methods = def.$methods;
    def.$protected_methods = def.$methods;
    def.$public_methods = def.$methods;
    def.$singleton_methods = function() {
      
      return [];
    };
    ;__donate(this, ["$methods", "$private_methods", "$protected_methods", "$public_methods", "$singleton_methods"]);
  });
  this.$singleton_class()._proto.$to_s = function() {
    
    return "main"
  };
  this.$singleton_class()._proto.$include = function(mod) {
    
    return __scope.Object.$include(mod)
  };
  __klass(this, null, "Class", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$new = TMP_11 = function(sup) {
      var __context, block; 
      block = TMP_11._p || nil;
      __context = block._s;
      TMP_11._p = null;
      if (sup == null) {
        sup = __scope.Object;
      }
      
      var klass        = boot_class(sup);
          klass._name = nil;

      make_metaclass(klass, sup._klass);

      sup.$inherited(klass);

      if (block !== nil) {
        block.call(klass);
      }

      return klass;
    
    };
    def.$allocate = function() {
      
      return new this._alloc();
    };
    def.$new = TMP_12 = function(args) {
      var __context, block; 
      block = TMP_12._p || nil;
      __context = block._s;
      TMP_12._p = null;
      args = __slice.call(arguments, 0);
      
      var obj = this.$allocate();
      obj._p  = block;
      obj.$initialize.apply(obj, args);
      return obj;
    
    };
    def.$inherited = function(cls) {
      
      return nil;
    };
    def.$superclass = function() {
      
      
      var sup = this._super;

      if (!sup) {
        if (this === RubyBasicObject) {
          return nil;
        }

        throw RubyRuntimeError.$new('uninitialized class');
      }

      while (sup && (sup._isIClass)) {
        sup = sup._super;
      }

      if (!sup) {
        return nil;
      }

      return sup;
    
    };
    ;__donate(this, ["$allocate", "$new", "$inherited", "$superclass"]);
  });
  __klass(this, Boolean, "Boolean", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    
    def._isBoolean = true;
  
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
    def.$singleton_class = def.$class;
    def.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };
    ;__donate(this, ["$and$", "$or$", "$xor$", "$eq$", "$class", "$singleton_class", "$to_s"]);
  });
  __klass(this, null, "TrueClass", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$eqq$ = function(obj) {
      
      return obj === true;
    }
    ;__donate(this, []);
  });
  __klass(this, null, "FalseClass", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$eqq$ = function(obj) {
      
      return obj === false;
    }
    ;__donate(this, []);
  });
  __scope.TRUE = true;
  __scope.FALSE = false;
  __klass(this, null, "NilClass", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
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
    def.$to_f = def.$to_i;
    def.$to_s = function() {
      
      return "";
    };
    ;__donate(this, ["$and$", "$or$", "$xor$", "$eq$", "$inspect", "$nil$p", "$singleton_class", "$to_a", "$to_i", "$to_f", "$to_s"]);
  });
  __scope.NIL = nil;
  __module(this, "Enumerable", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    def.$all$p = TMP_13 = function() {
      var __context, block; 
      block = TMP_13._p || nil;
      __context = block._s;
      TMP_13._p = null;
      
      
      var result = true, proc;

      if (block !== nil) {
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
    def.$any$p = TMP_14 = function() {
      var __context, block; 
      block = TMP_14._p || nil;
      __context = block._s;
      TMP_14._p = null;
      
      
      var result = false, proc;

      if (block !== nil) {
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
    def.$collect = TMP_15 = function() {
      var __context, block; 
      block = TMP_15._p || nil;
      __context = block._s;
      TMP_15._p = null;
      
      if ((block !== nil)) {

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
    def.$count = TMP_16 = function(object) {
      var __context, block; 
      block = TMP_16._p || nil;
      __context = block._s;
      TMP_16._p = null;
      
      
      var result = 0;

      if (block === nil) {
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
    def.$detect = TMP_17 = function(ifnone) {
      var __a, __context, block; 
      block = TMP_17._p || nil;
      __context = block._s;
      TMP_17._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("detect", ifnone)
      };
      
      var result = nil;

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result      = obj;
          __breaker.$v = nil;

          return __breaker;
        }
      };

      this.$each();

      if (result !== nil) {
        return result;
      }

      if (typeof(ifnone) === 'function') {
        return ifnone.$call();
      }

      return ifnone === undefined ? nil : ifnone;
    
    };
    def.$drop = function(number) {
      
      
      var result  = [],
          current = 0;

      this.$each._p = function(obj) {
        if (number < current) {
          result.push(e);
        }

        current++;
      };

      this.$each();

      return result;
    
    };
    def.$drop_while = TMP_18 = function() {
      var __a, __context, block; 
      block = TMP_18._p || nil;
      __context = block._s;
      TMP_18._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("drop_while")
      };
      
      var result = [];

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker;
        }

        if (value !== false && value !== nil) {
          result.push(obj);
        }
        else {
          return __breaker;
        }
      };

      this.$each();

      return result;
    
    };
    def.$each_with_index = TMP_19 = function() {
      var __a, __context, block; 
      block = TMP_19._p || nil;
      __context = block._s;
      TMP_19._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("each_with_index")
      };
      
      var index = 0;

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, index)) === __breaker) {
          return __breaker.$v;
        }

        index++;
      };

      this.$each();

      return nil;
    
    };
    def.$each_with_object = TMP_20 = function(object) {
      var __a, __context, block; 
      block = TMP_20._p || nil;
      __context = block._s;
      TMP_20._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("each_with_object")
      };
      
      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      this.$each();

      return object;
    
    };
    def.$entries = function() {
      
      
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    
    };
    def.$find = def.$detect;
    def.$find_all = TMP_21 = function() {
      var __a, __context, block; 
      block = TMP_21._p || nil;
      __context = block._s;
      TMP_21._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this.$enum_for("find_all")
      };
      
      var result = [];

      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          //result      = obj;
          //__breaker.$v = nil;

          //return __breaker;
          result.push(obj);
        }
      };

      this.$each();

      return result;
    
    };
    def.$find_index = TMP_22 = function(object) {
      var __context, block; 
      block = TMP_22._p || nil;
      __context = block._s;
      TMP_22._p = null;
      
      
      var proc, result = nil, index = 0;

      if (object != null) {
        proc = function (obj) { 
          if (obj.$eq$(object)) {
            result = index;
            return __breaker;
          }
          index += 1;
        };
      }
      else if (block === nil) {
        return this.$enum_for("find_index");
      } else {
        proc = function(obj) {
          var value;

          if ((value = block.call(__context, obj)) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            result     = index;
            __breaker.$v = index;

            return __breaker;
          }
          index += 1;
        };
      }

      this.$each._p = proc;

      this.$each();

      return result;
    
    };
    def.$first = function(number) {
      
      
      var result = [],
          current = 0,
          proc;

      if (number == null) {
        result = nil;
        proc = function(obj) {
            result = obj; return __breaker;
          };
      } else {
        proc = function(obj) {
            if (number <= current) {
              return __breaker;
            }

            result.push(obj);

            current++;
          };
      }

      this.$each._p = proc;

      this.$each();

      return result;
    
    };
    def.$grep = TMP_23 = function(pattern) {
      var __context, block; 
      block = TMP_23._p || nil;
      __context = block._s;
      TMP_23._p = null;
      
      
      var result = [];

      this.$each._p = (block !== nil
        ? function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value !== nil) {
              if ((value = block.call(__context, obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(obj) {
            var value = pattern.$eqq$(obj);

            if (value !== false && value !== nil) {
              result.push(obj);
            }
          });

      this.$each();

      return result;
    
    };
    def.$take = def.$first;
    def.$to_a = def.$entries;
        ;__donate(this, ["$all$p", "$any$p", "$collect", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$each_with_object", "$entries", "$find", "$find_all", "$find_index", "$first", "$grep", "$take", "$to_a"]);
  });
  __klass(this, null, "Enumerator", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    __klass(this, null, "Yielder", function() {
      var __class = this, __scope = this._scope, def = this._proto; 
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
      def.$lshft$ = def.$yield;
      ;__donate(this, ["$initialize", "$call", "$yield", "$lshft$"]);
    });
    __klass(this, null, "Generator", function() {
      var __class = this, __scope = this._scope, def = this._proto; 
      def.$enumerator = function() { return this.enumerator == null ? nil : this.enumerator; };
      def.$initialize = function(block) {
        
        return this.yielder = __scope.Yielder.$new(block);
      };
      def.$each = TMP_24 = function() {
        var __context, block; 
        if (this.yielder == null) this.yielder = nil;

        block = TMP_24._p || nil;
        __context = block._s;
        TMP_24._p = null;
        
        return this.yielder.$call(block);
      };
      ;__donate(this, ["$initialize", "$each"]);
    });
    def.$initialize = TMP_25 = function(object, method, args) {
      var __a, __context, block; 
      block = TMP_25._p || nil;
      __context = block._s;
      TMP_25._p = null;
      if (object == null) {
        object = nil;
      }if (method == null) {
        method = "each";
      }args = __slice.call(arguments, 2);
      if ((block !== nil)) {
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
      var result = nil, __a; 
      if (this.cache == null) this.cache = nil;
      if (this.current == null) this.current = nil;

      this.$_init_cache();
      (__a = result = this.cache.$aref$(this.current), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
      this.current = this.current.$plus$(1);
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
      var __a; 
      if (this.cache == null) this.cache = nil;
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
    def.$each = TMP_26 = function() {
      var __a, __context, block; 
      if (this.object == null) this.object = nil;
      if (this.method == null) this.method = nil;
      if (this.args == null) this.args = nil;

      block = TMP_26._p || nil;
      __context = block._s;
      TMP_26._p = null;
      
      if ((__a = block) !== false && __a !== nil) {

        } else {
        return this
      };
      return (__a = this.object, __a.$__send__._p = block.$to_proc(), __a.$__send__.apply(__a, [this.method].concat(this.args)));
    };
    def.$each_with_index = TMP_27 = function() {
      var __a, __context, block; 
      block = TMP_27._p || nil;
      __context = block._s;
      TMP_27._p = null;
      
      return (__a = this, __a.$with_index._p = block.$to_proc(), __a.$with_index());
    };
    def.$with_index = TMP_28 = function(offset) {
      var current = nil, __a, __b, __context, __yield; 
      __yield = TMP_28._p || nil;
      __context = __yield._s;
      TMP_28._p = null;
      if (offset == null) {
        offset = 0;
      }
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("with_index", offset)
      };
      current = 0;
      return (__b = this, __b.$each._p = (__a = function(args) {

        
        args = __slice.call(arguments, 0);
        if (current.$ge$(offset)) {

          } else {
          return nil;
        };
        __yield.apply(__context, [].concat(args).concat([["current"]]));
        return current = current.$plus$(1);
      }, __a._s = this, __a), __b.$each());
    };
    def.$with_object = TMP_29 = function(object) {
      var __a, __b, __context, __yield; 
      __yield = TMP_29._p || nil;
      __context = __yield._s;
      TMP_29._p = null;
      
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("with_object", object)
      };
      return (__b = this, __b.$each._p = (__a = function(args) {

        
        args = __slice.call(arguments, 0);
        return __yield.apply(__context, [].concat(args).concat([["object"]]))
      }, __a._s = this, __a), __b.$each());
    };
    def.$_init_cache = function() {
      var __a; 
      if (this.current == null) this.current = nil;
      if (this.cache == null) this.cache = nil;

      (__a = this.current, __a !== false && __a !== nil ? __a : this.current = 0);
      return (__a = this.cache, __a !== false && __a !== nil ? __a : this.cache = this.$to_a());
    };
    def.$_clear_cache = function() {
      
      this.cache = nil;
      return this.current = nil;
    };
    ;__donate(this, ["$initialize", "$next", "$next_values", "$peek", "$peel_values", "$rewind", "$each", "$each_with_index", "$with_index", "$with_object", "$_init_cache", "$_clear_cache"]);
  });
  __module(this, "Kernel", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    def.$enum_for = function(method, args) {
      var __a; if (method == null) {
        method = "each";
      }args = __slice.call(arguments, 1);
      return (__a = __scope.Enumerator).$new.apply(__a, [this, method].concat(args));
    };
    def.$to_enum = def.$enum_for;
        ;__donate(this, ["$enum_for", "$to_enum"]);
  });
  __module(this, "Comparable", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    def.$lt$ = function(other) {
      
      return this.$cmp$(other).$eq$(-1);
    };
    def.$le$ = function(other) {
      
      return this.$cmp$(other).$le$(0);
    };
    def.$eq$ = function(other) {
      
      return this.$cmp$(other).$eq$(0);
    };
    def.$gt$ = function(other) {
      
      return this.$cmp$(other).$eq$(1);
    };
    def.$ge$ = function(other) {
      
      return this.$cmp$(other).$ge$(0);
    };
    def.$between$p = function(min, max) {
      var __a; 
      return (__a = this.$gt$(min) ? this.$lt$(max) : __a);
    };
        ;__donate(this, ["$lt$", "$le$", "$eq$", "$gt$", "$ge$", "$between$p"]);
  });
  __klass(this, Array, "Array", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    
    def._isArray = true;
  
    this.$include(__scope.Enumerable);
    this.$singleton_class()._proto.$aref$ = function(objects) {
      objects = __slice.call(arguments, 0);
      
      var result = this.$allocate();

      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    
    };
    this.$singleton_class()._proto.$new = function(a) {
      a = __slice.call(arguments, 0);
      return this.$allocate()
    };
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
        if (index._isRange) {
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
    def.$collect = TMP_30 = function() {
      var __context, block; 
      block = TMP_30._p || nil;
      __context = block._s;
      TMP_30._p = null;
      
      if ((block !== nil)) {

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
    def.$collect$b = TMP_31 = function() {
      var __context, block; 
      block = TMP_31._p || nil;
      __context = block._s;
      TMP_31._p = null;
      
      if ((block !== nil)) {

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
    def.$delete_if = TMP_32 = function() {
      var __context, block; 
      block = TMP_32._p || nil;
      __context = block._s;
      TMP_32._p = null;
      
      if ((block !== nil)) {

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
    def.$drop_while = TMP_33 = function() {
      var __context, block; 
      block = TMP_33._p || nil;
      __context = block._s;
      TMP_33._p = null;
      
      if ((block !== nil)) {

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
    def.$dup = def.$clone;
    def.$each = TMP_34 = function() {
      var __context, block; 
      block = TMP_34._p || nil;
      __context = block._s;
      TMP_34._p = null;
      
      if ((block !== nil)) {

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
    def.$each_index = TMP_35 = function() {
      var __context, block; 
      block = TMP_35._p || nil;
      __context = block._s;
      TMP_35._p = null;
      
      if ((block !== nil)) {

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
    def.$each_with_index = TMP_36 = function() {
      var __context, block; 
      block = TMP_36._p || nil;
      __context = block._s;
      TMP_36._p = null;
      
      if ((block !== nil)) {

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
    def.$fetch = TMP_37 = function(index, defaults) {
      var __context, block; 
      block = TMP_37._p || nil;
      __context = block._s;
      TMP_37._p = null;
      
      
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

        if (item._isArray) {
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
    def.$index = TMP_38 = function(object) {
      var __a, __context, block; 
      block = TMP_38._p || nil;
      __context = block._s;
      TMP_38._p = null;
      
      if ((__a = (__a = (block !== nil) ? object.$eq$(this.$undefined()) : __a)) !== false && __a !== nil) {

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
    def.$inject = TMP_39 = function(initial) {
      var __context, block; 
      block = TMP_39._p || nil;
      __context = block._s;
      TMP_39._p = null;
      
      if ((block !== nil)) {

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
    def.$keep_if = TMP_40 = function() {
      var __context, block; 
      block = TMP_40._p || nil;
      __context = block._s;
      TMP_40._p = null;
      
      if ((block !== nil)) {

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
    def.$map = def.$collect;
    def.$map$b = def.$collect$b;
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
    def.$reject = TMP_41 = function() {
      var __context, block; 
      block = TMP_41._p || nil;
      __context = block._s;
      TMP_41._p = null;
      
      if ((block !== nil)) {

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
    def.$reject$b = TMP_42 = function() {
      var __context, block; 
      block = TMP_42._p || nil;
      __context = block._s;
      TMP_42._p = null;
      
      if ((block !== nil)) {

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
    def.$reverse_each = TMP_43 = function() {
      var __a, __context, block; 
      block = TMP_43._p || nil;
      __context = block._s;
      TMP_43._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("reverse_each")
      };
      (__a = this.$reverse(), __a.$each._p = block.$to_proc(), __a.$each());
      return this;
    };
    def.$rindex = TMP_44 = function(object) {
      var __a, __context, block; 
      block = TMP_44._p || nil;
      __context = block._s;
      TMP_44._p = null;
      
      if ((__a = (__a = (block !== nil) ? object.$eq$(this.$undefined()) : __a)) !== false && __a !== nil) {

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
    def.$select = TMP_45 = function() {
      var __context, block; 
      block = TMP_45._p || nil;
      __context = block._s;
      TMP_45._p = null;
      
      if ((block !== nil)) {

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
    def.$select$b = TMP_46 = function() {
      var __context, block; 
      block = TMP_46._p || nil;
      __context = block._s;
      TMP_46._p = null;
      
      if ((block !== nil)) {

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
    def.$size = def.$length;
    def.$slice = def.$aref$;
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
    def.$take_while = TMP_47 = function() {
      var __context, block; 
      block = TMP_47._p || nil;
      __context = block._s;
      TMP_47._p = null;
      
      if ((block !== nil)) {

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
    def.$to_ary = def.$to_a;
    def.$to_s = def.$inspect;
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
    def.$zip = TMP_48 = function(others) {
      var __context, block; 
      block = TMP_48._p || nil;
      __context = block._s;
      TMP_48._p = null;
      others = __slice.call(arguments, 0);
      
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

      if (block !== nil) {
        for (var i = 0; i < size; i++) {
          block.call(__context, result[i]);
        }

        return nil;
      }

      return result;
    
    };
    ;__donate(this, ["$and$", "$mul$", "$plus$", "$lshft$", "$cmp$", "$eq$", "$aref$", "$aset$", "$assoc", "$at", "$clear", "$clone", "$collect", "$collect$b", "$compact", "$compact$b", "$concat", "$count", "$delete", "$delete_at", "$delete_if", "$drop", "$drop_while", "$dup", "$each", "$each_index", "$each_with_index", "$empty$p", "$fetch", "$first", "$flatten", "$flatten$b", "$grep", "$hash", "$include$p", "$index", "$inject", "$insert", "$inspect", "$join", "$keep_if", "$last", "$length", "$map", "$map$b", "$pop", "$push", "$rassoc", "$reject", "$reject$b", "$replace", "$reverse", "$reverse$b", "$reverse_each", "$rindex", "$select", "$select$b", "$shift", "$size", "$slice", "$slice$b", "$take", "$take_while", "$to_a", "$to_ary", "$to_s", "$uniq", "$uniq$b", "$unshift", "$zip"]);
  });
  __klass(this, null, "Hash", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    
    var hash_class = this;

    var __hash = Opal.hash = function() {
      var hash    = new hash_class._alloc(),
          args    = __slice.call(arguments),
          assocs  = {};

      hash.map    = assocs;
      hash.none   = nil;
      hash.proc   = nil;

      if (args.length == 1 && args[0]._isArray) {
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
  
    this.$singleton_class()._proto.$aref$ = function(objs) {
      objs = __slice.call(arguments, 0);
      return __hash.apply(null, objs);
    };
    this.$singleton_class()._proto.$allocate = function() {
      
      return __hash();
    };
    this.$singleton_class()._proto.$new = TMP_49 = function(defaults) {
      var __context, block; 
      block = TMP_49._p || nil;
      __context = block._s;
      TMP_49._p = null;
      
      
      var hash = __hash();

      if (defaults != null) {
        hash.none = defaults;
      }
      else if (block !== nil) {
        hash.proc = block;
      }

      return hash;
    
    };
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
      
      
      var result = __hash(),
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
    def.$delete_if = TMP_50 = function() {
      var __context, block; 
      block = TMP_50._p || nil;
      __context = block._s;
      TMP_50._p = null;
      
      if ((block !== nil)) {

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
    def.$dup = def.$clone;
    def.$each = TMP_51 = function() {
      var __context, block; 
      block = TMP_51._p || nil;
      __context = block._s;
      TMP_51._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("each")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0], bucket[1]) === __breaker) {
          return $breaker.$v;
        }
      }

      return this;
    
    };
    def.$each_key = TMP_52 = function() {
      var __context, block; 
      block = TMP_52._p || nil;
      __context = block._s;
      TMP_52._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("each_key")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };
    def.$each_pair = def.$each;
    def.$each_value = TMP_53 = function() {
      var __context, block; 
      block = TMP_53._p || nil;
      __context = block._s;
      TMP_53._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("each_value")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[1]) === __breaker) {
          return __breaker.$v;
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
    def.$eql$p = def.$eq$;
    def.$fetch = TMP_54 = function(key, defaults) {
      var __context, block; 
      block = TMP_54._p || nil;
      __context = block._s;
      TMP_54._p = null;
      
      
      var bucket = this.map[key];

      if (bucket) {
        return bucket[1];
      }

      if (block !== nil) {
        var value;

        if ((value = block.call(__context, key)) === __breaker) {
          return __breaker.$v;
        }

        return value;
      }

      if (defaults != null) {
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

        if (value._isArray) {
          if (level == null || level === 1) {
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
    def.$include$p = def.$has_key$p;
    def.$index = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (object.$eq$(bucket[1])) {
          return bucket[0];
        }
      }

      return nil;
    
    };
    def.$indexes = function(keys) {
      keys = __slice.call(arguments, 0);
      
      var result = [], map = this.map, bucket;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (bucket = map[key]) {
          result.push(bucket[1]);
        }
        else {
          result.push(this.none);
        }
      }

      return result;
    
    };
    def.$indices = def.$indexes;
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
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[bucket[1]] = [bucket[1], bucket[0]];
      }

      return result;
    
    };
    def.$keep_if = TMP_55 = function() {
      var __context, block; 
      block = TMP_55._p || nil;
      __context = block._s;
      TMP_55._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("keep_if")
      };
      
      var map = this.map, value;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return $breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[assoc];
        }
      }

      return this;
    
    };
    def.$key = def.$index;
    def.$key$p = def.$has_key$p;
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
    def.$member$p = def.$has_key$p;
    def.$merge = TMP_56 = function(other) {
      var __context, block; 
      block = TMP_56._p || nil;
      __context = block._s;
      TMP_56._p = null;
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[assoc] = [bucket[0], bucket[1]];
      }

      map = other.map;

      if (block === nil) {
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
    def.$merge$b = TMP_57 = function(other) {
      var __context, block; 
      block = TMP_57._p || nil;
      __context = block._s;
      TMP_57._p = null;
      
      
      var map  = this.map,
          map2 = other.map;

      if (block === nil) {
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

      return nil;
    
    };
    def.$reject = TMP_58 = function() {
      var __context, block; 
      block = TMP_58._p || nil;
      __context = block._s;
      TMP_58._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("reject")
      };
      
      var map = this.map, result = __hash(), map2 = result.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          map2[bucket[0]] = [bucket[0], bucket[1]];
        }
      }

      return result;
    
    };
    def.$replace = function(other) {
      
      
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[bucket[0]] = [bucket[0], bucket[1]];
      }

      return this;
    
    };
    def.$select = TMP_59 = function() {
      var __context, block; 
      block = TMP_59._p || nil;
      __context = block._s;
      TMP_59._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("select")
      };
      
      var map = this.map, result = __hash(), map2 = result.map;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          map2[bucket[0]] = [bucket[0], bucket[1]];
        }
      }

      return result;
    
    };
    def.$select$b = TMP_60 = function() {
      var __context, block; 
      block = TMP_60._p || nil;
      __context = block._s;
      TMP_60._p = null;
      
      if ((block !== nil)) {

        } else {
        return this.$enum_for("select!")
      };
      
      var map = this.map, result = nil;

      for (var assoc in map) {
        var bucket = map[assoc],
            value;

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[assoc];
          result = this;
        }
      }

      return result;
    
    };
    def.$shift = function() {
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];
        delete map[assoc];
        return [bucket[0], bucket[1]];
      }

      return nil;
    
    };
    def.$size = def.$length;
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
    def.$to_s = def.$inspect;
    def.$update = def.$merge$b;
    def.$value$p = function(value) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var v = map[assoc][1];
        if ((v).$eq$(value)) {
          return true;
        }
      }

      return false;
    
    };
    def.$values_at = def.$indexes;
    def.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    
    };
    ;__donate(this, ["$eq$", "$aref$", "$aset$", "$assoc", "$clear", "$clone", "$default", "$default$e", "$default_proc", "$default_proc$e", "$delete", "$delete_if", "$dup", "$each", "$each_key", "$each_pair", "$each_value", "$empty$p", "$eql$p", "$fetch", "$flatten", "$has_key$p", "$has_value$p", "$hash", "$include$p", "$index", "$indexes", "$indices", "$inspect", "$invert", "$keep_if", "$key", "$key$p", "$keys", "$length", "$member$p", "$merge", "$merge$b", "$rassoc", "$reject", "$replace", "$select", "$select$b", "$shift", "$size", "$to_a", "$to_hash", "$to_s", "$update", "$value$p", "$values_at", "$values"]);
  });
  __klass(this, String, "String", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    
    def._isString = true;
    var string_class = this;
  
    this.$include(__scope.Comparable);
    this.$singleton_class()._proto.$try_convert = function(what) {
      
      return (function() { try {
      what.$to_str()
      } catch ($err) {
      if (true) {
nil}
else { throw $err; }
} }).call(this)
    };
    this.$singleton_class()._proto.$new = function(str) {
      if (str == null) {
        str = "";
      }
      return this.$allocate(str.$to_s())
    };
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
        return nil;
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
    def.$eqq$ = def.$eq$;
    def.$match$ = function(other) {
      
      
      if (typeof other === 'string') {
        throw RubyTypeError.$new('string given');
      }

      return other.$match$(this);
    
    };
    def.$aref$ = function(index, length) {
      
      
      if (length == null) {
        if (index < 0) {
          index += this.length;
        }

        if (index >= this.length || index < 0) {
          return nil;
        }

        return this.substr(index, 1);
      }

      if (index < 0) {
        index += this.length + 1;
      }

      if (index > this.length || index < 0) {
        return nil;
      }

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
    def.$chars = TMP_61 = function() {
      var __context, __yield; 
      __yield = TMP_61._p || nil;
      __context = __yield._s;
      TMP_61._p = null;
      
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("chars")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        __yield.call(__context, this.charAt(i))
      }
    
    };
    def.$chomp = function(separator) {
      if (separator == null) {
        separator = __gvars["$/"];
      }
      
      if (separator === "\n") {
        return this.replace(/(\n|\r|\r\n)$/, '');
      }
      else if (separator === "") {
        return this.replace(/(\n|\r\n)+$/, '');
      }
      return this.replace(new RegExp(separator + '$'), '');
    
    };
    def.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };
    def.$chr = function() {
      
      return this.charAt(0);
    };
    def.$downcase = function() {
      
      return this.toLowerCase();
    };
    def.$each_char = def.$chars;
    def.$each_line = TMP_62 = function(separator) {
      var __context, __yield; 
      __yield = TMP_62._p || nil;
      __context = __yield._s;
      TMP_62._p = null;
      if (separator == null) {
        separator = __gvars["$/"];
      }
      if ((__yield !== nil)) {

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
    def.$eql$p = def.$eq$;
    def.$equal$p = function(val) {
      
      return this.toString() === val.toString();
    };
    def.$getbyte = function(index) {
      
      return this.charCodeAt(index);
    };
    def.$gsub = TMP_63 = function(pattern, replace) {
      var __a, __context, block; 
      block = TMP_63._p || nil;
      __context = block._s;
      TMP_63._p = null;
      
      if ((__a = (__a = !block, __a !== false && __a !== nil ? pattern === undefined : __a)) !== false && __a !== nil) {
        return this.$enum_for("gsub", pattern, replace)
      };
      if ((__a = pattern.$is_a$p(__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return (__a = this, __a.$sub._p = block.$to_proc(), __a.$sub(new RegExp(regexp, options), replace));
    
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
      var __a; 
      if ((__a = (__a = __scope.String.$eqq$(what), __a !== false && __a !== nil ? __a : __scope.Regexp.$eqq$(what))) !== false && __a !== nil) {

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

      return result === -1 ? nil : result;
    
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
    def.$lines = def.$each_line;
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
      
      return this.replace(/^\s*/, '');
    };
    def.$match = TMP_64 = function(pattern, pos) {
      var __a, __b, __context, block; 
      block = TMP_64._p || nil;
      __context = block._s;
      TMP_64._p = null;
      
      return (__a = (function() { if ((__b = pattern.$is_a$p(__scope.Regexp)) !== false && __b !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this), __a.$match._p = block.$to_proc(), __a.$match(this, pos));
    };
    def.$next = function() {
      
      
      if (this.length === 0) {
        return "";
      }

      var initial = this.substr(0, this.length - 1);
      var last    = String.fromCharCode(this.charCodeAt(this.length - 1) + 1);

      return initial + last;
    
    };
    def.$ord = function() {
      
      return this.charCodeAt(0);
    };
    def.$partition = function(str) {
      
      
      var result = this.split(str);
      var splitter = (result[0].length === this.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    
    };
    def.$reverse = function() {
      
      return this.split('').reverse().join('');
    };
    def.$rstrip = function() {
      
      return this.replace(/\s*$/, '');
    };
    def.$size = def.$length;
    def.$slice = def.$aref$;
    def.$split = function(pattern, limit) {
      var __a; if (pattern == null) {
        pattern = (__a = __gvars["$;"], __a !== false && __a !== nil ? __a : " ");
      }
      return this.split(pattern, limit);
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
      
      return this.replace(/^\s*/, '').replace(/\s*$/, '');
    };
    def.$sub = TMP_65 = function(pattern, replace) {
      var __context, block; 
      block = TMP_65._p || nil;
      __context = block._s;
      TMP_65._p = null;
      
      
      if (typeof(replace) === 'string') {
        return this.replace(pattern, replace);
      }
      if (block !== nil) {
        return this.replace(pattern, function(str) {
          //$opal.match_data = arguments

          return block.call(__context, str);
        });
      }
      else if (replace != null) {
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
    def.$succ = def.$next;
    def.$sum = function(n) {
      if (n == null) {
        n = 16;
      }
      
      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        result += (this.charCodeAt(i) % ((1 << n) - 1));
      }

      return result;
    
    };
    def.$swapcase = function() {
      
      
      var str = this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (this._klass === string_class) {
        return str;
      }

      return this._klass.$new(str);
    
    };
    def.$to_a = function() {
      
      
      if (this.length === 0) {
        return [];
      }

      return [this];
    
    };
    def.$to_f = function() {
      
      
      var result = parseFloat(this);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    
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
      
      
      var self = this, jsid = mid_to_jsid(self);

      return function(arg) { return arg[jsid](); };
    
    };
    def.$to_s = function() {
      
      return this.toString();
    };
    def.$to_str = def.$to_s;
    def.$to_sym = def.$intern;
    def.$upcase = function() {
      
      return this.toUpperCase();
    };
    ;__donate(this, ["$mod$", "$mul$", "$plus$", "$cmp$", "$lt$", "$le$", "$gt$", "$ge$", "$eq$", "$eqq$", "$match$", "$aref$", "$capitalize", "$casecmp", "$chars", "$chomp", "$chop", "$chr", "$downcase", "$each_char", "$each_line", "$empty$p", "$end_with$p", "$eql$p", "$equal$p", "$getbyte", "$gsub", "$hash", "$hex", "$include$p", "$index", "$inspect", "$intern", "$lines", "$length", "$ljust", "$lstrip", "$match", "$next", "$ord", "$partition", "$reverse", "$rstrip", "$size", "$slice", "$split", "$start_with$p", "$strip", "$sub", "$succ", "$sum", "$swapcase", "$to_a", "$to_f", "$to_i", "$to_proc", "$to_s", "$to_str", "$to_sym", "$upcase"]);
  });
  __scope.Symbol = __scope.String;
  __klass(this, Number, "Numeric", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    
    def._isNumber = true;
  
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
    def.$downto = TMP_66 = function(finish) {
      var __context, block; 
      block = TMP_66._p || nil;
      __context = block._s;
      TMP_66._p = null;
      
      if ((block !== nil)) {

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
    def.$eql$p = def.$eq$;
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
    def.$magnitude = def.$abs;
    def.$modulo = def.$mod$;
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
    def.$succ = def.$next;
    def.$times = TMP_67 = function() {
      var __a, __context, block; 
      block = TMP_67._p || nil;
      __context = block._s;
      TMP_67._p = null;
      
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
    def.$upto = TMP_68 = function(finish) {
      var __context, block; 
      block = TMP_68._p || nil;
      __context = block._s;
      TMP_68._p = null;
      
      if ((block !== nil)) {

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
    def.$zero$p = function() {
      
      return this.valueOf() === 0;
    };
    ;__donate(this, ["$plus$", "$minus$", "$mul$", "$div$", "$mod$", "$and$", "$or$", "$xor$", "$lt$", "$le$", "$gt$", "$ge$", "$lshft$", "$rshft$", "$uplus$", "$uminus$", "$tild$", "$pow$", "$eq$", "$cmp$", "$abs", "$ceil", "$chr", "$downto", "$eql$p", "$even$p", "$floor", "$hash", "$integer$p", "$magnitude", "$modulo", "$next", "$nonzero$p", "$odd$p", "$ord", "$pred", "$succ", "$times", "$to_f", "$to_i", "$to_s", "$upto", "$zero$p"]);
  });
  __klass(this, null, "Integer", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$eqq$ = function(obj) {
      
      
      if (typeof(obj) !== 'number') {
        return false;
      }

      return other % 1 === 0;
    
    }
    ;__donate(this, []);
  });
  __klass(this, null, "Float", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$eqq$ = function(obj) {
      
      
      if (typeof(obj) !== 'number') {
        return false;
      }

      return obj % 1 !== 0;
    
    }
    ;__donate(this, []);
  });
  __klass(this, Function, "Proc", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    
    def._isProc = true;
  
    this.$singleton_class()._proto.$new = TMP_69 = function() {
      var __context, block; 
      block = TMP_69._p || nil;
      __context = block._s;
      TMP_69._p = null;
      
      if (block === nil) no_block_given();
      return block;
    };
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
    def.$arity = function() {
      
      return this.length - 1;
    };
    ;__donate(this, ["$to_proc", "$call", "$to_proc", "$to_s", "$lambda$p", "$arity"]);
  });
  __klass(this, null, "Range", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$include(__scope.Enumerable);
    
    var range_class = this;
    def._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new range_class._alloc();
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  
    def.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false;
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };
    def.$eq$ = function(other) {
      var __a; 
      if ((__a = __scope.Range.$eqq$(other)) !== false && __a !== nil) {

        } else {
        return false
      };
      return (__a = (__a = this.$exclude_end$p().$eq$(other.$exclude_end$p()), __a !== false && __a !== nil ? (this.begin).$eq$(other.$begin()) : __a), __a !== false && __a !== nil ? (this.end).$eq$(other.$end()) : __a);
    };
    def.$eqq$ = function(obj) {
      
      return obj >= this.begin && obj <= this.end;
    };
    def.$begin = function() {
      
      return this.begin;
    };
    def.$cover$p = function(value) {
      var __a, __b, __c; 
      return (__a = (this.begin).$le$(value) ? value.$le$((function() { if ((__b = this.$exclude_end$p()) !== false && __b !== nil) {
        return (__b = this.end, __c = 1, typeof(__b) === 'number' ? __b - __c : __b.$minus$(__c))
        } else {
        return this.end;
      }; return nil; }).call(this)) : __a);
    };
    def.$each = TMP_70 = function() {
      var current = nil, __a, __b, __context, __yield; 
      __yield = TMP_70._p || nil;
      __context = __yield._s;
      TMP_70._p = null;
      
      if ((__yield !== nil)) {

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
      var __a; 
      if ((__a = __scope.Range.$eqq$(other)) !== false && __a !== nil) {

        } else {
        return false
      };
      return (__a = (__a = this.$exclude_end$p().$eq$(other.$exclude_end$p()), __a !== false && __a !== nil ? (this.begin).$eql$p(other.$begin()) : __a), __a !== false && __a !== nil ? (this.end).$eql$p(other.$end()) : __a);
    };
    def.$exclude_end$p = function() {
      
      return this.exclude;
    };
    def.$include$p = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };
    def.$max = def.$end;
    def.$min = def.$begin;
    def.$member$p = def.$include$p;
    def.$step = TMP_71 = function(n) {
      var __context, __yield; 
      __yield = TMP_71._p || nil;
      __context = __yield._s;
      TMP_71._p = null;
      if (n == null) {
        n = 1;
      }
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("step", n)
      };
      return this.$raise(__scope.NotImplementedError);
    };
    def.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
    def.$inspect = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
    ;__donate(this, ["$initialize", "$eq$", "$eqq$", "$begin", "$cover$p", "$each", "$end", "$eql$p", "$exclude_end$p", "$include$p", "$max", "$min", "$member$p", "$step", "$to_s", "$inspect"]);
  });
  __klass(this, Error, "Exception", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
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
    def.$to_s = def.$message;
    ;__donate(this, ["$initialize", "$backtrace", "$inspect", "$message", "$to_s"]);
  });
  __klass(this, __scope.Exception, "StandardError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.Exception, "RuntimeError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "LocalJumpError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "TypeError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "NameError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.NameError, "NoMethodError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "ArgumentError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.Exception, "ScriptError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.ScriptError, "LoadError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "IndexError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.IndexError, "KeyError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.StandardError, "RangeError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, __scope.Exception, "NotImplementedError", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    nil
    ;__donate(this, []);
  });
  __klass(this, RegExp, "Regexp", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$escape = function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    };
    this.$singleton_class()._proto.$new = function(string, options) {
      
      return new RegExp(string, options);
    };
    def.$eq$ = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };
    def.$eqq$ = function(obj) {
      
      return this.test(obj);
    };
    def.$match$ = function(string) {
      
      
      var result = this.exec(string);

      if (result) {
        var match       = new __scope.MatchData._alloc();
            match.$data = result;

        __gvars["$~"] = match;
      }
      else {
        __gvars["$~"] = nil;
      }

      return result ? result.index : nil;
    
    };
    def.$eql$p = def.$eq$;
    def.$inspect = function() {
      
      return this.toString();
    };
    def.$match = function(pattern) {
      
      
      var result  = this.exec(pattern);

      if (result) {
        var match   = new __scope.MatchData._alloc();
        match.$data = result;

        return __gvars["$~"] = match;
      }
      else {
        return __gvars["$~"] = nil;
      }
    
    };
    def.$to_s = function() {
      
      return this.source;
    };
    ;__donate(this, ["$eq$", "$eqq$", "$match$", "$eql$p", "$inspect", "$match", "$to_s"]);
  });
  __klass(this, null, "MatchData", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
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
    def.$size = def.$length;
    def.$to_a = function() {
      
      return __slice.call(this.$data);
    };
    def.$to_s = function() {
      
      return this.$data[0];
    };
    ;__donate(this, ["$aref$", "$length", "$inspect", "$size", "$to_a", "$to_s"]);
  });
  __klass(this, null, "Time", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$include(__scope.Comparable);
    this.$singleton_class()._proto.$at = function(seconds, frac) {
      var result = nil; if (frac == null) {
        frac = 0;
      }
      result = this.$allocate();
      result.time = new Date(seconds * 1000 + frac);
      return result;
    };
    this.$singleton_class()._proto.$now = function() {
      var result = nil; 
      result = this.$allocate();
      result.time = new Date();
      return result;
    };
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
      return (__a = other.$is_a$p(__scope.Time), __a !== false && __a !== nil ? this.$cmp$(other).$zero$p() : __a);
    };
    def.$friday$p = function() {
      
      return this.time.getDay() === 5;
    };
    def.$hour = function() {
      
      return this.time.getHours();
    };
    def.$mday = def.$day;
    def.$min = function() {
      
      return this.time.getMinutes();
    };
    def.$mon = function() {
      
      return this.time.getMonth() + 1;
    };
    def.$monday$p = function() {
      
      return this.time.getDay() === 1;
    };
    def.$month = def.$mon;
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
    def.$year = function() {
      
      return this.time.getFullYear();
    };
    ;__donate(this, ["$initialize", "$plus$", "$minus$", "$cmp$", "$day", "$eql$p", "$friday$p", "$hour", "$mday", "$min", "$mon", "$monday$p", "$month", "$saturday$p", "$sec", "$sunday$p", "$thursday$p", "$to_f", "$to_i", "$tuesday$p", "$wday", "$wednesday$p", "$year"]);
  });
  __klass(this, null, "Struct", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$new = TMP_72 = function(name, args) {
      var __a, __b; args = __slice.call(arguments, 1);
      if ((__a = this.$eq$(__scope.Struct)) !== false && __a !== nil) {

        } else {
        return __class._super._proto.$new.apply(this, __slice.call(arguments))
      };
      if ((__a = name.$is_a$p(__scope.String)) !== false && __a !== nil) {
        return __scope.Struct.$const_set(name, this.$new.apply(this, [].concat(args)))
        } else {
        args.$unshift(name);
        return (__b = __scope.Class, __b.$new._p = (__a = function() {

          var __a, __b; 
          
          return (__b = args, __b.$each._p = (__a = function(name) {

            
            if (name == null) name = nil;

            return this.$define_struct_attribute(name)
          }, __a._s = this, __a), __b.$each())
        }, __a._s = this, __a), __b.$new(this));
      };
    };
    this.$singleton_class()._proto.$define_struct_attribute = function(name) {
      var __a, __b; 
      this.$members().$lshft$(name);
      (__b = this, __b.$define_method._p = (__a = function() {

        
        
        return this.$instance_variable_get("@" + name)
      }, __a._s = this, __a), __b.$define_method(name));
      return (__b = this, __b.$define_method._p = (__a = function(value) {

        
        if (value == null) value = nil;

        return this.$instance_variable_set("@" + name, value)
      }, __a._s = this, __a), __b.$define_method("" + name + "="));
    };
    this.$singleton_class()._proto.$members = function() {
      var __a; 
      if (this.members == null) this.members = nil;

      return (__a = this.members, __a !== false && __a !== nil ? __a : this.members = [])
    };
    this.$include(__scope.Enumerable);
    def.$initialize = function(args) {
      var __a, __b; args = __slice.call(arguments, 0);
      return (__b = this.$members(), __b.$each_with_index._p = (__a = function(name, index) {

        
        if (name == null) name = nil;
if (index == null) index = nil;

        return this.$instance_variable_set("@" + name, args.$aref$(index))
      }, __a._s = this, __a), __b.$each_with_index());
    };
    def.$members = function() {
      
      return this.$class().$members();
    };
    def.$aref$ = function(name) {
      var __a; 
      if ((__a = name.$is_a$p(__scope.Integer)) !== false && __a !== nil) {
        if (name.$ge$(this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + name + " too large for struct(size:" + this.$members().$size() + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__a = this.$members().$include$p(name.$to_sym())) !== false && __a !== nil) {

          } else {
          this.$raise(__scope.NameError, "no member '" + name + "' in struct")
        }
      };
      return this.$instance_variable_get("@" + name);
    };
    def.$aset$ = function(name, value) {
      var __a; 
      if ((__a = name.$is_a$p(__scope.Integer)) !== false && __a !== nil) {
        if (name.$ge$(this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + name + " too large for struct(size:" + this.$members().$size() + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__a = this.$members().$include$p(name.$to_sym())) !== false && __a !== nil) {

          } else {
          this.$raise(__scope.NameError, "no member '" + name + "' in struct")
        }
      };
      return this.$instance_variable_set("@" + name, value);
    };
    def.$each = TMP_73 = function() {
      var __a, __b, __context, __yield; 
      __yield = TMP_73._p || nil;
      __context = __yield._s;
      TMP_73._p = null;
      
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("each")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        
        if (name == null) name = nil;

        return __yield.call(__context, this.$aref$(name))
      }, __a._s = this, __a), __b.$each());
    };
    def.$each_pair = TMP_74 = function() {
      var __a, __b, __context, __yield; 
      __yield = TMP_74._p || nil;
      __context = __yield._s;
      TMP_74._p = null;
      
      if ((__yield !== nil)) {

        } else {
        return this.$enum_for("each_pair")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        
        if (name == null) name = nil;

        return __yield.call(__context, name, this.$aref$(name))
      }, __a._s = this, __a), __b.$each());
    };
    def.$eql$p = function(other) {
      var __a, __b; 
      return (__a = this.$hash().$eq$(other.$hash()), __a !== false && __a !== nil ? __a : (__b = other.$each_with_index(), __b.$all$p._p = (__a = function(object, index) {

        
        if (object == null) object = nil;
if (index == null) index = nil;

        return this.$aref$(this.$members().$aref$(index)).$eq$(object)
      }, __a._s = this, __a), __b.$all$p()));
    };
    def.$length = function() {
      
      return this.$members().$length();
    };
    def.$size = def.$length;
    def.$to_a = function() {
      var __a, __b; 
      return (__b = this.$members(), __b.$map._p = (__a = function(name) {

        
        if (name == null) name = nil;

        return this.$aref$(name)
      }, __a._s = this, __a), __b.$map());
    };
    def.$values = def.$to_a;
    ;__donate(this, ["$initialize", "$members", "$aref$", "$aset$", "$each", "$each_pair", "$eql$p", "$length", "$size", "$to_a", "$values"]);
  });
  __klass(this, null, "File", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    __scope.PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;
    this.$singleton_class()._proto.$expand_path = function(path, base) {
      
      
      if (!base) {
        base = '';
      }

      path = this.$join(base, path);

      var parts = path.split('/'), result = [], path;

      for (var i = 0, ii = parts.length; i < ii; i++) {
        part = parts[i];

        if (part === '..') {
          result.pop();
        }
        else if (part === '.' || part === '') {
          // ignore?
        }
        else {
          result.push(part);
        }
      }

      return result.join('/');
    
    };
    this.$singleton_class()._proto.$join = function(paths) {
      paths = __slice.call(arguments, 0);
      
      var result = [];

      for (var i = 0, length = paths.length; i < length; i++) {
        var part = paths[i];

        if (part != '') {
          result.push(part);
        }
      }

      return result.join('/');
    
    };
    this.$singleton_class()._proto.$dirname = function(path) {
      
      
      var dirname = __scope.PATH_RE.exec(path)[1];

      if (!dirname) {
        return '.';
      }
      else if (dirname === '/') {
        return dirname;
      }
      else {
        return dirname.substring(0, dirname.length - 1);
      }
    
    };
    this.$singleton_class()._proto.$extname = function(path) {
      
      
      var extname = __scope.PATH_RE.exec(path)[3];

      if (!extname || extname === '.') {
        return '';
      }
      else {
        return extname;
      }
    
    };
    this.$singleton_class()._proto.$basename = function(path, suffix) {
      
      return ""
    };
    this.$singleton_class()._proto.$exist$p = function(path) {
      
      return !!factories[this.$expand_path(path)];
    };
    ;__donate(this, []);
  });
  return __klass(this, null, "Dir", function() {
    var __class = this, __scope = this._scope, def = this._proto; 
    this.$singleton_class()._proto.$getwd = function() {
      
      return ""
    };
    this.$singleton_class()._proto.$pwd = function() {
      
      return ""
    };
    this.$singleton_class()._proto.$aref$ = function(globs) {
      globs = __slice.call(arguments, 0);
      
      var result = [], files = factories;

      for (var i = 0, ii = globs.length; i < ii; i++) {
        var glob = globs[i];

        var re = fs_glob_to_regexp(__scope.File.$expand_path(glob));

        for (var file in files) {
          if (re.exec(file)) {
            result.push(file);
          }
        }
      }

      return result;
    
    };
    
    function fs_glob_to_regexp(glob) {
      var parts  = glob.split(''),
          length = parts.length,
          result = '';

      var opt_group_stack = 0;

      for (var i = 0; i < length; i++) {
        var cur = parts[i];

        switch (cur) {
          case '*':
            if (parts[i + 1] === '*' && parts[i + 2] === '/') {
              result += '.*';
              i += 2;
            }
            else {
              result += '[^/]*';
            }
            break;

          case '.':
            result += '\\';
            result += cur;
            break;

          case ',':
            if (opt_group_stack) {
              result += '|';
            }
            else {
              result += ',';
            }
            break;

          case '{':
            result += '(';
            opt_group_stack++;
            break;

          case '}':
            if (opt_group_stack) {
              result += ')';
              opt_group_stack--;
            }
            else {
              result += '}'
            }
            break;

          default:
            result += cur;
        }
      }

      return new RegExp('^' + result + '$');
    }
  
    ;__donate(this, []);
  });;var TMP_1, TMP_2, TMP_3, TMP_4, TMP_5, TMP_6, TMP_7, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12, TMP_13, TMP_14, TMP_15, TMP_16, TMP_17, TMP_18, TMP_19, TMP_20, TMP_21, TMP_22, TMP_23, TMP_24, TMP_25, TMP_26, TMP_27, TMP_28, TMP_29, TMP_30, TMP_31, TMP_32, TMP_33, TMP_34, TMP_35, TMP_36, TMP_37, TMP_38, TMP_39, TMP_40, TMP_41, TMP_42, TMP_43, TMP_44, TMP_45, TMP_46, TMP_47, TMP_48, TMP_49, TMP_50, TMP_51, TMP_52, TMP_53, TMP_54, TMP_55, TMP_56, TMP_57, TMP_58, TMP_59, TMP_60, TMP_61, TMP_62, TMP_63, TMP_64, TMP_65, TMP_66, TMP_67, TMP_68, TMP_69, TMP_70, TMP_71, TMP_72, TMP_73, TMP_74;
}).call(Opal.top);
}).call(this);