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

function define_attr(klass, name, getter, setter) {
  if (getter)
    define_method(klass, mid_to_jsid(name), function() {
      var res = this[name];
      return res == null ? nil : res;
    });
  if (setter)
    define_method(klass, mid_to_jsid(name + '='), function(block, val) {
      return this[name] = val;
    });
}

// Find function body for the super call
function rb_super_find(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.$m[mid]) {
      if (klass.$m[mid] == callee) {
        cur_method = klass.$m[mid];
        break;
      }
    }
    klass = klass.$s;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.$s;

  while (klass) {
    if (klass.$m[mid]) {
      return klass.$m[mid];
    }

    klass = klass.$s;
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
  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }

  if (base.$c[id]) {
    return base.$c[id];
  }

  var parent = base.$parent;

  while (parent) {
    if (parent.$c[id] !== undefined) {
      return parent.$c[id];
    }

    parent = parent.$parent;
  }

  rb_raise(rb_eNameError, 'uninitialized constant ' + id);
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
    proc.call(proc.$S);
  }
};

// Globals table
VM.g = {};

// Define a method alias
var rb_alias_method = VM.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$a.prototype[old_name];

  if (!body) {
    rb_raise(rb_eNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  define_method(klass, new_name, body);
  return nil;
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

  klass.$a.prototype[id] = body;
  klass.$m[id] = body;

  var included_in = klass.$included_in, includee;

  if (included_in) {
    for (var i = 0, ii = included_in.length; i < ii; i++) {
      includee = included_in[i];

      define_method(includee, id, body);
    }
  }

  // Add method to toll-free prototypes as well
  if (klass.$bridge_prototype) {
    klass.$bridge_prototype[id] = body;
  }

  // Object donates all methods to bridged prototypes as well
  if (klass === rb_cObject) {
    var bridged = bridged_classes;

    for (var i = 0, ii = bridged.length; i < ii; i++) {
      // do not overwrite bridged impelementation
      if (!bridged[i][id]) {
        bridged[i][id] = body;
      }
    }
  }

  return nil;
}

// Define multiple methods for the given bridged class
function define_bridge_methods(klass, methods) {
  var proto = klass.$a.prototype, table = klass.$m, bridge = klass.$bridge_prototype;
  var body;

  for (var mid in methods) {
    body = methods[mid];
    proto[mid] = table[mid] = bridge[mid] = body;
    if (!body.$rbName) {
      body.$rbKlass = klass;
      body.$rbName  = mid;
    }
  }
}

// Define normal class methods
function define_methods(klass, methods) {
  var proto = klass.$a.prototype, table = klass.$m, body;
  for (var mid in methods) {
    body = methods[mid];
    proto[mid] = table[mid] = body;
    if (!body.$rbName) {
      body.$rbName  = mid;
      body.$rbKlass = klass;
    }
  }
}

// Define module specific methods
function define_module_methods(module, methods) {

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
  var range = new rb_cRange.$a();
  range.begin = beg;
  range.end = end;
  range.exclude = exc;
  return range;
};

// Root of all objects and classes inside opal
function RootObject() {};

RootObject.prototype.toString = function() {
  if (this.$f & T_OBJECT) {
    return "#<" + (this.$k).__classid__ + ":0x" + this.$id + ">";
  }
  else {
    return '<' + this.__classid__ + ' ' + this.$id + '>';
  }
};

// Boot a base class (makes instances).
function boot_defclass(superklass) {
  var cls = function() {
    this.$id = rb_hash_yield++;
    return this;
  };

  if (superklass) {
    var ctor = function() {};
    ctor.prototype = superklass.prototype;
    cls.prototype = new ctor();
  }
  else {
    cls.prototype = new RootObject();
  }

  cls.prototype.constructor = cls;
  cls.prototype.$f = T_OBJECT;
  return cls;
}

// Boot actual (meta classes) of core objects.
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.$id = rb_hash_yield++;
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.prototype;
  meta.prototype = new ctor();

  var proto = meta.prototype;
  proto.$included_in = [];
  proto.$m           = {};
  proto.$methods     = [];

  proto.$a           = klass;
  proto.$f           = T_CLASS;
  proto.__classid__  = id;
  proto.$s           = superklass;
  proto.constructor  = meta;

  // constants
  if (superklass.prototype.$constants_alloc) {
    proto.$c = new superklass.prototype.$constants_alloc();
    proto.$constants_alloc = function() {};
    proto.$constants_alloc.prototype = proto.$c;
  }
  else {
    proto.$constants_alloc = function() {};
    proto.$c = proto.$constants_alloc.prototype;
  }

  var result = new meta();
  klass.prototype.$k = result;
  return result;
}

