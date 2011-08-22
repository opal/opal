/*!
 * opal v0.3.2
 * http://opalscript.org
 *
 * Copyright 2011, Adam Beynon
 * Released under the MIT license
 */
opal = {};

(function(undefined) {

// So we can minimize
var Op = opal;

/**
  All methods and properties available to ruby/js sources at runtime. These
  are kept in their own namespace to keep the opal namespace clean.
*/
Op.runtime = {};

// for minimizng
var Rt = Op.runtime;
Rt.opal = Op;

/**
  Opal platform - this is overriden in gem context and nodejs context. These
  are the default values used in the browser, `opal-browser'.
*/
var PLATFORM_PLATFORM = "opal";
var PLATFORM_ENGINE   = "opal-gem";
var PLATFORM_VERSION  = "1.9.2";
var PLATFORM_ARGV     = "[]";

// Minimize js types
var ArrayProto     = Array.prototype,
    ObjectProto    = Object.prototype,

    ArraySlice     = ArrayProto.slice,

    hasOwnProperty = ObjectProto.hasOwnProperty;

/**
  prototypes of actual instances of classes.
*/
var boot_Object, boot_Module, boot_Class;

/**
  Core runtime classes, objects and literals.
*/
var cObject,          cModule,          cClass,
    mKernel,          cNilClass,        cTrueClass,       cFalseClass,
    cArray,           cNumeric,
    cRegexp,          cMatch,           top_self,            Qnil,
    Qfalse,           Qtrue,

    cDir;

/**
  Core object type flags. Added as local variables, and onto runtime.
*/
var T_CLASS       = 1,
    T_MODULE      = 2,
    T_OBJECT      = 4,
    T_BOOLEAN     = 8,
    T_STRING      = 16,
    T_ARRAY       = 32,
    T_NUMBER      = 64,
    T_PROC        = 128,
    T_SYMBOL      = 256,
    T_HASH        = 512,
    T_RANGE       = 1024,
    T_ICLASS      = 2056,
    FL_SINGLETON  = 4112;

/**
  Define classes. This is the public API for defining classes, shift classes
  and modules.

  @param {RubyObject} base
  @param {RClass} super_class
  @param {String} id
  @param {Function} body
  @param {Number} flag
*/
Rt.dc = function(base, super_class, id, body, flag) {
  var klass;

  switch (flag) {
    case 0:
      if (base.o$f & T_OBJECT) {
        base = class_real(base.o$k);
      }

      if (super_class == Qnil) {
        super_class = cObject;
      }

      klass = define_class_under(base, id, super_class);
      break;

    case 1:
      klass = singleton_class(base);
      break;

    case 2:
      if (base.o$f & T_OBJECT) {
        base = class_real(base.o$k);
      }
      klass = define_module_under(base, id);
      break;

    default:
      raise(eException, "define_class got a unknown flag " + flag);
  }

  var res = body(klass);

  return res;
};

/**
  Regexp object. This holds the results of last regexp match.
  X for regeXp.
*/
Rt.X = null;

/**
  Undefine methods
*/
Rt.um = function(kls) {
  var args = [].slice.call(arguments, 1);

  for (var i = 0, ii = args.length; i < ii; i++) {
    (function(mid) {
      var func = function() {
        raise(eNoMethodError, "undefined method `" + mid + "' for " + this.m$inspect());
      };

      kls.o$a.prototype['m$' + mid] = func;

      if (kls.$bridge_prototype) {
        kls.$bridge_prototype['m$' + mid] = func;
      }
    })(args[i].m$to_s());
  }

  return Qnil;
};

/**
  Method missing support - used in debug mode (opt in).
*/
Rt.mm = function(method_ids) {
  var prototype = boot_base_class.prototype;

  for (var i = 0, ii = method_ids.length; i < ii; i++) {
    var mid = 'm$' + method_ids[i];

    if (!prototype[mid]) {
      var imp = (function(mid, method_id) {
        return function() {
          var args = [].slice.call(arguments, 0);
          args.unshift(Rt.Y(method_id));
          return this.m$method_missing.apply(this, args);
        };
      })(mid, method_ids[i]);

      imp.$rbMM = true;

      prototype[mid] = prototype[mid] = imp;
    }
  }
};

/**
  Define methods. Public method for defining a method on the given base.

  @param {Object} klass The base to define method on
  @param {String} name Ruby mid
  @param {Function} public_body The method implementation
  @param {Number} arity Method arity
  @return {Qnil}
*/
Rt.dm = function(klass, name, body, arity) {
  if (klass.o$f & T_OBJECT) {
    klass = klass.o$k;
  }

  var mode = klass.$mode;

  if (!body.$rbName) {
    body.$rbName = name;
    body.$rbArity = arity;
  }

  klass.$methods.push(intern(name));
  define_raw_method(klass, 'm$' + name, body);

  return Qnil;
};

/**
  Define singleton method.

  @param {Object} base The base to define method on
  @param {String} method_id Method id
  @param {Function} body Method implementation
  @param {Number} arity Method arity
  @return {Qnil}
*/
Rt.ds = function(base, method_id, body, arity) {
  return Rt.dm(singleton_class(base), method_id, body);
};

/**
  Call a super method.

  callee is the function that actually called super(). We use this to find
  the right place in the tree to find the method that actually called super.
  This is actually done in super_find.
*/
Rt.S = function(callee, self, args) {
  var mid = 'm$' + callee.$rbName;
  var func = super_find(self.o$k, callee, mid);

  if (!func) {
    raise(eNoMethodError, "super: no super class method `" + mid + "`" +
      " for " + self.m$inspect());
  }

  // var args_to_send = [self].concat(args);
  var args_to_send = [].concat(args);
  return func.apply(self, args_to_send);
};

/**
  Actually find super impl to call.  Returns null if cannot find it.
*/
function super_find(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.o$m[mid]) {
      if (klass.o$m[mid] == callee) {
        cur_method = klass.o$m[mid];
        break;
      }
    }
    klass = klass.$super;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.$super;

  while (klass) {
    if (klass.o$m[mid]) {
      return klass.o$m[mid];
    }

    klass = klass.$super;
  }

  return null;
};

/**
  Exception classes. Some of these are used by runtime so they are here for
  convenience.
*/
var eException,       eStandardError,   eLocalJumpError,  eNameError,
    eNoMethodError,   eArgError,        eScriptError,     eLoadError,
    eRuntimeError,    eTypeError,       eIndexError,      eKeyError,
    eRangeError;

var eExceptionInstance;

/**
  Standard jump exceptions to save re-creating them everytime they are needed
*/
var eReturnInstance,
    eBreakInstance,
    eNextInstance;

/**
  Ruby break statement with the given value. When no break value is needed, nil
  should be passed here. An undefined/null value is not valid and will cause an
  internal error.

  @param {RubyObject} value The break value.
*/
Rt.B = function(value) {
  eBreakInstance.$value = value;
  raise_exc(eBreakInstance);
};

/**
  Ruby return, with the given value. The func is the reference function which
  represents the method that this statement must return from.
*/
Rt.R = function(value, func) {
  eReturnInstance.$value = value;
  eReturnInstance.$func = func;
  throw eReturnInstance;
};

/**
  Get the given constant name from the given base
*/
Rt.cg = function(base, id) {
  if (base.o$f & T_OBJECT) {
    base = class_real(base.o$k);
  }
  return const_get(base, id);
};

/**
  Set constant from runtime
*/
Rt.cs = function(base, id, val) {
  if (base.o$f & T_OBJECT) {
    base = class_real(base.o$k);
  }
  return const_set(base, id, val);
};

/**
  Get global by id
*/
Rt.gg = function(id) {
  return gvar_get(id);
};

/**
  Set global by id
*/
Rt.gs = function(id, value) {
  return gvar_set(id, value);
};

function regexp_match_getter(id) {
  var matched = Rt.X;

  if (matched) {
    if (matched.$md) {
      return matched.$md;
    } else {
      var res = new cMatch.o$a();
      res.$data = matched;
      matched.$md = res;
      return res;
    }
  } else {
    return Qnil;
  }
}


/**
  Sets the constant value `val` on the given `klass` as `id`.

  @param {RClass} klass
  @param {String} id
  @param {Object} val
  @return {Object} returns the set value
*/
function const_set(klass, id, val) {
  klass.$c[id] = val;
  return val;
}

/**
  Lookup a constant named `id` on the `klass`. This will throw an error if
  the constant cannot be found.

  @param {RClass} klass
  @param {String} id
*/
function const_get(klass, id) {
  if (klass.$c[id]) {
    return (klass.$c[id]);
  }

  var parent = klass.$parent;

  while (parent && parent != cObject) {
  // while (parent) {
    if (parent.$c[id] !== undefined) {
      return parent.$c[id];
    }

    parent = parent.$parent;
  }

  raise(eNameError, 'uninitialized constant ' + id);
};

Rt.const_get = const_get;

/**
  Returns true or false depending whether a constant named `id` is defined
  on the receiver `klass`.

  @param {RClass} klass
  @param {String} id
  @return {true, false}
*/
function const_defined(klass, id) {
  if (klass.$c[id]) {
    return true;
  }

  return false;
};

/**
  This table holds all the global variables accessible from ruby.

  Entries are mapped by their global id => an object that contains the
  given keys:

    - name
    - value
    - getter
    - setter
*/
var global_tbl = {};

/**
  Defines a hooked/global variable.

  @param {String} name The global name (e.g. '$:')
  @param {Function} getter The getter function to return the variable
  @param {Function} setter The setter function used for setting the var
  @return {null}
*/
function define_hooked_variable(name, getter, setter) {
  var entry = {
    "name": name,
    "value": Qnil,
    "getter": getter,
    "setter": setter
  };

  global_tbl[name] = entry;
};

/**
  A default read only getter for a global variable. This will simply throw a
  name error with the given id. This can be used for variables that should
  not be altered.
*/
function gvar_readonly_setter(id, value) {
  raise(eNameError, id + " is a read-only variable");
};

/**
  Retrieve a global variable. This will use the assigned getter.
*/
function gvar_get(id) {
  var entry = global_tbl[id];
  if (!entry) { return Qnil; }
  return entry.getter(id);
};

/**
  Set a global. If not already set, then we assign basic getters and setters.
*/
function gvar_set(id, value) {
  var entry = global_tbl[id];
  if (entry)  { return entry.setter(id, value); }

  define_hooked_variable(id,

    function(id) {
      return global_tbl[id].value;
    },

    function(id, value) {
      return (global_tbl[id].value = value);
    }
  );

  return gvar_set(id, value);
};

/**
  Every object has a unique id. This count is used as the next id for the
  next created object. Therefore, first ruby object has id 0, next has 1 etc.
*/
var hash_yield = 0;

/**
  Yield the next object id, updating the count, and returning it.
*/
function yield_hash() {
  return hash_yield++;
};

var cHash;

/**
  Returns a new hash with values passed from the runtime.
*/
Rt.H = function() {
  var hash = new cHash.o$a(), k, v, args = Array.prototype.slice.call(arguments);
  var keys = hash.k = [];
  var assocs = hash.a = {};
  hash.d = Qnil;

  for (var i = 0, ii = args.length; i < ii; i++) {
    k = args[i];
    v = args[i + 1];
    i++;
    keys.push(k);
    assocs[k.$hash()] = v;
  }

  return hash;
};

var alias_method = Rt.alias_method = function(klass, new_name, old_name) {
  var body = klass.o$a.prototype['m$' + old_name];

  if (!body) {
    throw new Error("NameError: undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  define_raw_method(klass, 'm$' + new_name, body, body);
  return Qnil;
};

/**
  This does the main work, but does not call runtime methods like
  singleton_method_added etc. define_method does that.

*/
function define_raw_method(klass, name, body) {

  klass.o$a.prototype[name] = body;
  klass.o$m[name] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_raw_method(includee, name, body);
    }
  }

  // this class is actually bridged, so add method to bridge native
  // prototype as well
  if (klass.$bridge_prototype) {
    klass.$bridge_prototype[name] = body;
  }

  // if we are dealing with Object , we need to donate
  // to bridged prototypes as well
  if (klass == cObject) {
    var bridged = bridged_classes;

    for (var i = 0, ii = bridged.length; i < ii; i++) {
      // do not overwrite bridged's own implementation
      if (!bridged[i][name] || bridged[i][name].$rbMM) {
        bridged[i][name] = body;
      }
    }
  }
};

function define_alias(base, new_name, old_name) {
  define_method(base, new_name, base.$m_tbl[old_name]);
  return Qnil;
};

function obj_alloc(klass) {
  var result = new klass.o$a();
  return result;
};

/**
  Raise the exception class with the given string message.
*/
function raise(exc, str) {
  if (str === undefined) {
    str = exc;
    exc = eException;
  }

  var exception = exc.m$new(str);
  raise_exc(exception);
};

Rt.raise = raise;

/**
  Raise an exception instance (DO NOT pass strings to this)
*/
function raise_exc(exc) {
  throw exc;
};

var cString, cSymbol;

/**
  Returns a new ruby symbol with the given intern value. Symbols are made
  using the new String() constructor, and just have its klass and method
  table reassigned. This makes dealing with strings/symbols internally
  easier as both can be used as a string within opal.

  @param {String} intern Symbol value
  @return {RSymbol} symbol
*/
var intern = Rt.Y = function(intern) {
  if (hasOwnProperty.call(symbol_table, intern)) {
    return symbol_table[intern];
  }

  var res = new cSymbol.o$a();
  res.sym = intern;
  symbol_table[intern] = res;
  return res;
};

/**
  Call a super method.

  callee is the function that actually called super(). We use this to find
  the right place in the tree to find the method that actually called super.
  This is actually done in super_find.
*/
Rt.S = function(callee, self, args) {
  var mid = 'm$' + callee.$rbName;
  var func = super_find(self.o$k, callee, mid);

  if (!func) {
    raise(eNoMethodError, "super: no super class method `" + mid + "`" +
      " for " + self.m$inspect());
  }

  // var args_to_send = [self].concat(args);
  var args_to_send = [].concat(args);
  return func.apply(self, args_to_send);
};

/**
  Actually find super impl to call.  Returns null if cannot find it.
*/
function super_find(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.o$m[mid]) {
      if (klass.o$m[mid] == callee) {
        cur_method = klass.o$m[mid];
        break;
      }
    }
    klass = klass.$super;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.$super;

  while (klass) {
    if (klass.o$m[mid]) {
      return klass.o$m[mid];
    }

    klass = klass.$super;
  }

  return null;
};

