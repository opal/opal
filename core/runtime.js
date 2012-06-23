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

// Gets the singleton class of `shift` and run the given `body`
// against it.
Opal.sklass = function(shift, body) {
  var klass = shift.$singleton_class();
  return body.call(klass);
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

  superklass._subclasses.push(constructor);

  var smethods;

  if (superklass === Object) {
    smethods     = Module._methods.slice();
  }
  else {
    smethods = superklass._smethods.slice();
  }

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

BasicObject._klass = Object._klass = Class._klass = Class;

// Module needs to donate methods to all classes
// 
// @param [Array<String>] defined array of methods just defined
Module._donate = function(defined) {
  var methods = this._methods;

  this._methods = methods.concat(defined);

  Object._smethods = Object._smethods.concat(defined);

  for (var i = 0, len = defined.length; i < len; i++) {
    var m = defined[i];

    for (var j = 0, len2 = classes.length; j < len2; j++) {
      var cls = classes[j];

      // don't overwrite a pre-existing method
      if (!cls[m]) {
        cls[m] = this.prototype[m];
      }
    }
  }
};

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