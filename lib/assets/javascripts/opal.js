// Opal v0.3.29
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
Opal.version = "0.3.29";
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, def = self._klass.prototype, __breaker = __opal.breaker, __slice = __opal.slice, __gvars = __opal.gvars;
  
  __gvars["~"] = nil;
  __gvars["/"] = "\n";
  __scope.RUBY_ENGINE = "opal";
  __scope.RUBY_PLATFORM = "opal";
  __scope.RUBY_VERSION = "1.9.2";
  __scope.OPAL_VERSION = __opal.version;
  self.$to_s = function() {
    
    return "main";
  };
  return self.$include = function(mod) {
    
    return __scope.Object.$include(mod);
  };
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Class() {};
    Class = __klass(__base, __super, "Class", Class);

    ;Class._sdonate(["$new"]);    var Class_prototype = Class.prototype, __scope = Class._scope, TMP_1, TMP_2, TMP_3, TMP_4;

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

    Class_prototype.$allocate = function() {
      
      
      var obj = new this;
      obj._id = unique_id++;
      return obj;
    
    };

    Class_prototype.$alias_method = function(newname, oldname) {
      
      this.prototype['$' + newname] = this.prototype['$' + oldname];
      return this;
    };

    Class_prototype.$ancestors = function() {
      
      
      var parent = this,
          result = [];

      while (parent) {
        result.push(parent);
        parent = parent._super;
      }

      return result;
    
    };

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

      if (prototype._smethods) {
        prototype._sdonate(methods);
      }

      if (klass.$included_in) {
        klass._donate(methods.slice(), true);
      }
    
      return this;
    };

    Class_prototype.$attr_accessor = function() {
      
      return nil;
    };

    Class_prototype.$attr_reader = Class_prototype.$attr_accessor;

    Class_prototype.$attr_writer = Class_prototype.$attr_accessor;

    Class_prototype.$attr = Class_prototype.$attr_accessor;

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

    Class_prototype.$included = function(mod) {
      
      return nil;
    };

    Class_prototype.$inherited = function(cls) {
      
      return nil;
    };

    Class_prototype.$module_eval = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this);
    
    };

    Class_prototype.$class_eval = Class_prototype.$module_eval;

    Class_prototype.$name = function() {
      
      return this._name;
    };

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

    Class_prototype.$public = function() {
      
      return nil;
    };

    Class_prototype.$private = Class_prototype.$public;

    Class_prototype.$protected = Class_prototype.$public;

    Class_prototype.$superclass = function() {
      
      
      return this._super || nil;
    
    };

    return nil;
  })(self, null)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function Kernel() {};
    Kernel = __module(__base, "Kernel", Kernel);
    var Kernel_prototype = Kernel.prototype, __scope = Kernel._scope, TMP_1, TMP_2, TMP_3, TMP_4, TMP_5, TMP_6, TMP_7, TMP_8;

    Kernel_prototype['$=~'] = function(obj) {
      
      return false;
    };

    Kernel_prototype['$=='] = function(other) {
      
      return this === other;
    };

    Kernel_prototype['$==='] = function(other) {
      
      return this == other;
    };

    Kernel_prototype.$methods = function(all) {
      if (all == null) {
        all = true
      }
      
      var methods = [];
      for(var k in this) {
        if(k[0] == "$" && typeof (this)[k] === "function") {
          if(all === false || all === nil) {
            if(!Object.hasOwnProperty.call(this, k)) {
              continue;
            }
          }
          methods.push(k.substr(1));
        }
      }
      return methods;
    
    };

    Kernel_prototype.$__send__ = TMP_1 = function(symbol, args) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      args = __slice.call(arguments, 1);
      
      return this['$' + symbol].apply(this, args);
    
    };

    Kernel_prototype['$eql?'] = Kernel_prototype['$=='];

    Kernel_prototype.$Array = function(object) {
      
      
      if (object.$to_ary) {
        return object.$to_ary();
      }
      else if (object.$to_a) {
        return object.$to_a();
      }

      return [object];
    
    };

    Kernel_prototype.$class = function() {
      
      return this._klass;
    };

    Kernel_prototype.$define_singleton_method = TMP_2 = function(name) {
      var __context, body;
      body = TMP_2._p || nil, __context = body._s, TMP_2._p = null;
      
      
      if (body === nil) {
        no_block_given();
      }

      var jsid   = '$' + name;
      body._jsid = jsid;
      body._sup  = this[jsid]

      this[jsid] = body;

      return this;
    
    };

    Kernel_prototype['$equal?'] = function(other) {
      
      return this === other;
    };

    Kernel_prototype.$extend = function(mods) {
      mods = __slice.call(arguments, 0);
      
      for (var i = 0, length = mods.length; i < length; i++) {
        this.$singleton_class().$include(mods[i]);
      }

      return this;
    
    };

    Kernel_prototype.$hash = function() {
      
      return this._id;
    };

    Kernel_prototype.$initialize = function() {
      
      return nil;
    };

    Kernel_prototype.$inspect = function() {
      
      return this.$to_s();
    };

    Kernel_prototype.$instance_eval = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }

      return block.call(this, this);
    
    };

    Kernel_prototype.$instance_exec = TMP_4 = function(args) {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      args = __slice.call(arguments, 0);
      
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    
    };

    Kernel_prototype['$instance_of?'] = function(klass) {
      
      return this._klass === klass;
    };

    Kernel_prototype['$instance_variable_defined?'] = function(name) {
      
      return __hasOwn.call(this, name.substr(1));
    };

    Kernel_prototype.$instance_variable_get = function(name) {
      
      
      var ivar = this[name.substr(1)];

      return ivar == null ? nil : ivar;
    
    };

    Kernel_prototype.$instance_variable_set = function(name, value) {
      
      return this[name.substr(1)] = value;
    };

    Kernel_prototype.$instance_variables = function() {
      
      
      var result = [];

      for (var name in this) {
        result.push(name);
      }

      return result;
    
    };

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

    Kernel_prototype.$lambda = TMP_5 = function() {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      
      return block;
    };

    Kernel_prototype.$loop = TMP_6 = function() {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      while (true) {;
      if (block.call(__context) === __breaker) return __breaker.$v;
      };
      return this;
    };

    Kernel_prototype['$nil?'] = function() {
      
      return false;
    };

    Kernel_prototype.$object_id = function() {
      
      return this._id || (this._id = unique_id++);
    };

    Kernel_prototype.$proc = TMP_7 = function() {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      
      
      if (block === nil) {
        no_block_given();
      }
      block.is_lambda = false;
      return block;
    
    };

    Kernel_prototype.$puts = function(strs) {
      strs = __slice.call(arguments, 0);
      
      for (var i = 0; i < strs.length; i++) {
        if(strs[i] instanceof Array) {
          this.$puts.apply(this, [].concat((strs[i])))
        } else {
          __opal.puts((strs[i]).$to_s());
        }
      }
    
      return nil;
    };

    Kernel_prototype.$p = function(args) {
      args = __slice.call(arguments, 0);
      console.log.apply(console, args);
      if (args.$length()['$<='](1)) {
        return args['$[]'](0)
        } else {
        return args
      };
    };

    Kernel_prototype.$print = Kernel_prototype.$puts;

    Kernel_prototype.$raise = function(exception, string) {
      
      
      if (typeof(exception) === 'string') {
        exception = __scope.RuntimeError.$new(exception);
      }
      else if (!exception['$is_a?'](__scope.Exception)) {
        exception = exception.$new(string);
      }

      throw exception;
    
    };

    Kernel_prototype.$rand = function(max) {
      
      return max == null ? Math.random() : Math.floor(Math.random() * max);
    };

    Kernel_prototype['$respond_to?'] = function(name) {
      
      return !!this['$' + name];
    };

    Kernel_prototype.$send = Kernel_prototype.$__send__;

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

    Kernel_prototype.$tap = TMP_8 = function() {
      var __context, block;
      block = TMP_8._p || nil, __context = block._s, TMP_8._p = null;
      
      if (block.call(__context, this) === __breaker) return __breaker.$v;
      return this;
    };

    Kernel_prototype.$to_json = function() {
      
      return this.$to_s().$to_json();
    };

    Kernel_prototype.$to_proc = function() {
      
      return this;
    };

    Kernel_prototype.$to_s = function() {
      
      return "#<" + this._klass._name + ":" + this._id + ">";
    };
        ;Kernel._donate(["$=~", "$==", "$===", "$methods", "$__send__", "$eql?", "$Array", "$class", "$define_singleton_method", "$equal?", "$extend", "$hash", "$initialize", "$inspect", "$instance_eval", "$instance_exec", "$instance_of?", "$instance_variable_defined?", "$instance_variable_get", "$instance_variable_set", "$instance_variables", "$is_a?", "$kind_of?", "$lambda", "$loop", "$nil?", "$object_id", "$proc", "$puts", "$p", "$print", "$raise", "$rand", "$respond_to?", "$send", "$singleton_class", "$tap", "$to_json", "$to_proc", "$to_s"]);
  })(self)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function NilClass() {};
    NilClass = __klass(__base, __super, "NilClass", NilClass);

    var NilClass_prototype = NilClass.prototype, __scope = NilClass._scope;

    NilClass_prototype['$&'] = function(other) {
      
      return false;
    };

    NilClass_prototype['$|'] = function(other) {
      
      return other !== false && other !== nil;
    };

    NilClass_prototype['$^'] = function(other) {
      
      return other !== false && other !== nil;
    };

    NilClass_prototype['$=='] = function(other) {
      
      return other === nil;
    };

    NilClass_prototype.$inspect = function() {
      
      return "nil";
    };

    NilClass_prototype['$nil?'] = function() {
      
      return true;
    };

    NilClass_prototype.$singleton_class = function() {
      
      return __scope.NilClass;
    };

    NilClass_prototype.$to_a = function() {
      
      return [];
    };

    NilClass_prototype.$to_i = function() {
      
      return 0;
    };

    NilClass_prototype.$to_f = NilClass_prototype.$to_i;

    NilClass_prototype.$to_json = function() {
      
      return "null";
    };

    NilClass_prototype.$to_native = function() {
      
      return null;
    };

    NilClass_prototype.$to_s = function() {
      
      return "";
    };

    return nil;
  })(self, null)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Boolean() {};
    Boolean = __klass(__base, __super, "Boolean", Boolean);

    var Boolean_prototype = Boolean.prototype, __scope = Boolean._scope;

    
    Boolean_prototype._isBoolean = true;
  

    Boolean_prototype['$&'] = function(other) {
      
      return (this == true) ? (other !== false && other !== nil) : false;
    };

    Boolean_prototype['$|'] = function(other) {
      
      return (this == true) ? true : (other !== false && other !== nil);
    };

    Boolean_prototype['$^'] = function(other) {
      
      return (this == true) ? (other === false || other === nil) : (other !== false && other !== nil);
    };

    Boolean_prototype['$=='] = function(other) {
      
      return (this == true) === other.valueOf();
    };

    Boolean_prototype.$singleton_class = Boolean_prototype.$class;

    Boolean_prototype.$to_json = function() {
      
      return (this == true) ? 'true' : 'false';
    };

    Boolean_prototype.$to_s = function() {
      
      return (this == true) ? 'true' : 'false';
    };

    return nil;
  })(self, Boolean)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  (function(__base, __super){
    function Exception() {};
    Exception = __klass(__base, __super, "Exception", Exception);

    ;Exception._sdonate(["$new"]);    var Exception_prototype = Exception.prototype, __scope = Exception._scope;
    Exception_prototype.message = nil;

    Exception_prototype.$message = function() {
      
      return this.message
    }, nil;

    Exception.$new = function(message) {
      if (message == null) {
        message = ""
      }
      
      var err = new Error(message);
      err._klass = this;
      return err;
    
    };

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

    Exception_prototype.$inspect = function() {
      
      return "#<" + (this.$class().$name()) + ": '" + (this.message) + "'>";
    };

    return Exception_prototype.$to_s = Exception_prototype.$message;
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
  return __scope.RangeError = __scope.Exception;
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass, __gvars = __opal.gvars;
  
  (function(__base, __super){
    function Regexp() {};
    Regexp = __klass(__base, __super, "Regexp", Regexp);

    ;Regexp._sdonate(["$escape", "$new"]);    var Regexp_prototype = Regexp.prototype, __scope = Regexp._scope;

    Regexp.$escape = function(string) {
      
      return string.replace(/([.*+?^=!:${}()|[]\/\])/g, '\$1');
    };

    Regexp.$new = function(string, options) {
      
      return new RegExp(string, options);
    };

    Regexp_prototype['$=='] = function(other) {
      
      return other.constructor == RegExp && this.toString() === other.toString();
    };

    Regexp_prototype['$==='] = Regexp_prototype.test;

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

    Regexp_prototype.$to_s = function() {
      
      return this.source;
    };

    
    function match_to_s() {
      return this[0];
    }

    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }
  
  })(self, RegExp);
  return (function(__base, __super){
    function MatchData() {};
    MatchData = __klass(__base, __super, "MatchData", MatchData);

    var MatchData_prototype = MatchData.prototype, __scope = MatchData._scope;

    return nil
  })(self, null);
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function Comparable() {};
    Comparable = __module(__base, "Comparable", Comparable);
    var Comparable_prototype = Comparable.prototype, __scope = Comparable._scope;

    Comparable_prototype['$<'] = function(other) {
      
      return this['$<=>'](other)['$=='](-1);
    };

    Comparable_prototype['$<='] = function(other) {
      
      return this['$<=>'](other)['$<='](0);
    };

    Comparable_prototype['$=='] = function(other) {
      
      return this['$<=>'](other)['$=='](0);
    };

    Comparable_prototype['$>'] = function(other) {
      
      return this['$<=>'](other)['$=='](1);
    };

    Comparable_prototype['$>='] = function(other) {
      
      return this['$<=>'](other)['$>='](0);
    };

    Comparable_prototype['$between?'] = function(min, max) {
      var __a;
      return ((__a = this['$>'](min)) ? this['$<'](max) : __a);
    };
        ;Comparable._donate(["$<", "$<=", "$==", "$>", "$>=", "$between?"]);
  })(self)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module;
  
  return (function(__base){
    function Enumerable() {};
    Enumerable = __module(__base, "Enumerable", Enumerable);
    var Enumerable_prototype = Enumerable.prototype, __scope = Enumerable._scope, TMP_1, TMP_2, TMP_3, TMP_4, TMP_5, TMP_6, TMP_7, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12;

    Enumerable_prototype['$all?'] = TMP_1 = function() {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
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

    Enumerable_prototype['$any?'] = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
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

    Enumerable_prototype.$collect = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
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

    Enumerable_prototype.$reduce = TMP_4 = function(object) {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      
      
      var result = object == undefined ? 0 : object;

      var proc = function() {
        var obj = __slice.call(arguments), value;

        if ((value = block.apply(__context, [result].concat(obj))) === __breaker) {
          result = __breaker.$v;
          __breaker.$v = nil;

          return __breaker;
        }

        result = value;
      };

      this.$each._p = proc;
      this.$each();

      return result;
    
    };

    Enumerable_prototype.$count = TMP_5 = function(object) {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      
      
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

    Enumerable_prototype.$detect = TMP_6 = function(ifnone) {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      
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

    Enumerable_prototype.$drop_while = TMP_7 = function() {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      
      
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

    Enumerable_prototype.$each_with_index = TMP_8 = function() {
      var __context, block;
      block = TMP_8._p || nil, __context = block._s, TMP_8._p = null;
      
      
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

    Enumerable_prototype.$each_with_object = TMP_9 = function(object) {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      
      this.$each._p = function(obj) {
        var value;

        if ((value = block.call(__context, obj, object)) === __breaker) {
          return __breaker.$v;
        }
      };

      this.$each();

      return object;
    
    };

    Enumerable_prototype.$entries = function() {
      
      
      var result = [];

      this.$each._p = function(obj) {
        result.push(obj);
      };

      this.$each();

      return result;
    
    };

    Enumerable_prototype.$find = Enumerable_prototype.$detect;

    Enumerable_prototype.$find_all = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      
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

    Enumerable_prototype.$find_index = TMP_11 = function(object) {
      var __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
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

    Enumerable_prototype.$grep = TMP_12 = function(pattern) {
      var __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      
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

    Enumerable_prototype.$map = Enumerable_prototype.$collect;

    Enumerable_prototype.$select = Enumerable_prototype.$find_all;

    Enumerable_prototype.$take = Enumerable_prototype.$first;

    Enumerable_prototype.$to_a = Enumerable_prototype.$entries;

    Enumerable_prototype.$inject = Enumerable_prototype.$reduce;
        ;Enumerable._donate(["$all?", "$any?", "$collect", "$reduce", "$count", "$detect", "$drop", "$drop_while", "$each_with_index", "$each_with_object", "$entries", "$find", "$find_all", "$find_index", "$first", "$grep", "$map", "$select", "$take", "$to_a", "$inject"]);
  })(self)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Array() {};
    Array = __klass(__base, __super, "Array", Array);

    ;Array._sdonate(["$[]", "$new"]);    var Array_prototype = Array.prototype, __scope = Array._scope, TMP_1, TMP_2, TMP_3, TMP_4, TMP_5, TMP_6, TMP_7, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12, TMP_13, TMP_14, TMP_15, TMP_16, TMP_17;

    
    Array_prototype._isArray = true;
  

    Array.$include(__scope.Enumerable);

    Array['$[]'] = function(objects) {
      objects = __slice.call(arguments, 0);
      
      return objects;
    
    };

    Array.$new = TMP_1 = function(size, obj) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
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

    Array_prototype['$+'] = function(other) {
      
      return this.slice().concat(other.slice());
    };

    Array_prototype['$-'] = function(other) {
      var __a, __b;
      return (__b = this, __b.$reject._p = (__a = function(i) {

        
        if (i == null) i = nil;

        return other['$include?'](i)
      }, __a._s = this, __a), __b.$reject());
    };

    Array_prototype['$<<'] = function(object) {
      
      this.push(object);
      return this;
    };

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

    Array_prototype['$[]='] = function(index, value) {
      
      
      var size = this.length;

      if (index < 0) {
        index += size;
      }

      return this[index] = value;
    
    };

    Array_prototype.$assoc = function(object) {
      
      
      for (var i = 0, length = this.length, item; i < length; i++) {
        if (item = this[i], item.length && (item[0])['$=='](object)) {
          return item;
        }
      }

      return nil;
    
    };

    Array_prototype.$at = function(index) {
      
      
      if (index < 0) {
        index += this.length;
      }

      if (index < 0 || index >= this.length) {
        return nil;
      }

      return this[index];
    
    };

    Array_prototype.$clear = function() {
      
      this.splice(0, this.length);
      return this;
    };

    Array_prototype.$clone = function() {
      
      return this.slice();
    };

    Array_prototype.$collect = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
      var result = [];

      for (var i = 0, length = this.length, value; i < length; i++) {
        if ((value = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        result.push(value);
      }

      return result;
    
    };

    Array_prototype['$collect!'] = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      for (var i = 0, length = this.length, val; i < length; i++) {
        if ((val = block.call(__context, this[i])) === __breaker) {
          return __breaker.$v;
        }

        this[i] = val;
      }
    
      return this;
    };

    Array_prototype.$compact = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length, item; i < length; i++) {
        if ((item = this[i]) !== nil) {
          result.push(item);
        }
      }

      return result;
    
    };

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

    Array_prototype.$concat = function(other) {
      
      
      for (var i = 0, length = other.length; i < length; i++) {
        this.push(other[i]);
      }
    
      return this;
    };

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

    Array_prototype.$delete_if = TMP_4 = function() {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      
      
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

    Array_prototype.$drop = function(number) {
      
      return this.slice(number);
    };

    Array_prototype.$dup = Array_prototype.$clone;

    Array_prototype.$each = TMP_5 = function() {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, this[i]) === __breaker) return __breaker.$v;
      };
      return this;
    };

    Array_prototype.$each_index = TMP_6 = function() {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      for (var i = 0, length = this.length; i < length; i++) {
      if (block.call(__context, i) === __breaker) return __breaker.$v;
      };
      return this;
    };

    Array_prototype['$empty?'] = function() {
      
      return !this.length;
    };

    Array_prototype.$fetch = TMP_7 = function(index, defaults) {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      
      
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

    Array_prototype.$first = function(count) {
      
      
      if (count != null) {
        return this.slice(0, count);
      }

      return this.length === 0 ? nil : this[0];
    
    };

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

    Array_prototype['$flatten!'] = function(level) {
      
      
      var size = this.length;
      this.$replace(this.$flatten(level));

      return size === this.length ? nil : this;
    
    };

    Array_prototype.$hash = function() {
      
      return this._id || (this._id = unique_id++);
    };

    Array_prototype['$include?'] = function(member) {
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if ((this[i])['$=='](member)) {
          return true;
        }
      }

      return false;
    
    };

    Array_prototype.$index = TMP_8 = function(object) {
      var __context, block;
      block = TMP_8._p || nil, __context = block._s, TMP_8._p = null;
      
      
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

    Array_prototype.$keep_if = TMP_9 = function() {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      
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

    Array_prototype.$length = function() {
      
      return this.length;
    };

    Array_prototype.$map = Array_prototype.$collect;

    Array_prototype['$map!'] = Array_prototype['$collect!'];

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

    Array_prototype.$push = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = 0, length = objects.length; i < length; i++) {
        this.push(objects[i]);
      }
    
      return this;
    };

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

    Array_prototype.$reject = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      
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

    Array_prototype['$reject!'] = TMP_11 = function() {
      var __a, __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
      var original = this.length;
      (__a = this, __a.$delete_if._p = block.$to_proc(), __a.$delete_if());
      return this.length === original ? nil : this;
    
    };

    Array_prototype.$replace = function(other) {
      
      
      this.splice(0, this.length);
      this.push.apply(this, other);
      return this;
    
    };

    Array_prototype.$reverse = Array_prototype.reverse;

    Array_prototype['$reverse!'] = function() {
      
      
      this.splice(0);
      this.push.apply(this, this.$reverse());
      return this;
    
    };

    Array_prototype.$reverse_each = TMP_12 = function() {
      var __a, __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      (__a = this.$reverse(), __a.$each._p = block.$to_proc(), __a.$each());
      return this;
    };

    Array_prototype.$rindex = TMP_13 = function(object) {
      var __context, block;
      block = TMP_13._p || nil, __context = block._s, TMP_13._p = null;
      
      
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

    Array_prototype.$select = TMP_14 = function() {
      var __context, block;
      block = TMP_14._p || nil, __context = block._s, TMP_14._p = null;
      
      
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

    Array_prototype['$select!'] = TMP_15 = function() {
      var __a, __context, block;
      block = TMP_15._p || nil, __context = block._s, TMP_15._p = null;
      
      
      var original = this.length;
      (__a = this, __a.$keep_if._p = block.$to_proc(), __a.$keep_if());
      return this.length === original ? nil : this;
    
    };

    Array_prototype.$shift = function(count) {
      
      
      if (this.length === 0) {
        return nil;
      }

      return count == null ? this.shift() : this.splice(0, count)
    
    };

    Array_prototype.$size = Array_prototype.$length;

    Array_prototype.$slice = Array_prototype['$[]'];

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

    Array_prototype.$take = function(count) {
      
      return this.slice(0, count);
    };

    Array_prototype.$take_while = TMP_16 = function() {
      var __context, block;
      block = TMP_16._p || nil, __context = block._s, TMP_16._p = null;
      
      
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

    Array_prototype.$to_a = function() {
      
      return this;
    };

    Array_prototype.$to_ary = Array_prototype.$to_a;

    Array_prototype.$to_json = function() {
      
      
      var result = [];

      for (var i = 0, length = this.length; i < length; i++) {
        result.push((this[i]).$to_json());
      }

      return '[' + result.join(', ') + ']';
    
    };

    Array_prototype.$to_s = Array_prototype.$inspect;

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

    Array_prototype.$unshift = function(objects) {
      objects = __slice.call(arguments, 0);
      
      for (var i = objects.length - 1; i >= 0; i--) {
        this.unshift(objects[i]);
      }

      return this;
    
    };

    Array_prototype.$zip = TMP_17 = function(others) {
      var __context, block;
      block = TMP_17._p || nil, __context = block._s, TMP_17._p = null;
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

    return nil;
  })(self, Array)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Hash() {};
    Hash = __klass(__base, __super, "Hash", Hash);

    ;Hash._sdonate(["$[]", "$allocate", "$from_native", "$new"]);    var Hash_prototype = Hash.prototype, __scope = Hash._scope, TMP_1, TMP_2, TMP_3, TMP_4, TMP_5, TMP_6, TMP_7, TMP_8, TMP_9, TMP_10, TMP_11, TMP_12;
    Hash_prototype.proc = Hash_prototype.none = nil;

    Hash.$include(__scope.Enumerable);

    
    __hash = Opal.hash = function() {
      var hash   = new Hash,
          args   = __slice.call(arguments),
          keys   = [],
          assocs = {};

      hash.map   = assocs;
      hash.keys  = keys;

      for (var i = 0, length = args.length, key; i < length; i++) {
        var key = args[i], obj = args[++i];

        if (assocs[key] == null) {
          keys.push(key);
        }

        assocs[key] = obj;
      }

      return hash;
    };

    // hash2 is a faster creator for hashes that just use symbols and
    // strings as keys. The map and keys array can be constructed at
    // compile time, so they are just added here by the constructor
    // function
    __hash2 = Opal.hash2 = function(keys, map) {
      var hash = new Hash;
      hash.keys = keys;
      hash.map = map;
      return hash;
    }
  

    Hash['$[]'] = function(objs) {
      objs = __slice.call(arguments, 0);
      return __hash.apply(null, objs);
    };

    Hash.$allocate = function() {
      
      return __hash();
    };

    Hash.$from_native = function(obj) {
      
      
      var hash = __hash(), map = hash.map, keys = hash.keys;

      for (var key in obj) {
        keys.push(key);
        map[key] = obj[key];
      }

      return hash;
    
    };

    Hash.$new = TMP_1 = function(defaults) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
      var hash = __hash();

      if (defaults != null) {
        hash.none = defaults;
      }
      else if (block !== nil) {
        hash.proc = block;
      }

      return hash;
    
    };

    Hash_prototype['$=='] = function(other) {
      var __a;
      
      if (this === other) {
        return true;
      }

      if (!other.map || !other.keys) {
        return false;
      }

      if (this.keys.length !== other.keys.length) {
        return false;
      }

      var map  = this.map,
          map2 = other.map;

      for (var i = 0, length = this.keys.length; i < length; i++) {
        var key = this.keys[i], obj = map[key], obj2 = map2[key];

        if ((__a = (obj)['$=='](obj2), (__a === nil || __a === false))) {
          return false;
        }
      }

      return true;
    
    };

    Hash_prototype['$[]'] = function(key) {
      
      
      var bucket = this.map[key];

      if (bucket != null) {
        return bucket;
      }

      var proc = this.proc;

      if (proc !== nil) {
        return (proc).$call(this, key);
      }

      return this.none;
    
    };

    Hash_prototype['$[]='] = function(key, value) {
      
      
      var map = this.map;

      if (!__hasOwn.call(map, key)) {
        this.keys.push(key);
      }

      map[key] = value;

      return value;
    
    };

    Hash_prototype.$assoc = function(object) {
      
      
      var keys = this.keys, key;

      for (var i = 0, length = keys.length; i < length; i++) {
        key = keys[i];

        if ((key)['$=='](object)) {
          return [key, this.map[key]];
        }
      }

      return nil;
    
    };

    Hash_prototype.$clear = function() {
      
      
      this.map = {};
      this.keys = [];
      return this;
    
    };

    Hash_prototype.$clone = function() {
      
      
      var result = __hash(),
          map    = this.map,
          map2   = result.map,
          keys2  = result.keys;

      for (var i = 0, length = this.keys.length; i < length; i++) {
        keys2.push(this.keys[i]);
        map2[this.keys[i]] = map[this.keys[i]];
      }

      return result;
    
    };

    Hash_prototype.$default = function() {
      
      return this.none;
    };

    Hash_prototype['$default='] = function(object) {
      
      return this.none = object;
    };

    Hash_prototype.$default_proc = function() {
      
      return this.proc;
    };

    Hash_prototype['$default_proc='] = function(proc) {
      
      return this.proc = proc;
    };

    Hash_prototype.$delete = function(key) {
      
      
      var map  = this.map, result = map[key];

      if (result != null) {
        delete map[key];
        this.keys.$delete(key);

        return result;
      }

      return nil;
    
    };

    Hash_prototype.$delete_if = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
      var map = this.map, keys = this.keys, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block.call(__context, key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
        }
      }

      return this;
    
    };

    Hash_prototype.$dup = Hash_prototype.$clone;

    Hash_prototype.$each = TMP_3 = function() {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      var map = this.map, keys = this.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (block.call(__context, key, map[key]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Hash_prototype.$each_key = TMP_4 = function() {
      var __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      
      
      var keys = this.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (block.call(__context, key) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Hash_prototype.$each_pair = Hash_prototype.$each;

    Hash_prototype.$each_value = TMP_5 = function() {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      
      
      var map = this.map, keys = this.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        if (block.call(__context, map[keys[i]]) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Hash_prototype['$empty?'] = function() {
      
      
      return this.keys.length === 0;
    
    };

    Hash_prototype['$eql?'] = Hash_prototype['$=='];

    Hash_prototype.$fetch = TMP_6 = function(key, defaults) {
      var __context, block;
      block = TMP_6._p || nil, __context = block._s, TMP_6._p = null;
      
      
      var value = this.map[key];

      if (value != null) {
        return value;
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

    Hash_prototype.$flatten = function(level) {
      
      
      var map = this.map, keys = this.keys, result = [];

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], value = map[key];

        result.push(key);

        if (value._isArray) {
          if (level == null || level === 1) {
            result.push(value);
          }
          else {
            result = result.concat((value).$flatten(level - 1));
          }
        }
        else {
          result.push(value);
        }
      }

      return result;
    
    };

    Hash_prototype['$has_key?'] = function(key) {
      
      return this.map[key] != null;
    };

    Hash_prototype['$has_value?'] = function(value) {
      
      
      for (var assoc in this.map) {
        if ((this.map[assoc])['$=='](value)) {
          return true;
        }
      }

      return false;
    
    };

    Hash_prototype.$hash = function() {
      
      return this._id;
    };

    Hash_prototype['$include?'] = Hash_prototype['$has_key?'];

    Hash_prototype.$index = function(object) {
      
      
      var map = this.map, keys = this.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        if (object['$=='](map[key])) {
          return key;
        }
      }

      return nil;
    
    };

    Hash_prototype.$indexes = function(keys) {
      keys = __slice.call(arguments, 0);
      
      var result = [], map = this.map, val;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], val = map[key];

        if (val != null) {
          result.push(val);
        }
        else {
          result.push(this.none);
        }
      }

      return result;
    
    };

    Hash_prototype.$indices = Hash_prototype.$indexes;

    Hash_prototype.$inspect = function() {
      
      
      var inspect = [], keys = this.keys, map = this.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push((key).$inspect() + '=>' + (map[key]).$inspect());
      }

      return '{' + inspect.join(', ') + '}';
    
    };

    Hash_prototype.$invert = function() {
      
      
      var result = __hash(), keys = this.keys, map = this.map,
          keys2 = result.keys, map2 = result.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        keys2.push(obj);
        map2[obj] = key;
      }

      return result;
    
    };

    Hash_prototype.$keep_if = TMP_7 = function() {
      var __context, block;
      block = TMP_7._p || nil, __context = block._s, TMP_7._p = null;
      
      
      var map = this.map, keys = this.keys, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block.call(__context, key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
        }
      }

      return this;
    
    };

    Hash_prototype.$key = Hash_prototype.$index;

    Hash_prototype['$key?'] = Hash_prototype['$has_key?'];

    Hash_prototype.$keys = function() {
      
      
      return this.keys.slice(0);
    
    };

    Hash_prototype.$length = function() {
      
      
      return this.keys.length;
    
    };

    Hash_prototype['$member?'] = Hash_prototype['$has_key?'];

    Hash_prototype.$merge = TMP_8 = function(other) {
      var __context, block;
      block = TMP_8._p || nil, __context = block._s, TMP_8._p = null;
      
      
      var keys = this.keys, map = this.map,
          result = __hash(), keys2 = result.keys, map2 = result.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];

        keys2.push(key);
        map2[key] = map[key];
      }

      var keys = other.keys, map = other.map;

      if (block === nil) {
        for (var i = 0, length = keys.length; i < length; i++) {
          var key = keys[i];

          if (map2[key] == null) {
            keys2.push(key);
          }

          map2[key] = map[key];
        }
      }
      else {
        for (var i = 0, length = keys.length; i < length; i++) {
          var key = keys[i];

          if (map2[key] == null) {
            keys2.push(key);
            map2[key] = map[key];
          }
          else {
            map2[key] = block.call(__context, key, map2[key], map[key]);
          }
        }
      }

      return result;
    
    };

    Hash_prototype['$merge!'] = TMP_9 = function(other) {
      var __context, block;
      block = TMP_9._p || nil, __context = block._s, TMP_9._p = null;
      
      
      var keys = this.keys, map = this.map,
          keys2 = other.keys, map2 = other.map;

      if (block === nil) {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i];

          if (map[key] == null) {
            keys.push(key);
          }

          map[key] = map2[key];
        }
      }
      else {
        for (var i = 0, length = keys2.length; i < length; i++) {
          var key = keys2[i];

          if (map[key] == null) {
            keys.push(key);
            map[key] = map2[key];
          }
          else {
            map[key] = block.call(__context, key, map[key], map2[key]);
          }
        }
      }

      return this;
    
    };

    Hash_prototype.$rassoc = function(object) {
      
      
      var keys = this.keys, map = this.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((obj)['$=='](object)) {
          return [key, obj];
        }
      }

      return nil;
    
    };

    Hash_prototype.$reject = TMP_10 = function() {
      var __context, block;
      block = TMP_10._p || nil, __context = block._s, TMP_10._p = null;
      
      
      var keys = this.keys, map = this.map,
          result = __hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key], value;

        if ((value = block.call(__context, key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          keys2.push(key);
          map2[key] = obj;
        }
      }

      return result;
    
    };

    Hash_prototype.$replace = function(other) {
      
      
      var map = this.map = {}, keys = this.keys = [];

      for (var i = 0, length = other.keys.length; i < length; i++) {
        var key = other.keys[i];
        keys.push(key);
        map[key] = other.map[key];
      }

      return this;
    
    };

    Hash_prototype.$select = TMP_11 = function() {
      var __context, block;
      block = TMP_11._p || nil, __context = block._s, TMP_11._p = null;
      
      
      var keys = this.keys, map = this.map,
          result = __hash(), map2 = result.map, keys2 = result.keys;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key], value;

        if ((value = block.call(__context, key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value !== false && value !== nil) {
          keys2.push(key);
          map2[key] = obj;
        }
      }

      return result;
    
    };

    Hash_prototype['$select!'] = TMP_12 = function() {
      var __context, block;
      block = TMP_12._p || nil, __context = block._s, TMP_12._p = null;
      
      
      var map = this.map, keys = this.keys, value, result = nil;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if ((value = block.call(__context, key, obj)) === __breaker) {
          return __breaker.$v;
        }

        if (value === false || value === nil) {
          keys.splice(i, 1);
          delete map[key];

          length--;
          i--;
          result = this
        }
      }

      return result;
    
    };

    Hash_prototype.$shift = function() {
      
      
      var keys = this.keys, map = this.map;

      if (keys.length) {
        var key = keys[0], obj = map[key];

        delete map[key];
        keys.splice(0, 1);

        return [key, obj];
      }

      return nil;
    
    };

    Hash_prototype.$size = Hash_prototype.$length;

    Hash_prototype.$to_a = function() {
      
      
      var keys = this.keys, map = this.map, result = [];

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        result.push([key, map[key]]);
      }

      return result;
    
    };

    Hash_prototype.$to_hash = function() {
      
      return this;
    };

    Hash_prototype.$to_json = function() {
      
      
      var inspect = [], keys = this.keys, map = this.map;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i];
        inspect.push((key).$to_json() + ': ' + (map[key]).$to_json());
      }

      return '{' + inspect.join(', ') + '}';
    
    };

    Hash_prototype.$to_native = function() {
      
      
      var result = {}, keys = this.keys, map = this.map, bucket, value;

      for (var i = 0, length = keys.length; i < length; i++) {
        var key = keys[i], obj = map[key];

        if (obj.$to_native) {
          result[key] = (obj).$to_native();
        }
        else {
          result[key] = obj;
        }
      }

      return result;
    
    };

    Hash_prototype.$to_s = Hash_prototype.$inspect;

    Hash_prototype.$update = Hash_prototype['$merge!'];

    Hash_prototype['$value?'] = function(value) {
      
      
      var map = this.map;

      for (var assoc in map) {
        var v = map[assoc];
        if ((v)['$=='](value)) {
          return true;
        }
      }

      return false;
    
    };

    Hash_prototype.$values_at = Hash_prototype.$indexes;

    Hash_prototype.$values = function() {
      
      
      var map    = this.map,
          result = [];

      for (var key in map) {
        result.push(map[key]);
      }

      return result;
    
    };

    return nil;
  })(self, null)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass, __gvars = __opal.gvars;
  
  (function(__base, __super){
    function String() {};
    String = __klass(__base, __super, "String", String);

    ;String._sdonate(["$try_convert", "$new"]);    var String_prototype = String.prototype, __scope = String._scope, TMP_1, TMP_2, TMP_3, TMP_4, TMP_5;

    String_prototype._isString = true;

    String.$include(__scope.Comparable);

    String.$try_convert = function(what) {
      
      try {
      return what.$to_str()
      } catch ($err) {
      if (true) {
      nil}
      else { throw $err; }
      }
    };

    String.$new = function(str) {
      if (str == null) {
        str = ""
      }
      
      return new String(str)
    ;
    };

    String_prototype['$%'] = function(data) {
      
      
      var idx = 0;
      return this.replace(/%((%)|s)/g, function (match) {
        return match[2] || data[idx++] || '';
      });
    
    };

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

    String_prototype['$+'] = function(other) {
      
      return this.toString() + other;
    };

    String_prototype['$<=>'] = function(other) {
      
      
      if (typeof other !== 'string') {
        return nil;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    
    };

    String_prototype['$<'] = function(other) {
      
      return this < other;
    };

    String_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    String_prototype['$>'] = function(other) {
      
      return this > other;
    };

    String_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    String_prototype['$=='] = function(other) {
      
      return other == String(this);
    };

    String_prototype['$==='] = String_prototype['$=='];

    String_prototype['$=~'] = function(other) {
      
      
      if (typeof other === 'string') {
        this.$raise("string given");
      }

      return other['$=~'](this);
    
    };

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

    String_prototype.$capitalize = function() {
      
      return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
    };

    String_prototype.$casecmp = function(other) {
      
      
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    
    };

    String_prototype.$chars = TMP_1 = function() {
      var __context, __yield;
      __yield = TMP_1._p || nil, __context = __yield._s, TMP_1._p = null;
      
      
      for (var i = 0, length = this.length; i < length; i++) {
        if (__yield.call(__context, this.charAt(i)) === __breaker) return __breaker.$v
      }
    
    };

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

    String_prototype.$chop = function() {
      
      return this.substr(0, this.length - 1);
    };

    String_prototype.$chr = function() {
      
      return this.charAt(0);
    };

    String_prototype.$count = function(str) {
      
      return (this.length - this.replace(new RegExp(str,"g"), '').length) / str.length;
    };

    String_prototype.$demodulize = function() {
      
      
      var idx = this.lastIndexOf('::');

      if (idx > -1) {
        return this.substr(idx + 2);
      }
      
      return this;
    
    };

    String_prototype.$downcase = String_prototype.toLowerCase;

    String_prototype.$each_char = String_prototype.$chars;

    String_prototype.$each_line = TMP_2 = function(separator) {
      var __context, __yield;
      __yield = TMP_2._p || nil, __context = __yield._s, TMP_2._p = null;
      if (separator == null) {
        separator = __gvars["/"]
      }
      
      var splitted = this.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        if (__yield.call(__context, splitted[i] + separator) === __breaker) return __breaker.$v
      }
    
    };

    String_prototype['$empty?'] = function() {
      
      return this.length === 0;
    };

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

    String_prototype['$equal?'] = function(val) {
      
      return this.toString() === val.toString();
    };

    String_prototype.$getbyte = String_prototype.charCodeAt;

    String_prototype.$gsub = TMP_3 = function(pattern, replace) {
      var __a, __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      if ((__a = pattern['$is_a?'](__scope.String)) !== false && __a !== nil) {
        pattern = (new RegExp("" + __scope.Regexp.$escape(pattern)))
      };
      
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return (__a = this, __a.$sub._p = block.$to_proc(), __a.$sub(new RegExp(regexp, options), replace));
    
    };

    String_prototype.$hash = String_prototype.toString;

    String_prototype.$hex = function() {
      
      return this.$to_i(16);
    };

    String_prototype['$include?'] = function(other) {
      
      return this.indexOf(other) !== -1;
    };

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

    String_prototype.$intern = function() {
      
      return this;
    };

    String_prototype.$lines = String_prototype.$each_line;

    String_prototype.$length = function() {
      
      return this.length;
    };

    String_prototype.$ljust = function(integer, padstr) {
      if (padstr == null) {
        padstr = " "
      }
      return this.$raise(__scope.NotImplementedError);
    };

    String_prototype.$lstrip = function() {
      
      return this.replace(/^\s*/, '');
    };

    String_prototype.$match = TMP_4 = function(pattern, pos) {
      var __a, __b, __context, block;
      block = TMP_4._p || nil, __context = block._s, TMP_4._p = null;
      
      return (__a = (function() { if ((__b = pattern['$is_a?'](__scope.Regexp)) !== false && __b !== nil) {
        return pattern
        } else {
        return (new RegExp("" + __scope.Regexp.$escape(pattern)))
      }; return nil; }).call(this), __a.$match._p = block.$to_proc(), __a.$match(this, pos));
    };

    String_prototype.$next = function() {
      
      
      if (this.length === 0) {
        return "";
      }

      var initial = this.substr(0, this.length - 1);
      var last    = String.fromCharCode(this.charCodeAt(this.length - 1) + 1);

      return initial + last;
    
    };

    String_prototype.$ord = function() {
      
      return this.charCodeAt(0);
    };

    String_prototype.$partition = function(str) {
      
      
      var result = this.split(str);
      var splitter = (result[0].length === this.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    
    };

    String_prototype.$reverse = function() {
      
      return this.split('').reverse().join('');
    };

    String_prototype.$rstrip = function() {
      
      return this.replace(/\s*$/, '');
    };

    String_prototype.$size = String_prototype.$length;

    String_prototype.$slice = String_prototype['$[]'];

    String_prototype.$split = function(pattern, limit) {
      var __a;if (pattern == null) {
        pattern = ((__a = __gvars[";"]), __a !== false && __a !== nil ? __a : " ")
      }
      return this.split(pattern, limit);
    };

    String_prototype['$start_with?'] = function(prefixes) {
      prefixes = __slice.call(arguments, 0);
      
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    
    };

    String_prototype.$strip = function() {
      
      return this.replace(/^\s*/, '').replace(/\s*$/, '');
    };

    String_prototype.$sub = TMP_5 = function(pattern, replace) {
      var __context, block;
      block = TMP_5._p || nil, __context = block._s, TMP_5._p = null;
      
      
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

    String_prototype.$swapcase = function() {
      
      
      var str = this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (this._klass === String) {
        return str;
      }

      return this.$class().$new(str);
    
    };

    String_prototype.$to_a = function() {
      
      
      if (this.length === 0) {
        return [];
      }

      return [this];
    
    };

    String_prototype.$to_f = function() {
      
      
      var result = parseFloat(this);

      return isNaN(result) ? 0 : result;
    
    };

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

    String_prototype.$to_proc = function() {
      
      
      var name = '$' + this;

      return function(arg) { return arg[name](arg); };
    
    };

    String_prototype.$to_s = String_prototype.toString;

    String_prototype.$to_str = String_prototype.$to_s;

    String_prototype.$to_sym = String_prototype.$intern;

    String_prototype.$underscore = function() {
      
      return this.replace(/[-\s]+/g, '_')
            .replace(/([A-Z\d]+)([A-Z][a-z])/g, '$1_$2')
            .replace(/([a-z\d])([A-Z])/g, '$1_$2')
            .toLowerCase();
    };

    return String_prototype.$upcase = String_prototype.toUpperCase;
  })(self, String);
  return __scope.Symbol = __scope.String;
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  (function(__base, __super){
    function Numeric() {};
    Numeric = __klass(__base, __super, "Numeric", Numeric);

    var Numeric_prototype = Numeric.prototype, __scope = Numeric._scope, TMP_1, TMP_2, TMP_3;

    
    Numeric_prototype._isNumber = true;
  

    Numeric.$include(__scope.Comparable);

    Numeric_prototype['$+'] = function(other) {
      
      return this + other;
    };

    Numeric_prototype['$-'] = function(other) {
      
      return this - other;
    };

    Numeric_prototype['$*'] = function(other) {
      
      return this * other;
    };

    Numeric_prototype['$/'] = function(other) {
      
      return this / other;
    };

    Numeric_prototype['$%'] = function(other) {
      
      return this % other;
    };

    Numeric_prototype['$&'] = function(other) {
      
      return this & other;
    };

    Numeric_prototype['$|'] = function(other) {
      
      return this | other;
    };

    Numeric_prototype['$^'] = function(other) {
      
      return this ^ other;
    };

    Numeric_prototype['$<'] = function(other) {
      
      return this < other;
    };

    Numeric_prototype['$<='] = function(other) {
      
      return this <= other;
    };

    Numeric_prototype['$>'] = function(other) {
      
      return this > other;
    };

    Numeric_prototype['$>='] = function(other) {
      
      return this >= other;
    };

    Numeric_prototype['$<<'] = function(count) {
      
      return this << count;
    };

    Numeric_prototype['$>>'] = function(count) {
      
      return this >> count;
    };

    Numeric_prototype['$+@'] = function() {
      
      return +this;
    };

    Numeric_prototype['$-@'] = function() {
      
      return -this;
    };

    Numeric_prototype['$~'] = function() {
      
      return ~this;
    };

    Numeric_prototype['$**'] = function(other) {
      
      return Math.pow(this, other);
    };

    Numeric_prototype['$=='] = function(other) {
      
      return this == other;
    };

    Numeric_prototype['$<=>'] = function(other) {
      
      
      if (typeof(other) !== 'number') {
        return nil;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    
    };

    Numeric_prototype.$abs = function() {
      
      return Math.abs(this);
    };

    Numeric_prototype.$ceil = function() {
      
      return Math.ceil(this);
    };

    Numeric_prototype.$chr = function() {
      
      return String.fromCharCode(this);
    };

    Numeric_prototype.$downto = TMP_1 = function(finish) {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      
      for (var i = this; i >= finish; i--) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Numeric_prototype['$eql?'] = Numeric_prototype['$=='];

    Numeric_prototype['$even?'] = function() {
      
      return this % 2 === 0;
    };

    Numeric_prototype.$floor = function() {
      
      return Math.floor(this);
    };

    Numeric_prototype.$hash = function() {
      
      return this.toString();
    };

    Numeric_prototype['$integer?'] = function() {
      
      return this % 1 === 0;
    };

    Numeric_prototype.$magnitude = Numeric_prototype.$abs;

    Numeric_prototype.$modulo = Numeric_prototype['$%'];

    Numeric_prototype.$next = function() {
      
      return this + 1;
    };

    Numeric_prototype['$nonzero?'] = function() {
      
      return this === 0 ? nil : this;
    };

    Numeric_prototype['$odd?'] = function() {
      
      return this % 2 !== 0;
    };

    Numeric_prototype.$ord = function() {
      
      return this;
    };

    Numeric_prototype.$pred = function() {
      
      return this - 1;
    };

    Numeric_prototype.$succ = Numeric_prototype.$next;

    Numeric_prototype.$times = TMP_2 = function() {
      var __context, block;
      block = TMP_2._p || nil, __context = block._s, TMP_2._p = null;
      
      
      for (var i = 0; i < this; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Numeric_prototype.$to_f = function() {
      
      return parseFloat(this);
    };

    Numeric_prototype.$to_i = function() {
      
      return parseInt(this);
    };

    Numeric_prototype.$to_json = function() {
      
      return this.toString();
    };

    Numeric_prototype.$to_s = function(base) {
      if (base == null) {
        base = 10
      }
      return this.toString();
    };

    Numeric_prototype.$upto = TMP_3 = function(finish) {
      var __context, block;
      block = TMP_3._p || nil, __context = block._s, TMP_3._p = null;
      
      
      for (var i = this; i <= finish; i++) {
        if (block.call(__context, i) === __breaker) {
          return __breaker.$v;
        }
      }

      return this;
    
    };

    Numeric_prototype['$zero?'] = function() {
      
      return this == 0;
    };

    return nil;
  })(self, Number);
  return __scope.Fixnum = __scope.Numeric;
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Proc() {};
    Proc = __klass(__base, __super, "Proc", Proc);

    ;Proc._sdonate(["$new"]);    var Proc_prototype = Proc.prototype, __scope = Proc._scope, TMP_1;

    
    Proc_prototype._isProc = true;
    Proc_prototype.is_lambda = true;
  

    Proc.$new = TMP_1 = function() {
      var __context, block;
      block = TMP_1._p || nil, __context = block._s, TMP_1._p = null;
      
      if (block === nil) no_block_given();
      block.is_lambda = false;
      return block;
    };

    Proc_prototype.$call = function(args) {
      args = __slice.call(arguments, 0);
      return this.apply(this._s, args);
    };

    Proc_prototype.$to_proc = function() {
      
      return this;
    };

    Proc_prototype['$lambda?'] = function() {
      
      return !!this.is_lambda;
    };

    Proc_prototype.$arity = function() {
      
      return this.length - 1;
    };

    return nil;
  })(self, Function)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Range() {};
    Range = __klass(__base, __super, "Range", Range);

    var Range_prototype = Range.prototype, __scope = Range._scope, TMP_1;
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
  

    Range_prototype.$begin = function() {
      
      return this.begin
    }, nil;

    Range_prototype.$end = function() {
      
      return this.end
    }, nil;

    Range_prototype.$initialize = function(min, max, exclude) {
      if (exclude == null) {
        exclude = false
      }
      this.begin = min;
      this.end = max;
      return this.exclude = exclude;
    };

    Range_prototype['$=='] = function(other) {
      
      
      if (!other._isRange) {
        return false;
      }

      return this.exclude === other.exclude && this.begin == other.begin && this.end == other.end;
    
    };

    Range_prototype['$==='] = function(obj) {
      
      return obj >= this.begin && (this.exclude ? obj < this.end : obj <= this.end);
    };

    Range_prototype['$cover?'] = function(value) {
      var __a, __b, __c;
      return ((__a = (this.begin)['$<='](value)) ? value['$<=']((function() { if ((__b = this['$exclude_end?']()) !== false && __b !== nil) {
        return (__b = this.end, __c = 1, typeof(__b) === 'number' ? __b - __c : __b['$-'](__c))
        } else {
        return this.end;
      }; return nil; }).call(this)) : __a);
    };

    Range_prototype.$each = TMP_1 = function() {
      var current = nil, __a, __b, __c, __context, __yield;
      __yield = TMP_1._p || nil, __context = __yield._s, TMP_1._p = null;
      
      current = this.$min();
      while ((__b = (__c = current['$=='](this.$max()), (__c === nil || __c === false))) !== false && __b !== nil){if (__yield.call(__context, current) === __breaker) return __breaker.$v;
      current = current.$succ();};
      if ((__a = this['$exclude_end?']()) === false || __a === nil) {
        if (__yield.call(__context, current) === __breaker) return __breaker.$v
      };
      return this;
    };

    Range_prototype['$eql?'] = function(other) {
      var __a;
      if ((__a = __scope.Range['$==='](other)) === false || __a === nil) {
        return false
      };
      return (__a = ((__a = this['$exclude_end?']()['$=='](other['$exclude_end?']())) ? (this.begin)['$eql?'](other.$begin()) : __a), __a !== false && __a !== nil ? (this.end)['$eql?'](other.$end()) : __a);
    };

    Range_prototype['$exclude_end?'] = function() {
      
      return this.exclude;
    };

    Range_prototype['$include?'] = function(val) {
      
      return obj >= this.begin && obj <= this.end;
    };

    Range_prototype.$max = Range_prototype.$end;

    Range_prototype.$min = Range_prototype.$begin;

    Range_prototype['$member?'] = Range_prototype['$include?'];

    Range_prototype.$step = function(n) {
      if (n == null) {
        n = 1
      }
      return this.$raise(__scope.NotImplementedError);
    };

    Range_prototype.$to_s = function() {
      
      return this.begin + (this.exclude ? '...' : '..') + this.end;
    };

    return Range_prototype.$inspect = Range_prototype.$to_s;
  })(self, null)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass;
  
  return (function(__base, __super){
    function Time() {};
    Time = __klass(__base, __super, "Time", Time);

    ;Time._sdonate(["$at", "$new", "$now"]);    var Time_prototype = Time.prototype, __scope = Time._scope;

    Time.$include(__scope.Comparable);

    Time.$at = function(seconds, frac) {
      if (frac == null) {
        frac = 0
      }
      return new Date(seconds * 1000 + frac);
    };

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

    Time.$now = function() {
      
      return new Date();
    };

    Time_prototype['$+'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a + __b : __a['$+'](__b)));
    };

    Time_prototype['$-'] = function(other) {
      var __a, __b;
      return __scope.Time.$allocate((__a = this.$to_f(), __b = other.$to_f(), typeof(__a) === 'number' ? __a - __b : __a['$-'](__b)));
    };

    Time_prototype['$<=>'] = function(other) {
      
      return this.$to_f()['$<=>'](other.$to_f());
    };

    Time_prototype.$day = Time_prototype.getDate;

    Time_prototype['$eql?'] = function(other) {
      var __a;
      return (__a = other['$is_a?'](__scope.Time), __a !== false && __a !== nil ? this['$<=>'](other)['$zero?']() : __a);
    };

    Time_prototype['$friday?'] = function() {
      
      return this.getDay() === 5;
    };

    Time_prototype.$hour = Time_prototype.getHours;

    Time_prototype.$mday = Time_prototype.$day;

    Time_prototype.$min = Time_prototype.getMinutes;

    Time_prototype.$mon = function() {
      
      return this.getMonth() + 1;
    };

    Time_prototype['$monday?'] = function() {
      
      return this.getDay() === 1;
    };

    Time_prototype.$month = Time_prototype.$mon;

    Time_prototype['$saturday?'] = function() {
      
      return this.getDay() === 6;
    };

    Time_prototype.$sec = Time_prototype.getSeconds;

    Time_prototype['$sunday?'] = function() {
      
      return this.getDay() === 0;
    };

    Time_prototype['$thursday?'] = function() {
      
      return this.getDay() === 4;
    };

    Time_prototype.$to_f = function() {
      
      return this.getTime() / 1000;
    };

    Time_prototype.$to_i = function() {
      
      return parseInt(this.getTime() / 1000);
    };

    Time_prototype['$tuesday?'] = function() {
      
      return this.getDay() === 2;
    };

    Time_prototype.$wday = Time_prototype.getDay;

    Time_prototype['$wednesday?'] = function() {
      
      return this.getDay() === 3;
    };

    return Time_prototype.$year = Time_prototype.getFullYear;
  })(self, Date)
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __module = __opal.module, __hash2 = __opal.hash2;
  
  var json_parse = JSON.parse;
  return (function(__base){
    function JSON() {};
    JSON = __module(__base, "JSON", JSON);
    var JSON_prototype = JSON.prototype, __scope = JSON._scope;

    JSON.$parse = function(source) {
      
      return to_opal(json_parse(source));
    };

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
            var hash = __hash2([], {}), v, map = hash.map, keys = hash.keys;

            for (var k in value) {
              if (__hasOwn.call(value, k)) {
                v = to_opal(value[k]);
                keys.push(k);
                map[k] = v;
              }
            }
          }

          return hash;
      }
    };
  
        ;JSON._sdonate(["$parse", "$from_object"]);
  })(self);
})();
(function() {
  var __opal = Opal, self = __opal.top, __scope = __opal, nil = __opal.nil, __breaker = __opal.breaker, __slice = __opal.slice, __klass = __opal.klass, __hash2 = __opal.hash2;
  
  return (function(__base, __super){
    function Template() {};
    Template = __klass(__base, __super, "Template", Template);

    ;Template._sdonate(["$[]", "$[]="]);    var Template_prototype = Template.prototype, __scope = Template._scope, TMP_1;
    Template_prototype.body = nil;

    Template._cache = __hash2([], {});

    Template['$[]'] = function(name) {
      
      if (this._cache == null) this._cache = nil;

      return this._cache['$[]'](name)
    };

    Template['$[]='] = function(name, instance) {
      
      if (this._cache == null) this._cache = nil;

      return this._cache['$[]='](name, instance)
    };

    Template_prototype.$initialize = TMP_1 = function(name) {
      var __context, body;
      body = TMP_1._p || nil, __context = body._s, TMP_1._p = null;
      
      this.body = body;
      this.name = name;
      return __scope.Template['$[]='](name, this);
    };

    Template_prototype.$render = function(ctx) {
      var __a;if (ctx == null) {
        ctx = this
      }
      return (__a = ctx, __a.$instance_eval._p = this.body.$to_proc(), __a.$instance_eval());
    };

    return nil;
  })(self, null)
})();
}).call(this);