/**
  Exception classes. Some of these are used by runtime so they are here for
  convenience.
*/
var eException,       eStandardError,   eLocalJumpError,  eNameError,
    eNoMethodError,   eArgError,        eScriptError,     eLoadError,
    eRuntimeError,    eTypeError,       eIndexError,      eKeyError,
    eRangeError;

var eExceptionInstance;

/**
  Standard jump exceptions to save re-creating them everytime they are needed
*/
var eReturnInstance,
    eBreakInstance,
    eNextInstance;

/**
  Ruby break statement with the given value. When no break value is needed, nil
  should be passed here. An undefined/null value is not valid and will cause an
  internal error.

  @param {RubyObject} value The break value.
*/
Rt.B = function(value) {
  eBreakInstance.$value = value;
  raise_exc(eBreakInstance);
};

/**
  Ruby return, with the given value. The func is the reference function which
  represents the method that this statement must return from.
*/
Rt.R = function(value, func) {
  eReturnInstance.$value = value;
  eReturnInstance.$func = func;
  throw eReturnInstance;
};

/**
  Get the given constant name from the given base
*/
Rt.cg = function(base, id) {
  if (base.o$f & T_OBJECT) {
    base = class_real(base.o$k);
  }
  return const_get(base, id);
};

/**
  Set constant from runtime
*/
Rt.cs = function(base, id, val) {
  if (base.o$f & T_OBJECT) {
    base = class_real(base.o$k);
  }
  return const_set(base, id, val);
};

/**
  Get global by id
*/
Rt.gg = function(id) {
  return gvar_get(id);
};

/**
  Set global by id
*/
Rt.gs = function(id, value) {
  return gvar_set(id, value);
};

function regexp_match_getter(id) {
  var matched = Rt.X;

  if (matched) {
    if (matched.$md) {
      return matched.$md;
    } else {
      var res = new cMatch.o$a();
      res.$data = matched;
      matched.$md = res;
      return res;
    }
  } else {
    return Qnil;
  }
}

var cIO, stdin, stdout, stderr;

function stdio_getter(id) {
  switch (id) {
    case "$stdout":
      return stdout;
    case "$stdin":
      return stdin;
    case "$stderr":
      return stderr;
    default:
      raise(eRuntimeError, "stdout_setter being used for bad variable");
  }
};

function stdio_setter(id, value) {
  raise(eException, "stdio_setter cannot currently set stdio variables");

  switch (id) {
    case "$stdout":
      return stdout = value;
    case "$stdin":
      return stdin = value;
    case "$stderr":
      return stderr = value;
    default:
      raise(eRuntimeError, "stdout_setter being used for bad variable: " + id);
  }
};

var cProc;

/**
  Block passing - holds current block for runtime

  f: function
  p: proc
  y: yield error
*/
var block = Rt.P = {
  f: null,
  p: null,
  y: function() {
    throw new Error("LocalJumpError - no block given");
  }
};

block.y.o$s = block.y;

/**
  Turns the given proc/function into a lambda. This is useful for the
  Proc#lambda method, but also for blocks that are turned into
  methods, in Module#define_method, for example. Lambdas and methods
  from blocks are the same thing. Lambdas basically wrap the passed
  block function and perform stricter arg checking to make sure the
  right number of args are passed. Procs are liberal in their arg
  checking, and simply turned ommited args into nil. Lambdas and
  methods MUST check args and throw an error if the wrong number are
  given. Also, lambdas/methods must catch return statements as lambdas
  capture returns.

  FIXME: wrap must detect if we are the receiver of a block, and fix
  the block to send it to the proc.

  FIXME: need to be strict on checking proc arity

  FIXME: need to catch return statements which may be thrown.

  @param {Function} proc The proc/function to lambdafy.
  @return {Function} Wrapped lambda function.
*/
Rt.lambda = function(proc) {
  if (proc.$lambda) return proc;

  var wrap = function() {
    var args = Array.prototype.slice.call(arguments, 0);
    return proc.apply(null, args);
  };

  wrap.$lambda = true;
  wrap.o$s = proc.o$s;

  return Rt.proc(wrap);
};

var cRange;

/**
  Returns a new ruby range. G for ranGe.
*/
Rt.G = function(beg, end, exc) {
  var range = new cRange.o$a();
  range.beg = beg;
  range.end = end;
  range.exc = exc;
  return range;
};

/**
  Print to console - this is overriden upon init so that it will print to
  stdout
*/
var puts = function(str) {
  console.log(str);
};

/**
  Main init method. This is called once this file has fully loaded. It setups
  all the core objects and classes and required runtime features.
*/
function init() {
  var metaclass;

  // what will be the instances of these core classes...
  boot_Object = boot_defclass('Object');
  boot_Module = boot_defclass('Module', boot_Object);
  boot_Class = boot_defclass('Class', boot_Module);

  // the actual classes
  Rt.Object = cObject = boot_makemeta('Object', boot_Object, boot_Class);
  Rt.Module = cModule = boot_makemeta('Module', boot_Module, cObject.constructor);
  Rt.Class = cClass = boot_makemeta('Class', boot_Class, cModule.constructor);

  boot_defmetameta(cObject, cClass);
  boot_defmetameta(cModule, cClass);
  boot_defmetameta(cClass, cClass);

  // fix superclasses
  cObject.$super = null;
  cModule.$super = cObject;
  cClass.$super = cModule;

  const_set(cObject, 'Object', cObject);
  const_set(cObject, 'Module', cModule);
  const_set(cObject, 'Class', cClass);

  mKernel = Rt.Kernel = define_module('Kernel');

  top_self = obj_alloc(cObject);
  Rt.top = top_self;

  cNilClass = define_class('NilClass', cObject);
  Rt.Qnil = Qnil = obj_alloc(cNilClass);
  Qnil.$r = false;

  cTrueClass = define_class('TrueClass', cObject);
  Rt.Qtrue = Qtrue = obj_alloc(cTrueClass);

  cFalseClass = define_class('FalseClass', cObject);
  Rt.Qfalse = Qfalse = obj_alloc(cFalseClass);
  Qfalse.$r = false;

  cArray = bridge_class(Array.prototype, T_OBJECT | T_ARRAY, 'Array', cObject);
  var ary_proto = Array.prototype, ary_inst = cArray.o$a.prototype;
  ary_inst.o$f = T_ARRAY | T_OBJECT;
  ary_inst.push    = ary_proto.push;
  ary_inst.pop     = ary_proto.pop;
  ary_inst.slice   = ary_proto.slice;
  ary_inst.splice  = ary_proto.splice;
  ary_inst.concat  = ary_proto.concat;
  ary_inst.shift   = ary_proto.shift;
  ary_inst.unshift = ary_proto.unshift;

  cHash = define_class('Hash', cObject);

  cNumeric = bridge_class(Number.prototype,
    T_OBJECT | T_NUMBER, 'Numeric', cObject);

  cString = bridge_class(String.prototype,
    T_OBJECT | T_STRING, 'String', cObject);

  cProc = bridge_class(Function.prototype,
    T_OBJECT | T_PROC, 'Proc', cObject);

  cSymbol = define_class('Symbol', cObject);

  cRange = define_class('Range', cObject);

  cRegexp = bridge_class(RegExp.prototype,
    T_OBJECT, 'Regexp', cObject);

  cMatch = define_class('MatchData', cObject);
  define_hooked_variable('$~', regexp_match_getter, gvar_readonly_setter);

  eException = bridge_class(Error.prototype,
    T_OBJECT, 'Exception', cObject);

  eStandardError = define_class("StandardError", eException);
  eRuntimeError = define_class("RuntimeError", eException);
  eLocalJumpError = define_class("LocalJumpError", eStandardError);
  Rt.TypeError = eTypeError = define_class("TypeError", eStandardError);

  eNameError = define_class("NameError", eStandardError);
  eNoMethodError = define_class('NoMethodError', eNameError);
  eArgError = define_class('ArgumentError', eStandardError);

  eScriptError = define_class('ScriptError', eException);
  eLoadError = define_class('LoadError', eScriptError);

  eIndexError = define_class("IndexError", eStandardError);
  eKeyError = define_class("KeyError", eIndexError);
  eRangeError = define_class("RangeError", eStandardError);

  eBreakInstance = new Error('unexpected break');
  eBreakInstance.o$k = eLocalJumpError;
  block.b = eBreakInstance;

  eReturnInstance = new Error('unexpected return');
  eReturnInstance.o$k = eLocalJumpError;

  eNextInstance = new Error('unexpected next');
  eNextInstance.o$k = eLocalJumpError;

  cIO = define_class('IO', cObject);
  stdin = obj_alloc(cIO);
  stdout = obj_alloc(cIO);
  stderr = obj_alloc(cIO);

  const_set(cObject, 'STDIN', stdin);
  const_set(cObject, 'STDOUT', stdout);
  const_set(cObject, 'STDERR', stderr);

  define_hooked_variable('$stdin', stdio_getter, stdio_setter);
  define_hooked_variable('$stdout', stdio_getter, stdio_setter);
  define_hooked_variable('$stderr', stdio_getter, stdio_setter);

  define_hooked_variable('$:', load_path_getter, gvar_readonly_setter);
  define_hooked_variable('$LOAD_PATH', load_path_getter, gvar_readonly_setter);

  Op.loader = new Loader(Op);
  Op.cache = {};

  const_set(cObject, 'RUBY_ENGINE', PLATFORM_ENGINE);
  const_set(cObject, 'RUBY_PLATFORM', PLATFORM_PLATFORM);
  const_set(cObject, 'RUBY_VERSION', PLATFORM_VERSION);
  const_set(cObject, 'ARGV', PLATFORM_ARGV);

  opal.run(core_lib);

  puts = function(str) {
    stdout.m$puts(str);
  };
};

/**
  Symbol table. All symbols are stored here.
*/
var symbol_table = { };


/**
  Root of all classes and objects (except for bridged).
*/
var boot_base_class = function() {};

boot_base_class.$hash = function() {
  return this.$id;
};

boot_base_class.prototype.$r = true;

/**
  Boot a base class (only used for very core object classes)
*/
function boot_defclass(id, super_klass) {
  var cls = function() {
    this.$id = yield_hash();
  };

  if (super_klass) {
    var ctor = function() {};
    ctor.prototype = super_klass.prototype;
    cls.prototype = new ctor();
  } else {
    cls.prototype = new boot_base_class();
  }

  cls.prototype.constructor = cls;
  cls.prototype.o$f = T_OBJECT;

  cls.prototype.$hash = function() { return this.$id; };
  cls.prototype.$r = true;
  return cls;
};

