/**
 *  Sets the constant value `val` on the given `klass` as `id`.
 *
 * @param {RClass} klass
 * @param {String} id
 * @param {Object} val
 * @return {Object} returns the set value
 */
function rb_const_set(klass, id, val) {
  klass.$c[id] = val;
  return val;
}

/**
 *  Lookup a constant named `id` on the `klass`. This will throw an error if
 * the constant cannot be found.
 *
 * @param {RClass} klass
 * @param {String} id
 */
function rb_const_get(klass, id) {
  if (klass.$c[id]) {
    return (klass.$c[id]);
  }

  var parent = klass.$parent;

  while (parent) {
    if (parent.$c[id] !== undefined) {
      return parent.$c[id];
    }

    parent = parent.$parent;
  }

  rb_raise(rb_eNameError, 'uninitialized constant ' + id);
};

/**
  Returns true or false depending whether a constant named `id` is defined
  on the receiver `klass`.

  @param {RClass} klass
  @param {String} id
  @return {true, false}
*/
function rb_const_defined(klass, id) {
  if (klass.$c[id]) {
    return true;
  }

  return false;
};

/**
 * All globals.
 */
var rb_global_tbl = {};

var rb_gvar_get = Rt.gg = function(id) {
  if (hasOwnProperty.call(rb_global_tbl, id)) {
    return rb_global_tbl[id];
  }

  return Qnil;
}

var rb_gvar_set = Rt.gs = function(id, value) {
  return rb_global_tbl[id] = value;
}

/**
 * Define alias.
 *
 * @param {String} new_name string name for new method
 * @param {String} old_name string name for old method name
 */
var rb_alias_method = Rt.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$m_tbl[old_name];

  if (!body) {
    console.log("cannot alias " + new_name + " to " + old_name + " for " + klass.__classid__);
    rb_raise(rb_eNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  rb_define_raw_method(klass, new_name, body);
  return Qnil;
};

/**
  This does the main work, but does not call runtime methods like
  singleton_method_added etc. define_method does that.

  The id passed here should be an opal id.

*/
function rb_define_raw_method(klass, id, body) {
  // If an object, make sure to use its class
  if (klass.$f & T_OBJECT) {
    klass = klass.$k;
  }

  // Useful debug info
  if (!body.$rbName) {
    body.$rbKlass = klass;
    body.$rbName = id;
  }

  klass.$m_tbl[id] = body;
  klass.$method_table[id] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      rb_define_raw_method(includee, id, body);
    }
  }

  return Qnil;
};

/**
  Raise the exception class with the given string message.
*/
function rb_raise(exc, str) {
  throw exc.$m.$new(exc, str);
};

/**
 * Generic object inspector.
 *
 * Used to provide a string version of objects for stack traces, but can
 * be used for any purpose. Objects are returned in the same format as
 * the default Kernel#inspect method, and classes are returned as just
 * their name.
 */
