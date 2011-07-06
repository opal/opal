
/**
  Sets the constant value `val` on the given `klass` as `id`.

  @param {RClass} klass
  @param {String} id
  @param {Object} val
  @return {Object} returns the set value
*/
function const_set(klass, id, val) {
  klass.$c_prototype[id] = val;
  klass.$const_table[id] = val;
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
  var hash = new RObject(cHash), k, v, args = [].slice.call(arguments);
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

var alias_method = Rt.alias_method = function(klass, new_name, old_name) {
  var body = klass.$m_tbl[old_name];

  if (!body) {
    throw new Error("NameError: undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  define_raw_method(klass, new_name, body, body);
  return Qnil;
};

/**
  This does the main work, but does not call runtime methods like
  singleton_method_added etc. define_method does that.

*/
function define_raw_method(klass, private_name, private_body, public_body) {
  var public_name = '$' + private_name;

  klass.$m_tbl[private_name] = private_body;
  klass.$m_tbl[public_name] = public_body;

  klass.$method_table[private_name] = private_body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_raw_method(includee, private_name, private_body, public_body);
    }
  }
};

Rt.private_methods = function(klass, args) {
  return;

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

function define_alias(base, new_name, old_name) {
  define_method(base, new_name, base.$m_tbl[old_name]);
  return Qnil;
};

function obj_alloc(klass) {
  var result = new RObject(klass);
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

  var exception = exc.$m['new'](exc, str);
  raise_exc(exception);
};

Rt.raise = raise;

/**
  Raise an exception instance (DO NOT pass strings to this)
*/
function raise_exc(exc) {
  throw exc;
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

  var res = new String(intern);
  res.$klass = cSymbol;
  res.$m = cSymbol.$m_tbl;
  res.$flags = T_OBJECT | T_SYMBOL;
  symbol_table[intern] = res;
  return res;
};


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
  // init_debug();

  var metaclass;

  Rt.BasicObject = cBasicObject = boot_defrootclass('BasicObject');
  Rt.Object = cObject = boot_defclass('Object', cBasicObject);
  Rt.Module = cModule = boot_defclass('Module', cObject);
  Rt.Class = cClass = boot_defclass('Class', cModule);

  const_set(cObject, 'BasicObject', cBasicObject);

  metaclass = make_metaclass(cBasicObject, cClass);
  metaclass = make_metaclass(cObject, metaclass);
  metaclass = make_metaclass(cModule, metaclass);
  metaclass = make_metaclass(cClass, metaclass);

  boot_defmetametaclass(cModule, metaclass);
  boot_defmetametaclass(cObject, metaclass);
  boot_defmetametaclass(cBasicObject, metaclass);

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

  cArray = bridge_class(Array.prototype,
    T_OBJECT | T_ARRAY, 'Array', cObject);

  Function.prototype.$hash = function() {
    return this.$id || (this.$id = yield_hash());
  };

  cHash = define_class('Hash', cObject);

  cNumeric = bridge_class(Number.prototype,
    T_OBJECT | T_NUMBER, 'Numeric', cObject);

  cString = bridge_class(String.prototype,
    T_OBJECT | T_STRING, 'String', cObject);

  cSymbol = define_class('Symbol', cObject);

  cProc = bridge_class(Function.prototype,
    T_OBJECT | T_PROC, 'Proc', cObject);

  Function.prototype.$hash = function() {
    return this.$id || (this.$id = yield_hash());
  };

  cRange = define_class('Range', cObject);

  cRegexp = bridge_class(RegExp.prototype,
    T_OBJECT, 'Regexp', cObject);

  cMatch = define_class('MatchData', cObject);
  define_hooked_variable('$~', regexp_match_getter, gvar_readonly_setter);

  eException = bridge_class(Error.prototype, T_OBJECT, 'Exception', cObject);

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

  eBreakInstance = new Error();
  eBreakInstance['@message'] = "unexpected break";
  block.b = eBreakInstance;
  // dont need this anymore???
  eBreakInstance.$keyword = 2;

  eReturnInstance = new Error();
  eReturnInstance.$klass = eLocalJumpError;
  eReturnInstance.$keyword = 1;

  eNextInstance = new Error();
  eNextInstance.$klass = eLocalJumpError;
  eNextInstance.$keyword = 3;

  // need to do this after we make symbol
  Rt.ds(cClass, 'new', class_s_new);

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

  // const_set(cObject, 'RUBY_ENGINE', Op.platform.engine);
  const_set(cObject, 'RUBY_ENGINE', 'opal-gem');

};

/**
  Symbol table. All symbols are stored here.
*/
var symbol_table = { };

function class_s_new(cls, sup) {
  var klass = define_class_id("AnonClass", sup || cObject);
  return klass;
};