// make the actual classes themselves (Object, Class, etc)
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.$id = yield_hash();
  };

  var ctor = function() {};
  ctor.prototype = superklass.prototype;
  meta.prototype = new ctor();

  var proto = meta.prototype;
  proto.$included_in = [];
  proto.o$m = {};
  proto.$methods = [];

  proto.o$a = klass;
  proto.o$f = T_CLASS;
  proto.__classid__ = id;
  proto.$super = superklass;
  proto.constructor = meta;

  // constants
  if (superklass.prototype.$constants_alloc) {
    proto.$c = new superklass.prototype.$constants_alloc();
    proto.$constants_alloc = function() {};
    proto.$constants_alloc.prototype = proto.$c;
  } else {
    proto.$constants_alloc = function() {};
    proto.$c = proto.$constants_alloc.prototype;
  }

  var result = new meta();
  klass.prototype.o$k = result;
  return result;
};

function boot_defmetameta(klass, meta) {
  klass.o$k = meta;
}

function class_boot(superklass) {
  // instances
  var cls = function() {
    this.$id = yield_hash();
  };

  var ctor = function() {};
  ctor.prototype = superklass.o$a.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.o$f = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = yield_hash();
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.o$a = cls;
  proto.o$f = T_CLASS;
  proto.o$m = {};
  proto.$methods = [];
  proto.constructor = meta;
  proto.$super = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.o$k = result;
  return result;
};

function class_real(klass) {
  while (klass.o$f & FL_SINGLETON) { klass = klass.$super; }
  return klass;
};

Rt.class_real = class_real;

/**
  Name the class with the given id.
*/
function name_class(klass, id) {
  klass.__classid__ = id;
};

/**
  Make metaclass for the given class
*/
function make_metaclass(klass, super_class) {
  if (klass.o$f & T_CLASS) {
    if ((klass.o$f & T_CLASS) && (klass.o$f & FL_SINGLETON)) {
      return make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = class_boot(super_class);
      // remove this??!
      meta.o$a.prototype = klass.constructor.prototype;
      meta.$c = meta.o$k.$c_prototype;
      meta.o$f |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      klass.o$k = meta;
      meta.$c = klass.$c;
      singleton_class_attached(meta, klass);
      // console.log("meta id: " + klass.__classid__);
      return meta;
    }
  } else {
    // if we want metaclass of an object, do this
    return make_singleton_class(klass);
  }
};

