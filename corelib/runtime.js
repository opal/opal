var opal = {};

this.opal = opal;

var VM = opal.runtime = {};

// Minify common function calls
var ArrayProto     = Array.prototype,
    ObjectProto    = Object.prototype,
    ArraySlice     = ArrayProto.slice,
    hasOwnProperty = ObjectProto.hasOwnProperty;

// Types - also added to bridged objects
var T_CLASS       = 0x0001,
    T_MODULE      = 0x0002,
    T_OBJECT      = 0x0004,
    T_BOOLEAN     = 0x0008,
    T_STRING      = 0x0010,
    T_ARRAY       = 0x0020,
    T_NUMBER      = 0x0040,
    T_PROC        = 0x0080,
    T_HASH        = 0x0200,
    T_RANGE       = 0x0400,
    T_ICLASS      = 0x0800,
    FL_SINGLETON  = 0x1000;

// Generates unique id for every ruby object
var rb_hash_yield = 0;

// Find function body for the super call
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
}

// Jump return - return in proc body
VM.R = function(value, func) {
  rb_eReturnInstance.$value = value;
  rb_eReturnInstance.$func = func;
  throw rb_eReturnInstance;
};

// Get constant with given id
VM.cg = function(base, id) {
  if (base == null) {
    base = rb_cNilClass;
  }
  else if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }
  return rb_const_get(base, id);
};

// Set constant with given id
VM.cs = function(base, id, val) {
  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }
  return base.$c[id] = val;
};

// Table holds all class variables
VM.c = {};

// Array of all procs to be called at_exit
var rb_end_procs = [];

// Call exit blocks in reverse order
VM.do_at_exit = function() {
  var proc;

  while (proc = rb_end_procs.pop()) {
    proc(proc.$S);
  }
};

// Get constant on receiver
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
}

// Globals table
VM.g = {};

// Define a method alias
var rb_alias_method = VM.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$m_tbl[old_name];

  if (!body) {
    rb_raise(rb_eNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  define_method(klass, new_name, body);
};

// Actually define methods
function define_method(klass, id, body) {
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

      define_method(includee, id, body);
    }
  }
}

// Raise a new exception using exception class and message
function rb_raise(exc, str) {
  throw exc.$m.$new(exc, str);
}

