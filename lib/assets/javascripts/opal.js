// Opal v0.3.20
// http://opalrb.org
// Copyright 2012, Adam Beynon
// Released under the MIT License
(function(undefined) {
// The Opal object that is exposed globally
var Opal = this.Opal = {};

// Very root class
function BasicObject(){}

// Core Object class
function Object(){}

// Class' class
function Class(){}

// Modules are just classes that cannot be instantiated
var Module = Class;

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

// Table holds all class variables
Opal.cvars = {};

// Globals table
Opal.gvars = {};

// Runtime method used to either define a new class, or re-open an old
// class. The base may be an object (rather than a class), which is
// always the case when defining classes in the top level as the top
// level is just the 'main' Object instance.
//
// The given ruby code:
//
//     class Foo
//       42
//     end
//
//     class Bar < Foo
//       3.142
//     end
//
// Would be compiled to something like:
//
//     var __klass = Opal.klass;
//
//     __klass(this, null, 'Foo', function() {
//       return 42;
//     });
//
//     __klass(this, __scope.Foo, 'Bar', function() {
//       return 3.142;
//     });
//
// @param [RubyObject] base the scope in which to define the class
// @param [RubyClass] superklass the superklass, may be null
// @param [String] id the name for the class
// @param [Function] body the class body
// @return returns last value from running body
Opal.klass = function(base, superklass, id, constructor) {
  var klass;
  if (base._isObject) {
    base = base._real;
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
    base = base._real;
  }

  if (__hasOwn.call(base._scope, id)) {
    klass = base._scope[id];
  }
  else {
    klass = boot_module(constructor, id);
    klass._name = (base === Object ? id : base._name + '::' + id);

    klass._isModule = true;
    klass.$included_in = [];

    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base._scope.alloc();
    klass._scope      = const_scope;
    const_scope.alloc = const_alloc;

    base[id] = base._scope[id]    = klass;
  }

  return klass;
}

// Convert a ruby method name into a javascript identifier
var mid_to_jsid = function(mid) {
  return method_names[mid] ||
    ('$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e'));
};

// Utility function to raise a "no block given" error
var no_block_given = function() {
  throw new Error('no block given');
};

// An array of all classes inside Opal. Used for donating methods from
// Module and Class.
var classes = Opal.classes = [];

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
  prototype._real       = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._name         = id;
  constructor._super        = superklass;
  constructor._methods      = [];
  constructor._smethods     = [];
  constructor._isObject     = false;
  constructor._subclasses   = [];

  constructor._donate = __donate;
  constructor._sdonate = __sdonate;

  Opal[id] = constructor;

  classes.push(constructor);

  return constructor;
};

// Create generic class with given superclass.
var boot_class = function(superklass, constructor) {
  var ctor = function() {};
      ctor.prototype = superklass.prototype;

  constructor.prototype = new ctor();
  var prototype = constructor.prototype;

  prototype._klass      = constructor;
  prototype._real       = constructor;
  prototype.constructor = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._super        = superklass;
  constructor._methods      = [];
  constructor._isObject     = false;
  constructor._klass        = Class;
  constructor._real         = Class;
  constructor._donate       = __donate
  constructor._sdonate      = __sdonate;
  constructor._subclasses   = [];

  constructor.$eqq$ = module_eqq;

  superklass._subclasses.push(constructor);

  var smethods;

  smethods = superklass._smethods.slice();

  constructor._smethods = smethods;
  for (var i = 0, length = smethods.length; i < length; i++) {
    var m = smethods[i];
    constructor[m] = superklass[m];
  }

  classes.push(constructor);

  return constructor;
};

var boot_module = function(constructor, id) {
  var ctor = function() {};
      ctor.prototype = Module.prototype;

  constructor.prototype = new ctor();
  var prototype = constructor.prototype;

  prototype.constructor = constructor;

  constructor._isModule = true;
  constructor._name     = id;
  constructor._methods  = [];
  constructor._smethods = [];
  constructor._klass    = Module;
  constructor._donate   = __donate;
  constructor._sdonate  = function(){};

  classes.push(constructor);

  var smethods = constructor._smethods = Module._methods.slice();
  for (var i = 0, length = smethods.length; i < length; i++) {
    var m = smethods[i];
    constructor[m] = Object[m];
  }

  return constructor;
};