function make_singleton_class(obj) {
  var orig_class = obj.o$k;
  var klass = class_boot(orig_class);

  klass.o$f |= FL_SINGLETON;

  obj.o$k = klass;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  singleton_class_attached(klass, obj);

  klass.o$k = class_real(orig_class).o$k;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function singleton_class_attached(klass, obj) {
  if (klass.o$f & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.o$k == metaclass) {
    metametaclass = class_boot(null);
    metametaclass.o$k = metametaclass;
  }
  else {
    metametaclass = class_boot(null);
    metametaclass.o$k = metaclass.o$k.o$k == metaclass.o$k
      ? make_metametaclass(metaclass.o$k)
      : metaclass.o$k.o$k;
  }

  metametaclass.o$f |= FL_SINGLETON;

  singleton_class_attached(metametaclass, metaclass);
  metaclass.o$k = metametaclass;
  super_of_metaclass = metaclass.$super;

  metametaclass.$super = super_of_metaclass.o$k.__attached__
    == super_of_metaclass
    ? super_of_metaclass.o$k
    : make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function boot_defmetametaclass(klass, metametaclass) {
  klass.o$k.o$k = metametaclass;
};

// Holds an array of all prototypes that are bridged. Any method defined on
// Object in ruby will also be added to the bridge classes.
var bridged_classes = [];

/**
  Define toll free bridged class
*/
function bridge_class(prototype, flags, id, super_class) {
  var klass = define_class(id, super_class);

  bridged_classes.push(prototype);
  klass.$bridge_prototype = prototype;

  for (var meth in cObject.o$m) {
    prototype[meth] = cObject.o$m[meth];
  }

  prototype.o$k = klass;
  prototype.o$f = flags;
  prototype.$r = true;

  prototype.$hash = function() { return flags + '_' + this; };

  return klass;
};

// make native prototype from class
function native_prototype(cls, proto) {
  var sup = cls.$super;

  if (sup != cObject) {
    raise(eRuntimeError, "native_error must be used on subclass of Object only");
  }

  bridged_classes.push(proto);
  cls.$bridge_prototype = proto;

  for (var meth in cObject.o$m) {
    proto[meth] = cObject.o$m[meth];
  }

  // add any methods already defined for class.. although, we should really
  // say that you must call Class#native_prototoype ASAP...
  for (var meth in cls.o$m) {
    console.log("need to add existing method " + meth);
  }

  proto.o$k = cls;
  proto.o$f = T_OBJECT;
  proto.$r = true;

  proto.$hash = function() { return this.$id || (this.$id = yield_hash()); };

  return cls;
}

/**
  Define a new class (normal way), with the given id and superclass. Will be
  top level.
*/
function define_class(id, super_klass) {
  return define_class_under(cObject, id, super_klass);
};

function define_class_under(base, id, super_klass) {
  var klass;

  if (const_defined(base, id)) {
    klass = const_get(base, id);

    if (!(klass.o$f & T_CLASS)) {
      throw new Error(id + " is not a class!");
    }

    if (klass.$super != super_klass && super_klass != cObject) {
      throw new Error("Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = define_class_id(id, super_klass);

  if (base == cObject) {
    name_class(klass, id);
  } else {
    name_class(klass, base.__classid__ + '::' + id);
  }

  const_set(base, id, klass);
  klass.$parent = base;

  // Class#inherited hook - here is a good place to call. We check method
  // is actually defined first (incase we are calling it during boot). We
  // can't do this earlier as an error will cause constant names not to be
  // set etc (this is the last place before returning back to scope).
  if (super_klass.m$inherited) {
    super_klass.m$inherited(klass);
  }

  return klass;
};

Rt.define_class_under = define_class_under;

/**
  Actually create class
*/
function define_class_id(id, super_klass) {
  var klass;

  if (!super_klass) {
    super_klass = cObject;
  }
  klass = class_create(super_klass);
  name_class(klass, id);
  make_metaclass(klass, super_klass.o$k);

  return klass;
};

function class_create(super_klass) {
  return class_boot(super_klass);
};

/**
  Get singleton class of obj
*/
function singleton_class(obj) {
  var klass;

  if (obj.o$f & T_OBJECT) {
    if ((obj.o$f & T_NUMBER) || (obj.o$f & T_SYMBOL)) {
      raise(eTypeError, "can't define singleton");
    }
  }

  if ((obj.o$k.o$f & FL_SINGLETON) && obj.o$k.__attached__ == obj) {
    klass = obj.o$k;
  }
  else {
    var class_id = obj.o$k.__classid__;
    klass = make_metaclass(obj, obj.o$k);
  }

  return klass;
};

Rt.singleton_class = singleton_class;


/**
  Define a top level module with the given id
*/
function define_module(id) {
  return define_module_under(cObject, id);
};

function define_module_under(base, id) {
  var module;

  if (const_defined(base, id)) {
    module = const_get(base, id);
    if (module.o$f & T_MODULE) {
      return module;
    }

    throw new Error(id + " is not a module.");
  }

  module = define_module_id(id);

  if (base == cObject) {
    name_class(module, id);
  } else {
    name_class(module, base.__classid__ + '::' + id);
  }

  const_set(base, id, module);
  module.$parent = base;
  return module;
};

function define_module_id(id) {
  var module = class_create(cModule);
  make_metaclass(module, cModule);

  module.o$f = T_MODULE;
  module.$included_in = [];
  return module;
};

function mod_create() {
  return class_boot(cModule);
};

function include_module(klass, module) {

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

  for (var method in module.o$m) {
    if (hasOwnProperty.call(module.o$m, method)) {
      define_raw_method(klass, method,
                        module.o$a.prototype[method]);
    }
  }

  for (var constant in module.$c) {
    if (hasOwnProperty.call(module.$c, constant)) {
      const_set(klass, constant, module.$c[constant]);
    }
  }
};

Rt.include_module = include_module;

function extend_module(klass, module) {
  if (!klass.$extended_modules) {
    klass.$extended_modules = [];
  }

  if (klass.$extended_modules.indexOf(module) != -1) {
    return;
  }
  klass.$extended_modules.push(module);

  if (!module.$extended_in) {
    module.$extended_in = [];
  }

  module.$extended_in.push(klass);

  var meta = klass.o$k;

  for (var method in module.o$m) {
    if (hasOwnProperty.call(module.o$m, method)) {
      define_raw_method(meta, method,
                        module.o$a.prototype[method]);
    }
  }
};

Rt.extend_module = extend_module;

// ..........................................................
// FILE SYSTEM
//

/**
  FileSystem namespace. Overiden in gem and node.js contexts
*/
var Fs = Op.fs = {};

/**
 RegExp for splitting filenames into their dirname, basename and ext.
 This currently only supports unix style filenames as this is what is
 used internally when running in the browser.
*/
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

/**
  Holds the current cwd for the application.

  @type {String}
*/
Fs.cwd = '/';

/**
  Join the given args using the default separator. The returned path
  is not expanded.

  @param {String} parts
  @return {String}
*/
function fs_join(parts) {
  parts = [].slice.call(arguments, 0);
  return parts.join('/');
}

/**
  Normalize the given path by removing '..' and '.' parts etc.

  @param {String} path Path to normalize
  @param {String} base Optional base to normalize with
  @return {String}
*/
function fs_expand_path(path, base) {
  if (!base) {
    if (path.charAt(0) !== '/') {
      base = Fs.cwd;
    }
    else {
      base = '';
    }
  }

  path = fs_join(base, path);

  var parts = path.split('/'), result = [], part;

  // initial /
  if (parts[0] === '') result.push('');

  for (var i = 0, ii = parts.length; i < ii; i++) {
    part = parts[i];

    if (part == '..') {
      result.pop();
    }
    else if (part == '.' || part == '') {

    }
    else {
      result.push(part);
    }
  }

  return result.join('/');
}

/**
  Return all of the path components except the last one.

  @param {String} path
  @return {String}
*/
var fs_dirname = Fs.dirname = function(path) {
  var dirname = PATH_RE.exec(path)[1];

  if (!dirname) return '.';
  else if (dirname === '/') return dirname;
  else return dirname.substring(0, dirname.length - 1);
};

/**
  Returns the file extension of the given `file_name`.

  @param {String} file_name
  @return {String}
*/
Fs.extname = function(file_name) {
  var extname = PATH_RE.exec(file_name)[3];

  if (!extname || extname === '.') return '';
  else return extname;
};

Fs.exist_p = function(path) {
  return Op.loader.factories[fs_expand_path(path)] ? true : false;
};

/**
  Glob
*/
Fs.glob = function() {
  var globs = [].slice.call(arguments);

  var result = [], files = opal.loader.factories;

  for (var i = 0, ii = globs.length; i < ii; i++) {
    var glob = globs[i];

    var re = fs_glob_to_regexp(glob);
    // console.log("glob: " + glob);
    // console.log("re  : " + re);

    for (var file in files) {
      if (re.exec(file)) {
        result.push(file);
      }
    }
  }

  return result;
};

/**
  Turns a glob string into a regexp
*/
function fs_glob_to_regexp(glob) {
  if (typeof glob !== 'string') {
    throw new Error("file_glob_to_regexp: glob must be a string");
  }

  // make sure absolute
  glob = fs_expand_path(glob);
  // console.log("full glob is: " + glob);
  
  var parts = glob.split(''), length = parts.length, result = '';

  var opt_group_stack = 0;

  for (var i = 0; i < length; i++) {
    var cur = parts[i];

    switch (cur) {
      case '*':
        if (parts[i + 1] == '*') {
          result += '.*';
          i++;
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
};


/**
  Valid file extensions opal can load/run
*/
var load_extensions = {};

load_extensions['.js'] = function(loader, path) {
  var source = loader.file_contents(path);
  return load_execute_file(loader, source, path);
};

load_extensions['.rb'] = function(loader, path) {
  var source = loader.ruby_file_contents(path);
  return load_execute_file(loader, source, path);
};

/**
  Require a file by its given lib path/id, or a full path.

  @param {String} id lib path/name
  @return {Boolean}
*/
var rb_require = Op.require = Rt.require = function(lib) {
  var resolved = Op.loader.resolve_lib(lib);
  var cached = Op.cache[resolved];

  // If we have a cache for this require then it has already been
  // required. We return false to indicate this.
  if (cached) return false;

  Op.cache[resolved] = true;

  // try/catch wrap entire file load?
  load_file(Op.loader, resolved);

  return true;
};

/**
  Sets the primary 'gem', by name, so we know which cwd to use etc.
  This can be changed at anytime, but it is only really recomended
  before the application is run.

  Also, if a gem with the given name cannot be found, then an error
  will/should be thrown.

  @param {String} name The root gem name to use
*/
Op.primary = function(name) {
  Fs.cwd = '/' + name;
};

/**
  Just go ahead and run the given block of code. The passed function
  should rake the usual runtime, self and file variables which it will
  be passed.

  @param {Function} body
*/
Op.run = function(body) {
  var res = Qnil;

  if (typeof body != 'function') {
    throw new Error("Expected body to be a function");
  }

  try {
    res = body(Rt, Rt.top, "(opal)");
  }
  catch (err) {
    var stack;

    if (err.$message) {
      puts(err.o$k.__classid__ + ': ' + err.$message);
    }
    else if (err.message) {
      puts(err.o$k.__classid__ + ': ' + err.message);
    }
    else {
      puts('NativeError: ' + err.message);
      //console.log(err);
    }
  }
  return res;
};

/**
  Register a lib or gem with the given info. If info is an object then
  a gem will be registered with the object represented a JSON version
  of the gemspec for the gem. If the info is simply a function (or
  string?) then a singular lib will be registerd with the function as
  its body.

  @param {String} name The lib/gem name
  @param {Object, Function} info
*/
Op.register = function(name, info) {
  // make sure name is useful
  if (typeof name !== 'string') {
    throw new Error("Cannot register a lib without a proper name");
  }

  // registering a lib/file?
  if (typeof info === 'string' || typeof info === 'function') {
    load_register_lib(name, info);
  }
  // registering a gem?
  else if (typeof info === 'object') {
    load_register_gem(name, info);
  }
  // something has gone wrong..
  else {
    throw new Error("Invalid gem/lib data for '" + name + "'");
  }
};

/**
  Actually register a predefined gem. This is for the browser context
  where gems can be serialized into JSON and defined before hand.

  @param {String} name Gem name
  @param {Object} info Serialized gemspec
*/
function load_register_gem(name, info) {
  var factories = Op.loader.factories,
      paths     = Op.loader.paths;

  // register all lib files
  var files = info.files || {};

  // root dir for gem is '/gem_name'
  var root_dir = '/' + name;

  // for now assume './lib' as dir for all libs (should be dynamic..)
  var lib_dir = './lib';

  // add lib dir to paths
  paths.unshift(fs_expand_path(fs_join(root_dir, lib_dir)));

  for (var file in files) {
    if (hasOwnProperty.call(files, file)) {
      var file_path = fs_expand_path(fs_join(root_dir, file));
      factories[file_path] = files[file];
    }
  }

  // register other info? (version etc??)
}

/**
  Register a single lib/file in browser before its needed. These libs
  are added to top level dir '/lib_name.rb'

  @param {String} name Lib name
  @param {Function, String} factory
*/
function load_register_lib(name, factory) {
  var path = '/' + name;
  Op.loader.factories[path] = factory;
}

/**
  The loader is the core machinery used for loading and executing libs
  within opal. An instance of opal will have a `.loader` property which
  is an instance of this Loader class. A Loader is responsible for
  finding, opening and reading contents of libs on disk. Within the
  browser a loader may use XHR requests or cached libs defined by JSON
  to load required libs/gems.

  @constructor
  @param {opal} opal Opal instance to use
*/
function Loader(opal) {
  this.opal = opal;
  this.paths = ['', '/lib'];
  this.factories = {};
  return this;
}

// For minimizing
var Lp = Loader.prototype;

/**
  The paths property is an array of disk paths in which to search for
  required modules. In the browser this functionality isn't really used.

  This array is created within the constructor method for uniqueness
  between instances for correct sandboxing.
*/
Lp.paths = null;

/**
  factories of registered packages, paths => function/string. This is
  generic, but in reality only the browser uses this, and it is treated
  as the mini filesystem. Not just factories can go here, anything can!
  Images, text, json, whatever.
*/
Lp.factories = {};

/**
  Resolves the path to the lib, which can then be used to load. This
  will throw an error if the module cannot be found. If this method
  returns a successful path, then subsequent methods can assume that
  the path exists.

  @param {String} lib The lib name/path to look for
  @return {String}
*/
Lp.resolve_lib = function(lib) {
  var resolved = this.find_lib(lib, this.paths);

  if (!resolved) {
    throw new Error("LoadError: no such file to load -- " + lib);
  }

  return resolved;
};

/**
  Locates the lib/file using the given paths.

  @param {String} lib The lib path/file to look for
  @param {Array} paths Load paths to use
  @return {String} Located path
*/
Lp.find_lib = function(id, paths) {
  var extensions = this.valid_extensions, factories = this.factories, candidate;

  for (var i = 0, ii = extensions.length; i < ii; i++) {
    for (var j = 0, jj = paths.length; j < jj; j++) {
      candidate = fs_join(paths[j], id + extensions[i]);

      if (factories[candidate]) {
        return candidate;
      }
    }
  }

  // try full path (we try to load absolute path!)
  if (factories[id]) {
    return id;
  }

  // try full path with each extension
  for (var i = 0; i < extensions.length; i++) {
    candidate = id + extensions[i];
    if (factories[candidate]) {
      return candidate;
    }
  }

  // try each path with no extension (if id already has extension)
  for (var i = 0; i < paths.length; i++) {
    candidate = fs_join(paths[j], id);

    if (factories[candidate]) {
      return candidate;
    }
  }

  return null;
};

/**
  Valid factory format for use in require();
*/
Lp.valid_extensions = ['.js', '.rb'];

/**
  Get lib contents for js files
*/
Lp.file_contents = function(path) {
  return this.factories[path];
};

Lp.ruby_file_contents = function(path) {
  return this.factories[path];
};

/**
  Actually run file with resolved name.

  @param {Loader} loader
  @param {String} path
*/
function load_file(loader, path) {
  var ext = load_extensions[PATH_RE.exec(path)[3] || '.js'];

  if (!ext) {
    throw new Error("load_run_file - Bad extension for resolved path");
  }

  ext(loader, path);
}

/**
  Run content which must now be javascript. Arguments we pass to func
  are:

    $rb
    top_self
    filename

  @param {String, Function} content
  @param {String} path
*/
function load_execute_file(loader, content, path) {
  var args = [Rt, top_self, path];

  if (typeof content === 'function') {
    return content.apply(Op, args);

  } else if (typeof content === 'string') {
    var func = loader.wrap(content, path);
    return func.apply(Op, args);

  } else {
    throw new Error(
      "Loader.execute - bad content sent for '" + path + "'");
  }
}

/**
  Getter method for getting the load path for opal.

  @param {String} id The globals id being retrieved.
  @return {Array} Load paths
*/
function load_path_getter(id) {
  return Rt.A(opal.loader.paths);
}

/**
  Getter method to get all loaded features.

  @param {String} id Feature global id
  @return {Array} Loaded features
*/
function loaded_feature_getter(id) {
  return loaded_features;
}

function obj_require(obj, path) {
  return Rt.require(path) ? Qtrue : Qfalse;
}

var core_lib = function($rb, self, __FILE__) { function $$(){$class(self, nil, 'Module', function(self) {  

  $defn(self, 'include', function(mods) { var self = this;mods = [].slice.call(arguments, 0);    
    var i = mods.length - 1, mod;
    while (i >= 0) {
      mod = mods[i];
      mod.m$append_features(self);
      mod.m$included(self);
      i--;
    }
    return self;
  }, -1);  

  $defn(self, 'append_features', function(mod) { var self = this;    
    include_module(mod, self);    
    return self;
  }, 1);  

  return $defn(self, 'included', function(mod) { var self = this;    
    return nil;
  }, 1);
}, 0);

$class(self, nil, 'Kernel', function(self) {   






  $defn(self, 'require', function(path) { var self = this;    
    rb_require(path) ? Qtrue : Qfalse;    
    return Qtrue;
  }, 1);  





  return $defn(self, 'puts', function(a) { var self = this;var __a;a = [].slice.call(arguments, 0);    
    (__a = $rb.gg('$stdout')).m$puts.apply(__a, a);    
    return nil;
  }, -1);
}, 2);

$class($rb.gg('$stdout'), nil, nil, function(self) {  



  return $defn(self, 'puts', function(a) { var self = this;a = [].slice.call(arguments, 0);    
    for (var i = 0, ii = a.length; i < ii; i++) {
      console.log(a[i].m$to_s().toString());
    }    
    return nil;
  }, -1);
}, 1);

$class(self, nil, 'Object', function(self) {  
  return self.m$include($cg(self, 'Kernel'));
}, 0);

$class(self, nil, 'Symbol', function(self) {  
  return $defn(self, 'to_s', function() { var self = this;    
    return self.sym.toString();
  }, 0);
}, 0);

$class(self, nil, 'String', function(self) {  
  return $defn(self, 'to_s', function() { var self = this;    
    return self.toString();
  }, 0);
}, 0);



$class(self, nil, 'Object', function(self) {  

  $defn(self, 'initialize', function(a) { var self = this;a = [].slice.call(arguments, 0);    return nil;

  }, -1);  

  $defn(self, '==', function(other) { var self = this;    
    if (self == other) return Qtrue;
    return Qfalse;
  }, 1);  

  $defn(self, 'equal?', function(other) { var self = this;    
    return self['m$=='](other);
  }, 1);  

  $defn(self, '!', function() { var self = this;    
    return (self.$r ? Qfalse : Qtrue);
  }, 0);  

  $defn(self, '!=', function(obj) { var self = this;    
    return (self['m$=='](obj).$r ? Qfalse : Qtrue);
  }, 1);  

  $defn(self, '__send__', function(method_id, args) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;args = [].slice.call(arguments, 1);var block = (($yy == $y.y) ? nil: $yy);    
    var method = self['m$' + method_id.m$to_s()];

    if ($B.f == arguments.callee) {
      $B.f = method;
    }

    return method.apply(self, args);
  }, -2);  

  $defn(self, 'instance_eval', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var block = (($yy == $y.y) ? nil: $yy);    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'ArgumentError'), "block not supplied")};    
    block.call(self);    
    return self;
  }, 0);  

  return $defn(self, 'method_missing', function(sym, args) { var self = this;args = [].slice.call(arguments, 1);    
    return self.m$raise($cg(self, 'NoMethodError'), ("undefined method `" + sym.m$to_s() + "` for " + self.m$inspect().m$to_s()));
  }, -2);
}, 0);




$class(self, nil, 'Module', function(self) {  

  $defn(self, 'name', function() { var self = this;    
    return self.__classid__;
  }, 0);  

  $defn(self, '===', function(obj) { var self = this;    
    return obj['m$kind_of?'](self);
  }, 1);  

  $defn(self, 'define_method', function(method_id) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var block = (($yy == $y.y) ? nil: $yy);    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'LocalJumpError'), "no block given")};    
    $rb.dm(self, method_id.m$to_s().toString(), block)    
    return nil;
  }, 1);  

  $defn(self, 'attr_accessor', function(attrs) { var self = this;var __a;attrs = [].slice.call(arguments, 0);    
    (__a = self).m$attr_reader.apply(__a, attrs);    
    return (__a = self).m$attr_writer.apply(__a, attrs);
  }, -1);  

  $defn(self, 'attr_reader', function(attrs) { var self = this;var __a, __b;attrs = [].slice.call(arguments, 0);    
    (__a = attrs, $B.f = __a.m$each, ($B.p =function(a) { var self = this; var method_id;      
      method_id = a.m$to_s();      
      $rb.dm(self, method_id, function() {
        var iv = this['$' + method_id];
        return iv == undefined ? nil : iv;
      });
    }).o$s=self, $B.f).call(__a);    
    return nil;
  }, -1);  

  $defn(self, 'attr_writer', function(attrs) { var self = this;var __a, __b;attrs = [].slice.call(arguments, 0);    
    (__a = attrs, $B.f = __a.m$each, ($B.p =function(a) { var self = this; var method_id;      
      method_id = a.m$to_s();      
      $rb.dm(self, method_id + '=', function(val) {
        return this['$' + method_id] = val;
      });
    }).o$s=self, $B.f).call(__a);    
    return nil;
  }, -1);  

  $defn(self, 'alias_method', function(new_name, old_name) { var self = this;    
    $rb.alias_method(self, new_name.m$to_s(), old_name.m$to_s());    
    return self;
  }, 2);  

  $defn(self, 'instance_methods', function() { var self = this;    
    return self.$methods;
  }, 0);  

  $defn(self, 'ancestors', function() { var self = this;    
    var ary = [], parent = self;

    while (parent) {
      if (parent.o$f & $rb.FL_SINGLETON) {
        // nothing?
      }
      else {
        ary.push(parent);
      }

      parent = parent.$super;
    }

    return ary;
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    return self.__classid__;
  }, 0);  

  $defn(self, 'const_set', function(id, value) { var self = this;    
    return $rb.cs(self, id.m$to_s(), value);
  }, 2);  

  $defn(self, 'class_eval', function(str) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;if (str == undefined) {str = nil;}var block = (($yy == $y.y) ? nil: $yy);    
    if (($yy == $y.y ? Qfalse : Qtrue).$r) {      
      block.call(self)
    } else {      
      return self.m$raise("need to compile str");
    }
  }, -1);  

  $defn(self, 'module_eval', function(str) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;if (str == undefined) {str = nil;}var block = (($yy == $y.y) ? nil: $yy);    
    return ($B.p = block, $B.f = (__a = self).m$class_eval).call(__a, str);
  }, -1);  

  return $defn(self, 'extend', function(mod) { var self = this;    
    $rb.extend_module(self, mod)    
    return nil;
  }, 1);
}, 0);

