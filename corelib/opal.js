var opal = {};
var Op = opal;

this.opal = opal;

var Rt = Op.runtime = {};

/**
 * Useful js methods used within runtime.
 */
var ArrayProto     = Array.prototype,
    ObjectProto    = Object.prototype,
    ArraySlice     = ArrayProto.slice,
    hasOwnProperty = ObjectProto.hasOwnProperty;

/**
 *  Core runtime classes, objects and literals.
 */
var rb_cBasicObject,  rb_cObject,       rb_cModule,       rb_cClass,
    rb_cNativeObject, rb_mKernel,       rb_cNilClass,     rb_cBoolean,
    rb_cArray,        rb_cNumeric,      rb_cString,       rb_cHash,
    rb_cRegexp,       rb_cMatch,        rb_top_self,      Qnil,
    rb_cDir,          rb_cProc,         rb_cRange;

/**
 *  Exception classes. Some of these are used by runtime so they are here for
 * convenience.
 */
var rb_eException,       rb_eStandardError,   rb_eLocalJumpError,  rb_eNameError,
    rb_eNoMethodError,   rb_eArgError,        rb_eScriptError,     rb_eLoadError,
    rb_eRuntimeError,    rb_eTypeError,       rb_eIndexError,      rb_eKeyError,
    rb_eRangeError,      rb_eNotImplementedError;

/**
 *  Standard jump exceptions to save re-creating them everytime they are needed
 */
var rb_eReturnInstance,
    rb_eBreakInstance,
    rb_eNextInstance;

/**
 * Core object type flags. Added as local variables, and onto runtime.
 */
var T_CLASS       = 0x0001,
    T_MODULE      = 0x0002,
    T_OBJECT      = 0x0004,
    T_BOOLEAN     = 0x0008,
    T_STRING      = 0x0010,
    T_ARRAY       = 0x0020,
    T_NUMBER      = 0x0040,
    T_PROC        = 0x0080,
    //T_SYMBOL      = 0x0100,   -- depreceated - no more symbol class!
    T_HASH        = 0x0200,
    T_RANGE       = 0x0400,
    T_ICLASS      = 0x0800,
    FL_SINGLETON  = 0x1000;

/**
  Every object has a unique id. This count is used as the next id for the
  next created object. Therefore, first ruby object has id 0, next has 1 etc.
*/
var rb_hash_yield = 0;

function rb_attr(klass, name, reader, writer) {
  if (reader) {
    rb_define_method(klass, name, function(self) {
      return self[name];
    });
  }
  if (writer) {
    rb_define_method(klass, name + '=', function(self, val) {
      return self[name] = val;
    });
  }
}

/**
  Define methods. Public method for defining a method on the given base.

  The given name here will be the real string name, not a ruby id.

  @param {Object} klass The base to define method on
  @param {String} name Ruby mid
  @param {Function} body The method implementation
  @return {Qnil}
*/
function rb_define_method(klass, name, body) {
  if (klass.$f & T_OBJECT) {
    klass = klass.$k;
  }

  if (!body.$rbName) {
    body.$rbKlass = klass;
    body.$rbName = name;
  }

  var id = mid_to_jsid(name);

  rb_define_raw_method(klass, id, body);
  klass.$methods.push(name);

  return Qnil;
};

/**
  Actually find super impl to call.  Returns null if cannot find it.
*/
function rb_super_find(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.$method_table[mid]) {
      if (klass.$method_table[mid] == callee) {
        cur_method = klass.$method_table[mid];
        break;
      }
    }
    klass = klass.o$s;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.o$s;

  while (klass) {
    if (klass.$method_table[mid]) {
      return klass.$method_table[mid];
    }

    klass = klass.o$s;
  }

  return null;
};


/**
  Ruby return, with the given value. The func is the reference function which
  represents the method that this statement must return from.
*/
Rt.R = function(value, func) {
  rb_eReturnInstance.$value = value;
  rb_eReturnInstance.$func = func;
  throw rb_eReturnInstance;
};

/**
  Get the given constant name from the given base
*/
Rt.cg = function(base, id) {
  if (base == null) {
    base = rb_cNilClass;
  }
  else if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }
  return rb_const_get(base, id);
};

/**
  Set constant from runtime
*/
Rt.cs = function(base, id, val) {
  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }
  return rb_const_set(base, id, val);
};

/**
  Class variables table
*/
var rb_class_variables = {};

