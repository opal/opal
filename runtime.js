opal = {};

(function() {

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
Op.platform = {
  platform: "opal",
  engine: "opal-browser",
  version: "1.9.2",
  argv: []
};

/**
  Core runtime classes, objects and literals.
*/
var cBasicObject,     cObject,          cModule,          cClass,
    mKernel,          cNilClass,        cTrueClass,       cFalseClass,
    cArray,
    cRegexp,          cMatch,           top_self,            Qnil,
    Qfalse,           Qtrue,

    cDir;


/**
  Core object type flags. Added as local variables, and onto runtime.
*/
var T_CLASS       = Rt.T_CLASS       = 1,
    T_MODULE      = Rt.T_MODULE      = 2,
    T_OBJECT      = Rt.T_OBJECT      = 4,
    T_BOOLEAN     = Rt.T_BOOLEAN     = 8,
    T_STRING      = Rt.T_STRING      = 16,
    T_ARRAY       = Rt.T_ARRAY       = 32,
    T_NUMBER      = Rt.T_NUMBER      = 64,
    T_PROC        = Rt.T_PROC        = 128,
    T_SYMBOL      = Rt.T_SYMBOL      = 256,
    T_HASH        = Rt.T_HASH        = 512,
    T_RANGE       = Rt.T_RANGE       = 1024,
    T_ICLASS      = Rt.T_ICLASS      = 2056,
    FL_SINGLETON  = Rt.FL_SINGLETON  = 4112;

/**
  Method visibility modes
 */
var FL_PUBLIC  = 0,
    FL_PRIVATE = 1;

/**
  Define methods. Public method for defining a method on the given base.

  @param {RubyObject} base The base to define method on
  @param {String} method_id Ruby mid
  @param {Function} body The method implementation
  @param {Boolean} singleton Singleton or Normal method. true for singleton
*/

Rt.dm = function(base, method_id, body, singleton) {
  if (singleton) {
    define_singleton_method(base, method_id, body);
  } else {
    // should this instead do a rb_singleton_method?? probably..
    if (base.$flags & T_OBJECT) {
      base = base.$klass;
    }

    define_method(base, method_id, body);
  }

  return Qnil;
};

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
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
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
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
      }
      klass = define_module_under(base, id);
      break;

    default:
      raise(eException, "define_class got a unknown flag " + flag);
  }

  // when reopening a class always set it back to public
  klass.$mode = FL_PUBLIC;

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

      kls.allocator.prototype['m$' + mid] = func;

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

      prototype[mid] = prototype['$' + mid] = imp;
    }
  }
};

/**
  Debug support for checking argument counts. This is called when a method
  did not receive the right number of args as expected.
*/
Rt.ac = function(expected, actual) {
  throw new Error("ArgumentError - wrong number of arguments(" + actual + " for " + expected + ")");
};

/**
  Sets the constant value `val` on the given `klass` as `id`.

  @param {RClass} klass
  @param {String} id
  @param {Object} val
  @return {Object} returns the set value
*/
function const_set(klass, id, val) {
  // klass.$c_prototype[id] = val;
  // klass.$const_table[id] = val;
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
  Set an instance variable on the receiver.
*/
function ivar_set(obj, id, val) {
  obj[id] = val;
  return val;
};

/**
  Return an instance variable set on the receiver, or nil if one does not
  exist.
*/
function ivar_get(obj, id) {
  return obj.hasOwnProperty(id) ? obj[id] : Qnil;
};

/**
  Determines whether and instance variable has been set on the receiver.
*/
function ivar_defined(obj, id) {
  return obj.hasOwnProperty(id) ? true : false;
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
  var hash = new cHash.allocator(), k, v, args = [].slice.call(arguments);
  hash.$keys = [];
  hash.$assocs = {};
  hash.$default = Qnil;

  for (var i = 0, ii = args.length; i < ii; i++) {
    k = args[i];
    v = args[i + 1];
    i++;
    hash.$keys.push(k);
    hash.$assocs[k.$hash()] = v;
  }

  return hash;
};

/**
  Root of all classes and objects (except for bridged).
*/
var boot_base_class = function() {};

boot_base_class.$hash = function() {
  return this.$id;
};

boot_base_class.prototype.$r = true;

/**
  Internal method for defining a method.

  @param {RClass} klass The klass to define the method on
  @param {String} name The method id
  @param {Function} body Method implementation
  @return {Qnil}
*/
function define_method(klass, name, public_body) {
  var mode = klass.$mode;
  var private_body = public_body;

  if (mode == FL_PRIVATE) {
    public_body = function() {
      raise(eNoMethodError, "private method `" + name +
                      "' called for " + this.m$inspect());
    };
  }

  if (!public_body.$rbName) {
    public_body.$rbName = name;
  }

  klass.$methods.push(intern(name));
  define_raw_method(klass, 'm$' + name, private_body, public_body);

  return Qnil;
};

Rt.define_method = define_method;

var alias_method = Rt.alias_method = function(klass, new_name, old_name) {
  var body = klass.allocator.prototype['m$' + old_name];

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
function define_raw_method(klass, public_name, private_body, public_body) {
  var private_name = '$' + public_name;

  klass.allocator.prototype[public_name] = public_body;
  klass.$method_table[public_name] = public_body;

  klass.allocator.prototype[private_name] = private_body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_raw_method(includee, public_name, private_body, public_body);
    }
  }

  // this class is actually bridged, so add method to bridge native
  // prototype as well
  if (klass.$bridge_prototype) {
    klass.$bridge_prototype[public_name] = public_body;
    klass.$bridge_prototype[private_name] = private_body;
  }

  // if we are dealing with Object or BasicObject, we need to donate
  // to bridged prototypes as well
  if (klass == cObject || klass == cBasicObject) {
    var bridged = bridged_classes;

    for (var i = 0, ii = bridged.length; i < ii; i++) {
      // do not overwrite bridged's own implementation
      if (!bridged[i][public_name] || bridged[i][public_name].$rbMM) {
        bridged[i][public_name] = public_body;
      }
    }
  }
};