$class(self, $cg(self, 'Module'), 'Class', function(self) {  

  $defs(self, 'new', function(sup) { var self = this;if (sup == undefined) {sup = $cg(self, 'Object');}    
    return define_class_id('AnonClass', sup);
  }, -1);  

  $defn(self, 'allocate', function() { var self = this;    
    return new self.o$a();
  }, 0);  

  $defn(self, 'new', function(args) { var self = this;var obj, __a;args = [].slice.call(arguments, 0);    
    obj = self.m$allocate();    

    if ($B.f == arguments.callee) {
      $B.f = obj.m$initialize;
    }    

    (__a = obj).m$initialize.apply(__a, args);    
    return obj;
  }, -1);  

  $defn(self, 'inherited', function(cls) { var self = this;    
    return nil;
  }, 1);  

  $defn(self, 'superclass', function() { var self = this;    
    var sup = self.$super;

    if (!sup) {
      if (self == cObject) return nil;
      throw new Error('RuntimeError: uninitialized class');
    }

    return sup;
  }, 0);  

  return $defn(self, 'native_prototype', function(proto) { var self = this;    
    native_prototype(self, proto);    
    return self;
  }, 1);
}, 0);




$class(self, nil, 'Kernel', function(self) {   


  $defn(self, 'instance_variable_defined?', function(name) { var self = this;    
    name = name.m$to_s();
    return self['$' + name.substr(1)] == undefined ? Qfalse : Qtrue;
  }, 1);  

  $defn(self, 'instance_variable_get', function(name) { var self = this;    
    name = name.m$to_s();
    return self['$' + name.substr(1)] == undefined ? nil : self['$' + name.substr(1)];
  }, 1);  

  $defn(self, 'instance_variable_set', function(name, value) { var self = this;    
    name = name.m$to_s();
    return self['$' + name.substr(1)] = value;
  }, 2);  








  $defn(self, 'block_given?', function() { var self = this;    
    return Qfalse;
  }, 0);  


  $defn(self, '__flags__', function() { var self = this;    
    return self.o$f;
  }, 0);  

  $defn(self, 'to_a', function() { var self = this;    
    return [self];
  }, 0);  

  $defn(self, 'tap', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'LocalJumpError'), "no block given")};    
    if ($yy.call($ys, self) == $yb) { return $yb.$value; };    
    return self;
  }, 0);  

  $defn(self, 'kind_of?', function(klass) { var self = this;    
    var search = self.o$k;

    while (search) {
      if (search == klass) {
        return Qtrue;
      }

      search = search.$super;
    }

    return Qfalse;
  }, 1);  

  $defn(self, 'is_a?', function(klass) { var self = this;    
    return self['m$kind_of?'](klass);
  }, 1);  

  $defn(self, 'nil?', function() { var self = this;    
    return Qfalse;
  }, 0);  















  $defn(self, 'respond_to?', function(method_id) { var self = this;    
    var method = self['m$' + method_id.m$to_s()];

    if (method && !method.$rbMM) {
      return Qtrue;
    }

    return Qfalse;
  }, 1);  

  $defn(self, '===', function(other) { var self = this;    
    return self['m$=='](other);
  }, 1);  

  $defn(self, 'send', function(method_id, args) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;args = [].slice.call(arguments, 1);var block = (($yy == $y.y) ? nil: $yy);    
    var method = self.$m[method_id.m$to_s()];

    if ($B.f == arguments.callee) {
      $B.f = method;
    }

    args.unshift(self);

    return method.apply(self, args);
  }, -2);  

  $defn(self, 'class', function() { var self = this;    
    return $rb.class_real(self.o$k);
  }, 0);  

  $defn(self, 'singleton_class', function() { var self = this;    
    return $rb.singleton_class(self);
  }, 0);  

  $defn(self, 'methods', function() { var self = this;    
    return self.o$k.$methods;
  }, 0);  













  $defn(self, 'rand', function(max) { var self = this;if (max == undefined) {max = undefined;}    
    if (max != undefined)
        return Math.floor(Math.random() * max);
    else
      return Math.random();
  }, -1);  

  $defn(self, '__id__', function() { var self = this;    
    return self.$hash();
  }, 0);  

  $defn(self, 'object_id', function() { var self = this;    
    return self.$hash();
  }, 0);  






  $defn(self, 'to_s', function() { var self = this;    
    return ("#<" + $rb.class_real(self.o$k).m$to_s() + ":0x" + (self.$hash() * 400487).toString(16).m$to_s() + ">");
  }, 0);  

  $defn(self, 'inspect', function() { var self = this;    
    return self.m$to_s();
  }, 0);  

  $defn(self, 'const_set', function(name, value) { var self = this;    
    return rb_const_set($rb.class_real(self.o$k), name, value);
  }, 2);  

  $defn(self, 'const_defined?', function(name) { var self = this;    
    return Qfalse;
  }, 1);  

  $defn(self, '=~', function(obj) { var self = this;    
    return nil;
  }, 1);  

  $defn(self, 'extend', function(mod) { var self = this;    
    extend_module($rb.singleton_class(self), mod);    
    return nil;
  }, 1);  




















  $defn(self, 'raise', function(exception, string) { var self = this;if (string == undefined) {string = nil;}    
    var msg = nil, exc;

    if (exception.o$f & T_STRING) {
      msg = exception;
      exc = $cg(self, 'RuntimeError').m$new(msg);
    } else if (exception['m$kind_of?']($cg(self, 'Exception')).$r) {
      exc = exception;
    } else {
      if (string != nil) msg = string;
      exc = exception.m$new(msg);
    }
    raise_exc(exc);
  }, -2);  

  self.m$alias_method($symbol_1, $symbol_2);  










  $defn(self, 'loop', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    while (true) {
      ((__a = $yy.call($ys)) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  









  $defn(self, 'proc', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var block = (($yy == $y.y) ? nil: $yy);    

    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'ArgumentError'), "tried to create Proc object without a block")};    
    return block;
  }, 0);  

  return $defn(self, 'lambda', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var block = (($yy == $y.y) ? nil: $yy);    

    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'ArgumentError'), "tried to create Proc object without a block")};    
    return $rb.lambda(block);
  }, 0);


}, 2);

$defs(self, 'to_s', function() { var self = this;  
  return "main";
}, 0);

$defs(self, 'include', function(mod) { var self = this;  
  return $cg(self, 'Object').m$include(mod);
}, 1);














$class(self, nil, 'NilClass', function(self) {  

  $defn(self, 'to_i', function() { var self = this;    
    return 0;
  }, 0);  

  $defn(self, 'to_f', function() { var self = this;    
    return 0.0;
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    return '';
  }, 0);  

  $defn(self, 'to_a', function() { var self = this;    
    return [];
  }, 0);  

  $defn(self, 'inspect', function() { var self = this;    
    return "nil";
  }, 0);  

  $defn(self, 'nil?', function() { var self = this;    
    return Qtrue;
  }, 0);  

  $defn(self, '&', function(other) { var self = this;    
    return Qfalse;
  }, 1);  

  $defn(self, '|', function(other) { var self = this;    
    return other.$r ? Qtrue : Qfalse;
  }, 1);  

  return $defn(self, '^', function(other) { var self = this;    
    return other.$r ? Qtrue : Qfalse;
  }, 1);
}, 0);

$rb.cs(self, 'NIL', nil);






















$class(self, nil, 'TrueClass', function(self) {  
  $defn(self, 'to_s', function() { var self = this;    
    return "true";
  }, 0);  

  $defn(self, '&', function(other) { var self = this;    
    return other.$r ? Qtrue : Qfalse;
  }, 1);  

  $defn(self, '|', function(other) { var self = this;    
    return Qtrue;
  }, 1);  

  return $defn(self, '^', function(other) { var self = this;    
    return other.$r ? Qfalse : Qtrue;
  }, 1);
}, 0);

$rb.cs(self, 'TRUE', Qtrue);






















$class(self, nil, 'FalseClass', function(self) {  









  $defn(self, 'to_s', function() { var self = this;    
    return "false";
  }, 0);  










  $defn(self, '&', function(other) { var self = this;    
    return Qfalse;
  }, 1);  












  $defn(self, '|', function(other) { var self = this;    
    return other.$r ? Qtrue : Qfalse;
  }, 1);  












  return $defn(self, '^', function(other) { var self = this;    
    return other.$r ? Qtrue : Qfalse;
  }, 1);
}, 0);

$rb.cs(self, 'FALSE', Qfalse);


$class(self, nil, 'Enumerable', function(self) {   









  $defn(self, 'to_a', function() { var self = this;var ary, __a, __b;    
    ary = [];    
    (__a = self, $B.f = __a.m$each, ($B.p =function(arg) { var self = this;      ary.push(arg);}).o$s=self, $B.f).call(__a);    
    return ary;
  }, 0);  

  self.m$alias_method($symbol_3, $symbol_4);  

  $defn(self, 'collect', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a, __b;var block = (($yy == $y.y) ? nil: $yy);    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("Enumerable#collect no block given")};    
    var result = [];    

    (__a = self, $B.f = __a.m$each, ($B.p =function(args) { var self = this; var __a;args = [].slice.call($A, 1);      
      result.push((__a = block).m$call.apply(__a, args));
    }).o$s=self, $B.f).call(__a);    

    return result;
  }, 0);  

  return self.m$alias_method($symbol_5, $symbol_6);
}, 2);