Rt.cvg = function(id) {
  var v = rb_class_variables[id];

  if (v) return v;

  return Qnil;
};

Rt.cvs = function(id, val) {
  return rb_class_variables[id] = val;
};

/**
 * An array of procs to call for at_exit()
 *
 * @param {Function} proc implementation
 */
var rb_end_procs = [];

/**
  Called upon exit: we need to run all of our registered procs
  in reverse order: i.e. call last ones first.

  FIXME: do we need to try/catch this??
*/
Rt.do_at_exit = function() {
  var proc;

  while (proc = rb_end_procs.pop()) {
    proc(proc.$S);
  }

  return null;
};

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

function init() {
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

  core_lib(rb_top_self, '(corelib)');
}

/**
 * Very root object - every RClass and RObject inherits from this.
 */
function RBaseObject() {
  return this;
}

/**
 * BaseObject prototype.
 */
var base_object_proto = RBaseObject.prototype;

/**
 * toString of every ruby object is just its id. This makes it simple to
 * use ruby objects in hashes etc (just use id as hash).
 */
base_object_proto.toString = function() {
  return this.$id;
};

/**
 * Root method table.
 */
function RMethodTable() {}

/**
 * Method table prototoype/
 */
var base_method_table = RMethodTable.prototype;

/**
 * Every class/module in opal is an instance of RClass.
 *
 * @param {RClass} superklass The superclass.
 */
function RClass(superklass) {
  this.$id = rb_hash_yield++;
  this.o$s = superklass;
  this.$k = rb_cClass;

  if (superklass) {
    var mtor = function(){};
    mtor.prototype = new superklass.$m_tor();
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var cctor = function(){};
    cctor.prototype = superklass.$c_prototype;

    var ctor = function(){};
    ctor.prototype = new cctor();

    this.$c = new ctor();
    this.$c_prototype = ctor.prototype;
  }
  else {
    var mtor = function(){};
    mtor.prototype = new RMethodTable();
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var ctor = function(){};
    this.$c = new ctor();
    this.$c_prototype = ctor.prototype;
  }

  this.$methods      = [];
  this.$method_table = {};
  this.$const_table  = {};

  return this;
}

RClass.prototype = new RBaseObject();

/**
 * RClass prototype for minimizing.
 */
var Rp = RClass.prototype;

/**
 * Every RClass is just a T_CLASS.
 */
Rp.$f = T_CLASS;

/**
 * Every object in opal (except toll-free native objects) are instances
 * of RObject.
 *
 * @param {RClass} klass The objects' class.
 */
function RObject(klass) {
  this.$id = rb_hash_yield++;
  this.$k  = klass;
  this.$m  = klass.$m_tbl;
  return this;
}

RObject.prototype = new RBaseObject();

/**
 * RObject prototype for minimizing.
 */
var Bp = RObject.prototype;

/**
 * Every RObject is just a T_OBJECT;
 */
Bp.$f = T_OBJECT;

/**
 * Get actual class ignoring singleton classes and iclasses.
 */
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) { klass = klass.o$s; }
  return klass;
};

/**
  Make metaclass for the given class
*/
function rb_make_metaclass(klass, superklass) {
  if (klass.$f & T_CLASS) {
    if ((klass.$f & T_CLASS) && (klass.$f & FL_SINGLETON)) {
      return rb_make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = new RClass(superklass);
      meta.$m = meta.$k.$m_tbl;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      meta.__classname__ = klass.__classid__;
      klass.$k = meta;
      klass.$m = meta.$m_tbl;
      meta.$c = klass.$c;
      rb_singleton_class_attached(meta, klass);
      return meta;
    }
  } else {
    // if we want metaclass of an object, do this
    return rb_make_singleton_class(klass);
  }
};