Rt.private_methods = function(klass, args) {

  if (args.length) {
    var proto = klass.allocator.prototype;

    for (var i = 0, ii = args.length; i < ii; i++) {
      var arg = args[i].$m$to_s(), mid = 'm$' + arg;

      // If method doesn't exist throw an error. Also check that if it
      // does exist that it isnt just a method missing implementation.
      if (!proto[mid] || proto[mid].$rbMM) {
        raise(eNameError, "undefined method `" + arg +
              "' for class `" + klass.__classid__ + "'");
      }

      // Set the public implementation to a function that just throws
      // and error when called
      klass.allocator.prototype[mid] = function() {
        raise(eNoMethodError, "private method `" + arg + "' called for " +
              this.$m$inspect());
      }

      // If this method is in the method_table then we must also set that.
      // If not then we inherited this method from further up the chain,
      // so we do not set it in our method table.
      if (klass.$method_table[mid]) {
        // set
      }
    }
  }
  else {
    // no args - set klass mode to private
    klass.$mode = FL_PRIVATE;
  }
};

function define_singleton_method(klass, name, body) {
  define_method(singleton_class(klass), name, body);
};

function define_alias(base, new_name, old_name) {
  define_method(base, new_name, base.$m_tbl[old_name]);
  return Qnil;
};

