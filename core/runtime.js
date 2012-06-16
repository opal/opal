
// The Opal object gets exposed globally (on window) and contains the
// useful runtime methods available to all ruby files, as well as all
// the top level ruby classes, modules and constants.
var Opal = this.Opal = {};

// TopScope is a constructor to hold the prototype that all top level
// Opal constants are defined on.
var TopScope = function(){};

// To make things simple, we alias the top scope prototype to the
// global Opal object.
TopScope.prototype = Opal;

Opal.alloc  = TopScope;
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

/**
  Runtime method used to either define a new class, or re-open an old
  class. The base may be an object (rather than a class), which is
  always the case when defining classes in the top level as the top
  level is just the 'main' Object instance.

  The given ruby code:

      class Foo
        42
      end

      class Bar < Foo
        3.142
      end

  Would be compiled to something like:

      var __klass = Opal.klass;

      __klass(this, null, 'Foo', function() {
        return 42;
      });

      __klass(this, __scope.Foo, 'Bar', function() {
        return 3.142;
      });

  @param [RubyObject] base the scope in which to define the class
  @param [RubyClass] superklass the superklass, may be null
  @param [String] id the name for the class
  @param [Function] body the class body
  @return returns last value from running body
*/
Opal.klass = function(base, superklass, id, constructor) {
  var klass;
  if (base._isObject) {
    base = base._real;
  }

  if (superklass === null) {
    superklass = _Object;
  }

  if (__hasOwn.call(base._scope, id)) {
    klass = base._scope[id];
  }
  else {
    if (!superklass._methods) {
      var bridged = superklass;
      superklass = _Object;
      // console.log("bridge native: " + id);
      // constructor = function() {};
      klass = bridge_class(bridged);
    }
    else {
      klass = boot_class(superklass, constructor);
    }

    klass._name = (base === _Object ? id : base._name + '::' + id);

    // make_metaclass(klass, superklass._klass);

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
    klass = boot_module(id);
    klass._name = (base === _Object ? id : base._name + '::' + id);

    // make_metaclass(klass, RubyModule);

    klass._isModule = true;
    klass.$included_in = [];

    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base._scope.alloc();
    klass._scope      = const_scope;
    const_scope.alloc = const_alloc;

    base[id] = base._scope[id]    = klass;
  }

  return body.call(klass);
}

var mid_to_jsid = function(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return '$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
};

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
  constructor._isObject     = false;
  constructor._subclasses   = [];

  constructor._donate = __donate;

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
  constructor._klass        = _Class;
  constructor._real         = _Class;
  constructor._donate       = __donate
  constructor._subclasses   = [];

  superklass._subclasses.push(constructor);

  classes.push(constructor);
  donate_module_methods(constructor);

  return constructor;
};

var boot_module = function(id) {
  var constructor = function(){};
  var ctor = function() {};
      ctor.prototype = _Module.prototype;

  constructor.prototype = new ctor();

  constructor._isModule = true;
  constructor._name     = id;
  constructor._methods  = [];
  constructor._klass    = _Module;
  constructor._donate   = __donate;

  classes.push(constructor);
  donate_module_methods(constructor);

  return constructor;
};

var bridge_class = function(constructor) {
  constructor.prototype._klass = constructor;
  constructor.prototype._real = constructor;

  constructor._included_in  = [];
  constructor._isClass      = true;
  constructor._super        = _Object;
  constructor._klass        = _Class;
  constructor._methods      = [];
  constructor._isObject     = false;
  constructor._subclasses   = [];

  constructor._donate = function(){};

  bridged_classes.push(constructor);
  classes.push(constructor);
  donate_module_methods(constructor);

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

  var table = _Object.prototype, methods = _Object._methods;

  // console.log("methods:");
  // console.log(methods);

  for (var i = 0, length = methods.length; i < length; i++) {
    var m = methods[i];
    // console.log("copying " + m);
    constructor.prototype[m] = table[m];
  }

  constructor.$allocate = allocator;

  return constructor;
};

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

function _BasicObject() {}
function _Object() {}
function _Class() {}
var _Module = _Class;

boot_defclass('BasicObject', _BasicObject);
boot_defclass('Object', _Object, _BasicObject);
boot_defclass('Class', _Class, _Object);

_BasicObject._klass = _Object._klass = _Class._klass = _Class;

/**
  Module needs to donate methods to all classes

  @param [Array<String>] defined array of methods just defined
*/
_Module._donate = function(defined) {
  var methods = this._methods;

  this._methods = methods.concat(defined);

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

function donate_module_methods(klass) {
  var modproto  = _Module.prototype,
      methods   = _Module._methods;

  for (var i = 0, len = methods.length; i < len; i++) {
    var m = methods[i];
    // console.log("donating " + m + " to " + klass._name);
    klass[m] = modproto[m];
  }
}

/**
  Donator for all 'normal' classes and modules
*/
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

var bridged_classes = _Object.$included_in = [];
_BasicObject.$included_in = bridged_classes;

_BasicObject._scope = _Object._scope = Opal;
Opal.Module = Opal.Class;
Opal.Kernel = _Object;

var class_const_alloc = function(){};
var class_const_scope = new TopScope();
class_const_scope.alloc = class_const_alloc;
_Class._scope = class_const_scope;

_Object.prototype.toString = function() {
  return this.$to_s();
};

Opal.top = new _Object;

function _NilClass() {}
Opal.klass(_Object, _Object, 'NilClass', _NilClass)
Opal.nil = new _NilClass;
Opal.nil.call = Opal.nil.apply = no_block_given;

var breaker = Opal.breaker  = new Error('unexpected break');
    breaker.$t              = function() { throw this; };