$class(self, nil, 'Array', function(self) {  










  $defs(self, '[]', function(objs) { var self = this;objs = [].slice.call(arguments, 0);    
    var ary = self.m$allocate();
    ary.splice.apply(ary, [0, 0].concat(objs));
    return ary;
  }, -1);  

  $defs(self, 'allocate', function() { var self = this;    
    var arr = new self.o$a();
    arr.length = 0;
    return arr;
  }, 0);  

  $defn(self, 'initialize', function(len, fill) { var self = this;if (len == undefined) {len = 0;}if (fill == undefined) {fill = nil;}    
    for (var i = 0; i < len; i++) {
      self[i] = fill;
    }

    self.length = len;

    return self;
  }, -1);  





  $defn(self, 'inspect', function() { var self = this;    
    var description = [];

    for (var i = 0, length = self.length; i < length; i++) {
      description.push(self[i].m$inspect());
    }

    return '[' + description.join(', ') + ']';
  }, 0);  



  $defn(self, 'to_s', function() { var self = this;    
    var description = [];

    for (var i = 0, length = self.length; i < length; i++) {
      description.push(self[i].m$to_s());
    }

    return description.join('');
  }, 0);  












  $defn(self, '<<', function(obj) { var self = this;    
    self.push(obj);    
    return self;
  }, 1);  









  $defn(self, 'length', function() { var self = this;    
    return self.length;
  }, 0);  

  self.m$alias_method($symbol_7, $symbol_8);  

















  $defn(self, 'each', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("Array#each no block given")};    

    for (var i = 0, len = self.length; i < len; i++) {    
    if ($yy.call($ys, self[i]) == $yb) { return $yb.$value; };    
    }    
    return self;
  }, 0);  



  $defn(self, 'each_with_index', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("Array#each_with_index no block given")};    

    for (var i = 0, len = self.length; i < len; i++) {    
    if ($yy.call($ys, self[i], i) == $yb) { return $yb.$value; };    
    }    
    return self;
  }, 0);  

















  $defn(self, 'each_index', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("Array#each_index no block given")};    

    for (var i = 0, len = self.length; i < len; i++) {    
    if ($yy.call($ys, i) == $yb) { return $yb.$value; };    
    }    
    return self;
  }, 0);  













  $defn(self, 'push', function(objs) { var self = this;objs = [].slice.call(arguments, 0);    
    for (var i = 0, ii = objs.length; i < ii; i++) {
      self.push(objs[i]);
    }
    return self;
  }, -1);  















  $defn(self, 'index', function(obj) { var self = this;    
    for (var i = 0, len = self.length; i < len; i++) {
      if (self[i]['m$=='](obj).$r) {
        return i;
      }
    }

    return nil;
  }, 1);  











  $defn(self, '+', function(other) { var self = this;    
    return self.slice(0).concat(other.slice());
  }, 1);  











  $defn(self, '-', function(other) { var self = this;    
    return self.m$raise("Array#- not yet implemented");
  }, 1);  













  $defn(self, '==', function(other) { var self = this;    
    if (self.$hash() == other.$hash()) return Qtrue;
    if (self.length != other.length) return Qfalse;

    for (var i = 0; i < self.length; i++) {
      if (!self[i]['m$=='](other[i]).$r) {
        return Qfalse;
      }
    }

    return Qtrue;
  }, 1);  















  $defn(self, 'assoc', function(obj) { var self = this;    
    var arg;

    for (var i = 0; i < self.length; i++) {
      arg = self[i];

      if (arg.length && arg[0]['m$=='](obj).$r) {
        return arg;
      }
    }

    return nil;
  }, 1);  













  $defn(self, 'at', function(idx) { var self = this;    
    var size = self.length;

    if (idx < 0) idx += size;

    if (idx < 0 || idx >= size) return nil;
    return self[idx];
  }, 1);  









  $defn(self, 'clear', function() { var self = this;    
    self.splice(0);
    return self;
  }, 0);  












  $defn(self, 'select', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var result = [], arg;

    for (var i = 0, ii = self.length; i < ii; i++) {
      arg = self[i];

      if (((__a = $yy.call($ys, arg)) == $yb ? $break() : __a).$r) {
        result.push(arg);
      }
    }

    return result;
  }, 0);  











  $defn(self, 'collect', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("Array#collect no block given")};    

    var result = [];

    for (var i = 0, ii = self.length; i < ii; i++) {
      result.push(((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a));
    }

    return result;
  }, 0);  

  self.m$alias_method($symbol_5, $symbol_6);  













  $defn(self, 'collect!', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = 0, ii = self.length; i < ii; i++) {
      self[i] = ((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  


  $defn(self, 'dup', function() { var self = this;    
    return self.slice(0);
  }, 0);  









  $defn(self, 'compact', function() { var self = this;    
    var result = [], length = self.length;

    for (var i = 0; i < length; i++) {
      if (self[i] != nil) {
        result.push(self[i]);
      }
    }

    return result;
  }, 0);  













  $defn(self, 'compact!', function() { var self = this;    
    var length = self.length;

    for (var i = 0; i < length; i++) {
      if (self[i] == nil) {
        self.splice(i, 1);
        i--;
      }
    }

    return length == self.length ? nil : self;
  }, 0);  










  $defn(self, 'concat', function(other) { var self = this;    
    var length = other.length;

    for (var i = 0; i < length; i++) {
      self.push(other[i]);
    }

    return self;
  }, 1);  













  $defn(self, 'count', function(obj) { var self = this;    
    if (obj != undefined) {
      var total = 0;

      for (var i = 0; i < self.length; i++) {
        if (self[i]['m$=='](obj).$r) {
          total++;
        }
      }

      return total;
    } else {
      return self.length;
    }
  }, -1);  



















  $defn(self, 'delete', function(obj) { var self = this;    
    var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (self[i]['m$=='](obj).$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return length == self.length ? nil : obj;
  }, 1);  
















  $defn(self, 'delete_at', function(idx) { var self = this;    
    if (idx < 0) idx += self.length;
    if (idx < 0 || idx >= self.length) return nil;
    var res = self[idx];
    self.splice(idx, 1);
    return self;
  }, 1);  










  $defn(self, 'delete_if', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = 0, ii = self.length; i < ii; i++) {
      if (((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        self.splice(i, 1);
        i--;
        ii = self.length;
      }
    }
    return self;
  }, 0);  













  $defn(self, 'drop', function(n) { var self = this;    
    if (n > self.length) return [];
    return self.slice(n);
  }, 1);  












  $defn(self, 'drop_while', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = 0; i < self.length; i++) {
      if (!((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        return self.slice(i);
      }
    }

    return [];
  }, 0);  









  $defn(self, 'empty?', function() { var self = this;    
    return self.length == 0 ? Qtrue : Qfalse;
  }, 0);  




























  $defn(self, 'fetch', function(idx, defaults) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var original = idx;

    if (idx < 0) idx += self.length;
    if (idx < 0 || idx >= self.length) {
      if (defaults == undefined)
        return rb_raise("Index Error: Array#fetch");
      else if (__block__)
        return ((__a = $yy.call($ys, original)) == $yb ? $break() : __a);
      else
        return defaults;
    }

    return self[idx];
  }, -2);  















  $defn(self, 'first', function(count) { var self = this;    
    if (count == undefined) {
      if (self.length == 0) return nil;
      return self[0];
    }
    return self.slice(0, count);
  }, -1);  






















  $defn(self, 'flatten', function(level) { var self = this;    
    var result = [], item;

    for (var i = 0; i < self.length; i++) {
      item = self[i];

      if (item.o$f & T_ARRAY) {
        if (level == undefined)
          result = result.concat(item.m$flatten());
        else if (level == 0)
          result.push(item);
        else
          result = result.concat(item.m$flatten(level - 1));
      } else {
        result.push(item);
      }
    }

    return result;
  }, -1);  
















  $defn(self, 'flatten!', function(level) { var self = this;    
    var length = self.length;
    var result = self.m$flatten(level);
    self.splice(0);

    for (var i = 0; i < result.length; i++) {
      self.push(result[i]);
    }

    if (self.length == length)
      return nil;

    return self;
  }, -1);  










  $defn(self, 'include?', function(member) { var self = this;    
    for (var i = 0; i < self.length; i++) {
      if (self[i]['m$=='](member).$r) {
        return Qtrue;
      }
    }

    return Qfalse;
  }, 1);  














  $defn(self, 'replace', function(other) { var self = this;    
    self.splice(0);

    for (var i = 0; i < other.length; i++) {
      self.push(other[i]);
    }

    return self;
  }, 1);  















  $defn(self, 'insert', function(idx, objs) { var self = this;objs = [].slice.call(arguments, 1);    
    var size = self.length;

    if (idx < 0) idx += size;

    if (idx < 0 || idx >= size)
      raise("IndexError: out of range");

    self.splice.apply(self, [idx, 0].concat(objs));
    return self;
  }, -2);  













  $defn(self, 'join', function(sep) { var self = this;if (sep == undefined) {sep = '';}    
    var result = [];

    for (var i = 0; i < self.length; i++) {
      result.push(self[i].m$to_s());
    }

    return result.join(sep);
  }, -1);  










  $defn(self, 'keep_if', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = 0; i < self.length; i++) {
      if (!((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self;
  }, 0);  














  $defn(self, 'last', function(count) { var self = this;    
    var size = self.length;

    if (count == undefined) {
      if (size == 0) return nil;
      return self[size - 1];
    } else {
      if (count > size) count = size;
      return self.slice(size - count, size);
    }
  }, -1);  

















  $defn(self, 'pop', function(count) { var self = this;    
    var size = self.length;

    if (count == undefined) {
      if (size) return self.pop();
      return nil;
    } else {
      return self.splice(size - count, size);
    }
  }, -1);  















  $defn(self, 'rassoc', function(obj) { var self = this;    
    var test;

    for (var i = 0; i < self.length; i++) {
      test = self[i];
      if (test.o$f & T_ARRAY && test[1] != undefined) {
        if (test[1]['m$=='](obj).$r) return test;
      }
    }

    return nil;
  }, 1);  













  $defn(self, 'reject', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var result = [];

    for (var i = 0; i < self.length; i++) {
      if (!((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        result.push(self[i]);
      }
    }

    return result;
  }, 0);  















  $defn(self, 'reject!', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;
  }, 0);  











  $defn(self, 'reverse', function() { var self = this;    
    var result = [];

    for (var i = self.length - 1; i >= 0; i--) {
      result.push(self[i]);
    }

    return result;
  }, 0);  












  $defn(self, 'reverse!', function() { var self = this;    
    var length = self.length / 2, tmp;

    for (var i = 0; i < length; i++) {
      tmp = self[i];
      self[i] = self[self.length - (i + 1)];
      self[self.length - (i + 1)] = tmp;
    }

    return self;
  }, 0);  












  $defn(self, 'reverse_each', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var ary = self, len = ary.length;

    for (var i = len - 1; i >= 0; i--) {
      ((__a = $yy.call($ys, ary[i])) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  

















  $defn(self, 'rindex', function(obj) { var self = this;    
    if (obj != undefined) {
      for (var i = self.length - 1; i >=0; i--) {
        if (self[i]['m$=='](obj).$r) {
          return i;
        }
      }
    } else if (true || __block__) {
      rb_raise("array#rindex needs to do block action");
    }

    return nil;
  }, -1);  
















  $defn(self, 'select!', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var length = self.length;

    for (var i = 0; i < self.length; i++) {
      if (!((__a = $yy.call($ys, self[i])) == $yb ? $break() : __a).$r) {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;
  }, 0);  






















  $defn(self, 'shift', function(count) { var self = this;    
    if (count != undefined)
      return self.splice(0, count);

    if (self.length)
      return self.shift();

    return nil;
  }, -1);  
























  $defn(self, 'slice!', function(index, length) { var self = this;if (length == undefined) {length = nil;}    
    var size = self.length;

    if (index < 0) index += size;

    if (index >= size || index < 0) return nil;

    if (length != nil) {
      if (length <= 0 || length > self.length) return nil;
      return self.splice(index, index + length);
    } else {
      return self.splice(index, 1)[0];
    }
  }, -2);  










  $defn(self, 'take', function(count) { var self = this;    
    return self.slice(0, count);
  }, 1);  












  $defn(self, 'take_while', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var result = [], arg;

    for (var i = 0, ii = self.length; i < ii; i++) {
      arg = self[i];
      if (((__a = $yy.call($ys, arg)) == $yb ? $break() : __a).$r) {
        result.push(self[i]);
      } else {
        break;
      }
    }

    return result;
  }, 0);  










  $defn(self, 'to_a', function() { var self = this;    
    return self;
  }, 0);  












  $defn(self, 'uniq', function() { var self = this;    
    var result = [], seen = [];

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$hash();
      if (seen.indexOf(hash) == -1) {
        seen.push(hash);
        result.push(test);
      }
    }

    return result;
  }, 0);  













  $defn(self, 'uniq!', function() { var self = this;    
    var seen = [], length = self.length;

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$hash();
      if (seen.indexOf(hash) == -1) {
        seen.push(hash);
      } else {
        self.splice(i, 1);
        i--;
      }
    }

    return self.length == length ? nil : self;
  }, 0);  













  $defn(self, 'unshift', function(objs) { var self = this;objs = [].slice.call(arguments, 0);    
    for (var i = objs.length - 1; i >= 0; i--) {
      self.unshift(objs[i]);
    }

    return self;
  }, -1);  











  $defn(self, '&', function(other) { var self = this;    
    var result = [], seen = [];

    for (var i = 0; i < self.length; i++) {
      var test = self[i], hash = test.$hash();

      if (seen.indexOf(hash) == -1) {
        for (var j = 0; j < other.length; j++) {
          var test_b = other[j], hash_b = test_b.$hash();

          if ((hash == hash_b) && seen.indexOf(hash) == -1) {
            seen.push(hash);
            result.push(test);
          }
        }
      }
    }

    return result;
  }, 1);  

















  $defn(self, '*', function(arg) { var self = this;    
    if (arg.o$f & T_STRING) {
      return self.m$join(arg);
    } else {
      var result = [];
      for (var i = 0; i < parseInt(arg); i++) {
        result = result.concat(self);
      }

      return result;
    }
  }, 1);  


























  $defn(self, '[]', function(index, length) { var self = this;    
    var ary = self, size = ary.length;

    if (index < 0) index += size;

    if (index >= size || index < 0) return nil;

    if (length != undefined) {
      if (length <= 0) return [];
      return ary.slice(index, index + length);
    } else {
      return ary[index];
    }
  }, -2);  




  return $defn(self, '[]=', function(index, value) { var self = this;    
    if (index < 0) index += self.length;
    return self[index] = value;
  }, 2);
}, 0);









































$class(self, nil, 'Numeric', function(self) {  








  $defn(self, '+@', function() { var self = this;    
    return self;
  }, 0);  









  $defn(self, '-@', function() { var self = this;    
    return -self;
  }, 0);  





  $defn(self, '%', function(other) { var self = this;    
    return self % other;
  }, 1);  

  $defn(self, 'modulo', function(other) { var self = this;    
    return self % other;
  }, 1);  





  $defn(self, '&', function(num2) { var self = this;    
    return self & num2;
  }, 1);  





  $defn(self, '*', function(other) { var self = this;    
    return self * other;
  }, 1);  





  $defn(self, '**', function(other) { var self = this;    
    return Math.pow(self, other);
  }, 1);  





  $defn(self, '+', function(other) { var self = this;    
    return self + other;
  }, 1);  





  $defn(self, '-', function(other) { var self = this;    
    return self - other;
  }, 1);  





  $defn(self, '/', function(other) { var self = this;    
    return self / other;
  }, 1);  






  $defn(self, '<', function(other) { var self = this;    
    return self < other ? Qtrue : Qfalse;
  }, 1);  






  $defn(self, '<=', function(other) { var self = this;    
    return self <= other ? Qtrue : Qfalse;
  }, 1);  






  $defn(self, '>', function(other) { var self = this;    
    return self > other ? Qtrue : Qfalse;
  }, 1);  






  $defn(self, '>=', function(other) { var self = this;    
    return self >= other ? Qtrue : Qfalse;
  }, 1);  





  $defn(self, '<<', function(count) { var self = this;    
    return self << count;
  }, 1);  





  $defn(self, '>>', function(count) { var self = this;    
    return self >> count;
  }, 1);  






  $defn(self, '<=>', function(other) { var self = this;    
    if (typeof other != 'number') return nil;
    else if (self < other) return -1;
    else if (self > other) return 1;
    return 0;
  }, 1);  





  $defn(self, '==', function(other) { var self = this;    
    return self.valueOf() === other.valueOf() ? Qtrue : Qfalse;
  }, 1);  





  $defn(self, '^', function(other) { var self = this;    
    return self ^ other;
  }, 1);  











  $defn(self, 'abs', function() { var self = this;    
    return Math.abs(self);
  }, 0);  

  $defn(self, 'magnitude', function() { var self = this;    
    return Math.abs(self);
  }, 0);  




  $defn(self, 'even?', function() { var self = this;    
    return (self % 2 == 0) ? Qtrue : Qfalse;
  }, 0);  




  $defn(self, 'odd?', function() { var self = this;    
    return (self % 2 == 0) ? Qfalse : Qtrue;
  }, 0);  











  $defn(self, 'succ', function() { var self = this;    
    return self + 1;
  }, 0);  

  $defn(self, 'next', function() { var self = this;    
    return self + 1;
  }, 0);  











  $defn(self, 'pred', function() { var self = this;    
    return self - 1;
  }, 0);  
















  $defn(self, 'upto', function(finish) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = self; i <= finish; i++) {
      ((__a = $yy.call($ys, i)) == $yb ? $break() : __a);
    }

    return self;
  }, 1);  















  $defn(self, 'downto', function(finish) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = self; i >= finish; i--) {
      ((__a = $yy.call($ys, i)) == $yb ? $break() : __a);
    }

    return self;
  }, 1);  














  $defn(self, 'times', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise("no block given")};    
    for (var i = 0; i < self; i++) {
      ((__a = $yy.call($ys, i)) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  





  $defn(self, '|', function(other) { var self = this;    
    return self | other;
  }, 1);  




  $defn(self, 'zero?', function() { var self = this;    
    return self == 0 ? Qtrue : Qfalse;
  }, 0);  




  $defn(self, 'nonzero?', function() { var self = this;    
    return self == 0 ? nil : self;
  }, 0);  




  $defn(self, '~', function() { var self = this;    
    return ~self;
  }, 0);  











  $defn(self, 'ceil', function() { var self = this;    
    return Math.ceil(self);
  }, 0);  









  $defn(self, 'floor', function() { var self = this;    
    return Math.floor(self);
  }, 0);  




  $defn(self, 'integer?', function() { var self = this;    
    return self % 1 == 0 ? Qtrue : Qfalse;
  }, 0);  

  $defn(self, 'inspect', function() { var self = this;    
    return self.toString();
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    return self.toString();
  }, 0);  

  $defn(self, 'to_i', function() { var self = this;    
    return parseInt(self);
  }, 0);  

  return $defs(self, 'allocate', function() { var self = this;    
    return self.m$raise($cg(self, 'RuntimeError'), "cannot instantiate instance of Numeric class");
  }, 0);
}, 0);








































$class(self, nil, 'Hash', function(self) {  




  $defs(self, '[]', function(args) { var self = this;args = [].slice.call(arguments, 0);    
    return $rb.H.apply(null, args);
  }, -1);  

  $defs(self, 'allocate', function() { var self = this;    
    return $rb.H();
  }, 0);  









  $defn(self, 'values', function() { var self = this;    
    var result = [], length = self.k.length;

    for (var i = 0; i < length; i++) {
      result.push(self.a[self.k[i].$hash()]);
    }

    return result;
  }, 0);  









  $defn(self, 'inspect', function() { var self = this;    
    var description = [], key, value;

    for (var i = 0, ii = self.k.length; i < ii; i++) {
      key = self.k[i];
      value = self.a[key.$hash()];
      description.push(key.m$inspect() + '=>' + value.m$inspect());
    }

    return '{' + description.join(', ') + '}';
  }, 0);  




  $defn(self, 'to_s', function() { var self = this;    
    var description = [], key, value;

    for (var i = 0, ii = self.k.length; i < ii; i++) {
      key = self.k[i];
      value = self.a[key.$hash()];
      description.push(key.m$inspect() + value.m$inspect());
    }

    return description.join('');
  }, 0);  











  $defn(self, 'each', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var keys = self.k, values = self.a, length = keys.length, key;

    for (var i = 0; i < length; i++) {
      key = keys[i];
      ((__a = $yy.call($ys, key, values[key.$hash()])) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  














  $defn(self, 'assoc', function(obj) { var self = this;    
    var key, keys = self.k, length = keys.length;

    for (var i = 0; i < length; i++) {
      key = keys[i];
      if (key['m$=='](obj).$r) {
        return [key, self.a[key.$hash()]];
      }
    }

    return nil;
  }, 1);  


















  $defn(self, '==', function(other) { var self = this;    
    if (self === other) return Qtrue;
    if (!other.k || !other.a) return Qfalse;
    if (self.k.length != other.k.length) return Qfalse;

    for (var i = 0; i < self.k.length; i++) {
      var key1 = self.k[i], assoc1 = key1.$hash();

      if (!hasOwnProperty.call(other.a, assoc1))
        return Qfalse;

      var assoc2 = other.a[assoc1];

      if (!self.a[assoc1]['m$=='](assoc2).$r)
        return Qfalse;
    }

    return Qtrue;
  }, 1);  














  $defn(self, '[]', function(key) { var self = this;    
    var assoc = key.$hash();

    if (hasOwnProperty.call(self.a, assoc))
      return self.a[assoc];

    return self.d;
  }, 1);  
















  $defn(self, '[]=', function(key, value) { var self = this;    
    var assoc = key.$hash();

    if (!hasOwnProperty.call(self.a, assoc))
      self.k.push(key);

    return self.a[assoc] = value;
  }, 2);  










  $defn(self, 'clear', function() { var self = this;    
    self.k = [];
    self.a = {};

    return self;
  }, 0);  


  $defn(self, 'default', function() { var self = this;    
    return self.d;
  }, 0);  





  $defn(self, 'default=', function(obj) { var self = this;    
    return self.d = obj;
  }, 1);  
















  $defn(self, 'delete', function(key) { var self = this;    
    var assoc = key.$hash();

    if (hasOwnProperty.call(self.a, assoc)) {
      var ret = self.a[assoc];
      delete self.a[assoc];
      self.k.splice(self.$keys.indexOf(key), 1);
      return ret;
    }

    return self.d;
  }, 1);  











  $defn(self, 'delete_if', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var key, value;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      value = self.a[key.$hash()];

      if (((__a = $yy.call($ys, key, value)) == $yb ? $break() : __a).$r) {
        delete self.a[key.$hash()];
        self.k.splice(i, 1);
        i--;
      }
    }

    return self;
  }, 0);  












  $defn(self, 'each_key', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    for (var i = 0, ii = self.k.length; i < ii; i++) {
      ((__a = $yy.call($ys, self.k[i])) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  












  $defn(self, 'each_value', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    var val;

    for (var i = 0, ii = self.k.length; i < ii; i++) {
      ((__a = $yy.call($ys, self.a[self.k[i].$hash()])) == $yb ? $break() : __a);
    }

    return self;
  }, 0);  









  $defn(self, 'empty?', function() { var self = this;    
    return self.k.length == 0 ? Qtrue : Qfalse;
  }, 0);  

















  $defn(self, 'fetch', function(key, defaults) { var self = this;if (defaults == undefined) {defaults = undefined;}    
    var value = self.a[key.$hash()];

    if (value != undefined)
      return value;
    else if (defaults == undefined)
      rb_raise('KeyError: key not found');
    else
      return defaults;
  }, -2);  

















  $defn(self, 'flatten', function(level) { var self = this;if (level == undefined) {level = 1;}    
    var result = [], key, value;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      value = self.a[key.$hash()];
      result.push(key);

      if (value instanceof Array) {
        if (level == 1) {
          result.push(value);
        } else {
          var tmp = value.m$flatten(level - 1);
          result = result.concat(tmp);
        }
      } else {
        result.push(value);
      }
    }

    return result;
  }, -1);  













  $defn(self, 'has_key?', function(key) { var self = this;    
    if (hasOwnProperty.call(self.a, key.$hash()))
      return Qtrue;

    return Qfalse;
  }, 1);  













  $defn(self, 'has_value?', function(value) { var self = this;    
    var key, value;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      val = self.a[key.$hash()];

      if (value['m$=='](val).$r)
        return Qtrue;
    }

    return Qfalse;
  }, 1);  











  $defn(self, 'replace', function(other) { var self = this;    
    self.k = []; self.a = {};

    for (var i = 0; i < other.k.length; i++) {
      var key = other.k[i];
      var val = other.a[key.$hash()];
      self.k.push(key);
      self.a[key.$hash()] = val;
    }

    return self;
  }, 1);  











  $defn(self, 'invert', function() { var self = this;    return nil;

  }, 0);  













  $defn(self, 'key', function(value) { var self = this;    
    var key, val;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      val = self.a[key.$hash()];

      if (value['m$=='](val).$r) {
        return key;
      }
    }

    return nil;
  }, 1);  











  $defn(self, 'keys', function() { var self = this;    
    return self.k.slice(0);
  }, 0);  










  $defn(self, 'length', function() { var self = this;    
    return self.k.length;
  }, 0);  


















  $defn(self, 'merge', function(other) { var self = this;    
    var result = $opal.H() , key, val;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i], val = self.a[key.$hash()];

      result.k.push(key);
      result.a[key.$hash()] = val;
    }

    for (var i = 0; i < other.k.length; i++) {
      key = other.k[i], val = other.a[key.$hash()];

      if (!hasOwnProperty.call(result.a, key.$hash())) {
        result.k.push(key);
      }

      result.a[key.$hash()] = val;
    }

    return result;
  }, 1);  















  $defn(self, 'merge!', function(other) { var self = this;    
    var key, val;

    for (var i = 0; i < other.k.length; i++) {
      key = other.k[i];
      val = other.a[key.$hash()];

      if (!hasOwnProperty.call(self.a, key.$hash())) {
        self.k.push(key);
      }

      self.a[key.$hash()] = val;
    }

    return self;
  }, 1);  














  $defn(self, 'rassoc', function(obj) { var self = this;    
    var key, val;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      val = self.a[key.$hash()];

      if (val['m$=='](obj).$r)
        return [key, val];
    }

    return nil;
  }, 1);  















  $defn(self, 'shift', function() { var self = this;    
    var key, val;

    if (self.k.length > 0) {
      key = self.k[0];
      val = self.a[key.$hash()];

      self.k.shift();
      delete self.a[key.$hash()];
      return [key, val];
    }

    return self.d;
  }, 0);  










  $defn(self, 'to_a', function() { var self = this;    
    var result = [], key, value;

    for (var i = 0; i < self.k.length; i++) {
      key = self.k[i];
      value = self.a[key.$hash()];
      result.push([key, value]);
    }

    return result;
  }, 0);  




  return $defn(self, 'to_hash', function() { var self = this;    
    return self;
  }, 0);
}, 0);


