function obj_alloc(klass) {
  var result = new klass.allocator();
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

Rt.native_exc = function(err) {
  var exc = new eException.allocator();
  exc.$rb_err = err;
  return exc;
};

/**
  Raise an exception instance (DO NOT pass strings to this)
*/
function raise_exc(exc) {
  var err = new Error();
  exc.$rb_err = err;
  err.$rb_exc = exc;
  throw err;
};

Rt.raise_exc = raise_exc;

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
  if (symbol_table.hasOwnProperty(intern)) {
    return symbol_table[intern];
  }

  var res = new cSymbol.allocator();
  res.$value = intern;
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
  var func = super_find(self.$klass, callee, mid);

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
    if (klass.$method_table[mid]) {
      if (klass.$method_table[mid] == callee) {
        break;
      }
    }
    klass = klass.$super;
  }

  if (!klass) { return null; }

  klass = klass.$super;

  while (klass) {
    if (klass.$method_table[mid]) {
      return klass.$method_table[mid];
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
  if (base.$flags & T_OBJECT) {
    base = class_real(base.$klass);
  }
  return const_get(base, id);
};

/**
  Set constant from runtime
*/
Rt.cs = function(base, id, val) {
  if (base.$flags & T_OBJECT) {
    base = class_real(base.$klass);
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
      var res = new cMatch.allocator();
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

Rt.re = function(re) {
  var regexp = new cRegexp.allocator();
  regexp.$re = re;
  return regexp;
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

block.y.$proc = [block.y];

Rt.proc = function(func) {
  var proc = new cProc.allocator();
  proc.$fn = func;
  return proc;
};

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
  proc = proc.$fn;
  if (proc.$lambda) return proc;

  var wrap = function() {
    var args = Array.prototype.slice.call(arguments, 0);
    return proc.apply(null, args);
  };

  wrap.$lambda = true;
  wrap.$proc = proc.$proc;

  return Rt.proc(wrap);
};

var cRange;

/**
  Returns a new ruby range. G for ranGe.
*/
Rt.G = function(beg, end, exc) {
  var range = new RObject(cRange, T_OBJECT);
  range.$beg = beg;
  range.$end = end;
  range.$exc = exc;
  return range;
};

Rt.A = function(objs) {
  var arr = new cArray.allocator();
  arr.splice.apply(arr, [0, 0].concat(objs));
  return arr;
};

/**
  Main init method. This is called once this file has fully loaded. It setups
  all the core objects and classes and required runtime features.
*/
function init() {
  var metaclass;

  // what will be the instances of these core classes...
  boot_BasicObject = boot_defclass('BasicObject');
  boot_Object = boot_defclass('Object', boot_BasicObject);
  boot_Module = boot_defclass('Module', boot_Object);
  boot_Class = boot_defclass('Class', boot_Module);

  // the actual classes
  Rt.BasicObject = cBasicObject = boot_makemeta('BasicObject', boot_BasicObject, boot_Class);
  Rt.Object = cObject = boot_makemeta('Object', boot_Object, cBasicObject.constructor);
  Rt.Module = cModule = boot_makemeta('Module', boot_Module, cObject.constructor);
  Rt.Class = cClass = boot_makemeta('Class', boot_Class, cModule.constructor);

  boot_defmetameta(cBasicObject, cClass);
  boot_defmetameta(cObject, cClass);
  boot_defmetameta(cModule, cClass);
  boot_defmetameta(cClass, cClass);

  // fix superclasses
  cBasicObject.$super = null;
  cObject.$super = cBasicObject;
  cModule.$super = cObject;
  cClass.$super = cModule;

  const_set(cObject, 'BasicObject', cBasicObject);
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

  cArray = define_class('Array', cObject);
  var ary_proto = Array.prototype, ary_inst = cArray.allocator.prototype;
  ary_inst.$flags = T_ARRAY | T_OBJECT;
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

  cSymbol = define_class('Symbol', cObject);

  cProc = define_class('Proc', cObject);

  cRange = define_class('Range', cObject);

  cRegexp = define_class('Regexp', cObject);

  cMatch = define_class('MatchData', cObject);
  define_hooked_variable('$~', regexp_match_getter, gvar_readonly_setter);

  eException = define_class('Exception', cObject);

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

  eBreakInstance = new eLocalJumpError.allocator();
  eBreakInstance['@message'] = "unexpected break";
  block.b = eBreakInstance;
  // dont need this anymore???
  eBreakInstance.$keyword = 2;

  eReturnInstance = new Error('unexpected return');
  eReturnInstance.$klass = eLocalJumpError;
  eReturnInstance.$keyword = 1;

  eNextInstance = new Error('unexpected next');
  eNextInstance.$klass = eLocalJumpError;
  eNextInstance.$keyword = 3;

  // need to do this after we make symbol
  define_singleton_method(cClass, "new", class_s_new);

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

  define_method(mKernel, 'require', obj_require);

  Op.loader = new Loader(Op);
  Op.cache = {};

  // const_set(cObject, 'RUBY_ENGINE', Op.platform.engine);
  const_set(cObject, 'RUBY_ENGINE', 'opal-gem');
};

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
    if (module.$flags & T_MODULE) {
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

  module.$flags = T_MODULE;
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

  for (var method in module.$method_table) {
    if (module.$method_table.hasOwnProperty(method)) {
      define_raw_method(klass, method,
                        module.allocator.prototype['$' + method],
                        module.$method_table[method]);
    }
  }

  for (var constant in module.$c) {
    if (module.$c.hasOwnProperty(constant)) {
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

  var meta = klass.$klass;

  for (var method in module.$method_table) {
    if (module.$method_table.hasOwnProperty(method)) {
      // FIXME: should be define_raw_method
      // define_method(meta, method, module.$method_table[method]);
      define_raw_method(meta, method,
                        module.allocator.prototype['$' + method],
                        module.$method_table[method]);
    }
  }
};

Rt.extend_module = extend_module;

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
  cls.prototype.$flags = T_OBJECT;

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
  proto.$method_table = {};
  proto.$methods = [];
  proto.allocator = klass;
  proto.constructor = meta;
  proto.__classid__ = id;
  proto.$super = superklass;
  proto.$flags = T_CLASS;

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
  klass.prototype.$klass = result;
  return result;
};

function boot_defmetameta(klass, meta) {
  klass.$klass = meta;
}

function class_boot(superklass) {
  // instances
  var cls = function() {
    this.$id = yield_hash();
  };

  var ctor = function() {};
  ctor.prototype = superklass.allocator.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.$flags = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = yield_hash();
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.allocator = cls;
  proto.$flags = T_CLASS;
  proto.$method_table = {};
  proto.$methods = [];
  proto.constructor = meta;
  proto.$super = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.$klass = result;
  return result;
};

function class_real(klass) {
  while (klass.$flags & FL_SINGLETON) { klass = klass.$super; }
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
  if (klass.$flags & T_CLASS) {
    if ((klass.$flags & T_CLASS) && (klass.$flags & FL_SINGLETON)) {
      return make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = class_boot(super_class);
      // remove this??!
      meta.allocator.prototype = klass.constructor.prototype;
      meta.$c = meta.$klass.$c_prototype;
      meta.$flags |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      klass.$klass = meta;
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
  var orig_class = obj.$klass;
  var klass = class_boot(orig_class);

  klass.$flags |= FL_SINGLETON;

  obj.$klass = klass;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  singleton_class_attached(klass, obj);

  klass.$klass = class_real(orig_class).$klass;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function singleton_class_attached(klass, obj) {
  if (klass.$flags & FL_SINGLETON) {
    ivar_set(klass, '__attached__', obj);
  }
};

function make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.$klass == metaclass) {
    metametaclass = class_boot(null);
    metametaclass.$klass = metametaclass;
  }
  else {
    metametaclass = class_boot(null);
    metametaclass.$klass = metaclass.$klass.$klass == metaclass.$klass
      ? make_metametaclass(metaclass.$klass)
      : metaclass.$klass.$klass;
  }

  metametaclass.$flags |= FL_SINGLETON;

  singleton_class_attached(metametaclass, metaclass);
  metaclass.$klass = metametaclass;
  metaclsss.$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.$super;

  metametaclass.$super = ivar_get(super_of_metaclass.$klass, '__attached__')
    == super_of_metaclass
    ? super_of_metaclass.$klass
    : make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function boot_defmetametaclass(klass, metametaclass) {
  klass.$klass.$klass = metametaclass;
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

  for (var meth in cBasicObject.$method_table) {
    prototype[meth] = cBasicObject.$method_table[meth];
  }

  for (var meth in cObject.$method_table) {
    prototype[meth] = cObject.$method_table[meth];
  }

  prototype.$klass = klass;
  prototype.$flags = flags;
  prototype.$r = true;

  prototype.$hash = function() { return flags + '_' + this; };

  return klass;
};

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

    if (!(klass.$flags & T_CLASS)) {
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
  make_metaclass(klass, super_klass.$klass);

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

  if (obj.$flags & T_OBJECT) {
    if ((obj.$flags & T_NUMBER) || (obj.$flags & T_SYMBOL)) {
      raise(eTypeError, "can't define singleton");
    }
  }

  if ((obj.$klass.$flags & FL_SINGLETON)&& ivar_get(obj.$klass, '__attached__') == obj) {
    klass = obj.$klass;
  }
  else {
    var class_id = obj.$klass.__classid__;
    klass = make_metaclass(obj, obj.$klass);
  }

  return klass;
};

Rt.singleton_class = singleton_class;

/**
  Symbol table. All symbols are stored here.
*/
var symbol_table = { };

function class_s_new(sup) {
  var klass = define_class_id("AnonClass", sup || cObject);
  return klass;
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
var load_require = Op.require = Rt.require = function(lib) {
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
    var exc, stack;
    exc = err.$rb_exc;

    if (exc && exc['@message']) {
      console.log(exc.$klass.__classid__ + ': ' + exc['@message']);
    }
    else {
      console.log('NativeError: ' + err.message);
    }

    if (stack = err.stack) {
      console.log(stack);
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
    if (files.hasOwnProperty(file)) {
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
  return opal.loader.factories[file_expand_path(path)] ? true : false;
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

init();

})();

// if in a commonjs system already (node etc), exports become our opal
// object. Otherwise, in the browser, we just get a top level opal var
if ((typeof require !== 'undefined') && (typeof module !== 'undefined')) {
  module.exports = opal;
}