function rb_inspect_object(obj) {
  if (obj.$f & T_OBJECT) {
    return "#<" + rb_class_real(obj.$k).__classid__ + ":0x" + (obj.$id * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}

/**
 * Print awesome backtrace to the conosle for given error
 */
Rt.bt = function(err) {
  console.log(err.$k.__classid__ + ": " + err.message);
  var bt = rb_exc_backtrace(err, rb_prepare_awesome_backtrace);
  console.log("\t" + bt.join("\n\t"));
};

function rb_exc_backtrace(err, formatter) {
  var old = Error.prepareStackTrace;
  Error.prepareStackTrace = formatter;

  var backtrace = err.stack;
  Error.prepareStackTrace = old;

  if (backtrace && backtrace.join) {
    return backtrace;
  }

  return ["No backtrace available"];
}

function rb_prepare_backtrace(error, stack) {
  var code = [], f, b, k;

  for (var i = 0; i < stack.length; i++) {
    f = stack[i];
    b = f.getFunction();

    if (!(k = b.$rbKlass)) {
      continue;
    }

    code.push("from " + f.getFileName() + ":" + f.getLineNumber() + ":in `" + b.$rbName + "' on " + rb_inspect_object(k));
  }

  return code;
}

function rb_prepare_awesome_backtrace(error, stack) {
  var code = [], f, b, k, t;

  for (var i = 0; i < stack.length; i++) {
    f = stack[i];
    b = f.getFunction();

    if (!(k = b.$rbKlass)) {
      //code.push("from " + f.getFunctionName() + " at " + f.getFileName() + ":" + f.getLineNumber());
      continue;
    }

    k = k.__classid__ + "#";

    code.push("from " + k + b.$rbName + " at " + f.getFileName() + ":" + f.getLineNumber());
  }

  return code;
};

function rb_string_inspect(self) {
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
};

/**
  Block passing - holds current block for runtime

  f: function
  p: proc
  y: yield error
*/
var rb_block = Rt.P = function() {
  rb_raise(rb_eLocalJumpError, "no block given");
};

rb_block.$S = rb_block;

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
function rb_make_lambda(proc) {
  if (proc.$lambda) return proc;

  var wrap = function() {
    var args = ArraySlice.call(arguments, 0);
    return proc.apply(null, args);
  };

  wrap.$lambda = true;
  wrap.o$s = proc.o$s;

  return proc;
};

/**
 *  Returns a new ruby range. G for ranGe.
 */
Rt.G = function(beg, end, exc) {
  var range = new RObject(rb_cRange);
  range.begin = beg;
  range.end = end;
  range.exclude = exc;
  return range;
};

/**
 * Boot very core runtime. This sets up just the very core runtime,
 * enough to get going before entire system is init().
 */
function boot() {
  var metaclass;

  rb_cBasicObject = new RClass();
  rb_cBasicObject.__classid__ = "BasicObject";

  rb_cObject = new RClass(rb_cBasicObject);
  rb_cObject.__classid__ = "Object";

  rb_cModule = new RClass(rb_cObject);
  rb_cModule.__classid__ = "Module";

  rb_cClass = new RClass(rb_cModule);
  rb_cClass.__classid__ = "Class";

  rb_const_set(rb_cObject, "BasicObject", rb_cBasicObject);
  rb_const_set(rb_cObject, "Object", rb_cObject);
  rb_const_set(rb_cObject, "Module", rb_cModule);
  rb_const_set(rb_cObject, "Class", rb_cClass);

  metaclass = rb_make_metaclass(rb_cBasicObject, rb_cClass);
  metaclass = rb_make_metaclass(rb_cObject, metaclass);
  metaclass = rb_make_metaclass(rb_cModule, metaclass);
  metaclass = rb_make_metaclass(rb_cClass, metaclass);

  rb_cModule.$k.$k = metaclass;
  rb_cObject.$k.$k = metaclass;
  rb_cBasicObject.$k.$k = metaclass;

  Rt.Object = rb_cObject;

  rb_mKernel = define_module(rb_cObject, "Kernel");

  // core, non-bridged, classes
  rb_cMatch     = define_class(rb_cObject, "MatchData", rb_cObject);
  rb_cRange     = define_class(rb_cObject, "Range", rb_cObject);
  rb_cHash      = define_class(rb_cObject, "Hash", rb_cObject);
  rb_cNilClass  = define_class(rb_cObject, "NilClass", rb_cObject);

  Rt.top = rb_top_self = new RObject(rb_cObject);
  Rt.NC = NilClassProto = new RObject(rb_cNilClass);
  Qnil = null;

  // core bridged classes
  rb_cBoolean   = rb_bridge_class(Boolean, T_OBJECT | T_BOOLEAN, "Boolean");
  rb_cArray     = rb_bridge_class(Array, T_OBJECT | T_ARRAY, "Array");
  rb_cNumeric   = rb_bridge_class(Number, T_OBJECT | T_NUMBER, "Numeric");
  rb_cString    = rb_bridge_class(String, T_OBJECT | T_STRING, "String");
  rb_cProc      = rb_bridge_class(Function, T_OBJECT | T_PROC, "Proc");
  rb_cRegexp    = rb_bridge_class(RegExp, T_OBJECT, "Regexp");
  rb_eException = rb_bridge_class(Error, T_OBJECT, "Exception");

  // other core errors and exception classes
  rb_eStandardError = define_class(rb_cObject, "StandardError", rb_eException);
  rb_eRuntimeError  = define_class(rb_cObject, "RuntimeError", rb_eException);
  rb_eLocalJumpError= define_class(rb_cObject, "LocalJumpError", rb_eStandardError);
  rb_eTypeError     = define_class(rb_cObject, "TypeError", rb_eStandardError);
  rb_eNameError     = define_class(rb_cObject, "NameError", rb_eStandardError);
  rb_eNoMethodError = define_class(rb_cObject, 'NoMethodError', rb_eNameError);
  rb_eArgError      = define_class(rb_cObject, 'ArgumentError', rb_eStandardError);
  rb_eScriptError   = define_class(rb_cObject, 'ScriptError', rb_eException);
  rb_eLoadError     = define_class(rb_cObject, 'LoadError', rb_eScriptError);
  rb_eIndexError    = define_class(rb_cObject, "IndexError", rb_eStandardError);
  rb_eKeyError      = define_class(rb_cObject, "KeyError", rb_eIndexError);
  rb_eRangeError    = define_class(rb_cObject, "RangeError", rb_eStandardError);
  rb_eNotImplError  = define_class(rb_cObject, "NotImplementedError", rb_eException);

  rb_eBreakInstance = new Error("unexpected break");
  rb_eBreakInstance.$k = rb_eLocalJumpError;
  rb_eBreakInstance.$m = rb_eLocalJumpError.$m_tbl;
  rb_eBreakInstance.$t = function() { throw this; };
  rb_eBreakInstance.$v = Qnil;
  VM.B = rb_eBreakInstance;
}

/**
 * Initialize opal. This will only be called once. Should be done
 * after registering method_ids and ivars for inital code (runtime?).
 */
Op.init = function() {
  core_lib(rb_top_self, '(corelib)');
};

