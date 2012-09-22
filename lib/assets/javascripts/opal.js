// Opal v0.3.27
// http://opal.github.com
// Copyright 2012, Adam Beynon
// Released under the MIT License
(function(undefined) {
// The Opal object that is exposed globally
var Opal = this.Opal = {};

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

// Initialization
// --------------

boot_defclass('Object', Object);
boot_defclass('Class', Class, Object);

Class.prototype = Function.prototype;
Object._klass = Class._klass = Class;

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

// Donator for singleton (class) methods
function __sdonate(defined) {
  this._smethods = this._smethods.concat(defined);
}

var bridged_classes = Object.$included_in = [];

Object._scope = Opal;
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
Opal.version = "0.3.27";
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, def = self._klass.prototype, __breaker = __opal.breaker, __slice = __opal.slice, __gvars = __opal.gvars, __klass = __opal.klass, __module = __opal.module, __hash = __opal.hash;
  
  __gvars["~"] = nil;
  __gvars["/"] = "\n";
  __scope.RUBY_ENGINE = "opal";
  __scope.RUBY_PLATFORM = "opal";
  __scope.RUBY_VERSION = "1.9.2";
  __scope.OPAL_VERSION = __opal.version;
  self.$to_s = function() {
    
    return "main";
  };
  self.$include = function(mod) {
    
    return __scope.Object.$include(mod);
  };
  (function(__base, __super){
    // line 19, (corelib), class Class
    function Class() {};
    Class = __klass(__base, __super, "Class", Class);
    var Class_prototype = Class.prototype, __scope = Class._scope, TMP_1, TMP_2, TMP_3, TMP_4;

    // line 20, (corelib), Class.new
    Class.$new = TMP_1 = function(sup) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
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

    // line 36, (corelib), Class#allocate
    Class_prototype.$allocate = function() {
      
      
      var obj = new this;
      obj._id = unique_id++;
      return obj;
    
    };

    // line 44, (corelib), Class#alias_method
    Class_prototype.$alias_method = function(newname, oldname) {
      
      this.prototype['$' + newname] = this.prototype['$' + oldname];
      return this;
    };

    // line 49, (corelib), Class#ancestors
    Class_prototype.$ancestors = function() {
      
      
      var parent = this,
          result = [];

      while (parent) {
        result.push(parent);
        parent = parent._super;
      }

      return result;
    
    };

    // line 63, (corelib), Class#append_features
    Class_prototype.$append_features = function(klass) {
      
      
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

    // line 103, (corelib), Class#attr_accessor
    Class_prototype.$attr_accessor = function() {
      
      return nil;
    };

    Class_prototype.$attr_reader = Class_prototype.$attr_accessor;

    Class_prototype.$attr_writer = Class_prototype.$attr_accessor;

    Class_prototype.$attr = Class_prototype.$attr_accessor;

    // line 109, (corelib), Class#define_method
    Class_prototype.$define_method = TMP_2 = function(name) {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
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

    // line 126, (corelib), Class#include
    Class_prototype.$include = function(mods) {
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

    // line 145, (corelib), Class#instance_methods
    Class_prototype.$instance_methods = function(include_super) {
      if (include_super == null) {
        include_super = false
      }
      
      var methods = [], proto = this.prototype;

      for (var prop in this.prototype) {
        if (!include_super && !proto.hasOwnProperty(prop)) {
          continue;
        }

        if (prop.charAt(0) === '$') {
          methods.push(prop.substr(1));
        }
      }

      return methods;
    
    };

    // line 163, (corelib), Class#included
    Class_prototype.$included = function(mod) {
      
      return nil;
    };

    // line 166, (corelib), Class#inherited
    Class_prototype.$inherited = function(cls) {
      
      return nil;
    };

    // line 169, (corelib), Class#module_eval
    Class_prototype.$module_eval = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };

    Class_prototype.$class_eval = Class_prototype.$module_eval;

    // line 181, (corelib), Class#name
    Class_prototype.$name = function() {
      
      return this._name;
    };

    // line 185, (corelib), Class#new
    Class_prototype.$new = TMP_4 = function(args) {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      args = __slice.call(arguments, 0);
      
      var obj = new this;
      obj._id = unique_id++;
      obj.$initialize._p  = block;

      obj.$initialize.apply(obj, args);
      return obj;
    
    };

    // line 196, (corelib), Class#public
    Class_prototype.$public = function() {
      
      return nil;
    };

    Class_prototype.$private = Class_prototype.$public;

    Class_prototype.$protected = Class_prototype.$public;

    // line 202, (corelib), Class#superclass
    Class_prototype.$superclass = function() {
      
      
      return this._super || nil;
    
    };
    ;Class._sdonate(["$new"]);
  })(self, null);
  (function(__base){
    // line 208, (corelib), module Kernel
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_5, TMP_6, TMP_7, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12;

    // line 209, (corelib), Kernel#=~
    Kernel_prototype['$=~'] = function(obj) {
      
      return false;
    };

    // line 213, (corelib), Kernel#==
    Kernel_prototype['$=='] = function(other) {
      
      return this === other;
    };

    // line 217, (corelib), Kernel#===
    Kernel_prototype['$==='] = function(other) {
      
      return this == other;
    };

    // line 221, (corelib), Kernel#__send__
    Kernel_prototype.$__send__ = TMP_5 = function(symbol, args) {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      args = __slice.call(arguments, 1);
      
      return this['$' + symbol].apply(this, args);
    
    };

    Kernel_prototype['$eql?'] = Kernel_prototype['$=='];

    // line 229, (corelib), Kernel#Array
    Kernel_prototype.$Array = function(object) {
      
      
      if (object.$to_ary) {
        return object.$to_ary();
      }
      else if (object.$to_a) {
        return object.$to_a();
      }

      return [object];
    
    };

    // line 242, (corelib), Kernel#attribute_get
    Kernel_prototype.$attribute_get = function(name) {
      
      
      var meth = '$' + name;
      if (this[meth]) {
        return this[meth]();
      }

      meth += '?';
      if (this[meth]) {
        return this[meth]()
      }

      return nil;
    
    };

    // line 258, (corelib), Kernel#attribute_set
    Kernel_prototype.$attribute_set = function(name, value) {
      
      
    if (this['$' + name + '=']) {
      return this['$' + name + '='](value);
    }

    return nil;
  
    };

    // line 268, (corelib), Kernel#class
    Kernel_prototype.$class = function() {
      
      return this._klass;
    };

    // line 272, (corelib), Kernel#define_singleton_method
    Kernel_prototype.$define_singleton_method = TMP_6 = function(name) {
      var __context, body;
      body = TMP_6._p || nil, __context = body._s, TMP_6._p = null;
      
      
      if (body === nil) {
        no_block_given();
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = this[jsid]

      this[jsid] = body;

      return this;
    
    };

    // line 288, (corelib), Kernel#equal?
    Kernel_prototype['$equal?'] = function(other) {
      
      return this === other;
    };

    // line 292, (corelib), Kernel#extend
    Kernel_prototype.$extend = function(mods) {
      mods = __slice.call(arguments, 0);
      
      for (var i = 0, length = mods.length; i < length; i++) {
        this.$singleton_class().$include(mods[i]);
      }

      return this;
    
    };

    // line 302, (corelib), Kernel#hash
    Kernel_prototype.$hash = function() {
      
      return this._id;
    };

    // line 306, (corelib), Kernel#initialize
    Kernel_prototype.$initialize = function() {
      
      return nil;
    };

    // line 309, (corelib), Kernel#inspect
    Kernel_prototype.$inspect = function() {
      
      return this.$to_s();
    };

    // line 313, (corelib), Kernel#instance_eval
    Kernel_prototype.$instance_eval = TMP_7 = function(string) {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this, this);
    
    };

    // line 323, (corelib), Kernel#instance_exec
    Kernel_prototype.$instance_exec = TMP_8 = function(args) {
      var __context, block;
      block = TMP_8._p || nil, __context = block._s, TMP_8._p = null;
      args = __slice.call(arguments, 0);
      
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    
    };

    // line 333, (corelib), Kernel#instance_of?
    Kernel_prototype['$instance_of?'] = function(klass) {
      
      return this._klass === klass;
    };

    // line 337, (corelib), Kernel#instance_variable_defined?
    Kernel_prototype['$instance_variable_defined?'] = function(name) {
      
      return __hasOwn.call(this, name.substr(1));
    };

    // line 341, (corelib), Kernel#instance_variable_get
    Kernel_prototype.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == null ? nil : ivar;
    
    };

    // line 349, (corelib), Kernel#instance_variable_set
    Kernel_prototype.$instance_variable_set = function(name, value) {
      
      return this[name.substr(1)] = value;
    };

    // line 353, (corelib), Kernel#instance_variables
    Kernel_prototype.$instance_variables = function() {
      
      
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    
    };

    // line 365, (corelib), Kernel#is_a?
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

    // line 383, (corelib), Kernel#lambda
    Kernel_prototype.$lambda = TMP_9 = function() {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      return block;
    };

    // line 387, (corelib), Kernel#loop
    Kernel_prototype.$loop = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      while (true) {;
      if (block.call(__context) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 395, (corelib), Kernel#nil?
    Kernel_prototype['$nil?'] = function() {
      
      return false;
    };

    // line 399, (corelib), Kernel#object_id
    Kernel_prototype.$object_id = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 403, (corelib), Kernel#proc
    Kernel_prototype.$proc = TMP_11 = function() {
      var __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }
      block.is_lambda = false;
      return block;
    
    };

    // line 413, (corelib), Kernel#puts
    Kernel_prototype.$puts = function(strs) {
      strs = __slice.call(arguments, 0);
      
      for (var i = 0; i < strs.length; i++) {
        __opal.puts((strs[i]).$to_s());
      }
    
      return nil;
    };

    Kernel_prototype.$print = Kernel_prototype.$puts;

    // line 424, (corelib), Kernel#raise
    Kernel_prototype.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = __scope.RuntimeError.$new(exception);
      }
      else if (!exception['$is_a?'](__scope.Exception)) {
        exception = exception.$new(string);
      }

      throw exception;
    
    };

    // line 437, (corelib), Kernel#rand
    Kernel_prototype.$rand = function(max) {
      
      return max == null ? Math.random() : Math.floor(Math.random() * max);
    };

    // line 441, (corelib), Kernel#respond_to?
    Kernel_prototype['$respond_to?'] = function(name) {
      
      return !!this['$' + name];
    };

    Kernel_prototype.$send = Kernel_prototype.$__send__;

    // line 447, (corelib), Kernel#singleton_class
    Kernel_prototype.$singleton_class = function() {
      
      
      if (this._isClass) {
        if (this._singleton) {
          return this._singleton;
        }

        var meta = new __opal.Class;
        meta._klass = __opal.Class;
        this._singleton = meta;
        meta.prototype = this;

        return meta;
      }

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

    // line 487, (corelib), Kernel#tap
    Kernel_prototype.$tap = TMP_12 = function() {
      var __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      if (block.call(__context, this) === __breaker) return __breaker.$v;
      return this;
    };

    // line 492, (corelib), Kernel#to_json
    Kernel_prototype.$to_json = function() {
      
      return this.$to_s().$to_json();
    };

    // line 496, (corelib), Kernel#to_proc
    Kernel_prototype.$to_proc = function() {
      
      return this;
    };

    // line 500, (corelib), Kernel#to_s
    Kernel_prototype.$to_s = function() {
      
      return "#<" + this._klass._name + ":" + this._id + ">";
    };
        ;Kernel._donate(["$=~", "$==", "$===", "$__send__", "$eql?", "$Array", "$attribute_get", "$attribute_set", "$class", "$define_singleton_method", "$equal?", "$extend", "$hash", "$initialize", "$inspect", "$instance_eval", "$instance_exec", "$instance_of?", "$instance_variable_defined?", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a?", "$kind_of?", "$lambda", "$loop", "$nil?", "$object_id", "$proc", "$puts", "$print", "$raise", "$rand", "$respond_to?", "$send", "$singleton_class", "$tap", "$to_json", "$to_proc", "$to_s"]);
  })(self);
  (function(__base, __super){
    // line 504, (corelib), class NilClass
    function NilClass() {};
    NilClass = __klass(__base, __super, "NilClass", NilClass);
    var NilClass_prototype = NilClass.prototype, __scope = NilClass._scope;

    // line 505, (corelib), NilClass#&
    NilClass_prototype['$&'] = function(other) {
      
      return false;
    };

    // line 509, (corelib), NilClass#|
    NilClass_prototype['$|'] = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 513, (corelib), NilClass#^
    NilClass_prototype['$^'] = function(other) {
      
      return other !== false && other !== nil;
    };

    // line 517, (corelib), NilClass#==
    NilClass_prototype['$=='] = function(other) {
      
      return other === nil;
    };

    // line 521, (corelib), NilClass#inspect
    NilClass_prototype.$inspect = function() {
      
      return "nil";
    };

    // line 525, (corelib), NilClass#nil?
    NilClass_prototype['$nil?'] = function() {
      
      return true;
    };

    // line 529, (corelib), NilClass#singleton_class
    NilClass_prototype.$singleton_class = function() {
      
      return __scope.NilClass;
    };

    // line 533, (corelib), NilClass#to_a
    NilClass_prototype.$to_a = function() {
      
      return [];
    };

    // line 537, (corelib), NilClass#to_i
    NilClass_prototype.$to_i = function() {
      
      return 0;
    };

    NilClass_prototype.$to_f = NilClass_prototype.$to_i;

    // line 543, (corelib), NilClass#to_json
    NilClass_prototype.$to_json = function() {
      
      return "null";
    };

    // line 547, (corelib), NilClass#to_native
    NilClass_prototype.$to_native = function() {
      
      return null;
    };

    // line 551, (corelib), NilClass#to_s
    NilClass_prototype.$to_s = function() {
      
      return "";
    };

  })(self, null);
  (function(__base, __super){
    // line 555, (corelib), class Boolean
    function Boolean() {};
    Boolean = __klass(__base, __super, "Boolean", Boolean);
    var Boolean_prototype = Boolean.prototype, __scope = Boolean._scope;

    
    Boolean_prototype._isBoolean = true;
  

    // line 560, (corelib), Boolean#&
    Boolean_prototype['$&'] = function(other) {
      
      return (this == true) ? (other !== false && other !== nil) : false;
    };

    // line 564, (corelib), Boolean#|
    Boolean_prototype['$|'] = function(other) {
      
      return (this == true) ? true : (other !== false && other !== nil);
    };

    // line 568, (corelib), Boolean#^
    Boolean_prototype['$^'] = function(other) {
      
      return (this == true) ? (other === false || other === nil) : (other !== false && other !== nil);
    };

    // line 572, (corelib), Boolean#==
    Boolean_prototype['$=='] = function(other) {
      
      return (this == true) === other.valueOf();
    };

    Boolean_prototype.$singleton_class = Boolean_prototype.$class;

    // line 578, (corelib), Boolean#to_json
    Boolean_prototype.$to_json = function() {
      
      return (this == true) ? 'true' : 'false';
    };

    // line 582, (corelib), Boolean#to_s
    Boolean_prototype.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };

  })(self, Boolean);
  (function(__base, __super){
    // line 586, (corelib), class Exception
    function Exception() {};
    Exception = __klass(__base, __super, "Exception", Exception);
    var Exception_prototype = Exception.prototype, __scope = Exception._scope;
    Exception_prototype.message = nil;

    // line 587, (corelib), Exception#message
    Exception_prototype.$message = function() {
      
      return this.message
    };

    // line 589, (corelib), Exception.new
    Exception.$new = function(message) {
      if (message == null) {
        message = ""
      }
      
      var err = new Error(message);
      err._klass = this;
      return err;
    
    };

    // line 597, (corelib), Exception#backtrace
    Exception_prototype.$backtrace = function() {
      
      
      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return backtrace.split("\n").slice(0, 15);
      }
      else if (backtrace) {
        return backtrace.slice(0, 15);
      }

      return [];
    
    };

    // line 612, (corelib), Exception#inspect
    Exception_prototype.$inspect = function() {
      
      return "#<" + (this.$class().$name()) + ": '" + (this.message) + "'>";
    };

    Exception_prototype.$to_s = Exception_prototype.$message;
    ;Exception._sdonate(["$new"]);
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
    // line 629, (corelib), class Regexp
    function Regexp() {};
    Regexp = __klass(__base, __super, "Regexp", Regexp);
    var Regexp_prototype = Regexp.prototype, __scope = Regexp._scope;

    // line 630, (corelib), Regexp.escape
    Regexp.$escape = function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    };

    // line 634, (corelib), Regexp.new
    Regexp.$new = function(string, options) {
      
      return new RegExp(string, options);
    };

    // line 638, (corelib), Regexp#==
    Regexp_prototype['$=='] = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };

    Regexp_prototype['$==='] = Regexp_prototype.test;

    // line 644, (corelib), Regexp#=~
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

    Regexp_prototype.$inspect = Regexp_prototype.toString;

    // line 667, (corelib), Regexp#match
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

    // line 684, (corelib), Regexp#to_s
    Regexp_prototype.$to_s = function() {
      
      return this.source;
    };

    
    function match_to_s() {
      return this[0];
    }

    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }
  
    ;Regexp._sdonate(["$escape", "$new"]);
  })(self, RegExp);
  (function(__base, __super){
    // line 699, (corelib), class MatchData
    function MatchData() {};
    MatchData = __klass(__base, __super, "MatchData", MatchData);
    var MatchData_prototype = MatchData.prototype, __scope = MatchData._scope;

    nil

  })(self, null);
  (function(__base){
    // line 701, (corelib), module Comparable
    function Comparable() {};
    Comparable = __module(__base, "Comparable", Comparable);
    var Comparable_prototype = Comparable.prototype, __scope = Comparable._scope;

    // line 702, (corelib), Comparable#<
    Comparable_prototype['$<'] = function(other) {
      
      return this['$<=>'](other)['$=='](-1);
    };

    // line 706, (corelib), Comparable#<=
    Comparable_prototype['$<='] = function(other) {
      
      return this['$<=>'](other)['$<='](0);
    };

    // line 710, (corelib), Comparable#==
    Comparable_prototype['$=='] = function(other) {
      
      return this['$<=>'](other)['$=='](0);
    };

    // line 714, (corelib), Comparable#>
    Comparable_prototype['$>'] = function(other) {
      
      return this['$<=>'](other)['$=='](1);
    };

    // line 718, (corelib), Comparable#>=
    Comparable_prototype['$>='] = function(other) {
      
      return this['$<=>'](other)['$>='](0);
    };

    // line 722, (corelib), Comparable#between?
    Comparable_prototype['$between?'] = function(min, max) {
      var __a;
      return ((__a = this['$>'](min)) ? this['$<'](max) : __a);
    };
        ;Comparable._donate(["$<", "$<=", "$==", "$>", "$>=", "$between?"]);
  })(self);
  (function(__base){
    // line 726, (corelib), module Enumerable
    function Enumerable() {};
    Enumerable = __module(__base, "Enumerable", Enumerable);
    var Enumerable_prototype = Enumerable.prototype, __scope = Enumerable._scope, TMP_13, TMP_14, TMP_15, TMP_16, TMP_17, TMP_18, TMP_19, TMP_20, TMP_21, TMP_22, TMP_23;

    // line 727, (corelib), Enumerable#all?
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

    // line 765, (corelib), Enumerable#any?
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

    // line 803, (corelib), Enumerable#collect
    Enumerable_prototype.$collect = TMP_15 = function() {
      var __context, block;
      block = TMP_15._p || nil, __context = block._s, TMP_15._p = null;
      
      
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

    // line 824, (corelib), Enumerable#count
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

    // line 854, (corelib), Enumerable#detect
    Enumerable_prototype.$detect = TMP_17 = function(ifnone) {
      var __context, block;
      block = TMP_17._p || nil, __context = block._s, TMP_17._p = null;
      
      
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

    // line 887, (corelib), Enumerable#drop
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

    // line 906, (corelib), Enumerable#drop_while
    Enumerable_prototype.$drop_while = TMP_18 = function() {
      var __context, block;
      block = TMP_18._p || nil, __context = block._s, TMP_18._p = null;
      
      
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

    // line 932, (corelib), Enumerable#each_with_index
    Enumerable_prototype.$each_with_index = TMP_19 = function() {
      var __context, block;
      block = TMP_19._p || nil, __context = block._s, TMP_19._p = null;
      
      
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

    // line 952, (corelib), Enumerable#each_with_object
    Enumerable_prototype.$each_with_object = TMP_20 = function(object) {
      var __context, block;
      block = TMP_20._p || nil, __context = block._s, TMP_20._p = null;
      
      
      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      this.$each();

      return object;
    
    };

    // line 968, (corelib), Enumerable#entries
    Enumerable_prototype.$entries = function() {
      
      
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    
    };

    Enumerable_prototype.$find = Enumerable_prototype.$detect;

    // line 984, (corelib), Enumerable#find_all
    Enumerable_prototype.$find_all = TMP_21 = function() {
      var __context, block;
      block = TMP_21._p || nil, __context = block._s, TMP_21._p = null;
      
      
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

    // line 1006, (corelib), Enumerable#find_index
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
      else {
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

    // line 1044, (corelib), Enumerable#first
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

    // line 1074, (corelib), Enumerable#grep
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

    Enumerable_prototype.$select = Enumerable_prototype.$find_all;

    Enumerable_prototype.$take = Enumerable_prototype.$first;

    Enumerable_prototype.$to_a = Enumerable_prototype.$entries;
        ;Enumerable._donate(["$all?", "$any?", "$collect", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$each_with_object", "$entries", "$find", "$find_all", "$find_index", "$first", "$grep", "$select", "$take", "$to_a"]);
  })(self);
  (function(__base, __super){
    // line 1110, (corelib), class Array
    function Array() {};
    Array = __klass(__base, __super, "Array", Array);
    var Array_prototype = Array.prototype, __scope = Array._scope, TMP_24, TMP_25, TMP_26, TMP_27, TMP_28, TMP_29, TMP_30, TMP_31, TMP_32, TMP_33, TMP_34, TMP_35, TMP_36, TMP_37, TMP_38, TMP_39, TMP_40;

    
    Array_prototype._isArray = true;
  

    Array.$include(__scope.Enumerable);

    // line 1117, (corelib), Array.[]
    Array['$[]'] = function(objects) {
      objects = __slice.call(arguments, 0);
      
      return objects;
    
    };

    // line 1123, (corelib), Array.new
    Array.$new = TMP_24 = function(size, obj) {
      var __context, block;
      block = TMP_24._p || nil, __context = block._s, TMP_24._p = null;
      if (obj == null) {
        obj = nil
      }
      
      var arr = [];

      if (size && size._isArray) {
        for (var i = 0; i < size.length; i++) {
          arr[i] = size[i];
        }
      }
      else {
        if (block === nil) {
          for (var i = 0; i < size; i++) {
            arr[i] = obj;
          }
        }
        else {
          for (var i = 0; i < size; i++) {
            arr[i] = block.call(__context, i);
          }
        }
      }

      return arr;
    
    };

    // line 1149, (corelib), Array#&
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

    // line 1174, (corelib), Array#*
    Array_prototype['$*'] = function(other) {
      
      
      if (typeof(other) === 'string') {
        return this.join(other);
      }

      var result = [];

      for (var i = 0; i < other; i++) {
        result = result.concat(this);
      }

      return result;
    
    };

    // line 1190, (corelib), Array#+
    Array_prototype['$+'] = function(other) {
      
      return this.slice().concat(other.slice());
    };

    // line 1194, (corelib), Array#-
    Array_prototype['$-'] = function(other) {
      var __a, __b;
      return (__b = this, __b.$reject._p = (__a = function(i) {

        
        if (i == null) i = nil;

        return other['$include?'](i)
      }, __a._s = this, __a), __b.$reject());
    };

    // line 1198, (corelib), Array#<<
    Array_prototype['$<<'] = function(object) {
      
      this.push(object);
      return this;
    };

    // line 1204, (corelib), Array#<=>
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

    // line 1224, (corelib), Array#==
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

    // line 1240, (corelib), Array#[]
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

    // line 1287, (corelib), Array#[]=
    Array_prototype['$[]='] = function(index, value) {
      
      
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    
    };

    // line 1299, (corelib), Array#assoc
    Array_prototype.$assoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && (item[0])['$=='](object)) {
          return item;
        }
      }

      return nil;
    
    };

    // line 1311, (corelib), Array#at
    Array_prototype.$at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    
    };

    // line 1325, (corelib), Array#clear
    Array_prototype.$clear = function() {
      
      this.splice(0, this.length);
      return this;
    };

    // line 1331, (corelib), Array#clone
    Array_prototype.$clone = function() {
      
      return this.slice();
    };

    // line 1335, (corelib), Array#collect
    Array_prototype.$collect = TMP_25 = function() {
      var __context, block;
      block = TMP_25._p || nil, __context = block._s, TMP_25._p = null;
      
      
      var result = [];

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      }

      return result;
    
    };

    // line 1351, (corelib), Array#collect!
    Array_prototype['$collect!'] = TMP_26 = function() {
      var __context, block;
      block = TMP_26._p || nil, __context = block._s, TMP_26._p = null;
      
      
      for (var i = 0, length = this.length, val; i < length; i++) {
        if ((val = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        this[i] = val;
      }
    
      return this;
    };

    // line 1365, (corelib), Array#compact
    Array_prototype.$compact = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

    // line 1379, (corelib), Array#compact!
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

    // line 1396, (corelib), Array#concat
    Array_prototype.$concat = function(other) {
      
      
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    
      return this;
    };

    // line 1406, (corelib), Array#count
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

    // line 1424, (corelib), Array#delete
    Array_prototype.$delete = function(object) {
      
      
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

    // line 1441, (corelib), Array#delete_at
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

    // line 1459, (corelib), Array#delete_if
    Array_prototype.$delete_if = TMP_27 = function() {
      var __context, block;
      block = TMP_27._p || nil, __context = block._s, TMP_27._p = null;
      
      
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

    // line 1478, (corelib), Array#drop
    Array_prototype.$drop = function(number) {
      
      return this.slice(number);
    };

    Array_prototype.$dup = Array_prototype.$clone;

    // line 1484, (corelib), Array#each
    Array_prototype.$each = TMP_28 = function() {
      var __context, block;
      block = TMP_28._p || nil, __context = block._s, TMP_28._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, this[i]) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 1492, (corelib), Array#each_index
    Array_prototype.$each_index = TMP_29 = function() {
      var __context, block;
      block = TMP_29._p || nil, __context = block._s, TMP_29._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, i) === __breaker) return __breaker.$v;
      };
      return this;
    };

    // line 1500, (corelib), Array#empty?
    Array_prototype['$empty?'] = function() {
      
      return !this.length;
    };

    // line 1504, (corelib), Array#fetch
    Array_prototype.$fetch = TMP_30 = function(index, defaults) {
      var __context, block;
      block = TMP_30._p || nil, __context = block._s, TMP_30._p = null;
      
      
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

    // line 1528, (corelib), Array#first
    Array_prototype.$first = function(count) {
      
      
      if (count != null) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    
    };

    // line 1538, (corelib), Array#flatten
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

    // line 1565, (corelib), Array#flatten!
    Array_prototype['$flatten!'] = function(level) {
      
      
      var size = this.length;
      this.$replace(this.$flatten(level));

      return size === this.length ? nil : this;
    
    };

    // line 1574, (corelib), Array#hash
    Array_prototype.$hash = function() {
      
      return this._id || (this._id = unique_id++);
    };

    // line 1578, (corelib), Array#include?
    Array_prototype['$include?'] = function(member) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i])['$=='](member)) {
          return true;
        }
      }

      return false;
    
    };

    // line 1590, (corelib), Array#index
    Array_prototype.$index = TMP_31 = function(object) {
      var __context, block;
      block = TMP_31._p || nil, __context = block._s, TMP_31._p = null;
      
      
      if (object != null) {
        for (var i = 0, length = this.length; i < length; i++) {
          if ((this[i])['$=='](object)) {
            return i;
          }
        }
      }
      else if (block !== nil) {
        for (var i = 0, length = this.length, value; i < length; i++) {
          if ((value = block.call(__context, this[i])) === __breaker) {
            return __breaker.$v;
          }

          if (value !== false && value !== nil) {
            return i;
          }
        }
      }

      return nil;
    
    };

    // line 1615, (corelib), Array#insert
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

    // line 1638, (corelib), Array#inspect
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

    // line 1658, (corelib), Array#join
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

    // line 1670, (corelib), Array#keep_if
    Array_prototype.$keep_if = TMP_32 = function() {
      var __context, block;
      block = TMP_32._p || nil, __context = block._s, TMP_32._p = null;
      
      
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

    // line 1689, (corelib), Array#last
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

    // line 1708, (corelib), Array#length
    Array_prototype.$length = function() {
      
      return this.length;
    };

    Array_prototype.$map = Array_prototype.$collect;

    Array_prototype['$map!'] = Array_prototype['$collect!'];

    // line 1716, (corelib), Array#pop
    Array_prototype.$pop = function(count) {
      
      
      var length = this.length;

      if (count == null) {
        return length === 0 ? nil : this.pop();
      }

      if (count < 0) {
        this.$raise("negative count given");
      }

      return count > length ? this.splice(0, this.length) : this.splice(length - count, length);
    
    };

    // line 1732, (corelib), Array#push
    Array_prototype.$push = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    
      return this;
    };

    // line 1742, (corelib), Array#rassoc
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

    // line 1758, (corelib), Array#reject
    Array_prototype.$reject = TMP_33 = function() {
      var __context, block;
      block = TMP_33._p || nil, __context = block._s, TMP_33._p = null;
      
      
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

    // line 1775, (corelib), Array#reject!
    Array_prototype['$reject!'] = TMP_34 = function() {
      var __context, block;
      block = TMP_34._p || nil, __context = block._s, TMP_34._p = null;
      
      
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

    // line 1796, (corelib), Array#replace
    Array_prototype.$replace = function(other) {
      
      
      this.splice(0, this.length);
      this.push.apply(this, other);
      return this;
    
    };

    Array_prototype.$reverse = Array_prototype.reverse;

    // line 1806, (corelib), Array#reverse!
    Array_prototype['$reverse!'] = function() {
      
      
      this.splice(0);
      this.push.apply(this, this.$reverse());
      return this;
    
    };

    // line 1814, (corelib), Array#reverse_each
    Array_prototype.$reverse_each = TMP_35 = function() {
      var __a, __context, block;
      block = TMP_35._p || nil, __context = block._s, TMP_35._p = null;
      
      (__a = this.$reverse(), __a.$each._p = block.$to_proc(), __a.$each());
      return this;
    };

    // line 1820, (corelib), Array#rindex
    Array_prototype.$rindex = TMP_36 = function(object) {
      var __context, block;
      block = TMP_36._p || nil, __context = block._s, TMP_36._p = null;
      
      
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
          if ((this[i])['$=='](object)) {
            return i;
          }
        }
      }

      return nil;
    
    };

    // line 1845, (corelib), Array#select
    Array_prototype.$select = TMP_37 = function() {
      var __context, block;
      block = TMP_37._p || nil, __context = block._s, TMP_37._p = null;
      
      
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

    // line 1865, (corelib), Array#select!
    Array_prototype['$select!'] = TMP_38 = function() {
      var __context, block;
      block = TMP_38._p || nil, __context = block._s, TMP_38._p = null;
      
      
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

    // line 1888, (corelib), Array#shift
    Array_prototype.$shift = function(count) {
      
      
      if (this.length === 0) {
        return nil;
      }

      return count == null ? this.shift() : this.splice(0, count)
    
    };

    Array_prototype.$size = Array_prototype.$length;

    Array_prototype.$slice = Array_prototype['$[]'];

    // line 1902, (corelib), Array#slice!
    Array_prototype['$slice!'] = function(index, length) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (length != null) {
        return this.splice(index, length);
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this.splice(index, 1)[0];
    
    };

    // line 1920, (corelib), Array#take
    Array_prototype.$take = function(count) {
      
      return this.slice(0, count);
    };

    // line 1924, (corelib), Array#take_while
    Array_prototype.$take_while = TMP_39 = function() {
      var __context, block;
      block = TMP_39._p || nil, __context = block._s, TMP_39._p = null;
      
      
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

    // line 1946, (corelib), Array#to_a
    Array_prototype.$to_a = function() {
      
      return this;
    };

    Array_prototype.$to_ary = Array_prototype.$to_a;

    // line 1952, (corelib), Array#to_json
    Array_prototype.$to_json = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_json());
      }

      return '[' + result.join(', ') + ']';
    
    };

    Array_prototype.$to_s = Array_prototype.$inspect;

    // line 1966, (corelib), Array#uniq
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

    // line 1986, (corelib), Array#uniq!
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

    // line 2010, (corelib), Array#unshift
    Array_prototype.$unshift = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = objects.length - 1; i >= 0; i--) {
        this.unshift(objects[i]);
      }

      return this;
    
    };

    // line 2020, (corelib), Array#zip
    Array_prototype.$zip = TMP_40 = function(others) {
      var __context, block;
      block = TMP_40._p || nil, __context = block._s, TMP_40._p = null;
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
    ;Array._sdonate(["$[]", "$new"]);
  })(self, Array);
  (function(__base, __super){
    // line 2052, (corelib), class Hash
    function Hash() {};
    Hash = __klass(__base, __super, "Hash", Hash);
    var Hash_prototype = Hash.prototype, __scope = Hash._scope, TMP_41, TMP_42, TMP_43, TMP_44, TMP_45, TMP_46, TMP_47, TMP_48, TMP_49, TMP_50, TMP_51, TMP_52;
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
  

    // line 2072, (corelib), Hash.[]
    Hash['$[]'] = function(objs) {
      objs = __slice.call(arguments, 0);
      return __hash.apply(null, objs);
    };

    // line 2076, (corelib), Hash.allocate
    Hash.$allocate = function() {
      
      return __hash();
    };

    // line 2080, (corelib), Hash.from_native
    Hash.$from_native = function(obj) {
      
      
      var hash = __hash(), map = hash.map;

      for (var key in obj) {
        map[key] = [key, obj[key]]
      }

      return hash;
    
    };

    // line 2092, (corelib), Hash.new
    Hash.$new = TMP_41 = function(defaults) {
      var __context, block;
      block = TMP_41._p || nil, __context = block._s, TMP_41._p = null;
      
      
      var hash = __hash();

      if (defaults != null) {
        hash.none = defaults;
      }
      else if (block !== nil) {
        hash.proc = block;
      }

      return hash;
    
    };

    // line 2107, (corelib), Hash#==
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

    // line 2137, (corelib), Hash#[]
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

    // line 2155, (corelib), Hash#[]=
    Hash_prototype['$[]='] = function(key, value) {
      
      
      this.map[key] = [key, value];

      return value;
    
    };

    // line 2163, (corelib), Hash#assoc
    Hash_prototype.$assoc = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if ((bucket[0])['$=='](object)) {
          return [bucket[0], bucket[1]];
        }
      }

      return nil;
    
    };

    // line 2177, (corelib), Hash#clear
    Hash_prototype.$clear = function() {
      
      
      this.map = {};

      return this;
    
    };

    // line 2185, (corelib), Hash#clone
    Hash_prototype.$clone = function() {
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map;

      for (var assoc in map) {
        map2[assoc] = [map[assoc][0], map[assoc][1]];
      }

      return result;
    
    };

    // line 2199, (corelib), Hash#default
    Hash_prototype.$default = function() {
      
      return this.none;
    };

    // line 2203, (corelib), Hash#default=
    Hash_prototype['$default='] = function(object) {
      
      return this.none = object;
    };

    // line 2207, (corelib), Hash#default_proc
    Hash_prototype.$default_proc = function() {
      
      return this.proc;
    };

    // line 2211, (corelib), Hash#default_proc=
    Hash_prototype['$default_proc='] = function(proc) {
      
      return this.proc = proc;
    };

    // line 2215, (corelib), Hash#delete
    Hash_prototype.$delete = function(key) {
      
      
      var map  = this.map, result;

      if (result = map[key]) {
        result = result[1];

        delete map[key];
        return result;
      }

      return nil;
    
    };

    // line 2230, (corelib), Hash#delete_if
    Hash_prototype.$delete_if = TMP_42 = function() {
      var __context, block;
      block = TMP_42._p || nil, __context = block._s, TMP_42._p = null;
      
      
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

    // line 2253, (corelib), Hash#each
    Hash_prototype.$each = TMP_43 = function() {
      var __context, block;
      block = TMP_43._p || nil, __context = block._s, TMP_43._p = null;
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[0], bucket[1]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 2269, (corelib), Hash#each_key
    Hash_prototype.$each_key = TMP_44 = function() {
      var __context, block;
      block = TMP_44._p || nil, __context = block._s, TMP_44._p = null;
      
      
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

    // line 2287, (corelib), Hash#each_value
    Hash_prototype.$each_value = TMP_45 = function() {
      var __context, block;
      block = TMP_45._p || nil, __context = block._s, TMP_45._p = null;
      
      
      var map = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        if (block.call(__context, bucket[1]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 2303, (corelib), Hash#empty?
    Hash_prototype['$empty?'] = function() {
      
      
      for (var assoc in this.map) {
        return false;
      }

      return true;
    
    };

    Hash_prototype['$eql?'] = Hash_prototype['$=='];

    // line 2315, (corelib), Hash#fetch
    Hash_prototype.$fetch = TMP_46 = function(key, defaults) {
      var __context, block;
      block = TMP_46._p || nil, __context = block._s, TMP_46._p = null;
      
      
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

    // line 2341, (corelib), Hash#flatten
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

    // line 2370, (corelib), Hash#has_key?
    Hash_prototype['$has_key?'] = function(key) {
      
      return !!this.map[key];
    };

    // line 2374, (corelib), Hash#has_value?
    Hash_prototype['$has_value?'] = function(value) {
      
      
      for (var assoc in this.map) {
        if ((this.map[assoc][1])['$=='](value)) {
          return true;
        }
      }

      return false;
    
    };

    // line 2386, (corelib), Hash#hash
    Hash_prototype.$hash = function() {
      
      return this._id;
    };

    Hash_prototype['$include?'] = Hash_prototype['$has_key?'];

    // line 2392, (corelib), Hash#index
    Hash_prototype.$index = function(object) {
      
      
      for (var assoc in this.map) {
        var bucket = this.map[assoc];

        if (object['$=='](bucket[1])) {
          return bucket[0];
        }
      }

      return nil;
    
    };

    // line 2406, (corelib), Hash#indexes
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

    // line 2427, (corelib), Hash#inspect
    Hash_prototype.$inspect = function() {
      
      
      var inspect = [],
          map     = this.map;

      for (var assoc in map) {
        var bucket = map[assoc];

        inspect.push((bucket[0]).$inspect() + '=>' + (bucket[1]).$inspect());
      }
      return '{' + inspect.join(', ') + '}';
    
    };

    // line 2441, (corelib), Hash#invert
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

    // line 2457, (corelib), Hash#keep_if
    Hash_prototype.$keep_if = TMP_47 = function() {
      var __context, block;
      block = TMP_47._p || nil, __context = block._s, TMP_47._p = null;
      
      
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

    // line 2481, (corelib), Hash#keys
    Hash_prototype.$keys = function() {
      
      
      var result = [];

      for (var assoc in this.map) {
        result.push(this.map[assoc][0]);
      }

      return result;
    
    };

    // line 2493, (corelib), Hash#length
    Hash_prototype.$length = function() {
      
      
      var result = 0;

      for (var assoc in this.map) {
        result++;
      }

      return result;
    
    };

    Hash_prototype['$member?'] = Hash_prototype['$has_key?'];

    // line 2507, (corelib), Hash#merge
    Hash_prototype.$merge = TMP_48 = function(other) {
      var __context, block;
      block = TMP_48._p || nil, __context = block._s, TMP_48._p = null;
      
      
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

    // line 2544, (corelib), Hash#merge!
    Hash_prototype['$merge!'] = TMP_49 = function(other) {
      var __context, block;
      block = TMP_49._p || nil, __context = block._s, TMP_49._p = null;
      
      
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

    // line 2572, (corelib), Hash#rassoc
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

    // line 2588, (corelib), Hash#reject
    Hash_prototype.$reject = TMP_50 = function() {
      var __context, block;
      block = TMP_50._p || nil, __context = block._s, TMP_50._p = null;
      
      
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

    // line 2609, (corelib), Hash#replace
    Hash_prototype.$replace = function(other) {
      
      
      var map = this.map = {};

      for (var assoc in other.map) {
        var bucket = other.map[assoc];

        map[bucket[0]] = [bucket[0], bucket[1]];
      }

      return this;
    
    };

    // line 2623, (corelib), Hash#select
    Hash_prototype.$select = TMP_51 = function() {
      var __context, block;
      block = TMP_51._p || nil, __context = block._s, TMP_51._p = null;
      
      
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

    // line 2644, (corelib), Hash#select!
    Hash_prototype['$select!'] = TMP_52 = function() {
      var __context, block;
      block = TMP_52._p || nil, __context = block._s, TMP_52._p = null;
      
      
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

    // line 2666, (corelib), Hash#shift
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

    // line 2682, (corelib), Hash#to_a
    Hash_prototype.$to_a = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        var bucket = map[assoc];

        result.push([bucket[0], bucket[1]]);
      }

      return result;
    
    };

    // line 2697, (corelib), Hash#to_hash
    Hash_prototype.$to_hash = function() {
      
      return this;
    };

    // line 2701, (corelib), Hash#to_json
    Hash_prototype.$to_json = function() {
      
      
      var parts = [], map = this.map, bucket;

      for (var assoc in map) {
        bucket = map[assoc];
        parts.push((bucket[0]).$to_json() + ': ' + (bucket[1]).$to_json());
      }

      return '{' + parts.join(', ') + '}';
    
    };

    // line 2714, (corelib), Hash#to_native
    Hash_prototype.$to_native = function() {
      
      
      var result = {}, map = this.map, bucket, value;

      for (var assoc in map) {
        bucket = map[assoc];
        value  = bucket[1];

        if (value.$to_native) {
          result[assoc] = (value).$to_native();
        }
        else {
          result[assoc] = value;
        }
      }

      return result;
    
    };

    Hash_prototype.$to_s = Hash_prototype.$inspect;

    Hash_prototype.$update = Hash_prototype['$merge!'];

    // line 2738, (corelib), Hash#value?
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

    // line 2755, (corelib), Hash#values
    Hash_prototype.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var assoc in map) {
        result.push(map[assoc][1]);
      }

      return result;
    
    };
    ;Hash._sdonate(["$[]", "$allocate", "$from_native", "$new"]);
  })(self, null);
  (function(__base, __super){
    // line 2768, (corelib), class String
    function String() {};
    String = __klass(__base, __super, "String", String);
    var String_prototype = String.prototype, __scope = String._scope, TMP_53, TMP_54, TMP_55, TMP_56, TMP_57;

    String_prototype._isString = true;

    String.$include(__scope.Comparable);

    // line 2773, (corelib), String.try_convert
    String.$try_convert = function(what) {
      
      return (function() { try {
      what.$to_str()
      } catch ($err) {
      if (true) {
      nil}
      else { throw $err; }
      } }).call(this)
    };

    // line 2779, (corelib), String.new
    String.$new = function(str) {
      if (str == null) {
        str = ""
      }
      
      return new String(str)
    ;
    };

    // line 2785, (corelib), String#%
    String_prototype['$%'] = function(data) {
      
      
      var idx = 0;
      return this.replace(/%((%)|s)/g, function (match) {
        return match[2] || data[idx++] || '';
      });
    
    };

    // line 2794, (corelib), String#*
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

    // line 2815, (corelib), String#+
    String_prototype['$+'] = function(other) {
      
      return this.toString() + other;
    };

    // line 2819, (corelib), String#<=>
    String_prototype['$<=>'] = function(other) {
      
      
      if (typeof other !== 'string') {
        return nil;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    
    };

    // line 2829, (corelib), String#<
    String_prototype['$<'] = function(other) {
      
      return this < other;
    };

    // line 2833, (corelib), String#<=
    String_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    // line 2837, (corelib), String#>
    String_prototype['$>'] = function(other) {
      
      return this > other;
    };

    // line 2841, (corelib), String#>=
    String_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    // line 2845, (corelib), String#==
    String_prototype['$=='] = function(other) {
      
      return other == String(this);
    };

    String_prototype['$==='] = String_prototype['$=='];

    // line 2851, (corelib), String#=~
    String_prototype['$=~'] = function(other) {
      
      
      if (typeof other === 'string') {
        this.$raise("string given");
      }

      return other['$=~'](this);
    
    };

    // line 2861, (corelib), String#[]
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

    // line 2902, (corelib), String#capitalize
    String_prototype.$capitalize = function() {
      
      return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
    };

    // line 2906, (corelib), String#casecmp
    String_prototype.$casecmp = function(other) {
      
      
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    
    };

    // line 2919, (corelib), String#chars
    String_prototype.$chars = TMP_53 = function() {
      var __context, __yield;
      __yield = TMP_53._p || nil, __context = __yield._s, TMP_53._p = null;
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (__yield.call(__context, this.charAt(i)) === __breaker) return __breaker.$v
      }
    
    };

    // line 2927, (corelib), String#chomp
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

    // line 2939, (corelib), String#chop
    String_prototype.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };

    // line 2943, (corelib), String#chr
    String_prototype.$chr = function() {
      
      return this.charAt(0);
    };

    // line 2947, (corelib), String#count
    String_prototype.$count = function(str) {
      
      return (this.length - this.replace(new RegExp(str,"g"), '').length) / str.length;
    };

    // line 2951, (corelib), String#demodulize
    String_prototype.$demodulize = function() {
      
      
      var idx = this.lastIndexOf('::');

      if (idx > -1) {
        return this.substr(idx + 2);
      }
      
      return this;
    
    };

    String_prototype.$downcase = String_prototype.toLowerCase;

    String_prototype.$each_char = String_prototype.$chars;

    // line 2967, (corelib), String#each_line
    String_prototype.$each_line = TMP_54 = function(separator) {
      var __context, __yield;
      __yield = TMP_54._p || nil, __context = __yield._s, TMP_54._p = null;
      if (separator == null) {
        separator = __gvars["/"]
      }
      
      var splitted = this.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        if (__yield.call(__context, splitted[i] + separator) === __breaker) return __breaker.$v
      }
    
    };

    // line 2977, (corelib), String#empty?
    String_prototype['$empty?'] = function() {
      
      return this.length === 0;
    };

    // line 2981, (corelib), String#end_with?
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

    // line 2997, (corelib), String#equal?
    String_prototype['$equal?'] = function(val) {
      
      return this.toString() === val.toString();
    };

    String_prototype.$getbyte = String_prototype.charCodeAt;

    // line 3003, (corelib), String#gsub
    String_prototype.$gsub = TMP_55 = function(pattern, replace) {
      var __a, __context, block;
      block = TMP_55._p || nil, __context = block._s, TMP_55._p = null;
      
      if ((__a = pattern['$is_a?'](__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return (__a = this, __a.$sub._p = block.$to_proc(), __a.$sub(new RegExp(regexp, options), replace));
    
    };

    String_prototype.$hash = String_prototype.toString;

    // line 3019, (corelib), String#hex
    String_prototype.$hex = function() {
      
      return this.$to_i(16);
    };

    // line 3023, (corelib), String#include?
    String_prototype['$include?'] = function(other) {
      
      return this.indexOf(other) !== -1;
    };

    // line 3027, (corelib), String#index
    String_prototype.$index = function(what, offset) {
      var __a;
      
      if (!what._isString && !what._isRegexp) {
        throw new Error('type mismatch');
      }

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

    // line 3064, (corelib), String#inspect
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

    // line 3088, (corelib), String#intern
    String_prototype.$intern = function() {
      
      return this;
    };

    String_prototype.$lines = String_prototype.$each_line;

    // line 3094, (corelib), String#length
    String_prototype.$length = function() {
      
      return this.length;
    };

    // line 3098, (corelib), String#ljust
    String_prototype.$ljust = function(integer, padstr) {
      if (padstr == null) {
        padstr = " "
      }
      return this.$raise(__scope.NotImplementedError);
    };

    // line 3102, (corelib), String#lstrip
    String_prototype.$lstrip = function() {
      
      return this.replace(/^\s*/, '');
    };

    // line 3106, (corelib), String#match
    String_prototype.$match = TMP_56 = function(pattern, pos) {
      var __a, __b, __context, block;
      block = TMP_56._p || nil, __context = block._s, TMP_56._p = null;
      
      return (__a = (function() { if ((__b = pattern['$is_a?'](__scope.Regexp)) !== false && __b !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this), __a.$match._p = block.$to_proc(), __a.$match(this, pos));
    };

    // line 3110, (corelib), String#next
    String_prototype.$next = function() {
      
      
      if (this.length === 0) {
        return "";
      }

      var initial = this.substr(0, this.length - 1);
      var last    = String.fromCharCode(this.charCodeAt(this.length - 1) + 1);

      return initial + last;
    
    };

    // line 3123, (corelib), String#ord
    String_prototype.$ord = function() {
      
      return this.charCodeAt(0);
    };

    // line 3127, (corelib), String#partition
    String_prototype.$partition = function(str) {
      
      
      var result = this.split(str);
      var splitter = (result[0].length === this.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    
    };

    // line 3136, (corelib), String#reverse
    String_prototype.$reverse = function() {
      
      return this.split('').reverse().join('');
    };

    // line 3140, (corelib), String#rstrip
    String_prototype.$rstrip = function() {
      
      return this.replace(/\s*$/, '');
    };

    String_prototype.$size = String_prototype.$length;

    String_prototype.$slice = String_prototype['$[]'];

    // line 3148, (corelib), String#split
    String_prototype.$split = function(pattern, limit) {
      var __a;if (pattern == null) {
        pattern = ((__a = __gvars[";"]), __a !== false && __a !== nil ? __a : " ")
      }
      return this.split(pattern, limit);
    };

    // line 3152, (corelib), String#start_with?
    String_prototype['$start_with?'] = function(prefixes) {
      prefixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    
    };

    // line 3164, (corelib), String#strip
    String_prototype.$strip = function() {
      
      return this.replace(/^\s*/, '').replace(/\s*$/, '');
    };

    // line 3168, (corelib), String#sub
    String_prototype.$sub = TMP_57 = function(pattern, replace) {
      var __context, block;
      block = TMP_57._p || nil, __context = block._s, TMP_57._p = null;
      
      
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

    // line 3205, (corelib), String#sum
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

    // line 3217, (corelib), String#swapcase
    String_prototype.$swapcase = function() {
      
      
      var str = this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (this._klass === String) {
        return str;
      }

      return this.$class().$new(str);
    
    };

    // line 3231, (corelib), String#to_a
    String_prototype.$to_a = function() {
      
      
      if (this.length === 0) {
        return [];
      }

      return [this];
    
    };

    // line 3241, (corelib), String#to_f
    String_prototype.$to_f = function() {
      
      
      var result = parseFloat(this);

      return isNaN(result) ? 0 : result;
    
    };

    // line 3249, (corelib), String#to_i
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

    // line 3263, (corelib), String#to_proc
    String_prototype.$to_proc = function() {
      
      
      var name = '$' + this;

      return function(arg) { return arg[name](arg); };
    
    };

    String_prototype.$to_s = String_prototype.toString;

    String_prototype.$to_str = String_prototype.$to_s;

    String_prototype.$to_sym = String_prototype.$intern;

    // line 3277, (corelib), String#underscore
    String_prototype.$underscore = function() {
      
      return this.replace(/[-\s]+/g, '_')
            .replace(/([A-Z\d]+)([A-Z][a-z])/g, '$1_$2')
            .replace(/([a-z\d])([A-Z])/g, '$1_$2')
            .toLowerCase();
    };

    String_prototype.$upcase = String_prototype.toUpperCase;
    ;String._sdonate(["$try_convert", "$new"]);
  })(self, String);
  __scope.Symbol = __scope.String;
  (function(__base, __super){
    // line 3288, (corelib), class Numeric
    function Numeric() {};
    Numeric = __klass(__base, __super, "Numeric", Numeric);
    var Numeric_prototype = Numeric.prototype, __scope = Numeric._scope, TMP_58, TMP_59, TMP_60;

    
    Numeric_prototype._isNumber = true;
  

    Numeric.$include(__scope.Comparable);

    // line 3295, (corelib), Numeric#+
    Numeric_prototype['$+'] = function(other) {
      
      return this + other;
    };

    // line 3299, (corelib), Numeric#-
    Numeric_prototype['$-'] = function(other) {
      
      return this - other;
    };

    // line 3303, (corelib), Numeric#*
    Numeric_prototype['$*'] = function(other) {
      
      return this * other;
    };

    // line 3307, (corelib), Numeric#/
    Numeric_prototype['$/'] = function(other) {
      
      return this / other;
    };

    // line 3311, (corelib), Numeric#%
    Numeric_prototype['$%'] = function(other) {
      
      return this % other;
    };

    // line 3315, (corelib), Numeric#&
    Numeric_prototype['$&'] = function(other) {
      
      return this & other;
    };

    // line 3319, (corelib), Numeric#|
    Numeric_prototype['$|'] = function(other) {
      
      return this | other;
    };

    // line 3323, (corelib), Numeric#^
    Numeric_prototype['$^'] = function(other) {
      
      return this ^ other;
    };

    // line 3327, (corelib), Numeric#<
    Numeric_prototype['$<'] = function(other) {
      
      return this < other;
    };

    // line 3331, (corelib), Numeric#<=
    Numeric_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    // line 3335, (corelib), Numeric#>
    Numeric_prototype['$>'] = function(other) {
      
      return this > other;
    };

    // line 3339, (corelib), Numeric#>=
    Numeric_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    // line 3343, (corelib), Numeric#<<
    Numeric_prototype['$<<'] = function(count) {
      
      return this << count;
    };

    // line 3347, (corelib), Numeric#>>
    Numeric_prototype['$>>'] = function(count) {
      
      return this >> count;
    };

    // line 3351, (corelib), Numeric#+@
    Numeric_prototype['$+@'] = function() {
      
      return +this;
    };

    // line 3355, (corelib), Numeric#-@
    Numeric_prototype['$-@'] = function() {
      
      return -this;
    };

    // line 3359, (corelib), Numeric#~
    Numeric_prototype['$~'] = function() {
      
      return ~this;
    };

    // line 3363, (corelib), Numeric#**
    Numeric_prototype['$**'] = function(other) {
      
      return Math.pow(this, other);
    };

    // line 3367, (corelib), Numeric#==
    Numeric_prototype['$=='] = function(other) {
      
      return this == other;
    };

    // line 3371, (corelib), Numeric#<=>
    Numeric_prototype['$<=>'] = function(other) {
      
      
      if (typeof(other) !== 'number') {
        return nil;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    
    };

    // line 3381, (corelib), Numeric#abs
    Numeric_prototype.$abs = function() {
      
      return Math.abs(this);
    };

    // line 3385, (corelib), Numeric#ceil
    Numeric_prototype.$ceil = function() {
      
      return Math.ceil(this);
    };

    // line 3389, (corelib), Numeric#chr
    Numeric_prototype.$chr = function() {
      
      return String.fromCharCode(this);
    };

    // line 3393, (corelib), Numeric#downto
    Numeric_prototype.$downto = TMP_58 = function(finish) {
      var __context, block;
      block = TMP_58._p || nil, __context = block._s, TMP_58._p = null;
      
      
      for (var i = this; i >= finish; i--) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Numeric_prototype['$eql?'] = Numeric_prototype['$=='];

    // line 3407, (corelib), Numeric#even?
    Numeric_prototype['$even?'] = function() {
      
      return this % 2 === 0;
    };

    // line 3411, (corelib), Numeric#floor
    Numeric_prototype.$floor = function() {
      
      return Math.floor(this);
    };

    // line 3415, (corelib), Numeric#hash
    Numeric_prototype.$hash = function() {
      
      return this.toString();
    };

    // line 3419, (corelib), Numeric#integer?
    Numeric_prototype['$integer?'] = function() {
      
      return this % 1 === 0;
    };

    Numeric_prototype.$magnitude = Numeric_prototype.$abs;

    Numeric_prototype.$modulo = Numeric_prototype['$%'];

    // line 3427, (corelib), Numeric#next
    Numeric_prototype.$next = function() {
      
      return this + 1;
    };

    // line 3431, (corelib), Numeric#nonzero?
    Numeric_prototype['$nonzero?'] = function() {
      
      return this === 0 ? nil : this;
    };

    // line 3435, (corelib), Numeric#odd?
    Numeric_prototype['$odd?'] = function() {
      
      return this % 2 !== 0;
    };

    // line 3439, (corelib), Numeric#ord
    Numeric_prototype.$ord = function() {
      
      return this;
    };

    // line 3443, (corelib), Numeric#pred
    Numeric_prototype.$pred = function() {
      
      return this - 1;
    };

    Numeric_prototype.$succ = Numeric_prototype.$next;

    // line 3449, (corelib), Numeric#times
    Numeric_prototype.$times = TMP_59 = function() {
      var __context, block;
      block = TMP_59._p || nil, __context = block._s, TMP_59._p = null;
      
      
      for (var i = 0; i <= this; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 3461, (corelib), Numeric#to_f
    Numeric_prototype.$to_f = function() {
      
      return parseFloat(this);
    };

    // line 3465, (corelib), Numeric#to_i
    Numeric_prototype.$to_i = function() {
      
      return parseInt(this);
    };

    // line 3469, (corelib), Numeric#to_json
    Numeric_prototype.$to_json = function() {
      
      return this.toString();
    };

    // line 3473, (corelib), Numeric#to_s
    Numeric_prototype.$to_s = function(base) {
      if (base == null) {
        base = 10
      }
      return this.toString();
    };

    // line 3477, (corelib), Numeric#upto
    Numeric_prototype.$upto = TMP_60 = function(finish) {
      var __context, block;
      block = TMP_60._p || nil, __context = block._s, TMP_60._p = null;
      
      
      for (var i = 0; i <= finish; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    // line 3489, (corelib), Numeric#zero?
    Numeric_prototype['$zero?'] = function() {
      
      return this == 0;
    };

  })(self, Number);
  __scope.Fixnum = __scope.Numeric;
  (function(__base, __super){
    // line 3495, (corelib), class Proc
    function Proc() {};
    Proc = __klass(__base, __super, "Proc", Proc);
    var Proc_prototype = Proc.prototype, __scope = Proc._scope, TMP_61;

    
    Proc_prototype._isProc = true;
    Proc_prototype.is_lambda = true;
  

    // line 3501, (corelib), Proc.new
    Proc.$new = TMP_61 = function() {
      var __context, block;
      block = TMP_61._p || nil, __context = block._s, TMP_61._p = null;
      
      if (block === nil) no_block_given();
      block.is_lambda = false;
      return block;
    };

    // line 3507, (corelib), Proc#call
    Proc_prototype.$call = function(args) {
      args = __slice.call(arguments, 0);
      return this.apply(this._s, args);
    };

    // line 3511, (corelib), Proc#to_proc
    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    // line 3515, (corelib), Proc#lambda?
    Proc_prototype['$lambda?'] = function() {
      
      return !!this.is_lambda;
    };

    // line 3521, (corelib), Proc#arity
    Proc_prototype.$arity = function() {
      
      return this.length - 1;
    };
    ;Proc._sdonate(["$new"]);
  })(self, Function);
  (function(__base, __super){
    // line 3525, (corelib), class Range
    function Range() {};
    Range = __klass(__base, __super, "Range", Range);
    var Range_prototype = Range.prototype, __scope = Range._scope, TMP_62;
    Range_prototype.begin = Range_prototype.end = nil;

    Range.$include(__scope.Enumerable);

    
    Range_prototype._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new Range;
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  

    // line 3541, (corelib), Range#begin
    Range_prototype.$begin = function() {
      
      return this.begin
    };

    // line 3542, (corelib), Range#end
    Range_prototype.$end = function() {
      
      return this.end
    };

    // line 3544, (corelib), Range#initialize
    Range_prototype.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };

    // line 3550, (corelib), Range#==
    Range_prototype['$=='] = function(other) {
      
      
      if (!other._isRange) {
        return false;
      }

      return this.exclude === other.exclude && this.begin == other.begin && this.end == other.end;
    
    };

    // line 3561, (corelib), Range#===
    Range_prototype['$==='] = function(obj) {
      
      return obj >= this.begin && (this.exclude ? obj < this.end : obj <= this.end);
    };

    // line 3565, (corelib), Range#cover?
    Range_prototype['$cover?'] = function(value) {
      var __a, __b, __c;
      return ((__a = (this.begin)['$<='](value)) ? value['$<=']((function() { if ((__b = this['$exclude_end?']()) !== false && __b !== nil) {
        return (__b = this.end, __c = 1, typeof(__b) === 'number' ? __b - __c : __b['$-'](__c))
        } else {
        return this.end;
      }; return nil; }).call(this)) : __a);
    };

    // line 3569, (corelib), Range#each
    Range_prototype.$each = TMP_62 = function() {
      var current = nil, __a, __b, __context, __yield;
      __yield = TMP_62._p || nil, __context = __yield._s, TMP_62._p = null;
      
      current = this.$min();
      while ((__b = !current['$=='](this.$max())) !== false && __b !== nil){if (__yield.call(__context, current) === __breaker) return __breaker.$v;
      current = current.$succ();};
      if ((__a = this['$exclude_end?']()) === false || __a === nil) {
        if (__yield.call(__context, current) === __breaker) return __breaker.$v
      };
      return this;
    };

    // line 3583, (corelib), Range#eql?
    Range_prototype['$eql?'] = function(other) {
      var __a;
      if ((__a = __scope.Range['$==='](other)) === false || __a === nil) {
        return false
      };
      return (__a = ((__a = this['$exclude_end?']()['$=='](other['$exclude_end?']())) ? (this.begin)['$eql?'](other.$begin()) : __a), __a !== false && __a !== nil ? (this.end)['$eql?'](other.$end()) : __a);
    };

    // line 3589, (corelib), Range#exclude_end?
    Range_prototype['$exclude_end?'] = function() {
      
      return this.exclude;
    };

    // line 3594, (corelib), Range#include?
    Range_prototype['$include?'] = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };

    Range_prototype.$max = Range_prototype.$end;

    Range_prototype.$min = Range_prototype.$begin;

    Range_prototype['$member?'] = Range_prototype['$include?'];

    // line 3604, (corelib), Range#step
    Range_prototype.$step = function(n) {
      if (n == null) {
        n = 1
      }
      return this.$raise(__scope.NotImplementedError);
    };

    // line 3608, (corelib), Range#to_s
    Range_prototype.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };

    Range_prototype.$inspect = Range_prototype.$to_s;

  })(self, null);
  (function(__base, __super){
    // line 3614, (corelib), class Time
    function Time() {};
    Time = __klass(__base, __super, "Time", Time);
    var Time_prototype = Time.prototype, __scope = Time._scope;

    Time.$include(__scope.Comparable);

    // line 3617, (corelib), Time.at
    Time.$at = function(seconds, frac) {
      if (frac == null) {
        frac = 0
      }
      return new Date(seconds * 1000 + frac);
    };

    // line 3621, (corelib), Time.new
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

    // line 3644, (corelib), Time.now
    Time.$now = function() {
      
      return new Date();
    };

    // line 3648, (corelib), Time#+
    Time_prototype['$+'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a + __b : __a['$+'](__b)));
    };

    // line 3652, (corelib), Time#-
    Time_prototype['$-'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a - __b : __a['$-'](__b)));
    };

    // line 3656, (corelib), Time#<=>
    Time_prototype['$<=>'] = function(other) {
      
      return this.$to_f()['$<=>'](other.$to_f());
    };

    Time_prototype.$day = Time_prototype.getDate;

    // line 3662, (corelib), Time#eql?
    Time_prototype['$eql?'] = function(other) {
      var __a;
      return (__a = other['$is_a?'](__scope.Time), __a !== false && __a !== nil ? this['$<=>'](other)['$zero?']() : __a);
    };

    // line 3666, (corelib), Time#friday?
    Time_prototype['$friday?'] = function() {
      
      return this.getDay() === 5;
    };

    Time_prototype.$hour = Time_prototype.getHours;

    Time_prototype.$mday = Time_prototype.$day;

    Time_prototype.$min = Time_prototype.getMinutes;

    // line 3676, (corelib), Time#mon
    Time_prototype.$mon = function() {
      
      return this.getMonth() + 1;
    };

    // line 3680, (corelib), Time#monday?
    Time_prototype['$monday?'] = function() {
      
      return this.getDay() === 1;
    };

    Time_prototype.$month = Time_prototype.$mon;

    // line 3686, (corelib), Time#saturday?
    Time_prototype['$saturday?'] = function() {
      
      return this.getDay() === 6;
    };

    Time_prototype.$sec = Time_prototype.getSeconds;

    // line 3692, (corelib), Time#sunday?
    Time_prototype['$sunday?'] = function() {
      
      return this.getDay() === 0;
    };

    // line 3696, (corelib), Time#thursday?
    Time_prototype['$thursday?'] = function() {
      
      return this.getDay() === 4;
    };

    // line 3700, (corelib), Time#to_f
    Time_prototype.$to_f = function() {
      
      return this.getTime() / 1000;
    };

    // line 3704, (corelib), Time#to_i
    Time_prototype.$to_i = function() {
      
      return parseInt(this.getTime() / 1000);
    };

    // line 3708, (corelib), Time#tuesday?
    Time_prototype['$tuesday?'] = function() {
      
      return this.getDay() === 2;
    };

    Time_prototype.$wday = Time_prototype.getDay;

    // line 3714, (corelib), Time#wednesday?
    Time_prototype['$wednesday?'] = function() {
      
      return this.getDay() === 3;
    };

    Time_prototype.$year = Time_prototype.getFullYear;
    ;Time._sdonate(["$at", "$new", "$now"]);
  })(self, Date);
  var json_parse = JSON.parse;
  (function(__base){
    // line 3722, (corelib), module JSON
    function JSON() {};
    JSON = __module(__base, "JSON", JSON);
    var JSON_prototype = JSON.prototype, __scope = JSON._scope;

    // line 3723, (corelib), JSON.parse
    JSON.$parse = function(source) {
      
      return to_opal(json_parse(source));
    };

    // line 3728, (corelib), JSON.from_object
    JSON.$from_object = function(js_object) {
      
      return to_opal(js_object);
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
  
        ;JSON._sdonate(["$parse", "$from_object"]);
  })(self);
  return (function(__base, __super){
    // line 3775, (corelib), class Template
    function Template() {};
    Template = __klass(__base, __super, "Template", Template);
    var Template_prototype = Template.prototype, __scope = Template._scope, TMP_63;
    Template_prototype.body = nil;

    Template._cache = __hash();

    // line 3777, (corelib), Template.[]
    Template['$[]'] = function(name) {
      
      if (this._cache == null) this._cache = nil;

      return this._cache['$[]'](name)
    };

    // line 3781, (corelib), Template.[]=
    Template['$[]='] = function(name, instance) {
      
      if (this._cache == null) this._cache = nil;

      return this._cache['$[]='](name, instance)
    };

    // line 3785, (corelib), Template#initialize
    Template_prototype.$initialize = TMP_63 = function(name) {
      var __context, body;
      body = TMP_63._p || nil, __context = body._s, TMP_63._p = null;
      
      this.body = body;
      this.name = name;
      return __scope.Template['$[]='](name, this);
    };

    // line 3791, (corelib), Template#render
    Template_prototype.$render = function(ctx) {
      var __a;if (ctx == null) {
        ctx = this
      }
      return (__a = ctx, __a.$instance_eval._p = this.body.$to_proc(), __a.$instance_eval());
    };
    ;Template._sdonate(["$[]", "$[]="]);
  })(self, null);
})();
}).call(this);