// Create generic class with given superclass.
function boot_class(superklass) {
  // instances
  var cls = function() {
    this.$id = rb_hash_yield++;
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.$a.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.$f = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = rb_hash_yield++;
    return this;
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.$a = cls;
  proto.$f = T_CLASS;
  proto.$m = {};
  proto.$methods = [];
  proto.constructor = meta;
  proto.$s = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.$k = result;
  return result;
}

// Get actual class ignoring singleton classes and iclasses.
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) { klass = klass.$s; }
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
      var meta = boot_class(superklass);
      meta.__classid__ = class_id;

      meta.$a.prototype = klass.constructor.prototype;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classname__ = klass.__classid__;
      klass.$k = meta;
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
  var klass = boot_class(orig_class);
  klass.__classid__ = class_id;

  klass.$f |= FL_SINGLETON;
  klass.$bridge_prototype = obj;

  obj.$k = klass;

  klass.__attached__ = obj;

  klass.$k = rb_class_real(orig_class).$k;

  return klass;
}

var bridged_classes = []

function rb_bridge_class(constructor, flags, id) {
  var klass = define_class(rb_cObject, id, rb_cObject);
  var prototype = constructor.prototype;

  klass.$bridge_prototype = prototype;
  bridged_classes.push(prototype);

  prototype.$k = klass;
  prototype.$f = flags;

  return klass;
}

// Define new ruby class
function define_class(base, id, superklass) {
  var klass;

  if (base.$c.hasOwnProperty(id)) {
    return base.$c[id];
  }

  var class_id = (base === rb_cObject ? id : base.__classid__ + '::' + id);

  klass = boot_class(superklass);
  klass.__classid__ = class_id;
  rb_make_metaclass(klass, superklass.$k);

  base.$c[id] = klass;
  klass.$parent = base;

  if (superklass.m$inherited) {
    superklass.m$inherited(klass);
  }

  return klass;
}

// Get singleton class of obj
function rb_singleton_class(obj) {
  var klass;

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
    return base.$c[id];
  }


  module = boot_class(rb_cModule);
  module.__classid__ = (base === rb_cObject ? id : base.__classid__ + '::' + id)

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

  for (var method in module.$m) {
    if (hasOwnProperty.call(module.$m, method)) {
      if (!klass.$a.prototype[method]) {
        define_method(klass, method,
                        module.$m[method]);
      }
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
  rb_top_self.m$require(id);
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

VM.define_class = function(id, superklass, base) {
  base || (base = rb_cObject);
  return define_class(base, id, superklass);
};

// VM define class. 0: regular, 1: module, 2: shift class.
VM.k = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    case 0:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      if (superklass === nil) {
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
VM.define_method = define_method;

VM.M = function(base, id, body) {
  return define_method(rb_singleton_class(base), id, body);
};

var define_singleton_method = VM.M;

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

  return func.apply(self, args);
};

function mid_to_jsid(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return 'm$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

function rb_method_missing_caller(recv, id) {
  var proto = recv == null ? NilClassProto : recv;
  var meth = mid_to_jsid[id];
  var func = proto.$m[mid_to_jsid('method_missing')];
  var args = [recv, 'method_missing', meth].concat(ArraySlice.call(arguments, 2));
  return func.apply(null, args);
}