$class(self, nil, 'Exception', function(self) {  

  $defs(self, 'allocate', function() { var self = this;    
    var err = new Error();
    err.o$k = self;
    return err;
  }, 0);  

  $defn(self, 'initialize', function(message) { var self = this;if (message == undefined) {message = '';}    
    return self.$message = message;
  }, -1);  

  $defn(self, 'message', function() { var self = this;var __a;self.$message==undefined&&(self.$message=nil);    
    return ((__a = self.$message).$r ? __a : self.message);
  }, 0);  

  $defn(self, 'inspect', function() { var self = this;    
    return "#<" + self.o$k.__classid__ + ": '" + self.m$message() + "'>";
  }, 0);  

  return $defn(self, 'to_s', function() { var self = this;    
    return self.m$message();
  }, 0);
}, 0);

























































$class(self, nil, 'String', function(self) {  

  $defs(self, 'new', function(str) { var self = this;if (str == undefined) {str = '';}    
    return str;
  }, -1);  










  $defn(self, '*', function(count) { var self = this;    
    var result = [];

    for (var i = 0; i < count; i++) {
      result.push(self);
    }

    return result.join('');
  }, 1);  











  $defn(self, '+', function(other) { var self = this;    
    return self + other;
  }, 1);  














  $defn(self, 'capitalize', function() { var self = this;    
    return self.charAt(0).toUpperCase() + self.substr(1).toLowerCase();
  }, 0);  










  $defn(self, 'downcase', function() { var self = this;    
    return self.toLowerCase();
  }, 0);  

  $defn(self, 'upcase', function() { var self = this;    
    return self.toUpperCase();
  }, 0);  











  $defn(self, 'inspect', function() { var self = this;    
    /* borrowed from json2.js, see file for license */
    var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,

    escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,

    meta = {
      '\b': '\\b',
      '\t': '\\t',
      '\n': '\\n',
      '\f': '\\f',
      '\r': '\\r',
      '"' : '\\"',
      '\\': '\\\\'
    };

    escapable.lastIndex = 0;

    return escapable.test(self) ? '"' + self.replace(escapable, function (a) {
      var c = meta[a];
      return typeof c === 'string' ? c :
        '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + self + '"';
  }, 0);  




  $defn(self, 'length', function() { var self = this;    
    return self.length;
  }, 0);  

  $defn(self, 'to_i', function() { var self = this;    
    return parseInt(self);
  }, 0);  













  $defn(self, 'to_sym', function() { var self = this;    
    return $rb.Y(self);
  }, 0);  

  $defn(self, 'intern', function() { var self = this;    
    return $rb.Y(self);
  }, 0);  









  $defn(self, 'reverse', function() { var self = this;    
    return self.split('').reverse().join('');
  }, 0);  

  $defn(self, 'succ', function() { var self = this;    
    return String.fromCharCode(self.charCodeAt(0));
  }, 0);  

  $defn(self, '[]', function(idx) { var self = this;    
    return self.substr(idx, idx + 1);
  }, 1);  

  $defn(self, 'sub', function(pattern) { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var __a;    
    return self.replace(pattern, function(str) {
      return ((__a = $yy.call($ys, str)) == $yb ? $break() : __a);
    });
  }, 1);  

  $defn(self, 'gsub', function(pattern, replace) { var self = this;    
    var r = pattern.toString();
    r = r.substr(1, r.lastIndexOf('/') - 1);
    r = new RegExp(r, 'g');
    return self.replace(pattern, function(str) {
      return replace;
    });
  }, 2);  

  $defn(self, 'slice', function(start, finish) { var self = this;if (finish == undefined) {finish = nil;}    
    return self.substr(start, finish);
  }, -2);  

  $defn(self, 'split', function(split, limit) { var self = this;if (limit == undefined) {limit = nil;}    
    return self.split(split);
  }, -2);  













  $defn(self, '<=>', function(other) { var self = this;    
    if (!(other.o$f & T_STRING)) return nil;
    else if (self > other) return 1;
    else if (self < other) return -1;
    return 0;
  }, 1);  






  $defn(self, '==', function(other) { var self = this;    
    return self.valueOf() === other.valueOf() ? Qtrue : Qfalse;
  }, 1);  










  $defn(self, '=~', function(obj) { var self = this;    
    if (obj.o$f & T_STRING) {
      raise(eTypeError, "type mismatch: String given");
    }    

    return obj['m$=~'](self);
  }, 1);  











  $defn(self, 'casecmp', function(other) { var self = this;    
    if (typeof other != 'string') return nil;
    var a = self.toLowerCase(), b = other.toLowerCase();
    if (a > b) return 1;
    else if (a < b) return -1;
    return 0;
  }, 1);  











  $defn(self, 'empty?', function() { var self = this;    
    return self.length == 0 ? Qtrue : Qfalse;
  }, 0);  










  $defn(self, 'end_with?', function(suffix) { var self = this;    
    if (self.lastIndexOf(suffix) == self.length - suffix.length) {
      return Qtrue;
    }

    return Qfalse;
  }, 1);  





  $defn(self, 'eql?', function(other) { var self = this;    
    return self == other ? Qtrue : Qfalse;
  }, 1);  










  $defn(self, 'include?', function(other) { var self = this;    
    return self.indexOf(other) == -1 ? Qfalse : Qtrue;
  }, 1);  















  $defn(self, 'index', function(substr) { var self = this;    
    var res = self.indexOf(substr);

    return res == -1 ? nil : res;
  }, 1);  











  return $defn(self, 'lstrip', function() { var self = this;    
    return self.replace(/^\s*/, '');
  }, 0);
}, 0);




























$class(self, nil, 'Symbol', function(self) {  

  $defn(self, 'inspect', function() { var self = this;    
    return ':' + self.sym.toString();
  }, 0);  

  $defn(self, 'to_sym', function() { var self = this;    
    return self;
  }, 0);  

  return $defn(self, 'intern', function() { var self = this;    
    return self;
  }, 0);
}, 0);






























$class(self, nil, 'Proc', function(self) {  

  $defs(self, 'new', function() { var self = this;var $y = $B, $yy, $ys, $yb = $y.b;if ($y.f == arguments.callee) { $yy = $y.p; }else { $yy = $y.y; }$y.f = nil ;$ys = $yy.o$s;var block = (($yy == $y.y) ? nil: $yy);    

    if(!(($yy == $y.y ? Qfalse : Qtrue)).$r) {self.m$raise($cg(self, 'ArgumentError'), "tried to create Proc object without a block")};    

    return block;
  }, 0);  

  $defn(self, 'to_proc', function() { var self = this;    
    return self;
  }, 0);  

  $defn(self, 'call', function(args) { var self = this;args = [].slice.call(arguments, 0);    
    return self.apply(self.o$s,args);
  }, -1);  

  $defn(self, 'to_s', function() { var self = this;    
    return "#<Proc:0x" + (self.$hash() * 400487).toString(16) + (self.$lambda ? ' (lambda)' : '') + ">";
  }, 0);  

  return $defn(self, 'lambda?', function() { var self = this;    
    return self.$lambda ? Qtrue : Qfalse;
  }, 0);
}, 0);

$class(self, nil, 'Range', function(self) {  

  $defn(self, 'begin', function() { var self = this;    
    return self.beg;
  }, 0);  

  self.m$alias_method($symbol_9, $symbol_10);  

  $defn(self, 'end', function() { var self = this;    
    return self.end;
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    var str = self.beg.m$to_s();
    var str2 = self.end.m$to_s();
    var join = self.exc ? '...' : '..';
    return str + join + str2;
  }, 0);  

  return $defn(self, 'inspect', function() { var self = this;    
    var str = self.beg.m$inspect();
    var str2 = self.end.m$inspect();
    var join = self.exc ? '...' : '..';
    return str + join + str2;
  }, 0);
}, 0);




















$class(self, nil, 'Regexp', function(self) {  

  $defs(self, 'escape', function(s) { var self = this;    
    return s;
  }, 1);  

  $defs(self, 'new', function(s) { var self = this;    
    return new RegExp(s);
  }, 1);  

  $defn(self, 'inspect', function() { var self = this;    
    return self.toString();
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    return self.source;
  }, 0);  

  $defn(self, '==', function(other) { var self = this;    
    return self.toString() === other.toString() ? Qtrue : Qfalse;
  }, 1);  

  $defn(self, 'eql?', function(other) { var self = this;    
    return self['m$=='](other);
  }, 1);  







  $defn(self, '=~', function(str) { var self = this;    
    var result = self.exec(str);
    $rb.X = result;

    if (result) {
      return result.index;
    }
    else {
      return nil;
    }
  }, 1);  

  return $defn(self, 'match', function(pattern) { var self = this;    
    self['m$=~'](pattern);    
    return $rb.gg('$~');
  }, 1);
}, 0);

$class(self, nil, 'MatchData', function(self) {  

  $defn(self, 'inspect', function() { var self = this;    
    return ("#<MatchData " + self.$data[0].m$inspect().m$to_s() + ">");
  }, 0);  

  $defn(self, 'to_s', function() { var self = this;    
    return self.$data[0];
  }, 0);  

  $defn(self, 'length', function() { var self = this;    
    return self.$data.length;
  }, 0);  

  $defn(self, 'size', function() { var self = this;    
    return self.$data.length;
  }, 0);  

  $defn(self, 'to_a', function() { var self = this;    
    return [].slice.call(self.$data, 0);
  }, 0);  

  return $defn(self, '[]', function(index) { var self = this;    
    var length = self.$data.length;

    if (index < 0) index += length;

    if (index >= length || index < 0) return nil;

    return self.$data[index];
  }, 1);
}, 0);


$class(self, nil, 'File', function(self) {  








  $defs(self, 'expand_path', function(file_name, dir_string) { var self = this;if (dir_string == undefined) {dir_string = nil;}    
    if (dir_string.$r) {      
      return Op.fs.expand_path(file_name, dir_string);
    } else {      
      return Op.fs.expand_path(file_name);
    }
  }, -2);  






  $defs(self, 'join', function(str) { var self = this;str = [].slice.call(arguments, 0);    
    return Op.fs.join.apply(Op.fs, str);
  }, -1);  






  $defs(self, 'dirname', function(file_name) { var self = this;    
    return Op.fs.dirname(file_name);
  }, 1);  





  $defs(self, 'extname', function(file_name) { var self = this;    
    return Op.fs.extname(file_name);
  }, 1);  








  $defs(self, 'basename', function(file_name, suffix) { var self = this;    
    return Op.fs.basename(file_name, suffix);
  }, 2);  

  return $defs(self, 'exist?', function(path) { var self = this;    
    return Op.fs.exist_p(path) ? Qtrue : Qfalse;
  }, 1);
}, 0);


return $class(self, nil, 'Dir', function(self) {  




  $defs(self, 'getwd', function() { var self = this;    
    return Op.fs.cwd;
  }, 0);  




  $defs(self, 'pwd', function() { var self = this;    
    return Op.fs.cwd;
  }, 0);  

  return $defs(self, '[]', function(a) { var self = this;a = [].slice.call(arguments, 0);    
    return Op.fs.glob.apply(Op.fs, a);
  }, -1);
}, 0);
}
var nil = $rb.Qnil, $ac = $rb.ac, $super = $rb.S, $break = $rb.B, $class = $rb.dc, $defn = $rb.dm, $defs = $rb.ds, $symbol = $rb.Y, $hash = $rb.H, $B = $rb.P, Qtrue = $rb.Qtrue, Qfalse = $rb.Qfalse, $cg = $rb.cg, $range = $rb.G, $symbol_10 = $symbol('begin'), $symbol_7 = $symbol('size'), $symbol_2 = $symbol('raise'), $symbol_6 = $symbol('collect'), $symbol_5 = $symbol('map'), $symbol_9 = $symbol('first'), $symbol_3 = $symbol('entries'), $symbol_8 = $symbol('length'), $symbol_4 = $symbol('to_a'), $symbol_1 = $symbol('fail');return $$();
};
init();

})(undefined);

// if in a commonjs system already (node etc), exports become our opal
// object. Otherwise, in the browser, we just get a top level opal var
if ((typeof require !== 'undefined') && (typeof module !== 'undefined')) {
  module.exports = opal;
}
