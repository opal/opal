// Opal v0.3.22
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
    klass = boot_class(Module, constructor);
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

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._name         = id;
  constructor._super        = superklass;
  constructor._methods      = [];
  constructor._smethods     = [];
  constructor._isObject     = false;

  constructor._donate = __donate;
  constructor._sdonate = __sdonate;

  Opal[id] = constructor;

  return constructor;
};

// Create generic class with given superclass.
var boot_class = function(superklass, constructor) {
  var ctor = function() {};
      ctor.prototype = superklass.prototype;

  constructor.prototype = new ctor();
  var prototype = constructor.prototype;

  prototype._klass      = constructor;
  prototype.constructor = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._super        = superklass;
  constructor._methods      = [];
  constructor._isObject     = false;
  constructor._klass        = Class;
  constructor._donate       = __donate
  constructor._sdonate      = __sdonate;

  constructor['$==='] = module_eqq;
  constructor.$to_s = module_to_s;

  var smethods;

  smethods = superklass._smethods.slice();

  constructor._smethods = smethods;
  for (var i = 0, length = smethods.length; i < length; i++) {
    var m = smethods[i];
    constructor[m] = superklass[m];
  }

  return constructor;
};

var bridge_class = function(constructor) {
  constructor.prototype._klass = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._super        = Object;
  constructor._klass        = Class;
  constructor._methods      = [];
  constructor._smethods     = [];
  constructor._isObject     = false;

  constructor._donate = function(){};
  constructor._sdonate = __sdonate;

  constructor['$==='] = module_eqq;
  constructor.$to_s = module_to_s;

  var smethods = constructor._smethods = Module._methods.slice();
  for (var i = 0, length = smethods.length; i < length; i++) {
    var m = smethods[i];
    constructor[m] = Object[m];
  }

  bridged_classes.push(constructor);

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

// Implementation of Module#to_s
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

// Donator for singleton (class) methods
function __sdonate(defined) {
  this._smethods = this._smethods.concat(defined);
}

var bridged_classes = Object.$included_in = [];
BasicObject.$included_in = bridged_classes;

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
Opal.version = "0.3.22";
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __mm = __opal.mm, __gvars = __opal.gvars, __klass = __opal.klass, __module = __opal.module, __hash = __opal.hash;
  
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

    // line 13, (corelib), Module#alias_method
    Module_prototype.$alias_method = function(newname, oldname) {
      
      this.prototype['$' + newname] = this.prototype['$' + oldname];
      return this;
    };

    // line 18, (corelib), Module#ancestors
    Module_prototype.$ancestors = function() {
      
      
      var parent = this,
          result = [];

      while (parent) {
        result.push(parent);
        parent = parent._super;
      }

      return result;
    
    };

    // line 32, (corelib), Module#append_features
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
        klass.prototype['$' + name] = function() {
          var res = this[name];
          return res == null ? nil : res;
        };

        klass._donate([name]);
      }

      if (setter) {
        klass.prototype['$' + name + '='] = function(val) {
          return this[name] = val;
        };

        klass._donate([name]);
      }
    }
  

    // line 93, (corelib), Module#attr_accessor
    Module_prototype.$attr_accessor = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return nil;
    
    };

    // line 103, (corelib), Module#attr_reader
    Module_prototype.$attr_reader = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return nil;
    
    };

    // line 113, (corelib), Module#attr_writer
    Module_prototype.$attr_writer = function(attrs) {
      attrs = __slice.call(arguments, 0);
      
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return nil;
    
    };

    // line 123, (corelib), Module#attr
    Module_prototype.$attr = function(name, setter) {
      if (setter == null) {
        setter = false
      }
      define_attr(this, name, true, setter);
      return this;
    };

    // line 129, (corelib), Module#define_method
    Module_prototype.$define_method = TMP_1 = function(name) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      var jsid    = '$' + name;
      block._jsid = jsid;
      block._sup  = this.prototype[jsid];

      this.prototype[jsid] = block;
      this._donate([jsid]);

      return nil;
    
    };

    // line 146, (corelib), Module#include
    Module_prototype.$include = function(mods) {
      mods = __slice.call(arguments, 0);
      
      var i = mods.length - 1, mod;
      while (i >= 0) {
        mod = mods[i];
        i--;

        if (mod === this) {
          continue;
        }

        (mod).$append_features(this);
        (mod).$included(this);
      }

      return this;
    
    };

    // line 166, (corelib), Module#instance_methods
    Module_prototype.$instance_methods = function() {
      
      return [];
    };

    // line 170, (corelib), Module#included
    Module_prototype.$included = function(mod) {
      
      return nil;
    };

    // line 173, (corelib), Module#module_eval
    Module_prototype.$module_eval = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };

    Module_prototype.$class_eval = Module_prototype.$module_eval;

    // line 185, (corelib), Module#name
    Module_prototype.$name = function() {
      
      return this._name;
    };

    Module_prototype.$public_instance_methods = Module_prototype.$instance_methods;

    // line 191, (corelib), Module#singleton_class
    Module_prototype.$singleton_class = function() {
      
      
      if (this._singleton) {
        return this._singleton;
      }

      var meta = new __opal.Class;
      this._singleton = meta;
      meta.prototype = this;

      return meta;
    
    };
    ;Module._donate(["$alias_method", "$ancestors", "$append_features", "$attr_accessor", "$attr_reader", "$attr_writer", "$attr", "$define_method", "$include", "$instance_methods", "$included", "$module_eval", "$class_eval", "$name", "$public_instance_methods", "$singleton_class"]);
  })(self, null);
  (function(__base, __super){
    // line 205, (corelib), class Class
    function Class() {};
    Class = __klass(__base, __super, "Class", Class);
    var Class_prototype = Class.prototype, __scope = Class._scope, TMP_3, TMP_4;

    // line 206, (corelib), Class.new
    Class['$new'] = TMP_3 = function(sup) {
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

    // line 222, (corelib), Class#allocate
    Class_prototype.$allocate = function() {
      
      
      var obj = new this;
      obj._id = unique_id++;
      return obj;
    
    };

    // line 230, (corelib), Class#new
    Class_prototype['$new'] = TMP_4 = function(args) {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      args = __slice.call(arguments, 0);
      
      var obj = new this;
      obj._id = unique_id++;
      obj.$initialize._p  = block;

      obj.$initialize.apply(obj, args);
      return obj;
    
    };

    // line 241, (corelib), Class#inherited
    Class_prototype.$inherited = function(cls) {
      
      return nil;
    };

    // line 244, (corelib), Class#superclass
    Class_prototype.$superclass = function() {
      
      
      var sup = this._super;

      if (!sup) {
        return nil;
      }

      return sup;
    
    };
    ;Class._donate(["$allocate", "$new", "$inherited", "$superclass"]);    ;Class._sdonate(["$new"]);
  })(self, null);
  (function(__base, __super){
    // line 256, (corelib), class BasicObject
    function BasicObject() {};
    BasicObject = __klass(__base, __super, "BasicObject", BasicObject);
    var BasicObject_prototype = BasicObject.prototype, __scope = BasicObject._scope, TMP_5, TMP_6, TMP_7;

    // line 257, (corelib), BasicObject#initialize
    BasicObject_prototype.$initialize = function() {
      
      return nil;
    };

    // line 260, (corelib), BasicObject#==
    BasicObject_prototype['$=='] = function(other) {
      
      return this === other;
    };

    // line 264, (corelib), BasicObject#__send__
    BasicObject_prototype.$__send__ = TMP_5 = function(symbol, args) {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      args = __slice.call(arguments, 1);
      
      var meth = this['$' + symbol];

      if (!meth) {
        return this.$method_missing(symbol);
      }

      return meth.apply(this, args);
    
    };

    BasicObject_prototype.$send = BasicObject_prototype.$__send__;

    BasicObject_prototype['$eql?'] = BasicObject_prototype['$=='];

    BasicObject_prototype['$equal?'] = BasicObject_prototype['$=='];

    // line 281, (corelib), BasicObject#instance_eval
    BasicObject_prototype.$instance_eval = TMP_6 = function(string) {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };

    // line 291, (corelib), BasicObject#instance_exec
    BasicObject_prototype.$instance_exec = TMP_7 = function(args) {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      args = __slice.call(arguments, 0);
      
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    
    };

    // line 301, (corelib), BasicObject#method_missing
    BasicObject_prototype.$method_missing = function(symbol, args) {
      args = __slice.call(arguments, 1);
      return this.$raise(__scope.NoMethodError, "undefined method `" + (symbol) + "` for " + (this.$inspect()));
    };
    ;BasicObject._donate(["$initialize", "$==", "$__send__", "$send", "$eql?", "$equal?", "$instance_eval", "$instance_exec", "$method_missing"]);
  })(self, null);
  (function(__base){
    // line 305, (corelib), module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12;

    // line 306, (corelib), Kernel#=~
    Kernel_prototype['$=~'] = function(obj) {
      
      return false;
    };

    // line 310, (corelib), Kernel#==
    Kernel_prototype['$=='] = function(other) {
      
      return this === other;
    };

    // line 314, (corelib), Kernel#===
    Kernel_prototype['$==='] = function(other) {
      
      return this == other;
    };

    // line 318, (corelib), Kernel#Array
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

    // line 340, (corelib), Kernel#class
    Kernel_prototype['$class'] = function() {
      
      return this._klass;
    };

    // line 344, (corelib), Kernel#define_singleton_method
    Kernel_prototype.$define_singleton_method = TMP_8 = function(name) {
      var __context, body;
      body = TMP_8._p || nil, __context = body._s, TMP_8._p = null;
      
      
      if (body === nil) {
        no_block_given();
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = this[jsid]

      this[jsid] = body;

      return this;
    
    };

    // line 360, (corelib), Kernel#equal?
    Kernel_prototype['$equal?'] = function(other) {
      
      return this === other;
    };

    // line 364, (corelib), Kernel#extend
    Kernel_prototype.$extend = function(mods) {
      mods = __slice.call(arguments, 0);
      
      for (var i = 0, length = mods.length; i < length; i++) {
        this.$singleton_class().$include(mods[i]);
      }

      return this;
    
    };

    // line 374, (corelib), Kernel#hash
    Kernel_prototype.$hash = function() {
      
      return this._id;
    };

    // line 378, (corelib), Kernel#inspect
    Kernel_prototype.$inspect = function() {
      
      return this.$to_s();
    };

    // line 382, (corelib), Kernel#instance_of?
    Kernel_prototype['$instance_of?'] = function(klass) {
      
      return this._klass === klass;
    };

    // line 386, (corelib), Kernel#instance_variable_defined?
    Kernel_prototype['$instance_variable_defined?'] = function(name) {
      
      return __hasOwn.call(this, name.substr(1));
    };

    // line 390, (corelib), Kernel#instance_variable_get
    Kernel_prototype.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == null ? nil : ivar;
    
    };

    // line 398, (corelib), Kernel#instance_variable_set
    Kernel_prototype.$instance_variable_set = function(name, value) {
      
      return this[name.substr(1)] = value;
    };

    // line 402, (corelib), Kernel#instance_variables
    Kernel_prototype.$instance_variables = function() {
      
      
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    
    };

    // line 414, (corelib), Kernel#is_a?
    Kernel_prototype['$is_a?'] = function(klass) {
      
      
      var search = this._klass;

      while (search) {
        if (search === klass) {
          return true;
        }

        search = search._super;
      }

      return false;
    
    };

    Kernel_prototype['$kind_of?'] = Kernel_prototype['$is_a?'];

    // line 432, (corelib), Kernel#lambda
    Kernel_prototype.$lambda = TMP_9 = function() {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      return block;
    };

    // line 436, (corelib), Kernel#loop
    Kernel_prototype.$loop = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      if (block === nil) {
        return this.$enum_for("loop")
      };
      while (true) {;
      if (block.call(__context) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 446, (corelib), Kernel#nil?
    Kernel_prototype['$nil?'] = function() {
      
      return false;
    };

    // line 450, (corelib), Kernel#object_id
    Kernel_prototype.$object_id = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 454, (corelib), Kernel#proc
    Kernel_prototype.$proc = TMP_11 = function() {
      var __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }
      block.is_lambda = false;
      return block;
    
    };

    // line 464, (corelib), Kernel#puts
    Kernel_prototype.$puts = function(strs) {
      strs = __slice.call(arguments, 0);
      
      for (var i = 0; i < strs.length; i++) {
        console.log((strs[i]).$to_s());
      }
    
      return nil;
    };

    Kernel_prototype.$print = Kernel_prototype.$puts;

    // line 475, (corelib), Kernel#raise
    Kernel_prototype.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = __scope.RuntimeError['$new'](exception);
      }
      else if (!exception['$is_a?'](__scope.Exception)) {
        exception = exception['$new'](string);
      }

      throw exception;
    
    };

    // line 488, (corelib), Kernel#rand
    Kernel_prototype.$rand = function(max) {
      
      return max == null ? Math.random() : Math.floor(Math.random() * max);
    };

    // line 492, (corelib), Kernel#respond_to?
    Kernel_prototype['$respond_to?'] = function(name) {
      
      return !!this['$' + name];
    };

    // line 496, (corelib), Kernel#singleton_class
    Kernel_prototype.$singleton_class = function() {
      
      
      if (!this._isObject) {
        return this._klass;
      }

      if (this._singleton) {
        return this._singleton;
      }

      else {
        var orig_class = this._klass,
            class_id   = "#<Class:#<" + orig_class._name + ":" + orig_class._id + ">>";

        function Singleton() {};
        var meta = boot_class(orig_class, Singleton);
        meta._name = class_id;

        meta.prototype = this;
        this._singleton = meta;
        meta._klass = orig_class._klass;

        return meta;
      }
    
    };

    // line 523, (corelib), Kernel#tap
    Kernel_prototype.$tap = TMP_12 = function() {
      var __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      if (block === nil) no_block_given();
      if (block.call(__context, this) === __breaker) return __breaker.$v;
      return this;
    };

    // line 530, (corelib), Kernel#to_json
    Kernel_prototype.$to_json = function() {
      
      return this.$to_s().$to_json();
    };

    // line 534, (corelib), Kernel#to_proc
    Kernel_prototype.$to_proc = function() {
      
      return this;
    };

    // line 538, (corelib), Kernel#to_s
    Kernel_prototype.$to_s = function() {
      
      return "#<" + this._klass._name + ":" + this._id + ">";
    };

    // line 542, (corelib), Kernel#enum_for
    Kernel_prototype.$enum_for = function(method, args) {
      var __a;if (method == null) {
        method = "each"
      }args = __slice.call(arguments, 1);
      return (__a = __scope.Enumerator)['$new'].apply(__a, [this, method].concat(args));
    };

    Kernel_prototype.$to_enum = Kernel_prototype.$enum_for;
        ;Kernel._donate(["$=~", "$==", "$===", "$Array", "$class", "$define_singleton_method", "$equal?", "$extend", "$hash", "$inspect", "$instance_of?", "$instance_variable_defined?", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a?", "$kind_of?", "$lambda", "$loop", "$nil?", "$object_id", "$proc", "$puts", "$print", "$raise", "$rand", "$respond_to?", "$singleton_class", "$tap", "$to_json", "$to_proc", "$to_s", "$enum_for", "$to_enum"]);
  })(self);
  (function(__base, __super){
    // line 548, (corelib), class Object
    function Object() {};
    Object = __klass(__base, __super, "Object", Object);
    var Object_prototype = Object.prototype, __scope = Object._scope;

    Object.$include(__scope.Kernel);

    // line 552, (corelib), Object#methods
    Object_prototype.$methods = function() {
      
      return [];
    };

    Object_prototype.$private_methods = Object_prototype.$methods;

    Object_prototype.$protected_methods = Object_prototype.$methods;

    Object_prototype.$public_methods = Object_prototype.$methods;

    // line 561, (corelib), Object#singleton_methods
    Object_prototype.$singleton_methods = function() {
      
      return [];
    };

    Object_prototype.$__send__ = Object_prototype.$__send__;

    Object_prototype.$send = Object_prototype.$send;
    ;Object._donate(["$methods", "$private_methods", "$protected_methods", "$public_methods", "$singleton_methods", "$__send__", "$send"]);
  })(self, null);
  self.$to_s = function() {
    
    return "main"
  };
  self.$include = function(mod) {
    
    return __scope.Object.$include(mod)
  };
  (function(__base, __super){
    // line 576, (corelib), class Boolean
    function Boolean() {};
    Boolean = __klass(__base, __super, "Boolean", Boolean);
    var Boolean_prototype = Boolean.prototype, __scope = Boolean._scope;

    
    Boolean_prototype._isBoolean = true;
  

    // line 581, (corelib), Boolean#&
    Boolean_prototype['$&'] = function(other) {
      
      return (this == true) ? (other !== false && other !== nil) : false;
    };

    // line 585, (corelib), Boolean#|
    Boolean_prototype['$|'] = function(other) {
      
      return (this == true) ? true : (other !== false && other !== nil);
    };

    // line 589, (corelib), Boolean#^
    Boolean_prototype['$^'] = function(other) {
      
      return (this == true) ? (other === false || other === nil) : (other !== false && other !== nil);
    };

    // line 593, (corelib), Boolean#==
    Boolean_prototype['$=='] = function(other) {
      
      return (this == true) === other.valueOf();
    };

    Boolean_prototype.$singleton_class = Boolean_prototype['$class'];

    // line 599, (corelib), Boolean#to_json
    Boolean_prototype.$to_json = function() {
      
      return this.valueOf() ? 'true' : 'false';
    };

    // line 603, (corelib), Boolean#to_s
    Boolean_prototype.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };
    ;Boolean._donate(["$&", "$|", "$^", "$==", "$singleton_class", "$to_json", "$to_s"]);
  })(self, Boolean);
  __scope.TRUE = true;
  __scope.FALSE = false;
  (function(__base, __super){
    // line 610, (corelib), class NilClass
    function NilClass() {};
    NilClass = __klass(__base, __super, "NilClass", NilClass);
    var NilClass_prototype = NilClass.prototype, __scope = NilClass._scope;

    // line 611, (corelib), NilClass#&
    NilClass_prototype['$&'] = function(other) {
      
      return false;
    };

    // line 615, (corelib), NilClass#|
    NilClass_prototype['$|'] = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 619, (corelib), NilClass#^
    NilClass_prototype['$^'] = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 623, (corelib), NilClass#==
    NilClass_prototype['$=='] = function(other) {
      
      return other === nil;
    };

    // line 627, (corelib), NilClass#inspect
    NilClass_prototype.$inspect = function() {
      
      return "nil";
    };

    // line 631, (corelib), NilClass#nil?
    NilClass_prototype['$nil?'] = function() {
      
      return true;
    };

    // line 635, (corelib), NilClass#singleton_class
    NilClass_prototype.$singleton_class = function() {
      
      return __scope.NilClass;
    };

    // line 639, (corelib), NilClass#to_a
    NilClass_prototype.$to_a = function() {
      
      return [];
    };

    // line 643, (corelib), NilClass#to_i
    NilClass_prototype.$to_i = function() {
      
      return 0;
    };

    NilClass_prototype.$to_f = NilClass_prototype.$to_i;

    // line 649, (corelib), NilClass#to_json
    NilClass_prototype.$to_json = function() {
      
      return "null";
    };

    // line 653, (corelib), NilClass#to_s
    NilClass_prototype.$to_s = function() {
      
      return "";
    };
    ;NilClass._donate(["$&", "$|", "$^", "$==", "$inspect", "$nil?", "$singleton_class", "$to_a", "$to_i", "$to_f", "$to_json", "$to_s"]);
  })(self, null);
  __scope.NIL = nil;
  (function(__base){
    // line 659, (corelib), module Enumerable
    function Enumerable() {};
    Enumerable = __module(__base, "Enumerable", Enumerable);
    var Enumerable_prototype = Enumerable.prototype, __scope = Enumerable._scope, TMP_13, TMP_14, TMP_15, TMP_16, TMP_17, TMP_18, TMP_19, TMP_20, TMP_21, TMP_22, TMP_23;

    // line 660, (corelib), Enumerable#all?
    Enumerable_prototype['$all?'] = TMP_13 = function() {
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

    // line 698, (corelib), Enumerable#any?
    Enumerable_prototype['$any?'] = TMP_14 = function() {
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

    // line 736, (corelib), Enumerable#collect
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

    // line 759, (corelib), Enumerable#count
    Enumerable_prototype.$count = TMP_16 = function(object) {
      var __context, block;
      block = TMP_16._p || nil, __context = block._s, TMP_16._p = null;
      
      
      var result = 0;

      if (object != null) {
        block = function(obj) { return (obj)['$=='](object); };
      }
      else if (block === nil) {
        block = function() { return true; };
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

    // line 789, (corelib), Enumerable#detect
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

    // line 824, (corelib), Enumerable#drop
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

    // line 843, (corelib), Enumerable#drop_while
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

        if (value === false || value === nil) {
          result.push(obj);
          return value;
        }
        
        
        return __breaker;
      };

      this.$each();

      return result;
    
    };

    // line 871, (corelib), Enumerable#each_with_index
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

    // line 893, (corelib), Enumerable#each_with_object
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

    // line 911, (corelib), Enumerable#entries
    Enumerable_prototype.$entries = function() {
      
      
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    
    };

    Enumerable_prototype.$find = Enumerable_prototype.$detect;

    // line 927, (corelib), Enumerable#find_all
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
          result.push(obj);
        }
      };

      this.$each();

      return result;
    
    };

    // line 951, (corelib), Enumerable#find_index
    Enumerable_prototype.$find_index = TMP_22 = function(object) {
      var __context, block;
      block = TMP_22._p || nil, __context = block._s, TMP_22._p = null;
      
      
      var proc, result = nil, index = 0;

      if (object != null) {
        proc = function (obj) { 
          if ((obj)['$=='](object)) {
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

    // line 991, (corelib), Enumerable#first
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

    // line 1021, (corelib), Enumerable#grep
    Enumerable_prototype.$grep = TMP_23 = function(pattern) {
      var __context, block;
      block = TMP_23._p || nil, __context = block._s, TMP_23._p = null;
      
      
      var result = [];

      this.$each._p = (block !== nil
        ? function(obj) {
            var value = pattern['$==='](obj);

            if (value !== false && value !== nil) {
              if ((value = block.call(__context, obj)) === __breaker) {
                return __breaker.$v;
              }

              result.push(value);
            }
          }
        : function(obj) {
            var value = pattern['$==='](obj);

            if (value !== false && value !== nil) {
              result.push(obj);
            }
          });

      this.$each();

      return result;
    
    };

    Enumerable_prototype.$take = Enumerable_prototype.$first;

    Enumerable_prototype.$to_a = Enumerable_prototype.$entries;
        ;Enumerable._donate(["$all?", "$any?", "$collect", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$each_with_object", "$entries", "$find", "$find_all", "$find_index", "$first", "$grep", "$take", "$to_a"]);
  })(self);
  (function(__base, __super){
    // line 1055, (corelib), class Enumerator
    function Enumerator() {};
    Enumerator = __klass(__base, __super, "Enumerator", Enumerator);
    var Enumerator_prototype = Enumerator.prototype, __scope = Enumerator._scope, TMP_25, TMP_26, TMP_27, TMP_28, TMP_29;
    Enumerator_prototype.cache = Enumerator_prototype.current = Enumerator_prototype.object = Enumerator_prototype.method = Enumerator_prototype.args = nil;

    Enumerator.$include(__scope.Enumerable);

    (function(__base, __super){
      // line 1058, (corelib), class Yielder
      function Yielder() {};
      Yielder = __klass(__base, __super, "Yielder", Yielder);
      var Yielder_prototype = Yielder.prototype, __scope = Yielder._scope;
      Yielder_prototype.block = Yielder_prototype.call = nil;

      // line 1059, (corelib), Yielder#initialize
      Yielder_prototype.$initialize = function(block) {
        
        return this.block = block;
      };

      // line 1063, (corelib), Yielder#call
      Yielder_prototype.$call = function(block) {
        
        this.call = block;
        return this.block.$call();
      };

      // line 1069, (corelib), Yielder#yield
      Yielder_prototype.$yield = function(value) {
        
        return this.call.$call(value);
      };

      Yielder_prototype['$<<'] = Yielder_prototype.$yield;
      ;Yielder._donate(["$initialize", "$call", "$yield", "$<<"]);
    })(Enumerator, null);

    (function(__base, __super){
      // line 1076, (corelib), class Generator
      function Generator() {};
      Generator = __klass(__base, __super, "Generator", Generator);
      var Generator_prototype = Generator.prototype, __scope = Generator._scope, TMP_24;
      Generator_prototype.enumerator = Generator_prototype.yielder = nil;

      // line 1077, (corelib), Generator#enumerator
      Generator_prototype.$enumerator = function() {
        
        return this.enumerator
      };

      // line 1079, (corelib), Generator#initialize
      Generator_prototype.$initialize = function(block) {
        
        return this.yielder = __scope.Yielder['$new'](block);
      };

      // line 1083, (corelib), Generator#each
      Generator_prototype.$each = TMP_24 = function() {
        var __context, block;
        block = TMP_24._p || nil, __context = block._s, TMP_24._p = null;
        
        return this.yielder.$call(block);
      };
      ;Generator._donate(["$enumerator", "$initialize", "$each"]);
    })(Enumerator, null);

    // line 1088, (corelib), Enumerator#initialize
    Enumerator_prototype.$initialize = TMP_25 = function(object, method, args) {
      var __a, __context, block;
      block = TMP_25._p || nil, __context = block._s, TMP_25._p = null;
      if (object == null) {
        object = nil
      }if (method == null) {
        method = "each"
      }args = __slice.call(arguments, 2);
      if ((block !== nil)) {
        this.object = __scope.Generator['$new'](block)
      };
      if ((__a = object) === false || __a === nil) {
        this.$raise(__scope.ArgumentError, "wrong number of argument (0 for 1+)")
      };
      this.object = object;
      this.method = method;
      return this.args = args;
    };

    // line 1100, (corelib), Enumerator#next
    Enumerator_prototype.$next = function() {
      var result = nil, __a;
      this.$_init_cache();
      ((__a = result = this.cache['$[]'](this.current)), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
      this.current = this.current['$+'](1);
      return result;
    };

    // line 1109, (corelib), Enumerator#next_values
    Enumerator_prototype.$next_values = function() {
      var result = nil, __a;
      result = this.$next();
      if ((__a = result['$is_a?'](__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };

    // line 1115, (corelib), Enumerator#peek
    Enumerator_prototype.$peek = function() {
      var __a;
      this.$_init_cache();
      return ((__a = this.cache['$[]'](this.current)), __a !== false && __a !== nil ? __a : this.$raise(__scope.StopIteration, "iteration reached an end"));
    };

    // line 1121, (corelib), Enumerator#peel_values
    Enumerator_prototype.$peel_values = function() {
      var result = nil, __a;
      result = this.$peek();
      if ((__a = result['$is_a?'](__scope.Array)) !== false && __a !== nil) {
        return result
        } else {
        return [result]
      };
    };

    // line 1127, (corelib), Enumerator#rewind
    Enumerator_prototype.$rewind = function() {
      
      return this.$_clear_cache();
    };

    // line 1131, (corelib), Enumerator#each
    Enumerator_prototype.$each = TMP_26 = function() {
      var __a, __context, block;
      block = TMP_26._p || nil, __context = block._s, TMP_26._p = null;
      
      if (block === nil) {
        return this
      };
      return (__a = this.object, __a.$__send__._p = block.$to_proc(), __a.$__send__.apply(null, [this.method].concat(this.args)));
    };

    // line 1137, (corelib), Enumerator#each_with_index
    Enumerator_prototype.$each_with_index = TMP_27 = function() {
      var __a, __context, block;
      block = TMP_27._p || nil, __context = block._s, TMP_27._p = null;
      
      return (__a = this, __a.$with_index._p = block.$to_proc(), __a.$with_index());
    };

    // line 1141, (corelib), Enumerator#with_index
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
        if ((__a = current['$>='](offset)) === false || __a === nil) {
          return nil;
        };
        if (__yield.apply(__context, [].concat(args).concat([["current"]])) === __breaker) return __breaker.$v;
        return current = current['$+'](1);
      }, __a._s = this, __a), __b.$each());
    };

    // line 1155, (corelib), Enumerator#with_object
    Enumerator_prototype.$with_object = TMP_29 = function(object) {
      var __a, __b, __context, __yield;
      __yield = TMP_29._p || nil, __context = __yield._s, TMP_29._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("with_object", object)
      };
      return (__b = this, __b.$each._p = (__a = function(args) {

        var __a;
        args = __slice.call(arguments, 0);
        return __a = __yield.apply(__context, [].concat(args).concat([["object"]])), __a === __breaker ? __a : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 1163, (corelib), Enumerator#_init_cache
    Enumerator_prototype.$_init_cache = function() {
      var __a;
      ((__a = this.current), __a !== false && __a !== nil ? __a : this.current = 0);
      return ((__a = this.cache), __a !== false && __a !== nil ? __a : this.cache = this.$to_a());
    };

    // line 1168, (corelib), Enumerator#_clear_cache
    Enumerator_prototype.$_clear_cache = function() {
      
      this.cache = nil;
      return this.current = nil;
    };
    ;Enumerator._donate(["$initialize", "$next", "$next_values", "$peek", "$peel_values", "$rewind", "$each", "$each_with_index", "$with_index", "$with_object", "$_init_cache", "$_clear_cache"]);
  })(self, null);
  (function(__base){
    // line 1173, (corelib), module Comparable
    function Comparable() {};
    Comparable = __module(__base, "Comparable", Comparable);
    var Comparable_prototype = Comparable.prototype, __scope = Comparable._scope;

    // line 1174, (corelib), Comparable#<
    Comparable_prototype['$<'] = function(other) {
      
      return this['$<=>'](other)['$=='](-1);
    };

    // line 1178, (corelib), Comparable#<=
    Comparable_prototype['$<='] = function(other) {
      
      return this['$<=>'](other)['$<='](0);
    };

    // line 1182, (corelib), Comparable#==
    Comparable_prototype['$=='] = function(other) {
      
      return this['$<=>'](other)['$=='](0);
    };

    // line 1186, (corelib), Comparable#>
    Comparable_prototype['$>'] = function(other) {
      
      return this['$<=>'](other)['$=='](1);
    };

    // line 1190, (corelib), Comparable#>=
    Comparable_prototype['$>='] = function(other) {
      
      return this['$<=>'](other)['$>='](0);
    };

    // line 1194, (corelib), Comparable#between?
    Comparable_prototype['$between?'] = function(min, max) {
      var __a;
      return ((__a = this['$>'](min)) ? this['$<'](max) : __a);
    };
        ;Comparable._donate(["$<", "$<=", "$==", "$>", "$>=", "$between?"]);
  })(self);
  (function(__base, __super){
    // line 1198, (corelib), class Array
    function Array() {};
    Array = __klass(__base, __super, "Array", Array);
    var Array_prototype = Array.prototype, __scope = Array._scope, TMP_30, TMP_31, TMP_32, TMP_33, TMP_34, TMP_35, TMP_36, TMP_37, TMP_38, TMP_39, TMP_40, TMP_41, TMP_42, TMP_43, TMP_44, TMP_45, TMP_46, TMP_47, TMP_48;

    
    Array_prototype._isArray = true;
  

    Array.$include(__scope.Enumerable);

    // line 1205, (corelib), Array.[]
    Array['$[]'] = function(objects) {
      objects = __slice.call(arguments, 0);
      
      var result = this.$allocate();

      result.splice.apply(result, [0, 0].concat(objects));

      return result;
    
    };

    // line 1215, (corelib), Array.new
    Array['$new'] = function(size, obj) {
      var arr = nil;if (obj == null) {
        obj = nil
      }
      arr = this.$allocate();
      
      if (size && size._isArray) {
        for (var i = 0; i < size.length; i++) {
          arr[i] = size[i];
        }
      }
      else {
        for (var i = 0; i < size; i++) {
          arr[i] = obj;
        }
      }
    
      return arr;
    };

    // line 1234, (corelib), Array#&
    Array_prototype['$&'] = function(other) {
      
      
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

    // line 1259, (corelib), Array#*
    Array_prototype['$*'] = function(other) {
      
      
      if (typeof(other) === 'string') {
        return this.join(other);
      }

      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result = result.concat(this);
      }

      return result;
    
    };

    // line 1275, (corelib), Array#+
    Array_prototype['$+'] = function(other) {
      
      return this.slice().concat(other.slice());
    };

    // line 1279, (corelib), Array#-
    Array_prototype['$-'] = function(other) {
      var __a, __b;
      return (__b = this, __b.$reject._p = (__a = function(i) {

        
        if (i == null) i = nil;

        return other['$include?'](i)
      }, __a._s = this, __a), __b.$reject());
    };

    // line 1283, (corelib), Array#<<
    Array_prototype['$<<'] = function(object) {
      
      this.push(object);
      return this;
    };

    // line 1289, (corelib), Array#<=>
    Array_prototype['$<=>'] = function(other) {
      
      
      if (this.$hash() === other.$hash()) {
        return 0;
      }

      if (this.length != other.length) {
        return (this.length > other.length) ? 1 : -1;
      }

      for (var i = 0, length = this.length, tmp; i < length; i++) {
        if ((tmp = (this[i])['$<=>'](other[i])) !== 0) {
          return tmp;
        }
      }

      return 0;
    
    };

    // line 1309, (corelib), Array#==
    Array_prototype['$=='] = function(other) {
      
      
      if (!other || (this.length !== other.length)) {
        return false;
      }

      for (var i = 0, length = this.length; i < length; i++) {
        if (!(this[i])['$=='](other[i])) {
          return false;
        }
      }

      return true;
    
    };

    // line 1326, (corelib), Array#[]
    Array_prototype['$[]'] = function(index, length) {
      
      
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

    // line 1374, (corelib), Array#[]=
    Array_prototype['$[]='] = function(index, value) {
      
      
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    
    };

    // line 1386, (corelib), Array#assoc
    Array_prototype.$assoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && (item[0])['$=='](object)) {
          return item;
        }
      }

      return nil;
    
    };

    // line 1398, (corelib), Array#at
    Array_prototype.$at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    
    };

    // line 1412, (corelib), Array#clear
    Array_prototype.$clear = function() {
      
      this.splice(0);
      return this;
    };

    // line 1418, (corelib), Array#clone
    Array_prototype.$clone = function() {
      
      return this.slice();
    };

    // line 1422, (corelib), Array#collect
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

    // line 1440, (corelib), Array#collect!
    Array_prototype['$collect!'] = TMP_31 = function() {
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

    // line 1456, (corelib), Array#compact
    Array_prototype.$compact = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 1470, (corelib), Array#compact!
    Array_prototype['$compact!'] = function() {
      
      
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

    // line 1487, (corelib), Array#concat
    Array_prototype.$concat = function(other) {
      
      
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    
      return this;
    };

    // line 1497, (corelib), Array#count
    Array_prototype.$count = function(object) {
      
      
      if (object == null) {
        return this.length;
      }

      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i])['$=='](object)) {
          result++;
        }
      }

      return result;
    
    };

    // line 1515, (corelib), Array#delete
    Array_prototype['$delete'] = function(object) {
      
      
      var original = this.length;

      for (var i = 0, length = original; i < length; i++) {
        if ((this[i])['$=='](object)) {
          this.splice(i, 1);

          length--;
          i--;
        }
      }

      return this.length === original ? nil : object;
    
    };

    // line 1532, (corelib), Array#delete_at
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

    // line 1550, (corelib), Array#delete_if
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

    // line 1571, (corelib), Array#drop
    Array_prototype.$drop = function(number) {
      
      return this.slice(number);
    };

    // line 1575, (corelib), Array#drop_while
    Array_prototype.$drop_while = TMP_33 = function() {
      var __context, block;
      block = TMP_33._p || nil, __context = block._s, TMP_33._p = null;
      
      if (block === nil) {
        return this.$enum_for("drop_while")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          return this.slice(i);
        }
      }

      return [];
    
    };

    Array_prototype.$dup = Array_prototype.$clone;

    // line 1595, (corelib), Array#each
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

    // line 1605, (corelib), Array#each_index
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

    // line 1615, (corelib), Array#each_with_index
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

    // line 1625, (corelib), Array#empty?
    Array_prototype['$empty?'] = function() {
      
      return !this.length;
    };

    // line 1629, (corelib), Array#fetch
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
        return block(__context, original);
      }

      this.$raise("Array#fetch");
    
    };

    // line 1653, (corelib), Array#first
    Array_prototype.$first = function(count) {
      
      
      if (count != null) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    
    };

    // line 1663, (corelib), Array#flatten
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

    // line 1690, (corelib), Array#flatten!
    Array_prototype['$flatten!'] = function(level) {
      
      
      var size = this.length;
      this.$replace(this.$flatten(level));

      return size === this.length ? nil : this;
    
    };

    // line 1699, (corelib), Array#grep
    Array_prototype.$grep = function(pattern) {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (pattern['$==='](item)) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 1715, (corelib), Array#hash
    Array_prototype.$hash = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 1719, (corelib), Array#include?
    Array_prototype['$include?'] = function(member) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i])['$=='](member)) {
          return true;
        }
      }

      return false;
    
    };

    // line 1731, (corelib), Array#index
    Array_prototype.$index = TMP_38 = function(object) {
      var __context, block;
      block = TMP_38._p || nil, __context = block._s, TMP_38._p = null;
      
      
      if (block === nil && object == null) {
        return this.$enum_for("index");
      }
      if (block !== nil) {
        for (var i = 0, length = this.length, value; i < length; i++) {
          if ((value = block.call(__context, '', this[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = 0, length = this.length; i < length; i++) {
          if ((this[i])['$=='](object)) {
            return i;
          }
        }
      }

      return nil;
    
    };

    // line 1759, (corelib), Array#inject
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
        if ((value = block(__context, result, this[i])) === __breaker) {
          return __breaker.$v;
        }

        result = value;
      }

      return result;
    
    };

    // line 1784, (corelib), Array#insert
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

    // line 1807, (corelib), Array#inspect
    Array_prototype.$inspect = function() {
      
      
      var i, inspect, el, el_insp, length, object_id;

      inspect = [];
      object_id = this.$object_id();
      length = this.length;

      for (i = 0; i < length; i++) {
        el = this['$[]'](i);

        // Check object_id to ensure it's not the same array get into an infinite loop
        el_insp = (el).$object_id() === object_id ? '[...]' : (el).$inspect();

        inspect.push(el_insp);
      }
      return '[' + inspect.join(', ') + ']';
    
    };

    // line 1827, (corelib), Array#join
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

    // line 1839, (corelib), Array#keep_if
    Array_prototype.$keep_if = TMP_40 = function() {
      var __context, block;
      block = TMP_40._p || nil, __context = block._s, TMP_40._p = null;
      
      if (block === nil) {
        return this.$enum_for("keep_if")
      };
      
      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block(__context, this[i])) === __breaker) {
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

    // line 1859, (corelib), Array#last
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

    // line 1878, (corelib), Array#length
    Array_prototype.$length = function() {
      
      return this.length;
    };

    Array_prototype.$map = Array_prototype.$collect;

    Array_prototype['$map!'] = Array_prototype['$collect!'];

    // line 1886, (corelib), Array#pop
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

    // line 1902, (corelib), Array#push
    Array_prototype.$push = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    
      return this;
    };

    // line 1912, (corelib), Array#rassoc
    Array_prototype.$rassoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        item = this[i];

        if (item.length && item[1] !== undefined) {
          if ((item[1])['$=='](object)) {
            return item;
          }
        }
      }

      return nil;
    
    };

    // line 1928, (corelib), Array#reject
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

    // line 1947, (corelib), Array#reject!
    Array_prototype['$reject!'] = TMP_42 = function() {
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

    // line 1970, (corelib), Array#replace
    Array_prototype.$replace = function(other) {
      
      
      this.splice(0);
      this.push.apply(this, other);
      return this;
    
    };

    // line 1978, (corelib), Array#reverse
    Array_prototype.$reverse = function() {
      
      return this.reverse();
    };

    // line 1982, (corelib), Array#reverse!
    Array_prototype['$reverse!'] = function() {
      
      
      this.splice(0);
      this.push.apply(this, this.$reverse());
      return this;
    
    };

    // line 1990, (corelib), Array#reverse_each
    Array_prototype.$reverse_each = TMP_43 = function() {
      var __a, __context, block;
      block = TMP_43._p || nil, __context = block._s, TMP_43._p = null;
      
      if (block === nil) {
        return this.$enum_for("reverse_each")
      };
      (__a = this.$reverse(), __a.$each._p = block.$to_proc(), __a.$each());
      return this;
    };

    // line 1998, (corelib), Array#rindex
    Array_prototype.$rindex = TMP_44 = function(object) {
      var __context, block;
      block = TMP_44._p || nil, __context = block._s, TMP_44._p = null;
      
      if (block === nil) {
        return this.$enum_for("rindex")
      };
      
      if (block !== nil) {
        for (var i = this.length - 1, value; i >= 0; i--) {
          if ((value = block(__context, this[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }
      else {
        for (var i = this.length - 1; i >= 0; i--) {
          if ((this[i])['$=='](object)) {
            return i;
          }
        }
      }

      return nil;
    
    };

    // line 2025, (corelib), Array#select
    Array_prototype.$select = TMP_45 = function() {
      var __context, block;
      block = TMP_45._p || nil, __context = block._s, TMP_45._p = null;
      
      if (block === nil) {
        return this.$enum_for("select")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block(__context, item)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 2047, (corelib), Array#select!
    Array_prototype['$select!'] = TMP_46 = function() {
      var __context, block;
      block = TMP_46._p || nil, __context = block._s, TMP_46._p = null;
      
      if (block === nil) {
        return this.$enum_for("select!")
      };
      
      var original = this.length;

      for (var i = 0, length = original, item, value; i < length; i++) {
        item = this[i];

        if ((value = block(__context, item)) === __breaker) {
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

    // line 2071, (corelib), Array#shift
    Array_prototype.$shift = function(count) {
      
      return count == null ? this.shift() : this.splice(0, count);
    };

    Array_prototype.$size = Array_prototype.$length;

    Array_prototype.$slice = Array_prototype['$[]'];

    // line 2079, (corelib), Array#slice!
    Array_prototype['$slice!'] = function(index, length) {
      
      
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

    // line 2097, (corelib), Array#take
    Array_prototype.$take = function(count) {
      
      return this.slice(0, count);
    };

    // line 2101, (corelib), Array#take_while
    Array_prototype.$take_while = TMP_47 = function() {
      var __context, block;
      block = TMP_47._p || nil, __context = block._s, TMP_47._p = null;
      
      if (block === nil) {
        return this.$enum_for("take_while")
      };
      
      var result = [];

      for (var i = 0, length = this.length, item, value; i < length; i++) {
        item = this[i];

        if ((value = block(__context, item)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          return result;
        }

        result.push(item);
      }

      return result;
    
    };

    // line 2125, (corelib), Array#to_a
    Array_prototype.$to_a = function() {
      
      return this;
    };

    Array_prototype.$to_ary = Array_prototype.$to_a;

    // line 2131, (corelib), Array#to_json
    Array_prototype.$to_json = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_json());
      }

      return '[' + result.join(', ') + ']';
    
    };

    Array_prototype.$to_s = Array_prototype.$inspect;

    // line 2145, (corelib), Array#uniq
    Array_prototype.$uniq = function() {
      
      
      var result = [],
          seen   = {};

      for (var i = 0, length = this.length, item, hash; i < length; i++) {
        item = this[i];
        hash = item;

        if (!seen[hash]) {
          seen[hash] = true;

          result.push(item);
        }
      }

      return result;
    
    };

    // line 2165, (corelib), Array#uniq!
    Array_prototype['$uniq!'] = function() {
      
      
      var original = this.length,
          seen     = {};

      for (var i = 0, length = original, item, hash; i < length; i++) {
        item = this[i];
        hash = item;

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

    // line 2189, (corelib), Array#unshift
    Array_prototype.$unshift = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.unshift(objects[i]);
      }

      return this;
    
    };

    // line 2199, (corelib), Array#zip
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
    ;Array._donate(["$&", "$*", "$+", "$-", "$<<", "$<=>", "$==", "$[]", "$[]=", "$assoc", "$at", "$clear", "$clone", "$collect", "$collect!", "$compact", "$compact!", "$concat", "$count", "$delete", "$delete_at", "$delete_if", "$drop", "$drop_while", "$dup", "$each", "$each_index", "$each_with_index", "$empty?", "$fetch", "$first", "$flatten", "$flatten!", "$grep", "$hash", "$include?", "$index", "$inject", "$insert", "$inspect", "$join", "$keep_if", "$last", "$length", "$map", "$map!", "$pop", "$push", "$rassoc", "$reject", "$reject!", "$replace", "$reverse", "$reverse!", "$reverse_each", "$rindex", "$select", "$select!", "$shift", "$size", "$slice", "$slice!", "$take", "$take_while", "$to_a", "$to_ary", "$to_json", "$to_s", "$uniq", "$uniq!", "$unshift", "$zip"]);    ;Array._sdonate(["$[]", "$new"]);
  })(self, Array);
  (function(__base, __super){
    // line 2231, (corelib), class Hash
    function Hash() {};
    Hash = __klass(__base, __super, "Hash", Hash);
    var Hash_prototype = Hash.prototype, __scope = Hash._scope, TMP_49, TMP_50, TMP_51, TMP_52, TMP_53, TMP_54, TMP_55, TMP_56, TMP_57, TMP_58, TMP_59, TMP_60;
    Hash_prototype.proc = Hash_prototype.none = nil;

    Hash.$include(__scope.Enumerable);

    
    __hash = Opal.hash = function() {
      var hash   = new Hash,
          args   = __slice.call(arguments),
          assocs = {};

      hash.map   = assocs;

      for (var i = 0, length = args.length, key; i < length; i++) {
        key = args[i];
        assocs[key] = [key, args[++i]];
      }

      return hash;
    };
  

    // line 2251, (corelib), Hash.[]
    Hash['$[]'] = function(objs) {
      objs = __slice.call(arguments, 0);
      return __hash.apply(null, objs);
    };

    // line 2255, (corelib), Hash.allocate
    Hash.$allocate = function() {
      
      return __hash();
    };

    // line 2259, (corelib), Hash.from_native
    Hash.$from_native = function(obj) {
      
      
      var hash = __hash(), map = hash.map;

      for (var key in obj) {
        map[key] = [key, obj[key]]
      }

      return hash;
    
    };

    // line 2271, (corelib), Hash.new
    Hash['$new'] = TMP_49 = function(defaults) {
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

    // line 2286, (corelib), Hash#==
    Hash_prototype['$=='] = function(other) {
      
      
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

        if (!(obj)['$=='](obj2)) {
          return false;
        }
      }

      return true;
    
    };

    // line 2316, (corelib), Hash#[]
    Hash_prototype['$[]'] = function(key) {
      
      
      var bucket;

      if (bucket = this.map[key]) {
        return bucket[1];
      }

      var proc = this.proc;

      if (proc !== nil) {
        return (proc).$call(this, key);
      }

      return this.none;
    
    };

    // line 2334, (corelib), Hash#[]=
    Hash_prototype['$[]='] = function(key, value) {
      
      
      this.map[key] = [key, value];

      return value;
    
    };

    // line 2342, (corelib), Hash#assoc
    Hash_prototype.$assoc = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if ((bucket[0])['$=='](object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };

    // line 2356, (corelib), Hash#clear
    Hash_prototype.$clear = function() {
      
      
      this.map = {};

      return this;
    
    };

    // line 2364, (corelib), Hash#clone
    Hash_prototype.$clone = function() {
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = [map[assoc][0], map[assoc][1]];
      }

      return result;
    
    };

    // line 2378, (corelib), Hash#default
    Hash_prototype['$default'] = function() {
      
      return this.none;
    };

    // line 2382, (corelib), Hash#default=
    Hash_prototype['$default='] = function(object) {
      
      return this.none = object;
    };

    // line 2386, (corelib), Hash#default_proc
    Hash_prototype.$default_proc = function() {
      
      return this.proc;
    };

    // line 2390, (corelib), Hash#default_proc=
    Hash_prototype['$default_proc='] = function(proc) {
      
      return this.proc = proc;
    };

    // line 2394, (corelib), Hash#delete
    Hash_prototype['$delete'] = function(key) {
      
      
      var map  = this.map, result;

      if (result = map[key]) {
        result = bucket[1];

        delete map[key];
      }

      return result;
    
    };

    // line 2408, (corelib), Hash#delete_if
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

    // line 2433, (corelib), Hash#each
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

    // line 2451, (corelib), Hash#each_key
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

    // line 2471, (corelib), Hash#each_value
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

    // line 2489, (corelib), Hash#empty?
    Hash_prototype['$empty?'] = function() {
      
      
      for (var assoc in this.map) {
        return false;
      }

      return true;
    
    };

    Hash_prototype['$eql?'] = Hash_prototype['$=='];

    // line 2501, (corelib), Hash#fetch
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

    // line 2527, (corelib), Hash#flatten
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
            result = result.concat((value).$flatten((__a = level, __b = 1, typeof(__a) === 'number' ? __a - __b : __a['$-'](__b))));
          }
        }
        else {
          result.push(value);
        }
      }

      return result;
    
    };

    // line 2556, (corelib), Hash#has_key?
    Hash_prototype['$has_key?'] = function(key) {
      
      return !!this.map[key];
    };

    // line 2560, (corelib), Hash#has_value?
    Hash_prototype['$has_value?'] = function(value) {
      
      
      for (var assoc in this.map) {
        if ((this.map[assoc][1])['$=='](value)) {
          return true;
        }
      }

      return false;
    
    };

    // line 2572, (corelib), Hash#hash
    Hash_prototype.$hash = function() {
      
      return this._id;
    };

    Hash_prototype['$include?'] = Hash_prototype['$has_key?'];

    // line 2578, (corelib), Hash#index
    Hash_prototype.$index = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (object['$=='](bucket[1])) {
          return bucket[0];
        }
      }

      return nil;
    
    };

    // line 2592, (corelib), Hash#indexes
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

    // line 2613, (corelib), Hash#inspect
    Hash_prototype.$inspect = function() {
      
      
      var inspect = [],
          map     = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push((bucket[0]).$inspect() + '=>' + (bucket[1]).$inspect());
      }
      return '{' + inspect.join(', ') + '}';
    
    };

    // line 2627, (corelib), Hash#invert
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

    // line 2643, (corelib), Hash#keep_if
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

    Hash_prototype['$key?'] = Hash_prototype['$has_key?'];

    // line 2669, (corelib), Hash#keys
    Hash_prototype.$keys = function() {
      
      
      var result = [];

      for (var assoc in this.map) {
        result.push(this.map[assoc][0]);
      }

      return result;
    
    };

    // line 2681, (corelib), Hash#length
    Hash_prototype.$length = function() {
      
      
      var result = 0;

      for (var assoc in this.map) {
        result++;
      }

      return result;
    
    };

    Hash_prototype['$member?'] = Hash_prototype['$has_key?'];

    // line 2695, (corelib), Hash#merge
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

    // line 2732, (corelib), Hash#merge!
    Hash_prototype['$merge!'] = TMP_57 = function(other) {
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

    // line 2760, (corelib), Hash#rassoc
    Hash_prototype.$rassoc = function(object) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if ((bucket[1])['$=='](object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };

    // line 2776, (corelib), Hash#reject
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

    // line 2799, (corelib), Hash#replace
    Hash_prototype.$replace = function(other) {
      
      
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[bucket[0]] = [bucket[0], bucket[1]];
      }

      return this;
    
    };

    // line 2813, (corelib), Hash#select
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

    // line 2836, (corelib), Hash#select!
    Hash_prototype['$select!'] = TMP_60 = function() {
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

    // line 2860, (corelib), Hash#shift
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

    // line 2876, (corelib), Hash#to_a
    Hash_prototype.$to_a = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    
    };

    // line 2891, (corelib), Hash#to_hash
    Hash_prototype.$to_hash = function() {
      
      return this;
    };

    // line 2895, (corelib), Hash#to_json
    Hash_prototype.$to_json = function() {
      
      
      var parts = [], map = this.map, bucket;

      for (var assoc in map) {
        bucket = map[assoc];
        parts.push((bucket[0]).$to_json() + ': ' + (bucket[1]).$to_json());
      }

      return '{' + parts.join(', ') + '}';
    
    };

    // line 2908, (corelib), Hash#to_native
    Hash_prototype.$to_native = function() {
      
      
      var result = {}, map = this.map, bucket;

      for (var assoc in map) {
        bucket = map[assoc];
        result[bucket[0]] = (bucket[1]).$to_json();
      }

      return result;
    
    };

    Hash_prototype.$to_s = Hash_prototype.$inspect;

    Hash_prototype.$update = Hash_prototype['$merge!'];

    // line 2925, (corelib), Hash#value?
    Hash_prototype['$value?'] = function(value) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var v = map[assoc][1];
        if ((v)['$=='](value)) {
          return true;
        }
      }

      return false;
    
    };

    Hash_prototype.$values_at = Hash_prototype.$indexes;

    // line 2942, (corelib), Hash#values
    Hash_prototype.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    
    };
    ;Hash._donate(["$==", "$[]", "$[]=", "$assoc", "$clear", "$clone", "$default", "$default=", "$default_proc", "$default_proc=", "$delete", "$delete_if", "$dup", "$each", "$each_key", "$each_pair", "$each_value", "$empty?", "$eql?", "$fetch", "$flatten", "$has_key?", "$has_value?", "$hash", "$include?", "$index", "$indexes", "$indices", "$inspect", "$invert", "$keep_if", "$key", "$key?", "$keys", "$length", "$member?", "$merge", "$merge!", "$rassoc", "$reject", "$replace", "$select", "$select!", "$shift", "$size", "$to_a", "$to_hash", "$to_json", "$to_native", "$to_s", "$update", "$value?", "$values_at", "$values"]);    ;Hash._sdonate(["$[]", "$allocate", "$from_native", "$new"]);
  })(self, null);
  (function(__base, __super){
    // line 2955, (corelib), class String
    function String() {};
    String = __klass(__base, __super, "String", String);
    var String_prototype = String.prototype, __scope = String._scope, TMP_61, TMP_62, TMP_63, TMP_64, TMP_65;

    String_prototype._isString = true;

    String.$include(__scope.Comparable);

    // line 2960, (corelib), String.try_convert
    String.$try_convert = function(what) {
      
      return (function() { try {
      what.$to_str()
      } catch ($err) {
      if (true) {
      nil}
      else { throw $err; }
      } }).call(this)
    };

    // line 2966, (corelib), String.new
    String['$new'] = function(str) {
      if (str == null) {
        str = ""
      }
      
      return this.$allocate(str)
    ;
    };

    // line 2972, (corelib), String#%
    String_prototype['$%'] = function(data) {
      
      
      var idx = 0;
      return this.replace(/%((%)|s)/g, function (match) {
        return match[2] || data[idx++] || '';
      });
    
    };

    // line 2981, (corelib), String#*
    String_prototype['$*'] = function(count) {
      
      
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

    // line 3002, (corelib), String#+
    String_prototype['$+'] = function(other) {
      
      return this.toString() + other;
    };

    // line 3006, (corelib), String#<=>
    String_prototype['$<=>'] = function(other) {
      
      
      if (typeof other !== 'string') {
        return nil;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    
    };

    // line 3016, (corelib), String#<
    String_prototype['$<'] = function(other) {
      
      return this < other;
    };

    // line 3020, (corelib), String#<=
    String_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    // line 3024, (corelib), String#>
    String_prototype['$>'] = function(other) {
      
      return this > other;
    };

    // line 3028, (corelib), String#>=
    String_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    // line 3032, (corelib), String#==
    String_prototype['$=='] = function(other) {
      
      return other == String(this);
    };

    String_prototype['$==='] = String_prototype['$=='];

    // line 3038, (corelib), String#=~
    String_prototype['$=~'] = function(other) {
      
      
      if (typeof other === 'string') {
        this.$raise("string given");
      }

      return other['$=~'](this);
    
    };

    // line 3049, (corelib), String#[]
    String_prototype['$[]'] = function(index, length) {
      
      
      var size = this.length;

      if (index._isRange) {
        var exclude = index.exclude,
            length  = index.end,
            index   = index.begin;

        if (index > size) {
          return nil;
        }

        if (length < 0) {
          length += size;
        }

        if (exclude) length -= 1;
        return this.substr(index, length);
      }

      if (index < 0) {
        index += this.length;
      }

      if (length == null) {
        if (index >= this.length || index < 0) {
          return nil;
        }

        return this.substr(index, 1);
      }

      if (index > this.length || index < 0) {
        return nil;
      }

      return this.substr(index, length);
    
    };

    // line 3090, (corelib), String#capitalize
    String_prototype.$capitalize = function() {
      
      return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
    };

    // line 3094, (corelib), String#casecmp
    String_prototype.$casecmp = function(other) {
      
      
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    
    };

    // line 3107, (corelib), String#chars
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

    // line 3117, (corelib), String#chomp
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

    // line 3129, (corelib), String#chop
    String_prototype.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };

    // line 3133, (corelib), String#chr
    String_prototype.$chr = function() {
      
      return this.charAt(0);
    };

    // line 3137, (corelib), String#count
    String_prototype.$count = function(str) {
      
      return (this.length - this.replace(new RegExp(str,"g"), '').length) / str.length;
    };

    // line 3141, (corelib), String#downcase
    String_prototype.$downcase = function() {
      
      return this.toLowerCase();
    };

    String_prototype.$each_char = String_prototype.$chars;

    // line 3147, (corelib), String#each_line
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

    // line 3159, (corelib), String#empty?
    String_prototype['$empty?'] = function() {
      
      return this.length === 0;
    };

    // line 3163, (corelib), String#end_with?
    String_prototype['$end_with?'] = function(suffixes) {
      suffixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (this.lastIndexOf(suffix) === this.length - suffix.length) {
          return true;
        }
      }

      return false;
    
    };

    String_prototype['$eql?'] = String_prototype['$=='];

    // line 3179, (corelib), String#equal?
    String_prototype['$equal?'] = function(val) {
      
      return this.toString() === val.toString();
    };

    // line 3183, (corelib), String#getbyte
    String_prototype.$getbyte = function(idx) {
      
      return this.charCodeAt(idx);
    };

    // line 3187, (corelib), String#gsub
    String_prototype.$gsub = TMP_63 = function(pattern, replace) {
      var __a, __b, __context, block;
      block = TMP_63._p || nil, __context = block._s, TMP_63._p = null;
      
      if ((__a = (__b = !block, __b !== false && __b !== nil ? pattern == null : __b)) !== false && __a !== nil) {
        return this.$enum_for("gsub", pattern, replace)
      };
      if ((__a = pattern['$is_a?'](__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return (__a = this, __a.$sub._p = block.$to_proc(), __a.$sub(new RegExp(regexp, options), replace));
    
    };

    // line 3203, (corelib), String#hash
    String_prototype.$hash = function() {
      
      return this.toString();
    };

    // line 3207, (corelib), String#hex
    String_prototype.$hex = function() {
      
      return this.$to_i(16);
    };

    // line 3211, (corelib), String#include?
    String_prototype['$include?'] = function(other) {
      
      return this.indexOf(other) !== -1;
    };

    // line 3215, (corelib), String#index
    String_prototype.$index = function(what, offset) {
      var __a, __b;
      if ((__a = ((__b = __scope.String['$==='](what)), __b !== false && __b !== nil ? __b : __scope.Regexp['$==='](what))) === false || __a === nil) {
        this.$raise(__scope.TypeError, "type mismatch: " + (what['$class']()) + " given")
      };
      
      var result = -1;

      if (offset != null) {
        if (offset < 0) {
          offset = this.length - offset;
        }

        if (what['$is_a?'](__scope.Regexp)) {
          result = ((__a = what['$=~'](this.substr(offset))), __a !== false && __a !== nil ? __a : -1)
        }
        else {
          result = this.substr(offset).indexOf(substr);
        }

        if (result !== -1) {
          result += offset;
        }
      }
      else {
        if (what['$is_a?'](__scope.Regexp)) {
          result = ((__a = what['$=~'](this)), __a !== false && __a !== nil ? __a : -1)
        }
        else {
          result = this.indexOf(substr);
        }
      }

      return result === -1 ? nil : result;
    
    };

    // line 3252, (corelib), String#inspect
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

    // line 3276, (corelib), String#intern
    String_prototype.$intern = function() {
      
      return this;
    };

    String_prototype.$lines = String_prototype.$each_line;

    // line 3282, (corelib), String#length
    String_prototype.$length = function() {
      
      return this.length;
    };

    // line 3286, (corelib), String#ljust
    String_prototype.$ljust = function(integer, padstr) {
      if (padstr == null) {
        padstr = " "
      }
      return this.$raise(__scope.NotImplementedError);
    };

    // line 3290, (corelib), String#lstrip
    String_prototype.$lstrip = function() {
      
      return this.replace(/^\s*/, '');
    };

    // line 3294, (corelib), String#match
    String_prototype.$match = TMP_64 = function(pattern, pos) {
      var __a, __b, __context, block;
      block = TMP_64._p || nil, __context = block._s, TMP_64._p = null;
      
      return (__a = (function() { if ((__b = pattern['$is_a?'](__scope.Regexp)) !== false && __b !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this), __a.$match._p = block.$to_proc(), __a.$match(this, pos));
    };

    // line 3298, (corelib), String#next
    String_prototype.$next = function() {
      
      
      if (this.length === 0) {
        return "";
      }

      var initial = this.substr(0, this.length - 1);
      var last    = String.fromCharCode(this.charCodeAt(this.length - 1) + 1);

      return initial + last;
    
    };

    // line 3311, (corelib), String#ord
    String_prototype.$ord = function() {
      
      return this.charCodeAt(0);
    };

    // line 3315, (corelib), String#partition
    String_prototype.$partition = function(str) {
      
      
      var result = this.split(str);
      var splitter = (result[0].length === this.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    
    };

    // line 3324, (corelib), String#reverse
    String_prototype.$reverse = function() {
      
      return this.split('').reverse().join('');
    };

    // line 3328, (corelib), String#rstrip
    String_prototype.$rstrip = function() {
      
      return this.replace(/\s*$/, '');
    };

    String_prototype.$size = String_prototype.$length;

    String_prototype.$slice = String_prototype['$[]'];

    // line 3336, (corelib), String#split
    String_prototype.$split = function(pattern, limit) {
      var __a;if (pattern == null) {
        pattern = ((__a = __gvars[";"]), __a !== false && __a !== nil ? __a : " ")
      }
      return this.split(pattern, limit);
    };

    // line 3340, (corelib), String#start_with?
    String_prototype['$start_with?'] = function(prefixes) {
      prefixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    
    };

    // line 3352, (corelib), String#strip
    String_prototype.$strip = function() {
      
      return this.replace(/^\s*/, '').replace(/\s*$/, '');
    };

    // line 3356, (corelib), String#sub
    String_prototype.$sub = TMP_65 = function(pattern, replace) {
      var __context, block;
      block = TMP_65._p || nil, __context = block._s, TMP_65._p = null;
      
      
      if (typeof(replace) === 'string') {
        return this.replace(pattern, replace);
      }
      if (block !== nil) {
        return this.replace(pattern, function(str, a) {
          __gvars["1"] = a;
          return block.call(__context, str);
        });
      }
      else if (replace != null) {
        if (replace['$is_a?'](__scope.Hash)) {
          return this.replace(pattern, function(str) {
            var value = replace['$[]'](this.$str());

            return (value == null) ? nil : this.$value().$to_s();
          });
        }
        else {
          replace = __scope.String.$try_convert(replace);

          if (replace == null) {
            this.$raise(__scope.TypeError, "can't convert " + (replace['$class']()) + " into String");
          }

          return this.replace(pattern, replace);
        }
      }
      else {
        return this.replace(pattern, replace.toString());
      }
    
    };

    String_prototype.$succ = String_prototype.$next;

    // line 3393, (corelib), String#sum
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

    // line 3405, (corelib), String#swapcase
    String_prototype.$swapcase = function() {
      
      
      var str = this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (this._klass === String) {
        return str;
      }

      return this['$class']()['$new'](str);
    
    };

    // line 3419, (corelib), String#to_a
    String_prototype.$to_a = function() {
      
      
      if (this.length === 0) {
        return [];
      }

      return [this];
    
    };

    // line 3429, (corelib), String#to_f
    String_prototype.$to_f = function() {
      
      
      var result = parseFloat(this);

      return isNaN(result) ? 0 : result;
    
    };

    // line 3437, (corelib), String#to_i
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

    // line 3451, (corelib), String#to_proc
    String_prototype.$to_proc = function() {
      
      
      var name = '$' + this;

      return function(arg) { return arg[name](arg); };
    
    };

    // line 3459, (corelib), String#to_s
    String_prototype.$to_s = function() {
      
      return this.toString();
    };

    String_prototype.$to_str = String_prototype.$to_s;

    String_prototype.$to_sym = String_prototype.$intern;

    // line 3467, (corelib), String#upcase
    String_prototype.$upcase = function() {
      
      return this.toUpperCase();
    };
    ;String._donate(["$%", "$*", "$+", "$<=>", "$<", "$<=", "$>", "$>=", "$==", "$===", "$=~", "$[]", "$capitalize", "$casecmp", "$chars", "$chomp", "$chop", "$chr", "$count", "$downcase", "$each_char", "$each_line", "$empty?", "$end_with?", "$eql?", "$equal?", "$getbyte", "$gsub", "$hash", "$hex", "$include?", "$index", "$inspect", "$intern", "$lines", "$length", "$ljust", "$lstrip", "$match", "$next", "$ord", "$partition", "$reverse", "$rstrip", "$size", "$slice", "$split", "$start_with?", "$strip", "$sub", "$succ", "$sum", "$swapcase", "$to_a", "$to_f", "$to_i", "$to_json", "$to_proc", "$to_s", "$to_str", "$to_sym", "$upcase"]);    ;String._sdonate(["$try_convert", "$new"]);
  })(self, String);
  __scope.Symbol = __scope.String;
  (function(__base, __super){
    // line 3473, (corelib), class Numeric
    function Numeric() {};
    Numeric = __klass(__base, __super, "Numeric", Numeric);
    var Numeric_prototype = Numeric.prototype, __scope = Numeric._scope, TMP_66, TMP_67, TMP_68;

    
    Numeric_prototype._isNumber = true;
  

    Numeric.$include(__scope.Comparable);

    // line 3480, (corelib), Numeric#+
    Numeric_prototype['$+'] = function(other) {
      
      return this + other;
    };

    // line 3484, (corelib), Numeric#-
    Numeric_prototype['$-'] = function(other) {
      
      return this - other;
    };

    // line 3488, (corelib), Numeric#*
    Numeric_prototype['$*'] = function(other) {
      
      return this * other;
    };

    // line 3492, (corelib), Numeric#/
    Numeric_prototype['$/'] = function(other) {
      
      return this / other;
    };

    // line 3496, (corelib), Numeric#%
    Numeric_prototype['$%'] = function(other) {
      
      return this % other;
    };

    // line 3500, (corelib), Numeric#&
    Numeric_prototype['$&'] = function(other) {
      
      return this & other;
    };

    // line 3504, (corelib), Numeric#|
    Numeric_prototype['$|'] = function(other) {
      
      return this | other;
    };

    // line 3508, (corelib), Numeric#^
    Numeric_prototype['$^'] = function(other) {
      
      return this ^ other;
    };

    // line 3512, (corelib), Numeric#<
    Numeric_prototype['$<'] = function(other) {
      
      return this < other;
    };

    // line 3516, (corelib), Numeric#<=
    Numeric_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    // line 3520, (corelib), Numeric#>
    Numeric_prototype['$>'] = function(other) {
      
      return this > other;
    };

    // line 3524, (corelib), Numeric#>=
    Numeric_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    // line 3528, (corelib), Numeric#<<
    Numeric_prototype['$<<'] = function(count) {
      
      return this << count;
    };

    // line 3532, (corelib), Numeric#>>
    Numeric_prototype['$>>'] = function(count) {
      
      return this >> count;
    };

    // line 3536, (corelib), Numeric#+@
    Numeric_prototype['$+@'] = function() {
      
      return +this;
    };

    // line 3540, (corelib), Numeric#-@
    Numeric_prototype['$-@'] = function() {
      
      return -this;
    };

    // line 3544, (corelib), Numeric#~
    Numeric_prototype['$~'] = function() {
      
      return ~this;
    };

    // line 3548, (corelib), Numeric#**
    Numeric_prototype['$**'] = function(other) {
      
      return Math.pow(this, other);
    };

    // line 3552, (corelib), Numeric#==
    Numeric_prototype['$=='] = function(other) {
      
      return this == other;
    };

    // line 3556, (corelib), Numeric#<=>
    Numeric_prototype['$<=>'] = function(other) {
      
      
      if (typeof(other) !== 'number') {
        return nil;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    
    };

    // line 3566, (corelib), Numeric#abs
    Numeric_prototype.$abs = function() {
      
      return Math.abs(this);
    };

    // line 3570, (corelib), Numeric#ceil
    Numeric_prototype.$ceil = function() {
      
      return Math.ceil(this);
    };

    // line 3574, (corelib), Numeric#chr
    Numeric_prototype.$chr = function() {
      
      return String.fromCharCode(this);
    };

    // line 3578, (corelib), Numeric#downto
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

    Numeric_prototype['$eql?'] = Numeric_prototype['$=='];

    // line 3594, (corelib), Numeric#even?
    Numeric_prototype['$even?'] = function() {
      
      return this % 2 === 0;
    };

    // line 3598, (corelib), Numeric#floor
    Numeric_prototype.$floor = function() {
      
      return Math.floor(this);
    };

    // line 3602, (corelib), Numeric#hash
    Numeric_prototype.$hash = function() {
      
      return this.toString();
    };

    // line 3606, (corelib), Numeric#integer?
    Numeric_prototype['$integer?'] = function() {
      
      return this % 1 === 0;
    };

    Numeric_prototype.$magnitude = Numeric_prototype.$abs;

    Numeric_prototype.$modulo = Numeric_prototype['$%'];

    // line 3614, (corelib), Numeric#next
    Numeric_prototype.$next = function() {
      
      return this + 1;
    };

    // line 3618, (corelib), Numeric#nonzero?
    Numeric_prototype['$nonzero?'] = function() {
      
      return this === 0 ? nil : this;
    };

    // line 3622, (corelib), Numeric#odd?
    Numeric_prototype['$odd?'] = function() {
      
      return this % 2 !== 0;
    };

    // line 3626, (corelib), Numeric#ord
    Numeric_prototype.$ord = function() {
      
      return this;
    };

    // line 3630, (corelib), Numeric#pred
    Numeric_prototype.$pred = function() {
      
      return this - 1;
    };

    Numeric_prototype.$succ = Numeric_prototype.$next;

    // line 3636, (corelib), Numeric#times
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

    // line 3650, (corelib), Numeric#to_f
    Numeric_prototype.$to_f = function() {
      
      return parseFloat(this);
    };

    // line 3654, (corelib), Numeric#to_i
    Numeric_prototype.$to_i = function() {
      
      return parseInt(this);
    };

    // line 3658, (corelib), Numeric#to_json
    Numeric_prototype.$to_json = function() {
      
      return this.toString();
    };

    // line 3662, (corelib), Numeric#to_s
    Numeric_prototype.$to_s = function(base) {
      if (base == null) {
        base = 10
      }
      return this.toString();
    };

    // line 3666, (corelib), Numeric#upto
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

    // line 3680, (corelib), Numeric#zero?
    Numeric_prototype['$zero?'] = function() {
      
      return this == 0;
    };
    ;Numeric._donate(["$+", "$-", "$*", "$/", "$%", "$&", "$|", "$^", "$<", "$<=", "$>", "$>=", "$<<", "$>>", "$+@", "$-@", "$~", "$**", "$==", "$<=>", "$abs", "$ceil", "$chr", "$downto", "$eql?", "$even?", "$floor", "$hash", "$integer?", "$magnitude", "$modulo", "$next", "$nonzero?", "$odd?", "$ord", "$pred", "$succ", "$times", "$to_f", "$to_i", "$to_json", "$to_s", "$upto", "$zero?"]);
  })(self, Number);
  __scope.Fixnum = __scope.Numeric;
  (function(__base, __super){
    // line 3686, (corelib), class Proc
    function Proc() {};
    Proc = __klass(__base, __super, "Proc", Proc);
    var Proc_prototype = Proc.prototype, __scope = Proc._scope, TMP_69;

    
    Proc_prototype._isProc = true;
    Proc_prototype.is_lambda = true;
  

    // line 3692, (corelib), Proc.new
    Proc['$new'] = TMP_69 = function() {
      var __context, block;
      block = TMP_69._p || nil, __context = block._s, TMP_69._p = null;
      
      if (block === nil) no_block_given();
      block.is_lambda = false;
      return block;
    };

    // line 3698, (corelib), Proc#to_proc
    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    // line 3702, (corelib), Proc#call
    Proc_prototype.$call = function(args) {
      args = __slice.call(arguments, 0);
      return this.apply(this._s, args);
    };

    // line 3706, (corelib), Proc#to_proc
    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    // line 3710, (corelib), Proc#lambda?
    Proc_prototype['$lambda?'] = function() {
      
      return !!this.is_lambda;
    };

    // line 3716, (corelib), Proc#arity
    Proc_prototype.$arity = function() {
      
      return this.length - 1;
    };
    ;Proc._donate(["$to_proc", "$call", "$to_proc", "$lambda?", "$arity"]);    ;Proc._sdonate(["$new"]);
  })(self, Function);
  (function(__base, __super){
    // line 3720, (corelib), class Range
    function Range() {};
    Range = __klass(__base, __super, "Range", Range);
    var Range_prototype = Range.prototype, __scope = Range._scope, TMP_70, TMP_71;

    Range.$include(__scope.Enumerable);

    
    Range_prototype._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new Range;
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  

    // line 3736, (corelib), Range#initialize
    Range_prototype.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };

    // line 3742, (corelib), Range#==
    Range_prototype['$=='] = function(other) {
      var __a;
      if ((__a = __scope.Range['$==='](other)) === false || __a === nil) {
        return false
      };
      return (__a = ((__a = this['$exclude_end?']()['$=='](other['$exclude_end?']())) ? (this.begin)['$=='](other.$begin()) : __a), __a !== false && __a !== nil ? (this.end)['$=='](other.$end()) : __a);
    };

    // line 3749, (corelib), Range#===
    Range_prototype['$==='] = function(obj) {
      
      return obj >= this.begin && (this.exclude ? obj < this.end : obj <= this.end);
    };

    // line 3753, (corelib), Range#begin
    Range_prototype.$begin = function() {
      
      return this.begin;
    };

    // line 3757, (corelib), Range#cover?
    Range_prototype['$cover?'] = function(value) {
      var __a, __b, __c;
      return ((__a = (this.begin)['$<='](value)) ? value['$<=']((function() { if ((__b = this['$exclude_end?']()) !== false && __b !== nil) {
        return (__b = this.end, __c = 1, typeof(__b) === 'number' ? __b - __c : __b['$-'](__c))
        } else {
        return this.end;
      }; return nil; }).call(this)) : __a);
    };

    // line 3761, (corelib), Range#each
    Range_prototype.$each = TMP_70 = function() {
      var current = nil, __a, __b, __context, __yield;
      __yield = TMP_70._p || nil, __context = __yield._s, TMP_70._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each")
      };
      current = this.$min();
      while ((__b = !current['$=='](this.$max())) !== false && __b !== nil){if (__yield.call(__context, current) === __breaker) return __breaker.$v;
      current = current.$succ();};
      if ((__a = this['$exclude_end?']()) === false || __a === nil) {
        if (__yield.call(__context, current) === __breaker) return __breaker.$v
      };
      return this;
    };

    // line 3777, (corelib), Range#end
    Range_prototype.$end = function() {
      
      return this.end;
    };

    // line 3781, (corelib), Range#eql?
    Range_prototype['$eql?'] = function(other) {
      var __a;
      if ((__a = __scope.Range['$==='](other)) === false || __a === nil) {
        return false
      };
      return (__a = ((__a = this['$exclude_end?']()['$=='](other['$exclude_end?']())) ? (this.begin)['$eql?'](other.$begin()) : __a), __a !== false && __a !== nil ? (this.end)['$eql?'](other.$end()) : __a);
    };

    // line 3787, (corelib), Range#exclude_end?
    Range_prototype['$exclude_end?'] = function() {
      
      return this.exclude;
    };

    // line 3792, (corelib), Range#include?
    Range_prototype['$include?'] = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };

    Range_prototype.$max = Range_prototype.$end;

    Range_prototype.$min = Range_prototype.$begin;

    Range_prototype['$member?'] = Range_prototype['$include?'];

    // line 3802, (corelib), Range#step
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

    // line 3808, (corelib), Range#to_s
    Range_prototype.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };

    // line 3812, (corelib), Range#inspect
    Range_prototype.$inspect = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };
    ;Range._donate(["$initialize", "$==", "$===", "$begin", "$cover?", "$each", "$end", "$eql?", "$exclude_end?", "$include?", "$max", "$min", "$member?", "$step", "$to_s", "$inspect"]);
  })(self, null);
  (function(__base, __super){
    // line 3816, (corelib), class Exception
    function Exception() {};
    Exception = __klass(__base, __super, "Exception", Exception);
    var Exception_prototype = Exception.prototype, __scope = Exception._scope;
    Exception_prototype.message = nil;

    // line 3817, (corelib), Exception#message
    Exception_prototype.$message = function() {
      
      return this.message
    };

    // line 3819, (corelib), Exception.new
    Exception['$new'] = function(message) {
      if (message == null) {
        message = ""
      }
      
      var err = this.$allocate();
      err.message = message;
      return err;
    
    };

    // line 3827, (corelib), Exception#backtrace
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

    // line 3842, (corelib), Exception#inspect
    Exception_prototype.$inspect = function() {
      
      return "#<" + (this['$class']().$name()) + ": '" + (this.message) + "'>";
    };

    Exception_prototype.$to_s = Exception_prototype.$message;
    ;Exception._donate(["$message", "$backtrace", "$inspect", "$to_s"]);    ;Exception._sdonate(["$new"]);
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
    // line 3859, (corelib), class Regexp
    function Regexp() {};
    Regexp = __klass(__base, __super, "Regexp", Regexp);
    var Regexp_prototype = Regexp.prototype, __scope = Regexp._scope;

    // line 3860, (corelib), Regexp.escape
    Regexp.$escape = function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    };

    // line 3864, (corelib), Regexp.new
    Regexp['$new'] = function(string, options) {
      
      return new RegExp(string, options);
    };

    // line 3868, (corelib), Regexp#==
    Regexp_prototype['$=='] = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };

    // line 3872, (corelib), Regexp#===
    Regexp_prototype['$==='] = function(obj) {
      
      return this.test(obj);
    };

    // line 3876, (corelib), Regexp#=~
    Regexp_prototype['$=~'] = function(string) {
      
      
      var result = this.exec(string);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._klass = __scope.MatchData;

        __gvars["~"] = result;
      }
      else {
        __gvars["~"] = nil;
      }

      return result ? result.index : nil;
    
    };

    Regexp_prototype['$eql?'] = Regexp_prototype['$=='];

    // line 3897, (corelib), Regexp#inspect
    Regexp_prototype.$inspect = function() {
      
      return this.toString();
    };

    // line 3901, (corelib), Regexp#match
    Regexp_prototype.$match = function(pattern) {
      
      
      var result  = this.exec(pattern);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._klass = __scope.MatchData;

        return __gvars["~"] = result;
      }
      else {
        return __gvars["~"] = nil;
      }
    
    };

    // line 3918, (corelib), Regexp#to_s
    Regexp_prototype.$to_s = function() {
      
      return this.source;
    };

    
    function match_to_s() {
      return this[0];
    }

    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }
  
    ;Regexp._donate(["$==", "$===", "$=~", "$eql?", "$inspect", "$match", "$to_s"]);    ;Regexp._sdonate(["$escape", "$new"]);
  })(self, RegExp);
  (function(__base, __super){
    // line 3933, (corelib), class MatchData
    function MatchData() {};
    MatchData = __klass(__base, __super, "MatchData", MatchData);
    var MatchData_prototype = MatchData.prototype, __scope = MatchData._scope;

    nil

  })(self, null);
  (function(__base, __super){
    // line 3935, (corelib), class Time
    function Time() {};
    Time = __klass(__base, __super, "Time", Time);
    var Time_prototype = Time.prototype, __scope = Time._scope;

    Time.$include(__scope.Comparable);

    // line 3938, (corelib), Time.at
    Time.$at = function(seconds, frac) {
      if (frac == null) {
        frac = 0
      }
      return this.$allocate(seconds * 1000 + frac)
    };

    // line 3942, (corelib), Time.new
    Time['$new'] = function(year, month, day, hour, minute, second, millisecond) {
      
      
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

    // line 3965, (corelib), Time.now
    Time.$now = function() {
      
      return new Date();
    };

    // line 3969, (corelib), Time#+
    Time_prototype['$+'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a + __b : __a['$+'](__b)));
    };

    // line 3973, (corelib), Time#-
    Time_prototype['$-'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a - __b : __a['$-'](__b)));
    };

    // line 3977, (corelib), Time#<=>
    Time_prototype['$<=>'] = function(other) {
      
      return this.$to_f()['$<=>'](other.$to_f());
    };

    // line 3981, (corelib), Time#day
    Time_prototype.$day = function() {
      
      return this.getDate();
    };

    // line 3985, (corelib), Time#eql?
    Time_prototype['$eql?'] = function(other) {
      var __a;
      return (__a = other['$is_a?'](__scope.Time), __a !== false && __a !== nil ? this['$<=>'](other)['$zero?']() : __a);
    };

    // line 3989, (corelib), Time#friday?
    Time_prototype['$friday?'] = function() {
      
      return this.getDay() === 5;
    };

    // line 3993, (corelib), Time#hour
    Time_prototype.$hour = function() {
      
      return this.getHours();
    };

    Time_prototype.$mday = Time_prototype.$day;

    // line 3999, (corelib), Time#min
    Time_prototype.$min = function() {
      
      return this.getMinutes();
    };

    // line 4003, (corelib), Time#mon
    Time_prototype.$mon = function() {
      
      return this.getMonth() + 1;
    };

    // line 4007, (corelib), Time#monday?
    Time_prototype['$monday?'] = function() {
      
      return this.getDay() === 1;
    };

    Time_prototype.$month = Time_prototype.$mon;

    // line 4013, (corelib), Time#saturday?
    Time_prototype['$saturday?'] = function() {
      
      return this.getDay() === 6;
    };

    // line 4017, (corelib), Time#sec
    Time_prototype.$sec = function() {
      
      return this.getSeconds();
    };

    // line 4021, (corelib), Time#sunday?
    Time_prototype['$sunday?'] = function() {
      
      return this.getDay() === 0;
    };

    // line 4025, (corelib), Time#thursday?
    Time_prototype['$thursday?'] = function() {
      
      return this.getDay() === 4;
    };

    // line 4029, (corelib), Time#to_f
    Time_prototype.$to_f = function() {
      
      return this.getTime() / 1000;
    };

    // line 4033, (corelib), Time#to_i
    Time_prototype.$to_i = function() {
      
      return parseInt(this.getTime() / 1000);
    };

    // line 4037, (corelib), Time#tuesday?
    Time_prototype['$tuesday?'] = function() {
      
      return this.getDay() === 2;
    };

    // line 4041, (corelib), Time#wday
    Time_prototype.$wday = function() {
      
      return this.getDay();
    };

    // line 4045, (corelib), Time#wednesday?
    Time_prototype['$wednesday?'] = function() {
      
      return this.getDay() === 3;
    };

    // line 4049, (corelib), Time#year
    Time_prototype.$year = function() {
      
      return this.getFullYear();
    };
    ;Time._donate(["$+", "$-", "$<=>", "$day", "$eql?", "$friday?", "$hour", "$mday", "$min", "$mon", "$monday?", "$month", "$saturday?", "$sec", "$sunday?", "$thursday?", "$to_f", "$to_i", "$tuesday?", "$wday", "$wednesday?", "$year"]);    ;Time._sdonate(["$at", "$new", "$now"]);
  })(self, Date);
  (function(__base, __super){
    // line 4053, (corelib), class Struct
    function Struct() {};
    Struct = __klass(__base, __super, "Struct", Struct);
    var Struct_prototype = Struct.prototype, __scope = Struct._scope, TMP_72, TMP_73, TMP_74;

    // line 4054, (corelib), Struct.new
    Struct['$new'] = TMP_72 = function(name, args) {
      var __a, __b;args = __slice.call(arguments, 1);
      if ((__a = this['$=='](__scope.Struct)) === false || __a === nil) {
        return Struct._super['$new'].apply(this, [self].concat(__slice.call(arguments)))
      };
      if (name['$[]'](0)['$=='](name['$[]'](0).$upcase())) {
        return __scope.Struct.$const_set(name, this['$new'].apply(this, [].concat(args)))
        } else {
        args.$unshift(name);
        return (__b = __scope.Class, __b['$new']._p = (__a = function() {

          var __a, __b;
          
          return (__b = args, __b.$each._p = (__a = function(name) {

            
            if (name == null) name = nil;

            return this.$define_struct_attribute(name)
          }, __a._s = this, __a), __b.$each())
        }, __a._s = this, __a), __b['$new'](this));
      };
    };

    // line 4068, (corelib), Struct.define_struct_attribute
    Struct.$define_struct_attribute = function(name) {
      var __a, __b, __c;
      if (this['$=='](__scope.Struct)) {
        this.$raise(__scope.ArgumentError, "you cannot define attributes to the Struct class")
      };
      this.$members()['$<<'](name);
      (__b = this, __b.$define_method._p = (__a = function() {

        
        
        return this.$instance_variable_get("@" + (name))
      }, __a._s = this, __a), __b.$define_method(name));
      return (__c = this, __c.$define_method._p = (__a = function(value) {

        
        if (value == null) value = nil;

        return this.$instance_variable_set("@" + (name), value)
      }, __a._s = this, __a), __c.$define_method("" + (name) + "="));
    };

    // line 4084, (corelib), Struct.members
    Struct.$members = function() {
      var __a;
      if (this.members == null) this.members = nil;

      if (this['$=='](__scope.Struct)) {
        this.$raise(__scope.ArgumentError, "the Struct class has no members")
      };
      return ((__a = this.members), __a !== false && __a !== nil ? __a : this.members = []);
    };

    Struct.$include(__scope.Enumerable);

    // line 4094, (corelib), Struct#initialize
    Struct_prototype.$initialize = function(args) {
      var __a, __b;args = __slice.call(arguments, 0);
      return (__b = this.$members(), __b.$each_with_index._p = (__a = function(name, index) {

        
        if (name == null) name = nil;
if (index == null) index = nil;

        return this.$instance_variable_set("@" + (name), args['$[]'](index))
      }, __a._s = this, __a), __b.$each_with_index());
    };

    // line 4100, (corelib), Struct#members
    Struct_prototype.$members = function() {
      
      return this['$class']().$members();
    };

    // line 4104, (corelib), Struct#[]
    Struct_prototype['$[]'] = function(name) {
      var __a;
      if ((__a = __scope.Integer['$==='](name)) !== false && __a !== nil) {
        if (name['$>='](this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + (name) + " too large for struct(size:" + (this.$members().$size()) + ")")
        };
        name = this.$members()['$[]'](name);
        } else {
        if ((__a = this.$members()['$include?'](name.$to_sym())) === false || __a === nil) {
          this.$raise(__scope.NameError, "no member '" + (name) + "' in struct")
        }
      };
      return this.$instance_variable_get("@" + (name));
    };

    // line 4116, (corelib), Struct#[]=
    Struct_prototype['$[]='] = function(name, value) {
      var __a;
      if ((__a = __scope.Integer['$==='](name)) !== false && __a !== nil) {
        if (name['$>='](this.$members().$size())) {
          this.$raise(__scope.IndexError, "offset " + (name) + " too large for struct(size:" + (this.$members().$size()) + ")")
        };
        name = this.$members()['$[]'](name);
        } else {
        if ((__a = this.$members()['$include?'](name.$to_sym())) === false || __a === nil) {
          this.$raise(__scope.NameError, "no member '" + (name) + "' in struct")
        }
      };
      return this.$instance_variable_set("@" + (name), value);
    };

    // line 4128, (corelib), Struct#each
    Struct_prototype.$each = TMP_73 = function() {
      var __a, __b, __context, __yield;
      __yield = TMP_73._p || nil, __context = __yield._s, TMP_73._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        var __a;
        if (name == null) name = nil;

        return __a = __yield.call(__context, this['$[]'](name)), __a === __breaker ? __a : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 4134, (corelib), Struct#each_pair
    Struct_prototype.$each_pair = TMP_74 = function() {
      var __a, __b, __context, __yield;
      __yield = TMP_74._p || nil, __context = __yield._s, TMP_74._p = null;
      
      if (__yield === nil) {
        return this.$enum_for("each_pair")
      };
      return (__b = this.$members(), __b.$each._p = (__a = function(name) {

        var __a;
        if (name == null) name = nil;

        return __a = __yield.call(__context, name, this['$[]'](name)), __a === __breaker ? __a : __a
      }, __a._s = this, __a), __b.$each());
    };

    // line 4140, (corelib), Struct#eql?
    Struct_prototype['$eql?'] = function(other) {
      var __a, __b, __c;
      return ((__a = this.$hash()['$=='](other.$hash())), __a !== false && __a !== nil ? __a : (__c = other.$each_with_index(), __c['$all?']._p = (__b = function(object, index) {

        
        if (object == null) object = nil;
if (index == null) index = nil;

        return this['$[]'](this.$members()['$[]'](index))['$=='](object)
      }, __b._s = this, __b), __c['$all?']()));
    };

    // line 4146, (corelib), Struct#length
    Struct_prototype.$length = function() {
      
      return this.$members().$length();
    };

    Struct_prototype.$size = Struct_prototype.$length;

    // line 4152, (corelib), Struct#to_a
    Struct_prototype.$to_a = function() {
      var __a, __b;
      return (__b = this.$members(), __b.$map._p = (__a = function(name) {

        
        if (name == null) name = nil;

        return this['$[]'](name)
      }, __a._s = this, __a), __b.$map());
    };

    Struct_prototype.$values = Struct_prototype.$to_a;
    ;Struct._donate(["$initialize", "$members", "$[]", "$[]=", "$each", "$each_pair", "$eql?", "$length", "$size", "$to_a", "$values"]);    ;Struct._sdonate(["$new", "$define_struct_attribute", "$members"]);
  })(self, null);
  var json_parse = JSON.parse;
  (function(__base){
    // line 4161, (corelib), module JSON
    function JSON() {};
    JSON = __module(__base, "JSON", JSON);
    var JSON_prototype = JSON.prototype, __scope = JSON._scope;

    // line 4162, (corelib), JSON.parse
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
  return (function(__base, __super){
    // line 4210, (corelib), class ERB
    function ERB() {};
    ERB = __klass(__base, __super, "ERB", ERB);
    var ERB_prototype = ERB.prototype, __scope = ERB._scope, TMP_75;
    ERB_prototype.body = nil;

    ERB.templates = __hash();

    // line 4214, (corelib), ERB.[]=
    ERB['$[]='] = function(name, instance) {
      
      if (this.templates == null) this.templates = nil;

      return this.templates['$[]='](name, instance)
    };

    // line 4218, (corelib), ERB.[]
    ERB['$[]'] = function(name) {
      
      if (this.templates == null) this.templates = nil;

      return this.templates['$[]'](name)
    };

    // line 4222, (corelib), ERB#initialize
    ERB_prototype.$initialize = TMP_75 = function(name) {
      var __context, body;
      body = TMP_75._p || nil, __context = body._s, TMP_75._p = null;
      
      __scope.ERB['$[]='](name, this);
      return this.body = body;
    };

    // line 4235, (corelib), ERB#result
    ERB_prototype.$result = function(context) {
      var __a;
      return (__a = context, __a.$instance_eval._p = this.body.$to_proc(), __a.$instance_eval());
    };
    ;ERB._donate(["$initialize", "$result"]);    ;ERB._sdonate(["$[]=", "$[]"]);
  })(self, null);
})();
}).call(this);