// Inspect object or class
function rb_inspect_object(obj) {
  if (obj.$f & T_OBJECT) {
    return "#<" + rb_class_real(obj.$k).__classid__ + ":0x" + (obj.$id * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}

// Print error backtrace to console
VM.bt = function(err) {
  console.log(err.$k.__classid__ + ": " + err.message);
  var bt = rb_exc_backtrace(err);
  console.log("\t" + bt.join("\n\t"));
};

function rb_exc_backtrace(err) {
  var old = Error.prepareStackTrace;
  Error.prepareStackTrace = rb_prepare_backtrace;

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

// Fake yielder used when no block given
VM.P = function() {
  rb_raise(rb_eLocalJumpError, "no block given");
};

// Create a new Range instance
VM.G = function(beg, end, exc) {
  var range = new RObject(rb_cRange);
  range.begin = beg;
  range.end = end;
  range.exclude = exc;
  return range;
};

// Very root object - every RClass and RObject inherits from this.
function RBaseObject() {
  return this;
}

RBaseObject.prototype.toString = function() {
  return this.$id;
};

// Root method table.
function RMethodTable() {}

var base_method_table = RMethodTable.prototype;

// Every class/module in opal is an instance of RClass.
function RClass(superklass, class_id) {
  this.__classid__ = class_id;
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
RClass.prototype.$f = T_CLASS;

// Every object in opal (except toll-free native objects) are instances
// of RObject.
function RObject(klass) {
  this.$id = rb_hash_yield++;
  this.$k  = klass;
  this.$m  = klass.$m_tbl;
  return this;
}

RObject.prototype = new RBaseObject();
RObject.prototype.$f = T_OBJECT;

// Get actual class ignoring singleton classes and iclasses.
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) { klass = klass.o$s; }
  return klass;
}

// Make metaclass for the given class
function rb_make_metaclass(klass, superklass) {
  if (klass.$f & T_CLASS) {
    if ((klass.$f & T_CLASS) && (klass.$f & FL_SINGLETON)) {
      rb_raise(rb_eException, "too much meta: return klass?");
    }
    else {
      var class_id = "#<Class:" + klass.__classid__ + ">";
      var meta = new RClass(superklass, class_id);
      meta.$m = meta.$k.$m_tbl;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classname__ = klass.__classid__;
      klass.$k = meta;
      klass.$m = meta.$m_tbl;
      meta.$c = klass.$c;
      meta.__attached__ = klass;
      return meta;
    }
  } else {
    return rb_make_singleton_class(klass);
  }
}

function rb_make_singleton_class(obj) {
  var orig_class = obj.$k;
  var class_id = "#<Class:#<" + orig_class.__classid__ + ":" + orig_class.$id + ">>";
  var klass = new RClass(orig_class, class_id);

  klass.$f |= FL_SINGLETON;

  obj.$k = klass;
  obj.$m = klass.$m_tbl;

  klass.__attached__ = obj;

  klass.$k = rb_class_real(orig_class).$k;
  klass.$m = klass.$k.$m_tbl;

  return klass;
}

function rb_bridge_class(constructor, flags, id) {
  var klass = define_class(rb_cObject, id, rb_cObject);
  var prototype = constructor.prototype;

  prototype.$k = klass;
  prototype.$m = klass.$m_tbl;
  prototype.$f = flags;

  return klass;
}

// Define new ruby class
function define_class(base, id, superklass) {
  var klass;

  if (base.$c.hasOwnProperty(id)) {
    return rb_const_get(base, id);
  }

  var class_id = (base === rb_cObject ? id : base.__classid__ + '::' + id);

  klass = new RClass(superklass, class_id);
  rb_make_metaclass(klass, superklass.$k);

  base.$c[id] = klass;
  klass.$parent = base;

  if (superklass.$m.inherited) {
    superklass.$m.inherited(superklass, klass);
  }

  return klass;
}

// Get singleton class of obj
function rb_singleton_class(obj) {
  var klass;

  // we cant use singleton nil
  if (obj == null) {
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
}

function define_module(base, id) {
  var module;

  if (base.$c.hasOwnProperty(id)) {
    return rb_const_get(base, id);
  }

  var class_id = (base === rb_cObject ? id : base.__classid__ + '::' + id)

  module = new RClass(rb_cModule, class_id);
  rb_make_metaclass(module, rb_cModule);

  module.$f = T_MODULE;
  module.$included_in = [];

  base.$c[id] = module;
  module.$parent = base;
  return module;
}

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
      define_method(klass, method,
                        module.$m_tbl[method]);
    }
  }
}

// App entry point with require file and working dir
opal.main = function(id, dir) {
  if (dir !== undefined) {
    if (dir.charAt(0) !== '/') {
      dir = '/' + dir;
    }

    FS_CWD = dir;
  }

  VM.g.$0 = rb_find_lib(id);
  rb_top_self.$m.require(rb_top_self, id);
  VM.do_at_exit();
};

// Register simple lib
opal.lib = function(name, factory) {
  var name = 'lib/' + name;
  var path = '/' + name;
  LOADER_FACTORIES[path] = factory;
  LOADER_LIBS[name] = path;
};

// Register gem/bundle
opal.bundle = function(info) {
  var loader_factories = LOADER_FACTORIES,
      loader_libs      = LOADER_LIBS,
      paths     = LOADER_PATHS,
      name      = info.name;

  var libs = info.libs || {};
  var files = info.files || {};
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
};

// Split to dirname, basename and extname
var PATH_RE = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// Current working directory
var FS_CWD = '/';

// Turns a glob string into a regexp
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

// VM define class. 0: regular, 1: module, 2: shift class.
VM.k = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    case 0:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      if (superklass === null) {
        superklass = rb_cObject;
      }

      klass = define_class(base, id, superklass);
      break;

    case 1:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      klass = define_module(base, id);
      break;

    case 2:
      klass = rb_singleton_class(base);
      break;
  }

  return body(klass);
};

VM.as = ArraySlice;

// Regexp match data
VM.X = null;

VM.m = define_method;