function rb_make_singleton_class(obj) {
  var orig_class = obj.$k;
  var klass = new RClass(orig_class);

  klass.$f |= FL_SINGLETON;

  obj.$k = klass;
  obj.$m = klass.$m_tbl;

  rb_singleton_class_attached(klass, obj);

  klass.$k = rb_class_real(orig_class).$k;
  klass.$m = klass.$k.$m_tbl;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function rb_singleton_class_attached(klass, obj) {
  if (klass.$f & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function rb_make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.$k == metaclass) {
    metametaclass = new RClass();
    metametaclass.$k = metametaclass;
  }
  else {
    metametaclass = new RClass();
    metametaclass.$k = metaclass.$k.$k == metaclass.$k
      ? rb_make_metametaclass(metaclass.$k)
      : metaclass.$k.$k;
  }

  metametaclass.$f |= FL_SINGLETON;

  rb_singleton_class_attached(metametaclass, metaclass);
  rb_metaclass.$k = metametaclass;
  metaclass.o$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.o$s;

  metametaclass.o$s = super_of_metaclass.$k.__attached__
    == super_of_metaclass
    ? super_of_metaclass.$k
    : rb_make_metametaclass(super_of_metaclass);

  return metametaclass;
};

/**
 *  Define toll free bridged class
 */
function rb_bridge_class(constructor, flags, id) {
  var klass = define_class(rb_cObject, id, rb_cObject);
  var prototype = constructor.prototype;

  prototype.$k = klass;
  prototype.$m = klass.$m_tbl;
  prototype.$f = flags;

  return klass;
};

/**
 * Define a class.
 *
 * @param {RClass} base Where to define under (e.g. rb_cObject).
 * @param {String} id Class name
 * @param {RClass} superklass The superclass.
 */
function define_class(base, id, superklass) {
  var klass;

  if (rb_const_defined(base, id)) {
    klass = rb_const_get(base, id);

    if (!(klass.$f & T_CLASS)) {
      rb_raise(rb_eException, id + " is not a class");
    }

    if (klass.o$s != superklass && superklass != rb_cObject) {
      rb_raise(rb_eException, "Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = new RClass(superklass);
  klass.$m_tbl.toString = function() {
    return "<method table for: " + id + ">";
  };
  klass.__classid__ = id;

  rb_make_metaclass(klass, superklass.$k);
  klass.$parent = superklass;

  if (base == rb_cObject) {
    klass.__classid__ = id;
  } else {
    klass.__classid__ = base.__classid__ + '::' + id;
  }

  rb_const_set(base, id, klass);
  klass.$parent = base;

  // Class#inherited hook - here is a good place to call. We check method
  // is actually defined first (incase we are calling it during boot). We
  // can't do this earlier as an error will cause constant names not to be
  // set etc (this is the last place before returning back to scope).
  if (superklass.$m.inherited) {
    superklass.$m.inherited(superklass, klass);
  }

  return klass;
};

/**
  Get singleton class of obj
*/
function rb_singleton_class(obj) {
  var klass;

  // we cant use singleton nil
  if (obj == Qnil) {
    rb_raise(rb_eTypeError, "can't define singleton");
  }

  if (obj.$f & T_OBJECT) {
    if ((obj.$f & T_NUMBER) || (obj.$f & T_STRING)) {
      rb_raise(rb_eTypeError, "can't define singleton");
    }
  }

  if ((obj.$k.$f & FL_SINGLETON) && obj.$k.__attached__ == obj) {
    klass = obj.$k;
  }
  else {
    var class_id = obj.$k.__classid__;
    klass = rb_make_metaclass(obj, obj.$k);
  }

  return klass;
};

function define_module(base, id) {
  var module;

  if (rb_const_defined(base, id)) {
    module = rb_const_get(base, id);
    if (module.$f & T_MODULE) {
      return module;
    }

    rb_raise(rb_eException, id + " is not a module");
  }

  module = new RClass(rb_cModule);
  rb_make_metaclass(module, rb_cModule);

  module.$f = T_MODULE;
  module.$included_in = [];

  if (base == rb_cObject) {
    module.__classid__ = id;
  } else {
    module.__classid__ = base.__classid__ + '::' + id;
  }

  rb_const_set(base, id, module);
  module.$parent = base;
  return module;
};

function rb_include_module(klass, module) {

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
    if (hasOwnProperty.call(module.$method_table, method)) {
      rb_define_raw_method(klass, method,
                        module.$m_tbl[method]);
    }
  }

  // for (var constant in module.$c) {
    // if (hasOwnProperty.call(module.$c, constant)) {
      // const_set(klass, constant, module.$c[constant]);
    // }
  // }
}

function rb_extend_module(klass, module) {
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

  var meta = klass.$k;

  for (var method in module.o$m) {
    if (hasOwnProperty.call(module.o$m, method)) {
      rb_define_raw_method(meta, method,
                        module.o$a.prototype[method]);
    }
  }
}

/**
  External API to require a ruby file. This differes from internal
  require as this method takes an optional second argument that
  specifies the current working directory to use.

  If the given dir does not begin with '/' then it is assumed to be
  the name of a gem/bundle, so we actually set the cwd directory to
  the dir where that gem is stored internally (which is usually
  "/$name".

  Usage:

      opal.main("main.rb", "my_bundle");

  Previous example will set the cwd to "/my_bundle" and then try to
  load main.rb using require(). If main.rb is actually found inside
  the new cwd, it can be loaded (cwd is in the load path).

  FIXME: should we do this here?
  This will also make at_exit blocks run.

  @param {String} id the path/id to require
  @param {String} dir the working directory to change to (optional)
*/
Op.main = function(id, dir) {
  if (dir !== undefined) {
    if (dir.charAt(0) !== '/') {
      dir = '/' + dir;
    }

    FS_CWD = dir;
  }

  // set 'main' file
  Rt.gs('$0', rb_find_lib(id));

  // load main file
  rb_top_self.$m.require(rb_top_self, id);

  // run exit blocks
  Rt.do_at_exit();
};

/**
 * Register a simple lib file. This file is simply just put into the lib
 * "directory" so it is ready to load"
 *
 * @param {String} name The lib/gem name
 * @param {String, Function} factory
 */
Op.lib = function(name, factory) {
  var name = 'lib/' + name;
  var path = '/' + name;
  LOADER_FACTORIES[path] = factory;
  LOADER_LIBS[name] = path;
};

/**
 * External api for defining a gem/bundle. This takes an object that
 * defines all the gem info and files.
 *
 * Actually register a predefined bundle. This is for the browser context
 * where bundle can be serialized into JSON and defined before hand.
 * @param {Object} info bundle info
 */
Op.bundle = function(info) {
  var loader_factories = LOADER_FACTORIES,
      loader_libs      = LOADER_LIBS,
      paths     = LOADER_PATHS,
      name      = info.name;

  // register all lib files
  var libs = info.libs || {};

  // register all other files
  var files = info.files || {};

  // root dir for gem is '/gem_name'
  var root_dir = '/' + name;

  var lib_dir = root_dir;

  // add lib dir to paths
  //paths.unshift(fs_expand_path(fs_join(root_dir, lib_dir)));


  for (var lib in libs) {
    if (hasOwnProperty.call(libs, lib)) {
      var file_path = lib_dir + '/' + lib;
      loader_factories[file_path] = libs[lib];
      loader_libs[lib] = file_path;
    }
  }

  for (var file in files) {
    if (hasOwnProperty.call(files, file)) {
      var file_path = root_dir + '/' + file;
      loader_factories[file_path] = files[file];
    }
  }
}

LOADER_PATHS = ['', '/lib'];

LOADER_FACTORIES = {};

LOADER_LIBS = {};

LOADER_CACHE = {};

var rb_find_lib = function(id) {
  var libs = LOADER_LIBS,
      lib  = 'lib/' + id;

  // try to load a lib path first - i.e. something in our load path
  if (libs[lib + '.rb']) {
    return libs[lib + '.rb'];
  }

  // next, incase our require() has a ruby extension..
  if (lib.lastIndexOf('.') === lib.length - 3) {
    if (libs[lib]) {
      return libs[lib];
    }
    // if not..
    // return null;
  }

  // if we have a .js file to require..
  if (libs[lib + '.js']) {
    return libs[lib + '.js'];
  }

  // check if id is full path..
  var factories = LOADER_FACTORIES;

  if (factories[id]) {
    return id;
  }

  // full path without '.rb'
  if (factories[id + '.rb']) {
    return id + '.rb';
  }

  // check in current working directory.
  var in_cwd = FS_CWD + '/' + id;

  if (factories[in_cwd]) {
    return in_cwd;
  }

  return null;
};

/**
 * RegExp for splitting filenames into their dirname, basename and ext.
 * This currently only supports unix style filenames as this is what is
 * used internally when running in the browser.
 */
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

/**
 * Holds the current cwd for the application.
 */
var FS_CWD = '/';

/**
 * Turns a glob string into a regexp
 */
function fs_glob_to_regexp(glob) {
  var parts = glob.split(''), length = parts.length, result = '';

  var opt_group_stack = 0;

  for (var i = 0; i < length; i++) {
    var cur = parts[i];

    switch (cur) {
      case '*':
        if (parts[i + 1] === '*' && parts[i + 2] === '/') {
          result += '.*';
          i += 2;
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
  All 'vm' methods and properties stored here. These are available to ruby
  sources at runtime through the +VM+ js variable.

  Not really a VM, more like a collection of useful functions/methods.
*/
var VM = Rt;

VM.opal = Op;

VM.k = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    // regular class
    case 0:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      if (superklass === null) {
        superklass = rb_cObject;
      }

      klass = define_class(base, id, superklass);
      break;

    // module
    case 1:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      klass = define_module(base, id);
      break;

    // shift class
    case 2:
      klass = rb_singleton_class(base);
      break;
  }

  return body(klass);
};

/**
  Expose Array.prototype.slice to the runtime. This is used a lot by methods
  that take splats, for insance. Useful and saves lots of code space.
*/
VM.as = ArraySlice;

/**
  Regexp data. This will store all match information for the last executed
  regexp. Useful for various methods and globals.
*/
VM.X = null;

VM.m = rb_define_raw_method;

VM.M = function(base, id, body) {
  return rb_define_raw_method(rb_singleton_class(base), id, body);
};
/**
  Undefine the given methods from the receiver klass.

  Usage:

      VM.um(rb_cObject, 'foo', 'bar', 'baz');

  @param {RClass} klass
*/
VM.um = function(klass) {
  var args = ArraySlice.call(arguments, 1);

  for (var i = 0, ii = args.length; i < ii; i++) {
    var mid = args[i], id = STR_TO_ID_TBL[mid];
    klass.$m_tbl[id] = rb_make_method_missing_stub(id, mid);
  }

  return null;
};


/**
  Calls a super method.

  @param {Function} callee current method calling super()
  @param {RObject} self self value calling super()
  @param {Array} args arguments to pass to super
  @return {RObject} return value from call
*/
VM.S = function(callee, self, args) {
  var mid = callee.$rbName;
  var func = rb_super_find(self.$k, callee, mid);

  if (!func) {
    rb_raise(rb_eNoMethodError, "super: no superclass method `" + mid + "'"
             + " for " + self.$m.inspect(self, 'inspect'));
  }

  args.unshift(self);
  return func.apply(null, args);
};

/**
 * Returns new hash with values passed from ruby
 */
VM.H = function() {
  var hash = new RObject(rb_cHash), key, val, args = ArraySlice.call(arguments);
  var assocs = hash.map = {};
  hash.none = null;

  for (var i = 0, ii = args.length; i < ii; i++) {
    key = args[i];
    val = args[i + 1];
    i++;
    assocs[key] = [key, val];
  }

  return hash;
};

var method_names = {
  "==": "$eq", "===": "$eqq", "[]": "$aref", "[]=": "$aset", "~": "$tild",
  "<=>": "$cmp", "=~": "$match", "+": "$plus", "-": "$minus", "/": "$div",
  "*": "$mul", "<": "$lt", "<=": "$le", ">": "$gt", ">=": "$ge",
  "<<": "$lshft", ">>": "$rshft", "|": "$or", "&": "$and", "^": "$xor",
  "+@": "$uplus", "-@": "$uminus", "%": "$mod", "**": "$pow",
  "break": "$break", "case": "$case", "catch": "$catch",
  "continue": "$continue", "debugger": "$debugger", "default": "$default",
  "delete": "$delete", "do": "$do", "else": "$else", "finally": "$finally",
  "for": "$for", "function": "$function", "if": "$if", "in": "$in",
  "instanceof": "$instanceof", "new": "$new", "return": "$return",
  "switch": "$switch", "this": "$this", "throw": "$throw", "try": "$try",
  "typeof": "$typeof", "var": "$var", "let": "$let", "void": "$void",
  "while": "$while", "with": "$with", "class": "$class", "enum": "$enum",
  "export": "$export", "extends": "$extends", "import": "$import",
  "super": "$super", "true": "$true", "false": "$false"
};

function mid_to_jsid(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

function rb_method_missing_caller(recv, id) {
  var proto = recv == null ? NilClassProto : recv;
  var meth = mid_to_jsid[id];
  var func = proto.$m[mid_to_jsid('method_missing')];
  var args = [recv, 'method_missing', meth].concat(ArraySlice.call(arguments, 2));
  return func.apply(null, args);
}

rb_method_missing_caller.$method_missing = true;
