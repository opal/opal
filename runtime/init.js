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
  var old_id = STR_TO_ID_TBL[old_name];
  var new_id = STR_TO_ID_TBL[new_name];

  if (!new_id) {
    new_id = rb_intern(new_name);
  }


  var body = klass.o$a.prototype[old_id];

  if (!body) {
    console.log("cannot alias " + new_name + " to " + old_name);
    rb_raise(rb_eNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  rb_define_raw_method(klass, new_id, body);
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

  klass.$methods.push(id);

  klass.o$a.prototype[id] = body;
  klass.o$m[id] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      rb_define_raw_method(includee, id, body);
    }
  }

  // Add methods to toll-free bridges as well
  if (klass.$bridge_prototype) {
    klass.$bridge_prototype[id] = body;
  }

  // Object methods get donated to native prototypes as well
  if (klass === rb_cObject) {
    var bridged = rb_bridged_classes;

    for (var i = 0, ii = bridged.length; i < ii; i++) {
      // do not overwrite bridged implementation
      if (!bridged[i][id]) {
        bridged[i][id] = body;
      }
    }
  }

  return Qnil;
};

/**
  Raise the exception class with the given string message.
*/
function rb_raise(exc, str) {
  throw exc[id_new](str);
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
    return "#<" + rb_class_real(obj.$k).__classid__ + ":0x" + (obj.$i * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}

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

    code.push("from " + f.getFileName() + ":" + f.getLineNumber() + ":in `" + ID_TO_STR_TBL[b.$rbName] + "' on " + rb_inspect_object(f.getThis()));
  }

  return code;
}

function rb_prepare_awesome_backtrace(error, stack) {
  var code = [], f, b, k, t;

  for (var i = 0; i < stack.length; i++) {
    f = stack[i];
    b = f.getFunction();

    if (!(k = b.$rbKlass)) {
      code.push("from " + f.getFunctionName() + " at " + f.getFileName() + ":" + f.getLineNumber());
      continue;
    }

    t = f.getThis();

    if (t.$f & T_OBJECT) {
      k = t.$k.__classid__ + "#";
    }
    else {
      k = t.__classid__ + '.';
    }

    code.push("from " + k + ID_TO_STR_TBL[b.$rbName] + " at " + f.getFileName() + ":" + f.getLineNumber());
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

rb_block.$self = Qnil;

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
  var range = new rb_cRange.o$a();
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
  // The *instances* of core objects
  rb_boot_BasicObject = rb_boot_defclass();
  rb_boot_Object      = rb_boot_defclass(rb_boot_BasicObject);
  rb_boot_Module      = rb_boot_defclass(rb_boot_Object);
  rb_boot_Class       = rb_boot_defclass(rb_boot_Module);

  // The *classes* of core objects
  rb_cBasicObject     = rb_boot_makemeta("BasicObject", rb_boot_BasicObject,
                                         rb_boot_Class);
  rb_cObject          = rb_boot_makemeta("Object", rb_boot_Object,
                                         rb_cBasicObject.constructor);
  rb_cModule          = rb_boot_makemeta("Module", rb_boot_Module,
                                         rb_cObject.constructor);
  rb_cClass           = rb_boot_makemeta("Class", rb_boot_Class,
                                         rb_cModule.constructor);

  // Fix core classes
  rb_cBasicObject.$k  = rb_cClass;
  rb_cObject.$k       = rb_cClass;
  rb_cModule.$k       = rb_cClass;
  rb_cClass.$k        = rb_cClass;

  // Fix core superclasses
  rb_cBasicObject.o$s  = null;
  rb_cObject.o$s       = rb_cBasicObject;
  rb_cModule.o$s       = rb_cObject;
  rb_cClass.o$s        = rb_cModule;

  rb_const_set(rb_cObject, "BasicObject", rb_cBasicObject);
  rb_const_set(rb_cObject, "Object", rb_cObject);
  rb_const_set(rb_cObject, "Module", rb_cModule);
  rb_const_set(rb_cObject, "Class", rb_cClass);

  Rt.Object = rb_cObject;

  rb_mKernel = rb_define_module("Kernel");

  Rt.top = rb_top_self = new rb_cObject.o$a();

  rb_cNilClass = rb_define_class("NilClass", rb_cObject);
  Rt.Qnil = Qnil = new rb_cNilClass.o$a();

  // core, non-bridged, classes
  rb_cMatch     = rb_define_class("MatchData", rb_cObject);
  rb_cRange     = rb_define_class("Range", rb_cObject);

  rb_cHash      = rb_define_class("Hash", rb_cObject);

  // core bridged classes
  rb_cBoolean   = rb_bridge_class(Boolean.prototype, T_OBJECT | T_BOOLEAN,
                                  "Boolean", rb_cObject);
  rb_cArray     = rb_bridge_class(Array.prototype, T_OBJECT | T_ARRAY,
                                  "Array", rb_cObject);
  rb_cNumeric   = rb_bridge_class(Number.prototype, T_OBJECT | T_NUMBER,
                                  "Numeric", rb_cObject);
  rb_cString    = rb_bridge_class(String.prototype, T_OBJECT | T_STRING,
                                  "String", rb_cObject);
  rb_cProc      = rb_bridge_class(Function.prototype, T_OBJECT | T_PROC,
                                  "Proc", rb_cObject);
  rb_cRegexp    = rb_bridge_class(RegExp.prototype, T_OBJECT,
                                  "Regexp", rb_cObject);
  rb_eException = rb_bridge_class(Error.prototype, T_OBJECT,
                                  "Exception", rb_cObject);

  rb_eException.o$a.prototype.toString = function() {
    return this.$k.__classid__ + ": " + this.message;
  };

  // other core errors and exception classes
  rb_eStandardError = rb_define_class("StandardError", rb_eException);
  rb_eRuntimeError  = rb_define_class("RuntimeError", rb_eException);
  rb_eLocalJumpError= rb_define_class("LocalJumpError", rb_eStandardError);
  rb_eTypeError     = rb_define_class("TypeError", rb_eStandardError);
  rb_eNameError     = rb_define_class("NameError", rb_eStandardError);
  rb_eNoMethodError = rb_define_class('NoMethodError', rb_eNameError);
  rb_eArgError      = rb_define_class('ArgumentError', rb_eStandardError);
  rb_eScriptError   = rb_define_class('ScriptError', rb_eException);
  rb_eLoadError     = rb_define_class('LoadError', rb_eScriptError);
  rb_eIndexError    = rb_define_class("IndexError", rb_eStandardError);
  rb_eKeyError      = rb_define_class("KeyError", rb_eIndexError);
  rb_eRangeError    = rb_define_class("RangeError", rb_eStandardError);
  rb_eNotImplError  = rb_define_class("NotImplementedError", rb_eException);
}

/**
 * Whether runtime has already been intialized.
 */
var OPAL_INITIALIZED = false;

/**
 * Initialize opal. This will only be called once. Should be done
 * after registering method_ids and ivars for inital code (runtime?).
 */
Op.init = function() {
  if (OPAL_INITIALIZED) {
    return;
  }

  OPAL_INITIALIZED = true;

  id_new        = rb_intern("new");
  id_inherited  = rb_intern("inherited");
  id_to_s       = rb_intern("to_s");
  id_require    = rb_intern("require");

  core_lib(rb_top_self, '(corelib)');
};