VM.M = function(base, id, body) {
  return define_method(rb_singleton_class(base), id, body);
};

// Undefine one or more methods
VM.um = function(klass) {
  var args = ArraySlice.call(arguments, 1);

  for (var i = 0, ii = args.length; i < ii; i++) {
    var mid = args[i], id = STR_TO_ID_TBL[mid];
    klass.$m_tbl[id] = rb_make_method_missing_stub(id, mid);
  }
};

// Calls a super method.
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

// Returns new hash with values passed from ruby
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

// Initialization
// --------------

var metaclass;

var rb_cBasicObject = new RClass(null, 'BasicObject');
var rb_cObject      = new RClass(rb_cBasicObject, 'Object');
var rb_cModule      = new RClass(rb_cObject, 'Module');
var rb_cClass       = new RClass(rb_cModule, 'Class');

rb_cObject.$c.BasicObject = rb_cBasicObject;
rb_cObject.$c.Object = rb_cObject;
rb_cObject.$c.Module = rb_cModule;
rb_cObject.$c.Class = rb_cClass;

metaclass = rb_make_metaclass(rb_cBasicObject, rb_cClass);
metaclass = rb_make_metaclass(rb_cObject, metaclass);
metaclass = rb_make_metaclass(rb_cModule, metaclass);
metaclass = rb_make_metaclass(rb_cClass, metaclass);

rb_cModule.$k.$k = metaclass;
rb_cObject.$k.$k = metaclass;
rb_cBasicObject.$k.$k = metaclass;

VM.Object = rb_cObject;

var rb_mKernel = define_module(rb_cObject, 'Kernel');

// core, non-bridged, classes
var rb_cMatch     = define_class(rb_cObject, 'MatchData', rb_cObject);
var rb_cRange     = define_class(rb_cObject, 'Range', rb_cObject);
var rb_cHash      = define_class(rb_cObject, 'Hash', rb_cObject);
var rb_cNilClass  = define_class(rb_cObject, 'NilClass', rb_cObject);

var rb_top_self = VM.top = new RObject(rb_cObject);
var NilClassProto = VM.NC = new RObject(rb_cNilClass);

// core bridged classes
var rb_cBoolean   = rb_bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
var rb_cArray     = rb_bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');
var rb_cNumeric   = rb_bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');
var rb_cString    = rb_bridge_class(String, T_OBJECT | T_STRING, 'String');
var rb_cProc      = rb_bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
var rb_cRegexp    = rb_bridge_class(RegExp, T_OBJECT, 'Regexp');
var rb_eException = rb_bridge_class(Error, T_OBJECT, 'Exception');

// other core errors and exception classes
var rb_eStandardError = define_class(rb_cObject, 'StandardError', rb_eException);
var rb_eRuntimeError  = define_class(rb_cObject, 'RuntimeError', rb_eException);
var rb_eLocalJumpError= define_class(rb_cObject, 'LocalJumpError', rb_eStandardError);
var rb_eTypeError     = define_class(rb_cObject, 'TypeError', rb_eStandardError);
var rb_eNameError     = define_class(rb_cObject, 'NameError', rb_eStandardError);
var rb_eNoMethodError = define_class(rb_cObject, 'NoMethodError', rb_eNameError);
var rb_eArgError      = define_class(rb_cObject, 'ArgumentError', rb_eStandardError);
var rb_eScriptError   = define_class(rb_cObject, 'ScriptError', rb_eException);
var rb_eLoadError     = define_class(rb_cObject, 'LoadError', rb_eScriptError);
var rb_eIndexError    = define_class(rb_cObject, 'IndexError', rb_eStandardError);
var rb_eKeyError      = define_class(rb_cObject, 'KeyError', rb_eIndexError);
var rb_eRangeError    = define_class(rb_cObject, 'RangeError', rb_eStandardError);
var rb_eNotImplError  = define_class(rb_cObject, 'NotImplementedError', rb_eException);

var rb_eBreakInstance = new Error('unexpected break');
rb_eBreakInstance.$k = rb_eLocalJumpError;
rb_eBreakInstance.$m = rb_eLocalJumpError.$m_tbl;
rb_eBreakInstance.$t = function() { throw this; };
VM.B = rb_eBreakInstance;