var bridge_class = function(constructor) {
  constructor.prototype._klass = constructor;
  constructor.prototype._real = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._super        = Object;
  constructor._klass        = Class;
  constructor._methods      = [];
  constructor._smethods     = [];
  constructor._isObject     = false;
  constructor._subclasses   = [];

  constructor._donate = function(){};
  constructor._sdonate = __sdonate;

  constructor.$eqq$ = module_eqq;

  var smethods = constructor._smethods = Module._methods.slice();
  for (var i = 0, length = smethods.length; i < length; i++) {
    var m = smethods[i];
    constructor[m] = Object[m];
  }

  bridgedClasses.push(constructor);
  classes.push(constructor);

  var allocator = function(initializer) {
    var result, kls = this, methods = kls._methods, proto = kls.prototype;

    if (initializer == null) {
      result = new constructor
    }
    else {
      result = new constructor(initializer);
    }

    if (kls === constructor) {
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

  var table = Object.prototype, methods = Object._methods;

  for (var i = 0, length = methods.length; i < length; i++) {
    var m = methods[i];
    constructor.prototype[m] = table[m];
  }

  constructor.$allocate = allocator;

  constructor._smethods.push('$allocate');

  return constructor;
};

// An IClass is a fake class created when a module is included into a
// class or another module. It is a "copy" of the module that is then
// injected into the hierarchy so it appears internally that the iclass
// is the super of the class instead of the old super class. This is
// actually hidden from the ruby side of things, but allows internal
// features such as super() etc to work. All useful properties from the
// module are copied onto this iclass.
//
// @param [RubyClass] klass the klass which is including the module
// @param [RubyModule] module the module which is being included
// @return [RubyIClass] returns newly created iclass
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

boot_defclass('BasicObject', BasicObject);
boot_defclass('Object', Object, BasicObject);
boot_defclass('Class', Class, Object);

Class.prototype = Function.prototype;

BasicObject._klass = Object._klass = Class._klass = Class;

Module._donate = function(defined) {
  // ...
};

// Implementation of Module#===
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

// Donator for all 'normal' classes and modules
function __donate(defined, indirect) {
  var methods = this._methods, included_in = this.$included_in;

  if (!indirect) {
    this._methods = methods.concat(defined);
  }

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

// Donator for singleton (class) methods
function __sdonate(defined) {
  var smethods = this._smethods, subclasses = this._subclasses;

  this._smethods = smethods.concat(defined);

  for (var i = 0, length = subclasses.length; i < length; i++) {
    var s = subclasses[i];

    for (var j = 0, jj = defined.length; j < jj; j++) {
    }
  }
}

var bridgedClasses = Object.$included_in = [];
BasicObject.$included_in = bridgedClasses;

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
Opal.nil = new NilClass;
Opal.nil.call = Opal.nil.apply = no_block_given;

Opal.breaker  = new Error('unexpected break');
var method_names = {'==': '$eq$', '===': '$eqq$', '[]': '$aref$', '[]=': '$aset$', '~': '$tild$', '<=>': '$cmp$', '=~': '$match$', '+': '$plus$', '-': '$minus$', '/': '$div$', '*': '$mul$', '<': '$lt$', '<=': '$le$', '>': '$gt$', '>=': '$ge$', '<<': '$lshft$', '>>': '$rshft$', '|': '$or$', '&': '$and$', '^': '$xor$', '+@': '$uplus$', '-@': '$uminus$', '%': '$mod$', '**': '$pow$'};
Opal.version = "0.3.20";
(function() {
var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __gvars = __opal.gvars, __klass = __opal.klass, __module = __opal.module, __hash = __opal.hash;

  __gvars["~"] = nil;
  __gvars["/"] = "\n";
  __scope.RUBY_ENGINE = "opal";
  __scope.RUBY_PLATFORM = "opal";
  __scope.RUBY_VERSION = "1.9.2";
  __scope.OPAL_VERSION = __opal.version;
  (function(__base, __super){
    // line 11, (corelib), class Module
    function Module() {};
    Module = __klass(__base, __super, "Module", Module);
    var Module_prototype = Module.prototype, __scope = Module._scope, TMP_1, TMP_2;

    // line 12, (corelib), Module#alias_method
    Module_prototype.$alias_method = function(newname, oldname) {
      
      this.prototype[mid_to_jsid(newname)] = this.prototype[mid_to_jsid(oldname)];
      return this;
    };

    // line 17, (corelib), Module#ancestors
    Module_prototype.$ancestors = function() {
      
      
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

    // line 39, (corelib), Module#append_features
    Module_prototype.$append_features = function(klass) {
      
      
      var module = this;

      if (!klass.$included_modules) {
        klass.$included_modules = [];
      }

      for (var idx = 0, length = klass.$included_modules.length; idx < length; idx++) {
        if (klass.$included_modules[idx] === module) {
          return;
        }
      }

      klass.$included_modules.push(module);

      if (!module.$included_in) {
        module.$included_in = [];
      }

      module.$included_in.push(klass);

      var donator   = module.prototype,
          prototype = klass.prototype,
          methods   = module._methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];
        prototype[method] = donator[method];
      }

      if (klass.$included_in) {
        klass._donate(methods.slice(), true);
      }
    
      return this;
    };

    
    function define_attr(klass, name, getter, setter) {
      if (getter) {
        var get_jsid = mid_to_jsid(name);

        klass.prototype[get_jsid] = function() {
          var res = this[name];
          return res == null ? nil : res;
        };

        klass._donate([get_jsid]);
      }

      if (setter) {
        var set_jsid = mid_to_jsid(name + '=');

        klass.prototype[set_jsid] = function(val) {
          return this[name] = val;
        };

        klass._donate([set_jsid]);
      }
    }
  

    // line 104, (corelib), Module#attr_accessor
    Module_prototype.$attr_accessor = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return nil;
    
    };

    // line 114, (corelib), Module#attr_reader
    Module_prototype.$attr_reader = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return nil;
    
    };

    // line 124, (corelib), Module#attr_writer
    Module_prototype.$attr_writer = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return nil;
    
    };

    // line 134, (corelib), Module#attr
    Module_prototype.$attr = function(name, setter) {
      if (setter == null) {
        setter = false
      }
      define_attr(this, name, true, setter);
      return this;
    };

    // line 140, (corelib), Module#define_method
    Module_prototype.$define_method = TMP_1 = function(name) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      var jsid = mid_to_jsid(name);
      block._jsid = jsid;
      block._sup = this.prototype[jsid];

      this.prototype[jsid] = block;
      this._donate([jsid]);

      return nil;
    
    };

    // line 157, (corelib), Module#include
    Module_prototype.$include = function(mods) {
      mods = __slice.call(arguments, 0);
      
      var i = mods.length - 1, mod;
      while (i >= 0) {
        mod = mods[i];
        i--;

        if (mod === this) {
          continue;
        }
        define_iclass(this, mod);
        mod.$append_features(this);
        mod.$included(this);
      }

      return this;
    
    };

    // line 177, (corelib), Module#instance_methods
    Module_prototype.$instance_methods = function() {
      
      return [];
    };

    // line 181, (corelib), Module#included
    Module_prototype.$included = function(mod) {
      
      return nil;
    };

    // line 184, (corelib), Module#module_eval
    Module_prototype.$module_eval = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };

    Module_prototype.$class_eval = Module_prototype.$module_eval;

    // line 196, (corelib), Module#name
    Module_prototype.$name = function() {
      
      return this._name;
    };

    Module_prototype.$public_instance_methods = Module_prototype.$instance_methods;

    // line 202, (corelib), Module#singleton_class
    Module_prototype.$singleton_class = function() {
      
      
      if (this._klass._isSingleton) {
        return this._klass;
      }
      else {
        var meta = new __opal.Class;
        this._klass = meta;
        meta._isSingleton = true;
        meta.prototype = this;

        return meta;
      }
    
    };

    Module_prototype.$to_s = Module_prototype.$name;
    ;Module._donate(["$alias_method", "$ancestors", "$append_features", "$attr_accessor", "$attr_reader", "$attr_writer", "$attr", "$define_method", "$include", "$instance_methods", "$included", "$module_eval", "$class_eval", "$name", "$public_instance_methods", "$singleton_class", "$to_s"]);
  })(self, null);
  (function(__base, __super){
    // line 220, (corelib), class Class
    function Class() {};
    Class = __klass(__base, __super, "Class", Class);
    var Class_prototype = Class.prototype, __scope = Class._scope, TMP_3, TMP_4;

    // line 221, (corelib), Class.new
    Class.$new = TMP_3 = function(sup) {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      if (sup == null) {
        sup = __scope.Object
      }
      
      function AnonClass(){};
      var klass   = boot_class(sup, AnonClass)
      klass._name = nil;

      sup.$inherited(klass);

      if (block !== nil) {
        block.call(klass);
      }

      return klass;
    
    };

    // line 237, (corelib), Class#allocate
    Class_prototype.$allocate = function() {
      
      
      var obj = new this;
      obj._id = unique_id++;
      return obj;
    
    };

    // line 245, (corelib), Class#new
    Class_prototype.$new = TMP_4 = function(args) {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      args = __slice.call(arguments, 0);
      
      var obj = this.$allocate();
      obj._p  = block;
      obj.$initialize.apply(obj, args);
      return obj;
    
    };

    // line 254, (corelib), Class#inherited
    Class_prototype.$inherited = function(cls) {
      
      return nil;
    };

    // line 257, (corelib), Class#superclass
    Class_prototype.$superclass = function() {
      
      
      var sup = this._super;

      if (!sup) {
        return nil;
      }

      while (sup && (sup._isIClass)) {
        sup = sup._super;
      }

      if (!sup) {
        return nil;
      }

      return sup;
    
    };
    ;Class._donate(["$allocate", "$new", "$inherited", "$superclass"]);    ;Class._sdonate(["$new"]);
  })(self, null);
  (function(__base, __super){
    // line 277, (corelib), class BasicObject
    function BasicObject() {};
    BasicObject = __klass(__base, __super, "BasicObject", BasicObject);
    var BasicObject_prototype = BasicObject.prototype, __scope = BasicObject._scope, TMP_5, TMP_6, TMP_7;

    // line 278, (corelib), BasicObject#initialize
    BasicObject_prototype.$initialize = function() {
      
      return nil;
    };

    // line 281, (corelib), BasicObject#==
    BasicObject_prototype.$eq$ = function(other) {
      
      return this === other;
    };

    // line 285, (corelib), BasicObject#__send__
    BasicObject_prototype.$__send__ = TMP_5 = function(symbol, args) {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      args = __slice.call(arguments, 1);
      
      var meth = this[mid_to_jsid(symbol)];

      return meth.apply(this, args);
    
    };

    BasicObject_prototype.$send = BasicObject_prototype.$__send__;

    BasicObject_prototype.$eql$p = BasicObject_prototype.$eq$;

    BasicObject_prototype.$equal$p = BasicObject_prototype.$eq$;

    // line 298, (corelib), BasicObject#instance_eval
    BasicObject_prototype.$instance_eval = TMP_6 = function(string) {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this, this);
    
    };

    // line 308, (corelib), BasicObject#instance_exec
    BasicObject_prototype.$instance_exec = TMP_7 = function(args) {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      args = __slice.call(arguments, 0);
      
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    
    };

    // line 318, (corelib), BasicObject#method_missing
    BasicObject_prototype.$method_missing = function(symbol, args) {
      args = __slice.call(arguments, 1);
      return this.$raise(__scope.NoMethodError, "undefined method `" + (symbol) + "` for " + (this.$inspect()));
    };
    ;BasicObject._donate(["$initialize", "$eq$", "$__send__", "$send", "$eql$p", "$equal$p", "$instance_eval", "$instance_exec", "$method_missing"]);
  })(self, null);
  (function(__base){
    // line 322, (corelib), module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12;

    // line 323, (corelib), Kernel#=~
    Kernel_prototype.$match$ = function(obj) {
      
      return false;
    };

    // line 327, (corelib), Kernel#==
    Kernel_prototype.$eq$ = function(other) {
      
      return this === other;
    };

    // line 331, (corelib), Kernel#===
    Kernel_prototype.$eqq$ = function(other) {
      
      return this == other;
    };

    // line 335, (corelib), Kernel#Array
    Kernel_prototype.$Array = function(object) {
      var __a;
      if ((__a = object) === false || __a === nil) {
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

    // line 357, (corelib), Kernel#class
    Kernel_prototype.$class = function() {
      
      return this._real;
    };

    // line 361, (corelib), Kernel#define_singleton_method
    Kernel_prototype.$define_singleton_method = TMP_8 = function(name) {
      var __context, body;
      body = TMP_8._p || nil, __context = body._s, TMP_8._p = null;
      
      
      if (body === nil) {
        no_block_given();
      }

      var jsid = mid_to_jsid(name);
      body._jsid = jsid;
      body._sup  = this[jsid]

      // FIXME: need to donate()
      this.$singleton_class().prototype[jsid] = body;

      return this;
    
    };

    // line 378, (corelib), Kernel#equal?
    Kernel_prototype.$equal$p = function(other) {
      
      return this === other;
    };

    // line 382, (corelib), Kernel#extend
    Kernel_prototype.$extend = function(mods) {
      mods = __slice.call(arguments, 0);
      
      for (var i = 0, length = mods.length; i < length; i++) {
        this.$singleton_class().$include(mods[i]);
      }

      return this;
    
    };

    // line 392, (corelib), Kernel#hash
    Kernel_prototype.$hash = function() {
      
      return this._id;
    };

    // line 396, (corelib), Kernel#inspect
    Kernel_prototype.$inspect = function() {
      
      return this.$to_s();
    };

    // line 400, (corelib), Kernel#instance_of?
    Kernel_prototype.$instance_of$p = function(klass) {
      
      return this._klass === klass;
    };

    // line 404, (corelib), Kernel#instance_variable_defined?
    Kernel_prototype.$instance_variable_defined$p = function(name) {
      
      return __hasOwn.call(this, name.substr(1));
    };

    // line 408, (corelib), Kernel#instance_variable_get
    Kernel_prototype.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == null ? nil : ivar;
    
    };

    // line 416, (corelib), Kernel#instance_variable_set
    Kernel_prototype.$instance_variable_set = function(name, value) {
      
      return this[name.substr(1)] = value;
    };

    // line 420, (corelib), Kernel#instance_variables
    Kernel_prototype.$instance_variables = function() {
      
      
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    
    };

    // line 432, (corelib), Kernel#is_a?
    Kernel_prototype.$is_a$p = function(klass) {
      
      
      var search = this._klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search._super;
      }

      return false;
    
    };

    Kernel_prototype.$kind_of$p = Kernel_prototype.$is_a$p;

    // line 450, (corelib), Kernel#lambda
    Kernel_prototype.$lambda = TMP_9 = function() {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      return block;
    };

    // line 454, (corelib), Kernel#loop
    Kernel_prototype.$loop = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      if (block === nil) {
        return this.$enum_for("loop")
      };
      
      while (true) {
        if (block.call(__context) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 468, (corelib), Kernel#nil?
    Kernel_prototype.$nil$p = function() {
      
      return false;
    };

    // line 472, (corelib), Kernel#object_id
    Kernel_prototype.$object_id = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 476, (corelib), Kernel#proc
    Kernel_prototype.$proc = TMP_11 = function() {
      var __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block;
    
    };

    // line 486, (corelib), Kernel#puts
    Kernel_prototype.$puts = function(strs) {
      strs = __slice.call(arguments, 0);
      
      for (var i = 0; i < strs.length; i++) {
        console.log((strs[i]).$to_s());
      }
    
      return nil;
    };

    Kernel_prototype.$print = Kernel_prototype.$puts;

    // line 497, (corelib), Kernel#raise
    Kernel_prototype.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = __scope.RuntimeError.$new(exception);
      }
      else if (!exception.$is_a$p(__scope.Exception)) {
        exception = exception.$new(string);
      }

      throw exception;
    
    };

    // line 510, (corelib), Kernel#rand
    Kernel_prototype.$rand = function(max) {
      
      return max == null ? Math.random() : Math.floor(Math.random() * max);
    };

    // line 514, (corelib), Kernel#respond_to?
    Kernel_prototype.$respond_to$p = function(name) {
      
      return !!this[mid_to_jsid(name)];
    };

    // line 518, (corelib), Kernel#singleton_class
    Kernel_prototype.$singleton_class = function() {
      
      
      if (!this._isObject) {
        return this._real;
      }

      if (this._klass._isSingleton) {
        return this._klass;
      }
      else {
        var orig_class = this._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function _Singleton() {};
        var meta = boot_class(orig_class, _Singleton);
        meta._name = class_id;

        meta._isSingleton = true;
        meta.prototype = this;
        this._klass = meta;
        meta._klass = orig_class._real;

        return meta;
      }
    
    };

    // line 545, (corelib), Kernel#tap
    Kernel_prototype.$tap = TMP_12 = function() {
      var __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      if (block === nil) no_block_given();
      if (block.call(__context, this) === __breaker) return __breaker.$v;
      return this;
    };

    // line 552, (corelib), Kernel#to_json
    Kernel_prototype.$to_json = function() {
      
      return this.$to_s().$to_json();
    };

    // line 556, (corelib), Kernel#to_proc
    Kernel_prototype.$to_proc = function() {
      
      return this;
    };

    // line 560, (corelib), Kernel#to_s
    Kernel_prototype.$to_s = function() {
      
      return "#<" + this._klass._real._name + ":0x" + (this._id * 400487).toString(16) + ">";
    };

    // line 564, (corelib), Kernel#enum_for
    Kernel_prototype.$enum_for = function(method, args) {
      var __a;if (method == null) {
        method = "each"
      }args = __slice.call(arguments, 1);
      return (__a = __scope.Enumerator).$new.apply(__a, [this, method].concat(args));
    };

    Kernel_prototype.$to_enum = Kernel_prototype.$enum_for;
        ;Kernel._donate(["$match$", "$eq$", "$eqq$", "$Array", "$class", "$define_singleton_method", "$equal$p", "$extend", "$hash", "$inspect", "$instance_of$p", "$instance_variable_defined$p", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a$p", "$kind_of$p", "$lambda", "$loop", "$nil$p", "$object_id", "$proc", "$puts", "$print", "$raise", "$rand", "$respond_to$p", "$singleton_class", "$tap", "$to_json", "$to_proc", "$to_s", "$enum_for", "$to_enum"]);
  })(self);
  (function(__base, __super){
    // line 570, (corelib), class Object
    function Object() {};
    Object = __klass(__base, __super, "Object", Object);
    var Object_prototype = Object.prototype, __scope = Object._scope;

    Object.$include(__scope.Kernel);

    // line 574, (corelib), Object#methods
    Object_prototype.$methods = function() {
      
      return [];
    };

    Object_prototype.$private_methods = Object_prototype.$methods;

    Object_prototype.$protected_methods = Object_prototype.$methods;

    Object_prototype.$public_methods = Object_prototype.$methods;

    // line 583, (corelib), Object#singleton_methods
    Object_prototype.$singleton_methods = function() {
      
      return [];
    };
    ;Object._donate(["$methods", "$private_methods", "$protected_methods", "$public_methods", "$singleton_methods"]);
  })(self, null);
  self.$singleton_class().prototype.$to_s = function() {
    
    return "main"
  };
  self.$singleton_class().prototype.$include = function(mod) {
    
    return __scope.Object.$include(mod)
  };
  (function(__base, __super){
    // line 594, (corelib), class Boolean
    function Boolean() {};
    Boolean = __klass(__base, __super, "Boolean", Boolean);
    var Boolean_prototype = Boolean.prototype, __scope = Boolean._scope;

    
    Boolean_prototype._isBoolean = true;
  

    // line 599, (corelib), Boolean#&
    Boolean_prototype.$and$ = function(other) {
      
      return (this == true) ? (other !== false && other !== nil) : false;
    };

    // line 603, (corelib), Boolean#|
    Boolean_prototype.$or$ = function(other) {
      
      return (this == true) ? true : (other !== false && other !== nil);
    };

    // line 607, (corelib), Boolean#^
    Boolean_prototype.$xor$ = function(other) {
      
      return (this == true) ? (other === false || other === nil) : (other !== false && other !== nil);
    };

    // line 611, (corelib), Boolean#==
    Boolean_prototype.$eq$ = function(other) {
      
      return (this == true) === other.valueOf();
    };

    Boolean_prototype.$singleton_class = Boolean_prototype.$class;

    // line 617, (corelib), Boolean#to_json
    Boolean_prototype.$to_json = function() {
      
      return this.valueOf() ? 'true' : 'false';
    };

    // line 621, (corelib), Boolean#to_s
    Boolean_prototype.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };
    ;Boolean._donate(["$and$", "$or$", "$xor$", "$eq$", "$singleton_class", "$to_json", "$to_s"]);
  })(self, Boolean);
  __scope.TRUE = true;
  __scope.FALSE = false;
  (function(__base, __super){
    // line 628, (corelib), class NilClass
    function NilClass() {};
    NilClass = __klass(__base, __super, "NilClass", NilClass);
    var NilClass_prototype = NilClass.prototype, __scope = NilClass._scope;

    // line 629, (corelib), NilClass#&
    NilClass_prototype.$and$ = function(other) {
      
      return false;
    };

    // line 633, (corelib), NilClass#|
    NilClass_prototype.$or$ = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 637, (corelib), NilClass#^
    NilClass_prototype.$xor$ = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 641, (corelib), NilClass#==
    NilClass_prototype.$eq$ = function(other) {
      
      return other === nil;
    };

    // line 645, (corelib), NilClass#inspect
    NilClass_prototype.$inspect = function() {
      
      return "nil";
    };

    // line 649, (corelib), NilClass#nil?
    NilClass_prototype.$nil$p = function() {
      
      return true;
    };

    // line 653, (corelib), NilClass#singleton_class
    NilClass_prototype.$singleton_class = function() {
      
      return __scope.NilClass;
    };

    // line 657, (corelib), NilClass#to_a
    NilClass_prototype.$to_a = function() {
      
      return [];
    };

    // line 661, (corelib), NilClass#to_i
    NilClass_prototype.$to_i = function() {
      
      return 0;
    };

    NilClass_prototype.$to_f = NilClass_prototype.$to_i;

    // line 667, (corelib), NilClass#to_json
    NilClass_prototype.$to_json = function() {
      
      return "null";
    };

    // line 671, (corelib), NilClass#to_s
    NilClass_prototype.$to_s = function() {
      
      return "";
    };
    ;NilClass._donate(["$and$", "$or$", "$xor$", "$eq$", "$inspect", "$nil$p", "$singleton_class", "$to_a", "$to_i", "$to_f", "$to_json", "$to_s"]);
  })(self, null);
  __scope.NIL = nil;
  (function(__base){
    // line 677, (corelib), module Enumerable
    function Enumerable() {};
    Enumerable = __module(__base, "Enumerable", Enumerable);
    var Enumerable_prototype = Enumerable.prototype, __scope = Enumerable._scope, TMP_13, TMP_14, TMP_15, TMP_16, TMP_17, TMP_18, TMP_19, TMP_20, TMP_21, TMP_22, TMP_23;

    // line 678, (corelib), Enumerable#all?
    Enumerable_prototype.$all$p = TMP_13 = function() {
      var __context, block;
      block = TMP_13._p || nil, __context = block._s, TMP_13._p = null;
      
      
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

    // line 716, (corelib), Enumerable#any?
    Enumerable_prototype.$any$p = TMP_14 = function() {
      var __context, block;
      block = TMP_14._p || nil, __context = block._s, TMP_14._p = null;
      
      
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

    // line 754, (corelib), Enumerable#collect
    Enumerable_prototype.$collect = TMP_15 = function() {
      var __context, block;
      block = TMP_15._p || nil, __context = block._s, TMP_15._p = null;
      
      if (block === nil) {
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

    // line 777, (corelib), Enumerable#count
    Enumerable_prototype.$count = TMP_16 = function(object) {
      var __context, block;
      block = TMP_16._p || nil, __context = block._s, TMP_16._p = null;
      
      
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

    // line 809, (corelib), Enumerable#detect
    Enumerable_prototype.$detect = TMP_17 = function(ifnone) {
      var __context, block;
      block = TMP_17._p || nil, __context = block._s, TMP_17._p = null;
      
      if (block === nil) {
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

      return ifnone == null ? nil : ifnone;
    
    };

    // line 844, (corelib), Enumerable#drop
    Enumerable_prototype.$drop = function(number) {
      
      
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

    // line 863, (corelib), Enumerable#drop_while
    Enumerable_prototype.$drop_while = TMP_18 = function() {
      var __context, block;
      block = TMP_18._p || nil, __context = block._s, TMP_18._p = null;
      
      if (block === nil) {
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

    // line 890, (corelib), Enumerable#each_with_index
    Enumerable_prototype.$each_with_index = TMP_19 = function() {
      var __context, block;
      block = TMP_19._p || nil, __context = block._s, TMP_19._p = null;
      
      if (block === nil) {
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

    // line 912, (corelib), Enumerable#each_with_object
    Enumerable_prototype.$each_with_object = TMP_20 = function(object) {
      var __context, block;
      block = TMP_20._p || nil, __context = block._s, TMP_20._p = null;
      
      if (block === nil) {
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

    // line 930, (corelib), Enumerable#entries
    Enumerable_prototype.$entries = function() {
      
      
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    
    };

    Enumerable_prototype.$find = Enumerable_prototype.$detect;

    // line 946, (corelib), Enumerable#find_all
    Enumerable_prototype.$find_all = TMP_21 = function() {
      var __context, block;
      block = TMP_21._p || nil, __context = block._s, TMP_21._p = null;
      
      if (block === nil) {
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

    // line 974, (corelib), Enumerable#find_index
    Enumerable_prototype.$find_index = TMP_22 = function(object) {
      var __context, block;
      block = TMP_22._p || nil, __context = block._s, TMP_22._p = null;
      
      
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

    // line 1015, (corelib), Enumerable#first
    Enumerable_prototype.$first = function(number) {
      
      
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

    // line 1046, (corelib), Enumerable#grep
    Enumerable_prototype.$grep = TMP_23 = function(pattern) {
      var __context, block;
      block = TMP_23._p || nil, __context = block._s, TMP_23._p = null;
      
      
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

    Enumerable_prototype.$take = Enumerable_prototype.$first;

    Enumerable_prototype.$to_a = Enumerable_prototype.$entries;
        ;Enumerable._donate(["$all$p", "$any$p", "$collect", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$each_with_object", "$entries", "$find", "$find_all", "$find_index", "$first", "$grep", "$take", "$to_a"]);
  })(self);
  (function(__base, __super){
    // line 1080, (corelib), class Enumerator
    function Enumerator() {};
    Enumerator = __klass(__base, __super, "Enumerator", Enumerator);
    var Enumerator_prototype = Enumerator.prototype, __scope = Enumerator._scope, TMP_25, TMP_26, TMP_27, TMP_28, TMP_29;
    Enumerator_prototype.cache = Enumerator_prototype.current = Enumerator_prototype.object = Enumerator_prototype.method = Enumerator_prototype.args = nil;

    Enumerator.$include(__scope.Enumerable);

    (function(__base, __super){
      // line 1083, (corelib), class Yielder
      function Yielder() {};
      Yielder = __klass(__base, __super, "Yielder", Yielder);
      var Yielder_prototype = Yielder.prototype, __scope = Yielder._scope;
      Yielder_prototype.block = Yielder_prototype.call = nil;

      // line 1084, (corelib), Yielder#initialize
      Yielder_prototype.$initialize = function(block) {
        
        return this.block = block;
      };

      // line 1088, (corelib), Yielder#call
      Yielder_prototype.$call = function(block) {
        
        this.call = block;
        return this.block.$call();
      };

      // line 1094, (corelib), Yielder#yield
      Yielder_prototype.$yield = function(value) {
        
        return this.call.$call(value);
      };

      Yielder_prototype.$lshft$ = Yielder_prototype.$yield;
      ;Yielder._donate(["$initialize", "$call", "$yield", "$lshft$"]);
    })(Enumerator, null);

    (function(__base, __super){
      // line 1101, (corelib), class Generator
      function Generator() {};
      Generator = __klass(__base, __super, "Generator", Generator);
      var Generator_prototype = Generator.prototype, __scope = Generator._scope, TMP_24;
      Generator_prototype.enumerator = Generator_prototype.yielder = nil;

      // line 1102, (corelib), Generator#enumerator
      Generator_prototype.$enumerator = function() {
        
        return this.enumerator
      };

      // line 1104, (corelib), Generator#initialize
      Generator_prototype.$initialize = function(block) {
        
        return this.yielder = __scope.Yielder.$new(block);
      };

      // line 1108, (corelib), Generator#each
      Generator_prototype.$each = TMP_24 = function() {
        var __context, block;
        block = TMP_24._p || nil, __context = block._s, TMP_24._p = null;
        
        return this.yielder.$call(block);
      };
      ;Generator._donate(["$enumerator", "$initialize", "$each"]);
    })(Enumerator, null);

    // line 1113, (corelib), Enumerator#initialize
    Enumerator_prototype.$initialize = TMP_25 = function(object, method, args) {
      var __a, __context, block;
      block = TMP_25._p || nil, __context = block._s, TMP_25._p = null;
      if (object == null) {
        object = nil
      }if (method == null) {
        method = "each"
      }args = __slice.call(arguments, 2);
      if ((block !== nil)) {
        this.object = __scope.Generator.$new(block)
      };
      if ((__a = object) === false || __a === nil) {
        this.$raise(__scope.ArgumentError, "wrong number of argument (0 for 1+)")
      };
      this.object = object;
      this.method = method;
      return this.args = args;
    };

    // line 1125, (corelib), Enumerator#next
    Enumerator_prototype.$next = function() {
      var result = nil, __a;
      this.$_init_cache();
      (__a = result = this.cache.$aref$(this.current), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
      this.current = this.current.$plus$(1);
      return result;
    };

    // line 1134, (corelib), Enumerator#next_values
    Enumerator_prototype.$next_values = function() {
      var result = nil, __a;
      result = this.$next();
      if ((__a = result.$is_a$p(__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };

    // line 1140, (corelib), Enumerator#peek
    Enumerator_prototype.$peek = function() {
      var __a;
      this.$_init_cache();
      return (__a = this.cache.$aref$(this.current), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
    };

    // line 1146, (corelib), Enumerator#peel_values
    Enumerator_prototype.$peel_values = function() {
      var result = nil, __a;
      result = this.$peek();
      if ((__a = result.$is_a$p(__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };

    // line 1152, (corelib), Enumerator#rewind
    Enumerator_prototype.$rewind = function() {
      
      return this.$_clear_cache();
    };

    // line 1156, (corelib), Enumerator#each
    Enumerator_prototype.$each = TMP_26 = function() {
      var __a, __context, block;
      block = TMP_26._p || nil, __context = block._s, TMP_26._p = null;
      
      if (block === nil) {
        return this
      };
      return (__a = this.object, __a.$__send__._p = block.$to_proc(), __a.$__send__.apply(__a, [this.method].concat(this.args)));
    };

    // line 1162, (corelib), Enumerator#each_with_index
    Enumerator_prototype.$each_with_index = TMP_27 = function() {
      var __a, __context, block;
      block = TMP_27._p || nil, __context = block._s, TMP_27._p = null;
      
      return (__a = this, __a.$with_index._p = block.$to_proc(), __a.$with_index());
    };

    // line 1166, (corelib), Enumerator#with_index
    Enumerator_prototype.$with_index = TMP_28 = function(offset) {
      var current = nil, __a, __b, __context, __yield;
      __yield = TMP_28._p || nil, __context = __yield._s, TMP_28._p = null;
      if (offset == null) {
        offset = 0
      }
      if (__yield === nil) {
        return this.$enum_for("with_index", offset)
      };
      current = 0;
      return (__b = this, __b.$each._p = (__a = function(args) {

        var __a;
        args = __slice.call(arguments, 0);
        if ((__a = current.$ge$(offset)) === false || __a === nil) {
          return nil;
        };
        if (__yield.apply(__context, [].concat(args).concat([["current"]])) === __breaker) return __breaker.$v;
        return current = current.$plus$(1);
      }, __a._s = this, __a), __b.$each());
    };

    // line 1180, (corelib), Enumerator#with_object
    Enumerator_prototype.$with_object = TMP_29 = function(object) {
      var __a, __b, __context, __yield;
      __yield = TMP_29._p || nil, __context = __yield._s, TMP_29._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("with_object", object)
      };
      return (__b = this, __b.$each._p = (__a = function(args) {

        var __a;
        args = __slice.call(arguments, 0);
        return __a = __yield.apply(__context, [].concat(args).concat([["object"]])), __a === __breaker ? __breaker.$v : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 1188, (corelib), Enumerator#_init_cache
    Enumerator_prototype.$_init_cache = function() {
      var __a;
      (__a = this.current, __a !== false && __a !== nil ? __a : this.current = 0);
      return (__a = this.cache, __a !== false && __a !== nil ? __a : this.cache = this.$to_a());
    };

    // line 1193, (corelib), Enumerator#_clear_cache
    Enumerator_prototype.$_clear_cache = function() {
      
      this.cache = nil;
      return this.current = nil;
    };
    ;Enumerator._donate(["$initialize", "$next", "$next_values", "$peek", "$peel_values", "$rewind", "$each", "$each_with_index", "$with_index", "$with_object", "$_init_cache", "$_clear_cache"]);
  })(self, null);
  (function(__base){
    // line 1198, (corelib), module Comparable
    function Comparable() {};
    Comparable = __module(__base, "Comparable", Comparable);
    var Comparable_prototype = Comparable.prototype, __scope = Comparable._scope;

    // line 1199, (corelib), Comparable#<
    Comparable_prototype.$lt$ = function(other) {
      
      return this.$cmp$(other).$eq$(-1);
    };

    // line 1203, (corelib), Comparable#<=
    Comparable_prototype.$le$ = function(other) {
      
      return this.$cmp$(other).$le$(0);
    };

    // line 1207, (corelib), Comparable#==
    Comparable_prototype.$eq$ = function(other) {
      
      return this.$cmp$(other).$eq$(0);
    };

    // line 1211, (corelib), Comparable#>
    Comparable_prototype.$gt$ = function(other) {
      
      return this.$cmp$(other).$eq$(1);
    };

    // line 1215, (corelib), Comparable#>=
    Comparable_prototype.$ge$ = function(other) {
      
      return this.$cmp$(other).$ge$(0);
    };

    // line 1219, (corelib), Comparable#between?
    Comparable_prototype.$between$p = function(min, max) {
      var __a;
      return (__a = this.$gt$(min) ? this.$lt$(max) : __a);
    };
        ;Comparable._donate(["$lt$", "$le$", "$eq$", "$gt$", "$ge$", "$between$p"]);
  })(self);
  (function(__base, __super){
    // line 1223, (corelib), class Array
    function Array() {};
    Array = __klass(__base, __super, "Array", Array);
    var Array_prototype = Array.prototype, __scope = Array._scope, TMP_30, TMP_31, TMP_32, TMP_33, TMP_34, TMP_35, TMP_36, TMP_37, TMP_38, TMP_39, TMP_40, TMP_41, TMP_42, TMP_43, TMP_44, TMP_45, TMP_46, TMP_47, TMP_48;

    
    Array_prototype._isArray = true;
  

    Array.$include(__scope.Enumerable);

    // line 1230, (corelib), Array.[]
    Array.$aref$ = function(objects) {
      objects = __slice.call(arguments, 0);
      
      var result = this.$allocate();

      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    
    };

    // line 1240, (corelib), Array.new
    Array.$new = function(size, obj) {
      var arr = nil;if (obj == null) {
        obj = nil
      }
      arr = this.$allocate();
      
      for (var i = 0; i < size; i++) {
        arr[i] = obj;
      }
    
      return arr;
    };

    // line 1252, (corelib), Array#&
    Array_prototype.$and$ = function(other) {
      
      
      var result = [],
          seen   = {};

      for (var i = 0, length = this.length; i < length; i++) {
        var item = this[i];

        if (!seen[item]) {
          for (var j = 0, length2 = other.length; j < length2; j++) {
            var item2 = other[j];

            if ((item === item2) && !seen[item]) {
              seen[item] = true;

              result.push(item);
            }
          }
        }
      }

      return result;
    
    };

    // line 1277, (corelib), Array#*
    Array_prototype.$mul$ = function(other) {
      
      
      if (typeof(other) === 'string') {
        return this.join(other);
      }

      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result = result.concat(this);
      }

      return result;
    
    };

    // line 1293, (corelib), Array#+
    Array_prototype.$plus$ = function(other) {
      
      return this.slice().concat(other.slice());
    };

    // line 1297, (corelib), Array#<<
    Array_prototype.$lshft$ = function(object) {
      
      this.push(object);
      return this;
    };

    // line 1303, (corelib), Array#<=>
    Array_prototype.$cmp$ = function(other) {
      
      
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

    // line 1323, (corelib), Array#==
    Array_prototype.$eq$ = function(other) {
      
      
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

    // line 1340, (corelib), Array#[]
    Array_prototype.$aref$ = function(index, length) {
      
      
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
          this.$raise("bad arg for Array#[]");
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

    // line 1388, (corelib), Array#[]=
    Array_prototype.$aset$ = function(index, value) {
      
      
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    
    };

    // line 1400, (corelib), Array#assoc
    Array_prototype.$assoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && (item[0]).$eq$(object)) {
          return item;
        }
      }

      return nil;
    
    };

    // line 1412, (corelib), Array#at
    Array_prototype.$at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    
    };

    // line 1426, (corelib), Array#clear
    Array_prototype.$clear = function() {
      
      this.splice(0);
      return this;
    };

    // line 1432, (corelib), Array#clone
    Array_prototype.$clone = function() {
      
      return this.slice();
    };

    // line 1436, (corelib), Array#collect
    Array_prototype.$collect = TMP_30 = function() {
      var __context, block;
      block = TMP_30._p || nil, __context = block._s, TMP_30._p = null;
      
      if (block === nil) {
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

    // line 1454, (corelib), Array#collect!
    Array_prototype.$collect$b = TMP_31 = function() {
      var __context, block;
      block = TMP_31._p || nil, __context = block._s, TMP_31._p = null;
      
      if (block === nil) {
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

    // line 1470, (corelib), Array#compact
    Array_prototype.$compact = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 1484, (corelib), Array#compact!
    Array_prototype.$compact$b = function() {
      
      
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

    // line 1501, (corelib), Array#concat
    Array_prototype.$concat = function(other) {
      
      
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    
      return this;
    };

    // line 1511, (corelib), Array#count
    Array_prototype.$count = function(object) {
      
      
      if (object == null) {
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

    // line 1529, (corelib), Array#delete
    Array_prototype.$delete = function(object) {
      
      
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

    // line 1546, (corelib), Array#delete_at
    Array_prototype.$delete_at = function(index) {
      
      
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

    // line 1564, (corelib), Array#delete_if
    Array_prototype.$delete_if = TMP_32 = function() {
      var __context, block;
      block = TMP_32._p || nil, __context = block._s, TMP_32._p = null;
      
      if (block === nil) {
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

    // line 1585, (corelib), Array#drop
    Array_prototype.$drop = function(number) {
      
      return this.slice(number);
    };

    // line 1589, (corelib), Array#drop_while
    Array_prototype.$drop_while = TMP_33 = function() {
      var __context, block;
      block = TMP_33._p || nil, __context = block._s, TMP_33._p = null;
      
      if (block === nil) {
        return this.$enum_for("drop_while")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          return this.slice(i);
        }
      }

      return [];
    
    };

    Array_prototype.$dup = Array_prototype.$clone;

    // line 1609, (corelib), Array#each
    Array_prototype.$each = TMP_34 = function() {
      var __context, block;
      block = TMP_34._p || nil, __context = block._s, TMP_34._p = null;
      
      if (block === nil) {
        return this.$enum_for("each")
      };
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, this[i]) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 1619, (corelib), Array#each_index
    Array_prototype.$each_index = TMP_35 = function() {
      var __context, block;
      block = TMP_35._p || nil, __context = block._s, TMP_35._p = null;
      
      if (block === nil) {
        return this.$enum_for("each_index")
      };
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, i) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 1629, (corelib), Array#each_with_index
    Array_prototype.$each_with_index = TMP_36 = function() {
      var __context, block;
      block = TMP_36._p || nil, __context = block._s, TMP_36._p = null;
      
      if (block === nil) {
        return this.$enum_for("each_with_index")
      };
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, this[i], i) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 1639, (corelib), Array#empty?
    Array_prototype.$empty$p = function() {
      
      return !this.length;
    };

    // line 1643, (corelib), Array#fetch
    Array_prototype.$fetch = TMP_37 = function(index, defaults) {
      var __context, block;
      block = TMP_37._p || nil, __context = block._s, TMP_37._p = null;
      
      
      var original = index;

      if (index < 0) {
        index += this.length;
      }

      if (index >= 0 && index < this.length) {
        return this[index];
      }

      if (defaults != null) {
        return defaults;
      }

      if (block !== nil) {
        return block.call(__context, original);
      }

      this.$raise("Array#fetch");
    
    };

    // line 1667, (corelib), Array#first
    Array_prototype.$first = function(count) {
      
      
      if (count != null) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    
    };

    // line 1677, (corelib), Array#flatten
    Array_prototype.$flatten = function(level) {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (item._isArray) {
          if (level == null) {
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

    // line 1704, (corelib), Array#flatten!
    Array_prototype.$flatten$b = function(level) {
      
      
      var size = this.length;
      this.$replace(this.$flatten(level));

      return size === this.length ? nil : this;
    
    };

    // line 1713, (corelib), Array#grep
    Array_prototype.$grep = function(pattern) {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (pattern.$eqq$(item)) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 1729, (corelib), Array#hash
    Array_prototype.$hash = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 1733, (corelib), Array#include?
    Array_prototype.$include$p = function(member) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i]).$eq$(member)) {
          return true;
        }
      }

      return false;
    
    };

    // line 1745, (corelib), Array#index
    Array_prototype.$index = TMP_38 = function(object) {
      var __a, __b, __context, block;
      block = TMP_38._p || nil, __context = block._s, TMP_38._p = null;
      
      if ((__a = (__b = (block !== nil) ? object.$eq$(this.$undefined()) : __b)) === false || __a === nil) {
        return this.$enum_for("index")
      };
      
      if (block !== nil) {
        for (var i = 0, length = this.length, value; i < length; i++) {
          if ((value = block.call(__context, this[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
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

      return nil;
    
    };

    // line 1772, (corelib), Array#inject
    Array_prototype.$inject = TMP_39 = function(initial) {
      var __context, block;
      block = TMP_39._p || nil, __context = block._s, TMP_39._p = null;
      
      if (block === nil) {
        return this.$enum_for("inject")
      };
      
      var result, i;

      if (initial == null) {
        result = this[0], i = 1;
      }
      else {
        result = initial, i = 0;
      }

      for (var length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, result, this[i])) === __breaker) {
          return __breaker.$v;
        }

        result = value;
      }

      return result;
    
    };

    // line 1797, (corelib), Array#insert
    Array_prototype.$insert = function(index, objects) {
      objects = __slice.call(arguments, 1);
      
      if (objects.length > 0) {
        if (index < 0) {
          index += this.length + 1;

          if (index < 0) {
            this.$raise("" + (index) + " is out of bounds");
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

    // line 1820, (corelib), Array#inspect
    Array_prototype.$inspect = function() {
      
      
      var inspect = [];

      for (var i = 0, length = this.length; i < length; i++) {
        inspect.push((this[i]).$inspect());
      }

      return '[' + inspect.join(', ') + ']';
    
    };

    // line 1832, (corelib), Array#join
    Array_prototype.$join = function(sep) {
      if (sep == null) {
        sep = ""
      }
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_s());
      }

      return result.join(sep);
    
    };

    // line 1844, (corelib), Array#keep_if
    Array_prototype.$keep_if = TMP_40 = function() {
      var __context, block;
      block = TMP_40._p || nil, __context = block._s, TMP_40._p = null;
      
      if (block === nil) {
        return this.$enum_for("keep_if")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }
    
      return this;
    };

    // line 1864, (corelib), Array#last
    Array_prototype.$last = function(count) {
      
      
      var length = this.length;

      if (count == null) {
        return length === 0 ? nil : this[length - 1];
      }
      else if (count < 0) {
        this.$raise("negative count given");
      }

      if (count > length) {
        count = length;
      }

      return this.slice(length - count, length);
    
    };

    // line 1883, (corelib), Array#length
    Array_prototype.$length = function() {
      
      return this.length;
    };

    Array_prototype.$map = Array_prototype.$collect;

    Array_prototype.$map$b = Array_prototype.$collect$b;

    // line 1891, (corelib), Array#pop
    Array_prototype.$pop = function(count) {
      
      
      var length = this.length;

      if (count == null) {
        return length === 0 ? nil : this.pop();
      }

      if (count < 0) {
        this.$raise("negative count given");
      }

      return count > length ? this.splice(0) : this.splice(length - count, length);
    
    };

    // line 1907, (corelib), Array#push
    Array_prototype.$push = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    
      return this;
    };

    // line 1917, (corelib), Array#rassoc
    Array_prototype.$rassoc = function(object) {
      
      
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

    // line 1933, (corelib), Array#reject
    Array_prototype.$reject = TMP_41 = function() {
      var __context, block;
      block = TMP_41._p || nil, __context = block._s, TMP_41._p = null;
      
      if (block === nil) {
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

    // line 1952, (corelib), Array#reject!
    Array_prototype.$reject$b = TMP_42 = function() {
      var __context, block;
      block = TMP_42._p || nil, __context = block._s, TMP_42._p = null;
      
      if (block === nil) {
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

    // line 1975, (corelib), Array#replace
    Array_prototype.$replace = function(other) {
      
      
      this.splice(0);
      this.push.apply(this, other);
      return this;
    
    };

    // line 1983, (corelib), Array#reverse
    Array_prototype.$reverse = function() {
      
      return this.reverse();
    };

    // line 1987, (corelib), Array#reverse!
    Array_prototype.$reverse$b = function() {
      
      
      this.splice(0);
      this.push.apply(this, this.$reverse());
      return this;
    
    };

    // line 1995, (corelib), Array#reverse_each
    Array_prototype.$reverse_each = TMP_43 = function() {
      var __a, __context, block;
      block = TMP_43._p || nil, __context = block._s, TMP_43._p = null;
      
      if (block === nil) {
        return this.$enum_for("reverse_each")
      };
      (__a = this.$reverse(), __a.$each._p = block.$to_proc(), __a.$each());
      return this;
    };

    // line 2003, (corelib), Array#rindex
    Array_prototype.$rindex = TMP_44 = function(object) {
      var __context, block;
      block = TMP_44._p || nil, __context = block._s, TMP_44._p = null;
      
      if (block === nil) {
        return this.$enum_for("rindex")
      };
      
      if (block !== nil) {
        for (var i = this.length - 1, value; i >= 0; i--) {
          if ((value = block.call(__context, this[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
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

      return nil;
    
    };

    // line 2030, (corelib), Array#select
    Array_prototype.$select = TMP_45 = function() {
      var __context, block;
      block = TMP_45._p || nil, __context = block._s, TMP_45._p = null;
      
      if (block === nil) {
        return this.$enum_for("select")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call(__context, item)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 2052, (corelib), Array#select!
    Array_prototype.$select$b = TMP_46 = function() {
      var __context, block;
      block = TMP_46._p || nil, __context = block._s, TMP_46._p = null;
      
      if (block === nil) {
        return this.$enum_for("select!")
      };
      
      var original = this.length;

      for (var i = 0, length = original, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call(__context, item)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : this;
    
    };

    // line 2076, (corelib), Array#shift
    Array_prototype.$shift = function(count) {
      
      return count == null ? this.shift() : this.splice(0, count);
    };

    Array_prototype.$size = Array_prototype.$length;

    Array_prototype.$slice = Array_prototype.$aref$;

    // line 2084, (corelib), Array#slice!
    Array_prototype.$slice$b = function(index, length) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      if (length != null) {
        return this.splice(index, index + length);
      }

      return this.splice(index, 1)[0];
    
    };

    // line 2102, (corelib), Array#take
    Array_prototype.$take = function(count) {
      
      return this.slice(0, count);
    };

    // line 2106, (corelib), Array#take_while
    Array_prototype.$take_while = TMP_47 = function() {
      var __context, block;
      block = TMP_47._p || nil, __context = block._s, TMP_47._p = null;
      
      if (block === nil) {
        return this.$enum_for("take_while")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block.call(__context, item)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    
    };

    // line 2130, (corelib), Array#to_a
    Array_prototype.$to_a = function() {
      
      return this;
    };

    Array_prototype.$to_ary = Array_prototype.$to_a;

    // line 2136, (corelib), Array#to_json
    Array_prototype.$to_json = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_json());
      }

      return '[' + result.join(', ') + ']';
    
    };

    Array_prototype.$to_s = Array_prototype.$inspect;

    // line 2150, (corelib), Array#uniq
    Array_prototype.$uniq = function() {
      
      
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

    // line 2170, (corelib), Array#uniq!
    Array_prototype.$uniq$b = function() {
      
      
      var original = this.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = this[i];
        hash = item.$hash();

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

    // line 2194, (corelib), Array#unshift
    Array_prototype.$unshift = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.unshift(objects[i]);
      }

      return this;
    
    };

    // line 2204, (corelib), Array#zip
    Array_prototype.$zip = TMP_48 = function(others) {
      var __context, block;
      block = TMP_48._p || nil, __context = block._s, TMP_48._p = null;
      others = __slice.call(arguments, 0);
      
      var result = [], size = this.length, part, o;

      for (var i = 0; i < size; i++) {
        part = [this[i]];

        for (var j = 0, jj = others.length; j < jj; j++) {
          o = others[j][i];

          if (o == null) {
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
    ;Array._donate(["$and$", "$mul$", "$plus$", "$lshft$", "$cmp$", "$eq$", "$aref$", "$aset$", "$assoc", "$at", "$clear", "$clone", "$collect", "$collect$b", "$compact", "$compact$b", "$concat", "$count", "$delete", "$delete_at", "$delete_if", "$drop", "$drop_while", "$dup", "$each", "$each_index", "$each_with_index", "$empty$p", "$fetch", "$first", "$flatten", "$flatten$b", "$grep", "$hash", "$include$p", "$index", "$inject", "$insert", "$inspect", "$join", "$keep_if", "$last", "$length", "$map", "$map$b", "$pop", "$push", "$rassoc", "$reject", "$reject$b", "$replace", "$reverse", "$reverse$b", "$reverse_each", "$rindex", "$select", "$select$b", "$shift", "$size", "$slice", "$slice$b", "$take", "$take_while", "$to_a", "$to_ary", "$to_json", "$to_s", "$uniq", "$uniq$b", "$unshift", "$zip"]);    ;Array._sdonate(["$aref$", "$new"]);
  })(self, Array);
  (function(__base, __super){
    // line 2236, (corelib), class Hash
    function Hash() {};
    Hash = __klass(__base, __super, "Hash", Hash);
    var Hash_prototype = Hash.prototype, __scope = Hash._scope, TMP_49, TMP_50, TMP_51, TMP_52, TMP_53, TMP_54, TMP_55, TMP_56, TMP_57, TMP_58, TMP_59, TMP_60;

    Hash.$include(__scope.Enumerable);

    
    __hash = Opal.hash = function() {
      var hash   = new Hash,
          args   = __slice.call(arguments),
          assocs = {};

      hash.map   = assocs;
      hash.none  = nil;
      hash.proc  = nil;

      for (var i = 0, length = args.length, key; i < length; i++) {
        key = args[i];
        assocs[key] = [key, args[++i]];
      }

      return hash;
    };
  

    // line 2258, (corelib), Hash.[]
    Hash.$aref$ = function(objs) {
      objs = __slice.call(arguments, 0);
      return __hash.apply(null, objs);
    };

    // line 2262, (corelib), Hash.allocate
    Hash.$allocate = function() {
      
      return __hash();
    };

    // line 2266, (corelib), Hash.new
    Hash.$new = TMP_49 = function(defaults) {
      var __context, block;
      block = TMP_49._p || nil, __context = block._s, TMP_49._p = null;
      
      
      var hash = __hash();

      if (defaults != null) {
        hash.none = defaults;
      }
      else if (block !== nil) {
        hash.proc = block;
      }

      return hash;
    
    };

    // line 2281, (corelib), Hash#==
    Hash_prototype.$eq$ = function(other) {
      
      
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

    // line 2311, (corelib), Hash#[]
    Hash_prototype.$aref$ = function(key) {
      
      
      var bucket;

      if (bucket = this.map[key]) {
        return bucket[1];
      }

      return this.none;
    
    };

    // line 2323, (corelib), Hash#[]=
    Hash_prototype.$aset$ = function(key, value) {
      
      
      this.map[key] = [key, value];

      return value;
    
    };

    // line 2331, (corelib), Hash#assoc
    Hash_prototype.$assoc = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if ((bucket[0]).$eq$(object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };

    // line 2345, (corelib), Hash#clear
    Hash_prototype.$clear = function() {
      
      
      this.map = {};

      return this;
    
    };

    // line 2353, (corelib), Hash#clone
    Hash_prototype.$clone = function() {
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = [map[assoc][0], map[assoc][1]];
      }

      return result;
    
    };

    // line 2367, (corelib), Hash#default
    Hash_prototype.$default = function() {
      
      return this.none;
    };

    // line 2371, (corelib), Hash#default=
    Hash_prototype.$default$e = function(object) {
      
      return this.none = object;
    };

    // line 2375, (corelib), Hash#default_proc
    Hash_prototype.$default_proc = function() {
      
      return this.proc;
    };

    // line 2379, (corelib), Hash#default_proc=
    Hash_prototype.$default_proc$e = function(proc) {
      
      return this.proc = proc;
    };

    // line 2383, (corelib), Hash#delete
    Hash_prototype.$delete = function(key) {
      
      
      var map  = this.map, result;

      if (result = map[key]) {
        result = bucket[1];

        delete map[key];
      }

      return result;
    
    };

    // line 2397, (corelib), Hash#delete_if
    Hash_prototype.$delete_if = TMP_50 = function() {
      var __context, block;
      block = TMP_50._p || nil, __context = block._s, TMP_50._p = null;
      
      if (block === nil) {
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

    Hash_prototype.$dup = Hash_prototype.$clone;

    // line 2422, (corelib), Hash#each
    Hash_prototype.$each = TMP_51 = function() {
      var __context, block;
      block = TMP_51._p || nil, __context = block._s, TMP_51._p = null;
      
      if (block === nil) {
        return this.$enum_for("each")
      };
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0], bucket[1]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 2440, (corelib), Hash#each_key
    Hash_prototype.$each_key = TMP_52 = function() {
      var __context, block;
      block = TMP_52._p || nil, __context = block._s, TMP_52._p = null;
      
      if (block === nil) {
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

    Hash_prototype.$each_pair = Hash_prototype.$each;

    // line 2460, (corelib), Hash#each_value
    Hash_prototype.$each_value = TMP_53 = function() {
      var __context, block;
      block = TMP_53._p || nil, __context = block._s, TMP_53._p = null;
      
      if (block === nil) {
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

    // line 2478, (corelib), Hash#empty?
    Hash_prototype.$empty$p = function() {
      
      
      for (var assoc in this.map) {
        return false;
      }

      return true;
    
    };

    Hash_prototype.$eql$p = Hash_prototype.$eq$;

    // line 2490, (corelib), Hash#fetch
    Hash_prototype.$fetch = TMP_54 = function(key, defaults) {
      var __context, block;
      block = TMP_54._p || nil, __context = block._s, TMP_54._p = null;
      
      
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

      this.$raise("key not found");
    
    };

    // line 2516, (corelib), Hash#flatten
    Hash_prototype.$flatten = function(level) {
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

    // line 2545, (corelib), Hash#has_key?
    Hash_prototype.$has_key$p = function(key) {
      
      return !!this.map[key];
    };

    // line 2549, (corelib), Hash#has_value?
    Hash_prototype.$has_value$p = function(value) {
      
      
      for (var assoc in this.map) {
        if ((this.map[assoc][1]).$eq$(value)) {
          return true;
        }
      }

      return false;
    
    };

    // line 2561, (corelib), Hash#hash
    Hash_prototype.$hash = function() {
      
      return this._id;
    };

    Hash_prototype.$include$p = Hash_prototype.$has_key$p;

    // line 2567, (corelib), Hash#index
    Hash_prototype.$index = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (object.$eq$(bucket[1])) {
          return bucket[0];
        }
      }

      return nil;
    
    };

    // line 2581, (corelib), Hash#indexes
    Hash_prototype.$indexes = function(keys) {
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

    Hash_prototype.$indices = Hash_prototype.$indexes;

    // line 2602, (corelib), Hash#inspect
    Hash_prototype.$inspect = function() {
      
      
      var inspect = [],
          map     = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push((bucket[0]).$inspect() + '=>' + (bucket[1]).$inspect());
      }
      return '{' + inspect.join(', ') + '}';
    
    };

    // line 2616, (corelib), Hash#invert
    Hash_prototype.$invert = function() {
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        map2[bucket[1]] = [bucket[1], bucket[0]];
      }

      return result;
    
    };

    // line 2632, (corelib), Hash#keep_if
    Hash_prototype.$keep_if = TMP_55 = function() {
      var __context, block;
      block = TMP_55._p || nil, __context = block._s, TMP_55._p = null;
      
      if (block === nil) {
        return this.$enum_for("keep_if")
      };
      
      var map = this.map, value;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((value = block.call(__context, bucket[0], bucket[1])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          delete map[assoc];
        }
      }

      return this;
    
    };

    Hash_prototype.$key = Hash_prototype.$index;

    Hash_prototype.$key$p = Hash_prototype.$has_key$p;

    // line 2658, (corelib), Hash#keys
    Hash_prototype.$keys = function() {
      
      
      var result = [];

      for (var assoc in this.map) {
        result.push(this.map[assoc][0]);
      }

      return result;
    
    };

    // line 2670, (corelib), Hash#length
    Hash_prototype.$length = function() {
      
      
      var result = 0;

      for (var assoc in this.map) {
        result++;
      }

      return result;
    
    };

    Hash_prototype.$member$p = Hash_prototype.$has_key$p;

    // line 2684, (corelib), Hash#merge
    Hash_prototype.$merge = TMP_56 = function(other) {
      var __context, block;
      block = TMP_56._p || nil, __context = block._s, TMP_56._p = null;
      
      
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

          if (__hasOwn.call(map2, assoc)) {
            val = block.call(__context, key, map2[assoc][1], val);
          }

          map2[assoc] = [key, val];
        }
      }

      return result;
    
    };

    // line 2721, (corelib), Hash#merge!
    Hash_prototype.$merge$b = TMP_57 = function(other) {
      var __context, block;
      block = TMP_57._p || nil, __context = block._s, TMP_57._p = null;
      
      
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

          if (__hasOwn.call(map, assoc)) {
            val = block.call(__context, key, map[assoc][1], val);
          }

          map[assoc] = [key, val];
        }
      }

      return this;
    
    };

    // line 2749, (corelib), Hash#rassoc
    Hash_prototype.$rassoc = function(object) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((bucket[1]).$eq$(object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };

    // line 2765, (corelib), Hash#reject
    Hash_prototype.$reject = TMP_58 = function() {
      var __context, block;
      block = TMP_58._p || nil, __context = block._s, TMP_58._p = null;
      
      if (block === nil) {
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

    // line 2788, (corelib), Hash#replace
    Hash_prototype.$replace = function(other) {
      
      
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[bucket[0]] = [bucket[0], bucket[1]];
      }

      return this;
    
    };

    // line 2802, (corelib), Hash#select
    Hash_prototype.$select = TMP_59 = function() {
      var __context, block;
      block = TMP_59._p || nil, __context = block._s, TMP_59._p = null;
      
      if (block === nil) {
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

    // line 2825, (corelib), Hash#select!
    Hash_prototype.$select$b = TMP_60 = function() {
      var __context, block;
      block = TMP_60._p || nil, __context = block._s, TMP_60._p = null;
      
      if (block === nil) {
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

    // line 2849, (corelib), Hash#shift
    Hash_prototype.$shift = function() {
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];
        delete map[assoc];
        return [bucket[0], bucket[1]];
      }

      return nil;
    
    };

    Hash_prototype.$size = Hash_prototype.$length;

    // line 2865, (corelib), Hash#to_a
    Hash_prototype.$to_a = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    
    };

    // line 2880, (corelib), Hash#to_hash
    Hash_prototype.$to_hash = function() {
      
      return this;
    };

    // line 2884, (corelib), Hash#to_json
    Hash_prototype.$to_json = function() {
      
      
      var parts = [], map = this.map, bucket;

      for (var assoc in map) {
        bucket = map[assoc];
        parts.push((bucket[0]).$to_json() + ': ' + (bucket[1]).$to_json());
      }

      return '{' + parts.join(', ') + '}';
    
    };

    Hash_prototype.$to_s = Hash_prototype.$inspect;

    Hash_prototype.$update = Hash_prototype.$merge$b;

    // line 2901, (corelib), Hash#value?
    Hash_prototype.$value$p = function(value) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var v = map[assoc][1];
        if ((v).$eq$(value)) {
          return true;
        }
      }

      return false;
    
    };

    Hash_prototype.$values_at = Hash_prototype.$indexes;

    // line 2918, (corelib), Hash#values
    Hash_prototype.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    
    };
    ;Hash._donate(["$eq$", "$aref$", "$aset$", "$assoc", "$clear", "$clone", "$default", "$default$e", "$default_proc", "$default_proc$e", "$delete", "$delete_if", "$dup", "$each", "$each_key", "$each_pair", "$each_value", "$empty$p", "$eql$p", "$fetch", "$flatten", "$has_key$p", "$has_value$p", "$hash", "$include$p", "$index", "$indexes", "$indices", "$inspect", "$invert", "$keep_if", "$key", "$key$p", "$keys", "$length", "$member$p", "$merge", "$merge$b", "$rassoc", "$reject", "$replace", "$select", "$select$b", "$shift", "$size", "$to_a", "$to_hash", "$to_json", "$to_s", "$update", "$value$p", "$values_at", "$values"]);    ;Hash._sdonate(["$aref$", "$allocate", "$new"]);
  })(self, null);
  (function(__base, __super){
    // line 2931, (corelib), class String
    function String() {};
    String = __klass(__base, __super, "String", String);
    var String_prototype = String.prototype, __scope = String._scope, TMP_61, TMP_62, TMP_63, TMP_64, TMP_65;

    
    String_prototype._isString = true;
  

    String.$include(__scope.Comparable);

    // line 2938, (corelib), String.try_convert
    String.$try_convert = function(what) {
      
      return (function() { try {
      what.$to_str()
      } catch ($err) {
      if (true) {
      nil}
      else { throw $err; }
      } }).call(this)
    };

    // line 2944, (corelib), String.new
    String.$new = function(str) {
      if (str == null) {
        str = ""
      }
      return this.$allocate(str.$to_s())
    };

    // line 2948, (corelib), String#%
    String_prototype.$mod$ = function(data) {
      
      return this.$sprintf(this, data);
    };

    // line 2952, (corelib), String#*
    String_prototype.$mul$ = function(count) {
      
      
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

    // line 2973, (corelib), String#+
    String_prototype.$plus$ = function(other) {
      
      return this + other;
    };

    // line 2977, (corelib), String#<=>
    String_prototype.$cmp$ = function(other) {
      
      
      if (typeof other !== 'string') {
        return nil;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    
    };

    // line 2987, (corelib), String#<
    String_prototype.$lt$ = function(other) {
      
      return this < other;
    };

    // line 2991, (corelib), String#<=
    String_prototype.$le$ = function(other) {
      
      return this <= other;
    };

    // line 2995, (corelib), String#>
    String_prototype.$gt$ = function(other) {
      
      return this > other;
    };

    // line 2999, (corelib), String#>=
    String_prototype.$ge$ = function(other) {
      
      return this >= other;
    };

    // line 3003, (corelib), String#==
    String_prototype.$eq$ = function(other) {
      
      return this == other;
    };

    String_prototype.$eqq$ = String_prototype.$eq$;

    // line 3009, (corelib), String#=~
    String_prototype.$match$ = function(other) {
      
      
      if (typeof other === 'string') {
        this.$raise("string given");
      }

      return other.$match$(this);
    
    };

    // line 3020, (corelib), String#[]
    String_prototype.$aref$ = function(index, length) {
      
      
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

    // line 3046, (corelib), String#capitalize
    String_prototype.$capitalize = function() {
      
      return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
    };

    // line 3050, (corelib), String#casecmp
    String_prototype.$casecmp = function(other) {
      
      
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    
    };

    // line 3063, (corelib), String#chars
    String_prototype.$chars = TMP_61 = function() {
      var __context, __yield;
      __yield = TMP_61._p || nil, __context = __yield._s, TMP_61._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("chars")
      };
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (__yield.call(__context, this.charAt(i)) === __breaker) return __breaker.$v
      }
    
    };

    // line 3073, (corelib), String#chomp
    String_prototype.$chomp = function(separator) {
      if (separator == null) {
        separator = __gvars["/"]
      }
      
      if (separator === "\n") {
        return this.replace(/(\n|\r|\r\n)$/, '');
      }
      else if (separator === "") {
        return this.replace(/(\n|\r\n)+$/, '');
      }
      return this.replace(new RegExp(separator + '$'), '');
    
    };

    // line 3085, (corelib), String#chop
    String_prototype.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };

    // line 3089, (corelib), String#chr
    String_prototype.$chr = function() {
      
      return this.charAt(0);
    };

    String_prototype.$downcase = String_prototype.toLowerCase;

    String_prototype.$each_char = String_prototype.$chars;

    // line 3097, (corelib), String#each_line
    String_prototype.$each_line = TMP_62 = function(separator) {
      var __context, __yield;
      __yield = TMP_62._p || nil, __context = __yield._s, TMP_62._p = null;
      if (separator == null) {
        separator = __gvars["/"]
      }
      if (__yield === nil) {
        return this.$enum_for("each_line", separator)
      };
      
      var splitted = this.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        if (__yield.call(__context, splitted[i] + separator) === __breaker) return __breaker.$v
      }
    
    };

    // line 3109, (corelib), String#empty?
    String_prototype.$empty$p = function() {
      
      return this.length === 0;
    };

    // line 3113, (corelib), String#end_with?
    String_prototype.$end_with$p = function(suffixes) {
      suffixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (this.lastIndexOf(suffix) === this.length - suffix.length) {
          return true;
        }
      }

      return false;
    
    };

    String_prototype.$eql$p = String_prototype.$eq$;

    // line 3129, (corelib), String#equal?
    String_prototype.$equal$p = function(val) {
      
      return this.toString() === val.toString();
    };

    String_prototype.$getbyte = String_prototype.charCodeAt;

    // line 3135, (corelib), String#gsub
    String_prototype.$gsub = TMP_63 = function(pattern, replace) {
      var __a, __b, __context, block;
      block = TMP_63._p || nil, __context = block._s, TMP_63._p = null;
      
      if ((__a = (__b = !block, __b !== false && __b !== nil ? pattern == null : __b)) !== false && __a !== nil) {
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

    String_prototype.$hash = String_prototype.toString;

    // line 3153, (corelib), String#hex
    String_prototype.$hex = function() {
      
      return this.$to_i(16);
    };

    // line 3157, (corelib), String#include?
    String_prototype.$include$p = function(other) {
      
      return this.indexOf(other) !== -1;
    };

    // line 3161, (corelib), String#index
    String_prototype.$index = function(what, offset) {
      var __a, __b;
      if ((__a = (__b = __scope.String.$eqq$(what), __b !== false && __b !== nil ? __b : __scope.Regexp.$eqq$(what))) === false || __a === nil) {
        this.$raise(__scope.TypeError, "type mismatch: " + (what.$class()) + " given")
      };
      
      var result = -1;

      if (offset != null) {
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

    // line 3198, (corelib), String#inspect
    String_prototype.$inspect = function() {
      
      
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

    // line 3222, (corelib), String#intern
    String_prototype.$intern = function() {
      
      return this;
    };

    String_prototype.$lines = String_prototype.$each_line;

    // line 3228, (corelib), String#length
    String_prototype.$length = function() {
      
      return this.length;
    };

    // line 3232, (corelib), String#ljust
    String_prototype.$ljust = function(integer, padstr) {
      if (padstr == null) {
        padstr = " "
      }
      return this.$raise(__scope.NotImplementedError);
    };

    // line 3236, (corelib), String#lstrip
    String_prototype.$lstrip = function() {
      
      return this.replace(/^\s*/, '');
    };

    // line 3240, (corelib), String#match
    String_prototype.$match = TMP_64 = function(pattern, pos) {
      var __a, __b, __context, block;
      block = TMP_64._p || nil, __context = block._s, TMP_64._p = null;
      
      return (__a = (function() { if ((__b = pattern.$is_a$p(__scope.Regexp)) !== false && __b !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this), __a.$match._p = block.$to_proc(), __a.$match(this, pos));
    };

    // line 3244, (corelib), String#next
    String_prototype.$next = function() {
      
      
      if (this.length === 0) {
        return "";
      }

      var initial = this.substr(0, this.length - 1);
      var last    = String.fromCharCode(this.charCodeAt(this.length - 1) + 1);

      return initial + last;
    
    };

    // line 3257, (corelib), String#ord
    String_prototype.$ord = function() {
      
      return this.charCodeAt(0);
    };

    // line 3261, (corelib), String#partition
    String_prototype.$partition = function(str) {
      
      
      var result = this.split(str);
      var splitter = (result[0].length === this.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    
    };

    // line 3270, (corelib), String#reverse
    String_prototype.$reverse = function() {
      
      return this.split('').reverse().join('');
    };

    // line 3274, (corelib), String#rstrip
    String_prototype.$rstrip = function() {
      
      return this.replace(/\s*$/, '');
    };

    String_prototype.$size = String_prototype.$length;

    String_prototype.$slice = String_prototype.$aref$;

    // line 3282, (corelib), String#split
    String_prototype.$split = function(pattern, limit) {
      var __a;if (pattern == null) {
        pattern = (__a = __gvars[";"], __a !== false && __a !== nil ? __a : " ")
      }
      return this.split(pattern, limit);
    };

    // line 3286, (corelib), String#start_with?
    String_prototype.$start_with$p = function(prefixes) {
      prefixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    
    };

    // line 3298, (corelib), String#strip
    String_prototype.$strip = function() {
      
      return this.replace(/^\s*/, '').replace(/\s*$/, '');
    };

    // line 3302, (corelib), String#sub
    String_prototype.$sub = TMP_65 = function(pattern, replace) {
      var __context, block;
      block = TMP_65._p || nil, __context = block._s, TMP_65._p = null;
      
      
      if (typeof(replace) === 'string') {
        return this.replace(pattern, replace);
      }
      if (block !== nil) {
        return this.replace(pattern, function(str) {
          return block.call(__context, str);
        });
      }
      else if (replace != null) {
        if (replace.$is_a$p(__scope.Hash)) {
          return this.replace(pattern, function(str) {
            var value = replace.$aref$(this.$str());

            return (value == null) ? nil : this.$value().$to_s();
          });
        }
        else {
          replace = __scope.String.$try_convert(replace);

          if (replace == null) {
            this.$raise(__scope.TypeError, "can't convert " + (replace.$class()) + " into String");
          }

          return this.replace(pattern, replace);
        }
      }
      else {
        return this.replace(pattern, replace.toString());
      }
    
    };

    String_prototype.$succ = String_prototype.$next;

    // line 3338, (corelib), String#sum
    String_prototype.$sum = function(n) {
      if (n == null) {
        n = 16
      }
      
      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        result += (this.charCodeAt(i) % ((1 << n) - 1));
      }

      return result;
    
    };

    // line 3350, (corelib), String#swapcase
    String_prototype.$swapcase = function() {
      
      
      var str = this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (this._klass === String) {
        return str;
      }

      return this._klass.$new(str);
    
    };

    // line 3364, (corelib), String#to_a
    String_prototype.$to_a = function() {
      
      
      if (this.length === 0) {
        return [];
      }

      return [this];
    
    };

    // line 3374, (corelib), String#to_f
    String_prototype.$to_f = function() {
      
      
      var result = parseFloat(this);

      return isNaN(result) ? 0 : result;
    
    };

    // line 3382, (corelib), String#to_i
    String_prototype.$to_i = function(base) {
      if (base == null) {
        base = 10
      }
      
      var result = parseInt(this, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    
    };

    String_prototype.$to_json = String_prototype.$inspect;

    // line 3396, (corelib), String#to_proc
    String_prototype.$to_proc = function() {
      
      
      var self = this, jsid = mid_to_jsid(self);

      return function(arg) { return arg[jsid](); };
    
    };

    String_prototype.$to_s = String_prototype.toString;

    String_prototype.$to_str = String_prototype.$to_s;

    String_prototype.$to_sym = String_prototype.$intern;

    String_prototype.$upcase = String_prototype.toUpperCase;
    ;String._donate(["$mod$", "$mul$", "$plus$", "$cmp$", "$lt$", "$le$", "$gt$", "$ge$", "$eq$", "$eqq$", "$match$", "$aref$", "$capitalize", "$casecmp", "$chars", "$chomp", "$chop", "$chr", "$downcase", "$each_char", "$each_line", "$empty$p", "$end_with$p", "$eql$p", "$equal$p", "$getbyte", "$gsub", "$hash", "$hex", "$include$p", "$index", "$inspect", "$intern", "$lines", "$length", "$ljust", "$lstrip", "$match", "$next", "$ord", "$partition", "$reverse", "$rstrip", "$size", "$slice", "$split", "$start_with$p", "$strip", "$sub", "$succ", "$sum", "$swapcase", "$to_a", "$to_f", "$to_i", "$to_json", "$to_proc", "$to_s", "$to_str", "$to_sym", "$upcase"]);    ;String._sdonate(["$try_convert", "$new"]);
  })(self, String);
  __scope.Symbol = __scope.String;
  (function(__base, __super){
    // line 3414, (corelib), class Numeric
    function Numeric() {};
    Numeric = __klass(__base, __super, "Numeric", Numeric);
    var Numeric_prototype = Numeric.prototype, __scope = Numeric._scope, TMP_66, TMP_67, TMP_68;

    
    Numeric_prototype._isNumber = true;
  

    Numeric.$include(__scope.Comparable);

    // line 3421, (corelib), Numeric#+
    Numeric_prototype.$plus$ = function(other) {
      
      return this + other;
    };

    // line 3425, (corelib), Numeric#-
    Numeric_prototype.$minus$ = function(other) {
      
      return this - other;
    };

    // line 3429, (corelib), Numeric#*
    Numeric_prototype.$mul$ = function(other) {
      
      return this * other;
    };

    // line 3433, (corelib), Numeric#/
    Numeric_prototype.$div$ = function(other) {
      
      return this / other;
    };

    // line 3437, (corelib), Numeric#%
    Numeric_prototype.$mod$ = function(other) {
      
      return this % other;
    };

    // line 3441, (corelib), Numeric#&
    Numeric_prototype.$and$ = function(other) {
      
      return this & other;
    };

    // line 3445, (corelib), Numeric#|
    Numeric_prototype.$or$ = function(other) {
      
      return this | other;
    };

    // line 3449, (corelib), Numeric#^
    Numeric_prototype.$xor$ = function(other) {
      
      return this ^ other;
    };

    // line 3453, (corelib), Numeric#<
    Numeric_prototype.$lt$ = function(other) {
      
      return this < other;
    };

    // line 3457, (corelib), Numeric#<=
    Numeric_prototype.$le$ = function(other) {
      
      return this <= other;
    };

    // line 3461, (corelib), Numeric#>
    Numeric_prototype.$gt$ = function(other) {
      
      return this > other;
    };

    // line 3465, (corelib), Numeric#>=
    Numeric_prototype.$ge$ = function(other) {
      
      return this >= other;
    };

    // line 3469, (corelib), Numeric#<<
    Numeric_prototype.$lshft$ = function(count) {
      
      return this << count;
    };

    // line 3473, (corelib), Numeric#>>
    Numeric_prototype.$rshft$ = function(count) {
      
      return this >> count;
    };

    // line 3477, (corelib), Numeric#+@
    Numeric_prototype.$uplus$ = function() {
      
      return +this;
    };

    // line 3481, (corelib), Numeric#-@
    Numeric_prototype.$uminus$ = function() {
      
      return -this;
    };

    // line 3485, (corelib), Numeric#~
    Numeric_prototype.$tild$ = function() {
      
      return ~this;
    };

    // line 3489, (corelib), Numeric#**
    Numeric_prototype.$pow$ = function(other) {
      
      return Math.pow(this, other);
    };

    // line 3493, (corelib), Numeric#==
    Numeric_prototype.$eq$ = function(other) {
      
      return this == other;
    };

    // line 3497, (corelib), Numeric#<=>
    Numeric_prototype.$cmp$ = function(other) {
      
      
      if (typeof(other) !== 'number') {
        return nil;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    
    };

    // line 3507, (corelib), Numeric#abs
    Numeric_prototype.$abs = function() {
      
      return Math.abs(this);
    };

    // line 3511, (corelib), Numeric#ceil
    Numeric_prototype.$ceil = function() {
      
      return Math.ceil(this);
    };

    // line 3515, (corelib), Numeric#chr
    Numeric_prototype.$chr = function() {
      
      return String.fromCharCode(this);
    };

    // line 3519, (corelib), Numeric#downto
    Numeric_prototype.$downto = TMP_66 = function(finish) {
      var __context, block;
      block = TMP_66._p || nil, __context = block._s, TMP_66._p = null;
      
      if (block === nil) {
        return this.$enum_for("downto", finish)
      };
      
      for (var i = this; i >= finish; i--) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Numeric_prototype.$eql$p = Numeric_prototype.$eq$;

    // line 3535, (corelib), Numeric#even?
    Numeric_prototype.$even$p = function() {
      
      return this % 2 === 0;
    };

    // line 3539, (corelib), Numeric#floor
    Numeric_prototype.$floor = function() {
      
      return Math.floor(this);
    };

    // line 3543, (corelib), Numeric#hash
    Numeric_prototype.$hash = function() {
      
      return this.toString();
    };

    // line 3547, (corelib), Numeric#integer?
    Numeric_prototype.$integer$p = function() {
      
      return this % 1 === 0;
    };

    Numeric_prototype.$magnitude = Numeric_prototype.$abs;

    Numeric_prototype.$modulo = Numeric_prototype.$mod$;

    // line 3555, (corelib), Numeric#next
    Numeric_prototype.$next = function() {
      
      return this + 1;
    };

    // line 3559, (corelib), Numeric#nonzero?
    Numeric_prototype.$nonzero$p = function() {
      
      return this.valueOf() === 0 ? nil : this;
    };

    // line 3563, (corelib), Numeric#odd?
    Numeric_prototype.$odd$p = function() {
      
      return this % 2 !== 0;
    };

    // line 3567, (corelib), Numeric#ord
    Numeric_prototype.$ord = function() {
      
      return this;
    };

    // line 3571, (corelib), Numeric#pred
    Numeric_prototype.$pred = function() {
      
      return this - 1;
    };

    Numeric_prototype.$succ = Numeric_prototype.$next;

    // line 3577, (corelib), Numeric#times
    Numeric_prototype.$times = TMP_67 = function() {
      var __context, block;
      block = TMP_67._p || nil, __context = block._s, TMP_67._p = null;
      
      if (block === nil) {
        return this.$enum_for("times")
      };
      
      for (var i = 0; i <= this; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 3591, (corelib), Numeric#to_f
    Numeric_prototype.$to_f = function() {
      
      return parseFloat(this);
    };

    // line 3595, (corelib), Numeric#to_i
    Numeric_prototype.$to_i = function() {
      
      return parseInt(this);
    };

    // line 3599, (corelib), Numeric#to_json
    Numeric_prototype.$to_json = function() {
      
      return this.toString();
    };

    // line 3603, (corelib), Numeric#to_s
    Numeric_prototype.$to_s = function(base) {
      if (base == null) {
        base = 10
      }
      return this.toString();
    };

    // line 3607, (corelib), Numeric#upto
    Numeric_prototype.$upto = TMP_68 = function(finish) {
      var __context, block;
      block = TMP_68._p || nil, __context = block._s, TMP_68._p = null;
      
      if (block === nil) {
        return this.$enum_for("upto", finish)
      };
      
      for (var i = 0; i <= finish; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 3621, (corelib), Numeric#zero?
    Numeric_prototype.$zero$p = function() {
      
      return this == 0;
    };
    ;Numeric._donate(["$plus$", "$minus$", "$mul$", "$div$", "$mod$", "$and$", "$or$", "$xor$", "$lt$", "$le$", "$gt$", "$ge$", "$lshft$", "$rshft$", "$uplus$", "$uminus$", "$tild$", "$pow$", "$eq$", "$cmp$", "$abs", "$ceil", "$chr", "$downto", "$eql$p", "$even$p", "$floor", "$hash", "$integer$p", "$magnitude", "$modulo", "$next", "$nonzero$p", "$odd$p", "$ord", "$pred", "$succ", "$times", "$to_f", "$to_i", "$to_json", "$to_s", "$upto", "$zero$p"]);
  })(self, Number);
  (function(__base, __super){
    // line 3625, (corelib), class Proc
    function Proc() {};
    Proc = __klass(__base, __super, "Proc", Proc);
    var Proc_prototype = Proc.prototype, __scope = Proc._scope, TMP_69;

    
    Proc_prototype._isProc = true;
  

    // line 3630, (corelib), Proc.new
    Proc.$new = TMP_69 = function() {
      var __context, block;
      block = TMP_69._p || nil, __context = block._s, TMP_69._p = null;
      
      if (block === nil) no_block_given();
      return block;
    };

    // line 3636, (corelib), Proc#to_proc
    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    // line 3640, (corelib), Proc#call
    Proc_prototype.$call = function(args) {
      args = __slice.call(arguments, 0);
      return this.apply(this._s, args);
    };

    // line 3644, (corelib), Proc#to_proc
    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    // line 3648, (corelib), Proc#to_s
    Proc_prototype.$to_s = function() {
      
      return "#<Proc:0x0000000>";
    };

    // line 3652, (corelib), Proc#lambda?
    Proc_prototype.$lambda$p = function() {
      
      return !!this.$lambda;
    };

    // line 3656, (corelib), Proc#arity
    Proc_prototype.$arity = function() {
      
      return this.length - 1;
    };
    ;Proc._donate(["$to_proc", "$call", "$to_proc", "$to_s", "$lambda$p", "$arity"]);    ;Proc._sdonate(["$new"]);
  })(self, Function);
  (function(__base, __super){
    // line 3660, (corelib), class Range
    function Range() {};
    Range = __klass(__base, __super, "Range", Range);
    var Range_prototype = Range.prototype, __scope = Range._scope, TMP_70, TMP_71;

    Range.$include(__scope.Enumerable);

    
    Range.prototype._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new Range;
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  

    // line 3676, (corelib), Range#initialize
    Range_prototype.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };

    // line 3682, (corelib), Range#==
    Range_prototype.$eq$ = function(other) {
      var __a;
      if ((__a = __scope.Range.$eqq$(other)) === false || __a === nil) {
        return false
      };
      return (__a = (__a = this.$exclude_end$p().$eq$(other.$exclude_end$p()) ? (this.begin).$eq$(other.$begin()) : __a), __a !== false && __a !== nil ? (this.end).$eq$(other.$end()) : __a);
    };

    // line 3689, (corelib), Range#===
    Range_prototype.$eqq$ = function(obj) {
      
      return obj >= this.begin && obj <= this.end;
    };

    // line 3693, (corelib), Range#begin
    Range_prototype.$begin = function() {
      
      return this.begin;
    };

    // line 3697, (corelib), Range#cover?
    Range_prototype.$cover$p = function(value) {
      var __a, __b, __c;
      return (__a = (this.begin).$le$(value) ? value.$le$((function() { if ((__b = this.$exclude_end$p()) !== false && __b !== nil) {
        return (__b = this.end, __c = 1, typeof(__b) === 'number' ? __b - __c : __b.$minus$(__c))
        } else {
        return this.end;
      }; return nil; }).call(this)) : __a);
    };

    // line 3701, (corelib), Range#each
    Range_prototype.$each = TMP_70 = function() {
      var current = nil, __a, __b, __context, __yield;
      __yield = TMP_70._p || nil, __context = __yield._s, TMP_70._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each")
      };
      current = this.$min();
      while ((__b = !current.$eq$(this.$max())) !== false && __b !== nil){if (__yield.call(__context, current) === __breaker) return __breaker.$v;
      current = current.$succ();};
      if ((__a = this.$exclude_end$p()) === false || __a === nil) {
        if (__yield.call(__context, current) === __breaker) return __breaker.$v
      };
      return this;
    };

    // line 3717, (corelib), Range#end
    Range_prototype.$end = function() {
      
      return this.end;
    };

    // line 3721, (corelib), Range#eql?
    Range_prototype.$eql$p = function(other) {
      var __a;
      if ((__a = __scope.Range.$eqq$(other)) === false || __a === nil) {
        return false
      };
      return (__a = (__a = this.$exclude_end$p().$eq$(other.$exclude_end$p()) ? (this.begin).$eql$p(other.$begin()) : __a), __a !== false && __a !== nil ? (this.end).$eql$p(other.$end()) : __a);
    };

    // line 3727, (corelib), Range#exclude_end?
    Range_prototype.$exclude_end$p = function() {
      
      return this.exclude;
    };

    // line 3732, (corelib), Range#include?
    Range_prototype.$include$p = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };

    Range_prototype.$max = Range_prototype.$end;

    Range_prototype.$min = Range_prototype.$begin;

    Range_prototype.$member$p = Range_prototype.$include$p;

    // line 3742, (corelib), Range#step
    Range_prototype.$step = TMP_71 = function(n) {
      var __context, __yield;
      __yield = TMP_71._p || nil, __context = __yield._s, TMP_71._p = null;
      if (n == null) {
        n = 1
      }
      if (__yield === nil) {
        return this.$enum_for("step", n)
      };
      return this.$raise(__scope.NotImplementedError);
    };

    // line 3748, (corelib), Range#to_s
    Range_prototype.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };

    // line 3752, (corelib), Range#inspect
    Range_prototype.$inspect = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
    ;Range._donate(["$initialize", "$eq$", "$eqq$", "$begin", "$cover$p", "$each", "$end", "$eql$p", "$exclude_end$p", "$include$p", "$max", "$min", "$member$p", "$step", "$to_s", "$inspect"]);
  })(self, null);
  (function(__base, __super){
    // line 3756, (corelib), class Exception
    function Exception() {};
    Exception = __klass(__base, __super, "Exception", Exception);
    var Exception_prototype = Exception.prototype, __scope = Exception._scope;
    Exception_prototype.message = nil;

    // line 3757, (corelib), Exception#message
    Exception_prototype.$message = function() {
      
      return this.message
    };

    // line 3759, (corelib), Exception#initialize
    Exception_prototype.$initialize = function(message) {
      if (message == null) {
        message = ""
      }
      return this.message = message;
    };

    // line 3763, (corelib), Exception#backtrace
    Exception_prototype.$backtrace = function() {
      
      
      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\n");
      }
      else if (backtrace) {
        return backtrace;
      }

      return ["No backtrace available"];
    
    };

    // line 3778, (corelib), Exception#inspect
    Exception_prototype.$inspect = function() {
      
      return "#<" + (this.$class()) + ": '" + (this.$message()) + "'>";
    };

    Exception_prototype.$to_s = Exception_prototype.$message;
    ;Exception._donate(["$message", "$initialize", "$backtrace", "$inspect", "$to_s"]);
  })(self, Error);
  __scope.StandardError = __scope.Exception;
  __scope.RuntimeError = __scope.Exception;
  __scope.LocalJumpError = __scope.Exception;
  __scope.TypeError = __scope.Exception;
  __scope.NameError = __scope.Exception;
  __scope.NoMethodError = __scope.Exception;
  __scope.ArgumentError = __scope.Exception;
  __scope.IndexError = __scope.Exception;
  __scope.KeyError = __scope.Exception;
  __scope.RangeError = __scope.Exception;
  (function(__base, __super){
    // line 3795, (corelib), class Regexp
    function Regexp() {};
    Regexp = __klass(__base, __super, "Regexp", Regexp);
    var Regexp_prototype = Regexp.prototype, __scope = Regexp._scope;

    // line 3796, (corelib), Regexp.escape
    Regexp.$escape = function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    };

    // line 3800, (corelib), Regexp.new
    Regexp.$new = function(string, options) {
      
      return new RegExp(string, options);
    };

    // line 3804, (corelib), Regexp#==
    Regexp_prototype.$eq$ = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };

    // line 3808, (corelib), Regexp#===
    Regexp_prototype.$eqq$ = function(obj) {
      
      return this.test(obj);
    };

    // line 3812, (corelib), Regexp#=~
    Regexp_prototype.$match$ = function(string) {
      
      
      var result = this.exec(string);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._real    = result._klass = __scope.MatchData;

        __gvars["~"] = result;
      }
      else {
        __gvars["~"] = nil;
      }

      return result ? result.index : nil;
    
    };

    Regexp_prototype.$eql$p = Regexp_prototype.$eq$;

    // line 3833, (corelib), Regexp#inspect
    Regexp_prototype.$inspect = function() {
      
      return this.toString();
    };

    // line 3837, (corelib), Regexp#match
    Regexp_prototype.$match = function(pattern) {
      
      
      var result  = this.exec(pattern);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._real    = result._klass = __scope.MatchData;

        return __gvars["~"] = result;
      }
      else {
        return __gvars["~"] = nil;
      }
    
    };

    // line 3854, (corelib), Regexp#to_s
    Regexp_prototype.$to_s = function() {
      
      return this.source;
    };

    
    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }

    function match_to_s() {
      return this[0];
    }
  
    ;Regexp._donate(["$eq$", "$eqq$", "$match$", "$eql$p", "$inspect", "$match", "$to_s"]);    ;Regexp._sdonate(["$escape", "$new"]);
  })(self, RegExp);
  (function(__base, __super){
    // line 3869, (corelib), class MatchData
    function MatchData() {};
    MatchData = __klass(__base, __super, "MatchData", MatchData);
    var MatchData_prototype = MatchData.prototype, __scope = MatchData._scope;

    nil

  })(self, null);
  (function(__base, __super){
    // line 3871, (corelib), class Time
    function Time() {};
    Time = __klass(__base, __super, "Time", Time);
    var Time_prototype = Time.prototype, __scope = Time._scope;

    Time.$include(__scope.Comparable);

    // line 3874, (corelib), Time.at
    Time.$at = function(seconds, frac) {
      if (frac == null) {
        frac = 0
      }
      return this.$allocate(seconds * 1000 + frac)
    };

    // line 3878, (corelib), Time.new
    Time.$new = function(year, month, day, hour, minute, second, millisecond) {
      
      
      switch (arguments.length) {
        case 1:
          return new Date(year);
        case 2:
          return new Date(year, month - 1);
        case 3:
          return new Date(year, month - 1, day);
        case 4:
          return new Date(year, month - 1, day, hour);
        case 5:
          return new Date(year, month - 1, day, hour, minute);
        case 6:
          return new Date(year, month - 1, day, hour, minute, second);
        case 7:
          return new Date(year, month - 1, day, hour, minute, second, millisecond);
        default:
          return new Date();
      }
    
    };

    // line 3901, (corelib), Time.now
    Time.$now = function() {
      
      return this.$allocate()
    };

    // line 3905, (corelib), Time#+
    Time_prototype.$plus$ = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a + __b : __a.$plus$(__b)));
    };

    // line 3909, (corelib), Time#-
    Time_prototype.$minus$ = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a - __b : __a.$minus$(__b)));
    };

    // line 3913, (corelib), Time#<=>
    Time_prototype.$cmp$ = function(other) {
      
      return this.$to_f().$cmp$(other.$to_f());
    };

    // line 3917, (corelib), Time#day
    Time_prototype.$day = function() {
      
      return this.getDate();
    };

    // line 3921, (corelib), Time#eql?
    Time_prototype.$eql$p = function(other) {
      var __a;
      return (__a = other.$is_a$p(__scope.Time), __a !== false && __a !== nil ? this.$cmp$(other).$zero$p() : __a);
    };

    // line 3925, (corelib), Time#friday?
    Time_prototype.$friday$p = function() {
      
      return this.getDay() === 5;
    };

    // line 3929, (corelib), Time#hour
    Time_prototype.$hour = function() {
      
      return this.getHours();
    };

    Time_prototype.$mday = Time_prototype.$day;

    // line 3935, (corelib), Time#min
    Time_prototype.$min = function() {
      
      return this.getMinutes();
    };

    // line 3939, (corelib), Time#mon
    Time_prototype.$mon = function() {
      
      return this.getMonth() + 1;
    };

    // line 3943, (corelib), Time#monday?
    Time_prototype.$monday$p = function() {
      
      return this.getDay() === 1;
    };

    Time_prototype.$month = Time_prototype.$mon;

    // line 3949, (corelib), Time#saturday?
    Time_prototype.$saturday$p = function() {
      
      return this.getDay() === 6;
    };

    // line 3953, (corelib), Time#sec
    Time_prototype.$sec = function() {
      
      return this.getSeconds();
    };

    // line 3957, (corelib), Time#sunday?
    Time_prototype.$sunday$p = function() {
      
      return this.getDay() === 0;
    };

    // line 3961, (corelib), Time#thursday?
    Time_prototype.$thursday$p = function() {
      
      return this.getDay() === 4;
    };

    // line 3965, (corelib), Time#to_f
    Time_prototype.$to_f = function() {
      
      return this.getTime() / 1000;
    };

    // line 3969, (corelib), Time#to_i
    Time_prototype.$to_i = function() {
      
      return parseInt(this.getTime() / 1000);
    };

    // line 3973, (corelib), Time#tuesday?
    Time_prototype.$tuesday$p = function() {
      
      return this.getDay() === 2;
    };

    // line 3977, (corelib), Time#wday
    Time_prototype.$wday = function() {
      
      return this.getDay();
    };

    // line 3981, (corelib), Time#wednesday?
    Time_prototype.$wednesday$p = function() {
      
      return this.getDay() === 3;
    };

    // line 3985, (corelib), Time#year
    Time_prototype.$year = function() {
      
      return this.getFullYear();
    };
    ;Time._donate(["$plus$", "$minus$", "$cmp$", "$day", "$eql$p", "$friday$p", "$hour", "$mday", "$min", "$mon", "$monday$p", "$month", "$saturday$p", "$sec", "$sunday$p", "$thursday$p", "$to_f", "$to_i", "$tuesday$p", "$wday", "$wednesday$p", "$year"]);    ;Time._sdonate(["$at", "$new", "$now"]);
  })(self, Date);
  (function(__base, __super){
    // line 3989, (corelib), class Struct
    function Struct() {};
    Struct = __klass(__base, __super, "Struct", Struct);
    var Struct_prototype = Struct.prototype, __scope = Struct._scope, TMP_72, TMP_73, TMP_74;
    Struct_prototype.members = nil;

    // line 3990, (corelib), Struct.new
    Struct.$new = TMP_72 = function(name, args) {
      var __a, __b;args = __slice.call(arguments, 1);
      if ((__a = this.$eq$(__scope.Struct)) === false || __a === nil) {
        return Struct._super.$new.apply(this, __slice.call(arguments))
      };
      if (name.$aref$(0).$eq$(name.$aref$(0).$upcase())) {
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

    // line 4004, (corelib), Struct.define_struct_attribute
    Struct.$define_struct_attribute = function(name) {
      var __a, __b;
      if (this.$eq$(__scope.Struct)) {
        this.$raise(__scope.ArgumentError, "you cannot define attributes to the Struct class")
      };
      this.$members().$lshft$(name);
      (__b = this, __b.$define_method._p = (__a = function() {

        
        
        return this.$instance_variable_get("@" + (name))
      }, __a._s = this, __a), __b.$define_method(name));
      return (__b = this, __b.$define_method._p = (__a = function(value) {

        
        if (value == null) value = nil;

        return this.$instance_variable_set("@" + (name), value)
      }, __a._s = this, __a), __b.$define_method("" + (name) + "="));
    };

    // line 4020, (corelib), Struct.members
    Struct.$members = function() {
      var __a;
      if (this.$eq$(__scope.Struct)) {
        this.$raise(__scope.ArgumentError, "the Struct class has no members")
      };
      return (__a = this.members, __a !== false && __a !== nil ? __a : this.members = []);
    };

    Struct.$include(__scope.Enumerable);

    // line 4030, (corelib), Struct#initialize
    Struct_prototype.$initialize = function(args) {
      var __a, __b;args = __slice.call(arguments, 0);
      return (__b = this.$members(), __b.$each_with_index._p = (__a = function(name, index) {

        
        if (name == null) name = nil;
if (index == null) index = nil;

        return this.$instance_variable_set("@" + (name), args.$aref$(index))
      }, __a._s = this, __a), __b.$each_with_index());
    };

    // line 4036, (corelib), Struct#members
    Struct_prototype.$members = function() {
      
      return this.$class().$members();
    };

    // line 4040, (corelib), Struct#[]
    Struct_prototype.$aref$ = function(name) {
      var __a;
      if ((__a = __scope.Integer.$eqq$(name)) !== false && __a !== nil) {
        if (name.$ge$(this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + (name) + " too large for struct(size:" + (this.$members().$size()) + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__a = this.$members().$include$p(name.$to_sym())) === false || __a === nil) {
          this.$raise(__scope.NameError, "no member '" + (name) + "' in struct")
        }
      };
      return this.$instance_variable_get("@" + (name));
    };

    // line 4052, (corelib), Struct#[]=
    Struct_prototype.$aset$ = function(name, value) {
      var __a;
      if ((__a = __scope.Integer.$eqq$(name)) !== false && __a !== nil) {
        if (name.$ge$(this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + (name) + " too large for struct(size:" + (this.$members().$size()) + ")")
        };
        name = this.$members().$aref$(name);
        } else {
        if ((__a = this.$members().$include$p(name.$to_sym())) === false || __a === nil) {
          this.$raise(__scope.NameError, "no member '" + (name) + "' in struct")
        }
      };
      return this.$instance_variable_set("@" + (name), value);
    };

    // line 4064, (corelib), Struct#each
    Struct_prototype.$each = TMP_73 = function() {
      var __a, __b, __context, __yield;
      __yield = TMP_73._p || nil, __context = __yield._s, TMP_73._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        var __a;
        if (name == null) name = nil;

        return __a = __yield.call(__context, this.$aref$(name)), __a === __breaker ? __breaker.$v : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 4070, (corelib), Struct#each_pair
    Struct_prototype.$each_pair = TMP_74 = function() {
      var __a, __b, __context, __yield;
      __yield = TMP_74._p || nil, __context = __yield._s, TMP_74._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each_pair")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        var __a;
        if (name == null) name = nil;

        return __a = __yield.call(__context, name, this.$aref$(name)), __a === __breaker ? __breaker.$v : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 4076, (corelib), Struct#eql?
    Struct_prototype.$eql$p = function(other) {
      var __a, __b, __c;
      return (__a = this.$hash().$eq$(other.$hash()) ? __a : (__c = other.$each_with_index(), __c.$all$p._p = (__b = function(object, index) {

        
        if (object == null) object = nil;
if (index == null) index = nil;

        return this.$aref$(this.$members().$aref$(index)).$eq$(object)
      }, __b._s = this, __b), __c.$all$p()));
    };

    // line 4082, (corelib), Struct#length
    Struct_prototype.$length = function() {
      
      return this.$members().$length();
    };

    Struct_prototype.$size = Struct_prototype.$length;

    // line 4088, (corelib), Struct#to_a
    Struct_prototype.$to_a = function() {
      var __a, __b;
      return (__b = this.$members(), __b.$map._p = (__a = function(name) {

        
        if (name == null) name = nil;

        return this.$aref$(name)
      }, __a._s = this, __a), __b.$map());
    };

    Struct_prototype.$values = Struct_prototype.$to_a;
    ;Struct._donate(["$initialize", "$members", "$aref$", "$aset$", "$each", "$each_pair", "$eql$p", "$length", "$size", "$to_a", "$values"]);    ;Struct._sdonate(["$new", "$define_struct_attribute", "$members"]);
  })(self, null);
  var json_parse = JSON.parse;
  return (function(__base){
    // line 4097, (corelib), module JSON
    function JSON() {};
    JSON = __module(__base, "JSON", JSON);
    var JSON_prototype = JSON.prototype, __scope = JSON._scope;

    // line 4098, (corelib), JSON.parse
    JSON.$parse = function(source) {
      
      return to_opal(json_parse(source));
    };

    
    function to_opal(value) {
      switch (typeof value) {
        case 'string':
          return value;

        case 'number':
          return value;

        case 'boolean':
          return !!value;

        case 'null':
          return nil;

        case 'object':
          if (!value) return nil;

          if (value._isArray) {
            var arr = [];

            for (var i = 0, ii = value.length; i < ii; i++) {
              arr.push(to_opal(value[i]));
            }

            return arr;
          }
          else {
            var hash = __hash(), v, map = hash.map;

            for (var k in value) {
              if (__hasOwn.call(value, k)) {
                v = to_opal(value[k]);
                map[k] = [k, v];
              }
            }
          }

          return hash;
      }
    };
  
        ;JSON._sdonate(["$parse"]);
  })(self);
})();
}).call(this);