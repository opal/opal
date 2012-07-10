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

// Root method table (BasicObject inherits from this)
function RootMethodTableConstructor() {}

// The prototype (actual table) for root
var RootMethodTable = RootMethodTableConstructor.prototype;

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
    if (!superklass._name) { //!superklass._methods) {
      var bridged = superklass;
      superklass  = Object;
      // constructor = superklass;
      // klass       = bridge_class(bridged);
    }
    // else {
      klass = boot_class(superklass, constructor);
    // }

    if (bridged) {
      bridged.prototype.$m = klass.$m_tbl;
      bridged.prototype.$k = klass;
    }

    klass._name = (base === Object ? id : base._name + '::' + id);

    var const_alloc   = function() {};
    var const_scope   = const_alloc.prototype = new base._scope.alloc();
    klass._scope      = const_scope;
    const_scope.alloc = const_alloc;

    base[id] = base._scope[id] = klass;

    if (superklass.$m.inherited) {
      superklass.$m.inherited(superklass, 'inherited', klass);
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
    klass = boot_module(constructor);
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

  // method table constructor;
  var m_ctr = function() {};

  if (superklass) {
    // not BasicObject
    m_ctr.prototype = new superklass.$m_ctr;
  }
  else {
    // BasicObject
    m_ctr.prototype = RootMethodTable;
  }

  var    m_tbl = m_ctr.prototype;
  m_tbl.constructor = m_ctr;

  var prototype = constructor.prototype;

  prototype.constructor = constructor;
  prototype._isObject   = true;
  prototype._klass      = constructor;

  // method table of instances
  prototype.$m          = m_tbl;

  // constructor._included_in  = [];
  // constructor._isClass      = true;
  // constructor._name         = id;
  // constructor._super        = superklass;
  // constructor._methods      = [];
  // constructor._smethods     = [];
  constructor._isObject     = false;

  // method table for class methods
  // constructor.$m            = c_tbl;
  // method table of instances
  constructor.$m_tbl        = m_tbl;
  // method table constructor of instances
  constructor.$m_ctr        = m_ctr;

  constructor._donate = __donate;
  constructor._sdonate = __sdonate;

  Opal[id] = constructor;

  return constructor;
};

var boot_defmeta = function(constructor, parent_m_tbl) {
  var m_ctr = function(){};
  m_ctr.prototype = new parent_m_tbl;

  var m_tbl = m_ctr.prototype;
  m_tbl.constructor = m_ctr;

  constructor.$m = m_tbl;

  return constructor;
};

// Create generic class with given superclass.
var boot_class = function(superklass, constructor) {
  // method table constructor
  function m_ctr(){};
  m_ctr.prototype = new superklass.$m_tbl.constructor;
  
  // method table itself
  var m_tbl = m_ctr.prototype;
  m_tbl.constructor = m_ctr;

  var prototype = constructor.prototype;

  prototype.constructor = constructor;
  prototype.$k = constructor; // instances need to know their class
  prototype.$m = m_tbl;       // all instances get method table


  constructor.$m_ctr  = m_ctr;
  constructor.$m_tbl  = m_tbl;

  // FIXME: need c_ctr
  var c_ctr = function(){};
  c_ctr.prototype = new superklass.$m.constructor;

  var c_tbl = c_ctr.prototype;
  c_tbl.constructor = c_ctr;
  constructor.$m = c_tbl;


  constructor.$k      = Class;
  constructor.$s      = superklass;

  constructor._donate       = __donate
  // constructor._included_in  = [];
  // constructor._isClass      = true;
  // constructor._super        = superklass;
  // constructor._methods      = [];
  constructor._isObject     = false;
  // constructor._klass        = Class;
  
  // constructor._sdonate      = __sdonate;

  return constructor;
};

var boot_module = function(constructor) {
  // constructor.$m_ctr  = m_ctr;
  constructor.$m_tbl  = {};     // simple method table for modules

  // FIXME: need c_ctr
  var c_ctr = function(){};
  c_ctr.prototype = new Module.$m.constructor;
  
  var c_tbl = c_ctr.prototype;
  constructor.$m = c_tbl;


  constructor.$k      = Class;

  constructor._donate       = __donate
  // constructor._included_in  = [];
  // constructor._isClass      = true;
  // constructor._super        = superklass;
  // constructor._methods      = [];
  constructor._isObject     = false;
  // constructor._klass        = Class;
  
  // constructor._sdonate      = __sdonate;

  return constructor;
};

var bridge_class = function(constructor) {
  return boot_class(Object, constructor);
};

// Requiring and Defining modules
// ------------------------------

// Map of all file id to their function body
var factories = Opal.factories = {};

// Current file executing by opal
Opal.file = "";

// Register file with given name
Opal.define = function(id, body) {
  factories[id] = body;
};

// Require specific file by id
Opal.require = function(id) {
  var body = factories[id];

  if (!body) {
    throw new Error('no file: "' + id + '"');
  }

  if (body._loaded) {
    return false;
  }

  Opal.file = id;

  body._loaded = true;
  body();

  return true;
};

// Initialization
// --------------

boot_defclass('BasicObject', BasicObject);
boot_defclass('Object', Object, BasicObject);
boot_defclass('Class', Class, Object);

boot_defmeta(BasicObject, Class.$m_tbl.constructor);
boot_defmeta(Object, BasicObject.$m.constructor);
boot_defmeta(Class, Object.$m.constructor);

BasicObject.$k = Object.$k = Class.$k = Class;

// Donator for all 'normal' classes and modules
function __donate(defined) {
  var included_in = this.$included_in, m_tbl = this.$m_tbl;

  if (included_in) {
    for (var i = 0, length = included_in.length; i < length; i++) {
      var includee = included_in[i];
      var dest = includee.$m_tbl;

      for (var idx = 0, jj = defined.length; idx < jj; idx++) {
        var method = defined[idx];
        dest[method] = m_tbl[method];
      }

      if (includee.$included_in) {
        // includee._donate(defined, true);
      }
    }

  }
}

// Donator for singleton (class) methods
function __sdonate(defined) {
  // this._smethods = this._smethods.concat(defined);
}

var bridged_classes = Object.$included_in = [];
BasicObject.$included_in = bridged_classes;

BasicObject._scope = Object._scope = Opal;
Opal.Module = Opal.Class;

var class_const_alloc = function(){};
var class_const_scope = new TopScope();
class_const_scope.alloc = class_const_alloc;
Class._scope = class_const_scope;

Object.prototype.toString = function() {
  return this.$m.to_s(this, 'to_s');
};

Opal.top = new Object;

Opal.klass(Object, Object, 'NilClass', NilClass)
Opal.nil = new NilClass;
Opal.nil.call = Opal.nil.apply = no_block_given;

Opal.breaker  = new Error('unexpected break');