var opal = this.opal = {};

// Minify common function calls
var ArrayProto          = Array.prototype,
    ObjectProto         = Object.prototype,
    $slice              = ArrayProto.slice,
    hasOwnProperty      = ObjectProto.hasOwnProperty;

// Types - also added to bridged objects
var T_CLASS      = 0x0001,
    T_MODULE     = 0x0002,
    T_OBJECT     = 0x0004,
    T_BOOLEAN    = 0x0008,
    T_STRING     = 0x0010,
    T_ARRAY      = 0x0020,
    T_NUMBER     = 0x0040,
    T_PROC       = 0x0080,
    T_HASH       = 0x0100,
    T_RANGE      = 0x0200,
    T_ICLASS     = 0x0400,
    FL_SINGLETON = 0x0800;

// Generates unique id for every ruby object
var unique_id = 0;

function define_attr(klass, name, getter, setter) {
  if (getter) {
    define_method(klass, mid_to_jsid(name), function() {
      var res = this[name];

      return res == null ? nil : res;
    });
  }

  if (setter) {
    define_method(klass, mid_to_jsid(name + '='), function(block, val) {
      return this[name] = val;
    });
  }
}

function define_attr_bridge(klass, target, name, getter, setter) {
  if (getter) {
    define_method(klass, mid_to_jsid(name), function() {
      var res = target[name];

      return res == null ? nil : res;
    });
  }

  if (setter) {
    define_method(klass, mid_to_jsid(name + '='), function (block, val) {
      return target[name] = val;
    });
  }
}

/**
 * Hash constructor
 */
function Hash() {
  var args    = $slice.call(arguments),
      assocs  = {},
      key;

  this.map  = assocs;
  this.none = nil;

  for (var i = 0, length = args.length; i < length; i++) {
    key = args[i];
    assocs[key.m$hash()] = [key, args[++i]];
  }

  return this;
};

// Returns new hash with values passed from ruby
opal.hash = Hash;

// Find function body for the super call
function find_super(klass, callee, mid) {
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
opal.jump = function(value, func) {
  throw new Error('jump return');
};

// Get constant with given id
opal.const_get = function(const_table, id) {
  if (const_table[id]) {
    return const_table[id];
  }

  raise(RubyNameError, 'uninitialized constant ' + id);
};

// Set constant with given id
opal.const_set = function(base, id, val) {
  if (base.$flags & T_OBJECT) {
    base = class_real(base.$klass);
  }

  return base.$const[id] = val;
};

// Table holds all class variables
opal.cvars = {};

// Array of all procs to be called at_exit
var end_procs = [];

// Call exit blocks in reverse order
opal.do_at_exit = function() {
  var proc;

  while (proc = end_procs.pop()) {
    proc.call(proc.$S);
  }
};

// Globals table
opal.gvars = {};

// Define a method alias
opal.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$allocator.prototype[old_name];

  if (!body) {
    raise(RubyNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
  }

  define_method(klass, new_name, body);
  return nil;
};

// Actually define methods
var define_method = opal.defn = function(klass, id, body) {
  // If an object, make sure to use its class
  if (klass.$flags & T_OBJECT) {
    klass = klass.$klass;
  }

  // super uses this
  if (!body.$rbName) {
    body.$rbName = id;
  }

  klass.$allocator.prototype[id] = body;
  klass.$m[id]           = body;

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
  if (klass === RubyObject) {
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

function define_method_bridge(klass, target, id, name) {
  define_method(klass, id, function() {
    return target.apply(this, $slice.call(arguments, 1));
  });
}

function string_inspect(self) {
  /* borrowed from json2.js, see file for license */
  var cx        = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
      escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
      meta      = {
        '\b': '\\b',
        '\t': '\\t',
        '\n': '\\n',
        '\f': '\\f',
        '\r': '\\r',
        '"' : '\\"',
        '\\': '\\\\'
      };

  escapable.lastIndex = 0;

  return escapable.test(self) ? '"' + self.replace(escapable, function(a) {
    var c = meta[a];

    return typeof c === 'string' ? c :
      '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
  }) + '"' : '"' + self + '"';
};

// Fake yielder used when no block given
opal.no_proc = function() {
  raise(RubyLocalJumpError, "no block given");
};

// Create a new Range instance
opal.range = function(beg, end, exc) {
  var range         = new RubyRange.$allocator();
      range.begin   = beg;
      range.end     = end;
      range.exclude = exc;

  return range;
};


function define_module(base, id) {
  var module;

  module             = boot_class(RubyModule);
  module.__classid__ = (base === RubyObject ? id : base.__classid__ + '::' + id)

  make_metaclass(module, RubyModule);

  module.$flags           = T_MODULE;
  module.$included_in = [];

  var const_alloc   = function() {};
  var const_scope   = const_alloc.prototype = new base.$const.alloc();
  module.$const     = const_scope;
  const_scope.alloc = const_alloc;

  base.$const[id]    = module;

  return module;
}

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

  for (var method in module.$m) {
    if (hasOwnProperty.call(module.$m, method)) {
      if (!klass.$allocator.prototype[method]) {
        define_method(klass, method, module.$m[method]);
      }
    }
  }
}

// opal define class. 0: regular, 1: module, 2: shift class.
opal.klass = function(base, superklass, id, body, type) {
  var klass;

  switch (type) {
    case 0:
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
      }

      if (superklass === nil) {
        superklass = RubyObject;
      }

      if (base.$const.hasOwnProperty(id)) {
        klass = base.$const[id];
      }
      else {
        klass = define_class(base, id, superklass);
      }

      break;

    case 1:
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
      }

      if (base.$const.hasOwnProperty(id)) {
        klass = base.$const[id];
      }
      else {
        klass = define_module(base, id);
      }

      break;

    case 2:
      klass = singleton_class(base);
      break;
  }

  return body(klass);
};

opal.slice = $slice;

opal.defs = function(base, id, body) {
  return define_method(singleton_class(base), id, body);
};

// Undefine one or more methods
opal.undef = function(klass) {
  var args = $slice.call(arguments, 1);

  for (var i = 0, length = args.length; i < length; i++) {
    var mid = args[i], id = mid_to_jsid[mid];

    delete klass.$m_tbl[id];
  }
};

// Calls a super method.
opal.zuper = function(callee, self, args) {
  var mid  = callee.$rbName,
      func = find_super(self.$klass, callee, mid);

  if (!func) {
    raise(RubyNoMethodError, "super: no superclass method `" + mid + "'"
             + " for " + self.$m.inspect(self, 'inspect'));
  }

  args.unshift(null);
  return func.apply(self, args);
};

function mid_to_jsid(mid) {
  if (method_names[mid]) {
    return method_names[mid];
  }

  return 'm$' + mid.replace('!', '$b').replace('?', '$p').replace('=', '$e');
}

function jsid_to_mid(jsid) {
  if (reverse_method_names[jsid]) {
    return reverse_method_names[jsid];
  }

  jsid = jsid.substr(2); // remove 'm$'

  return jsid.replace('$b', '!').replace('$p', '?').replace('$e', '=');
}

// Raise a new exception using exception class and message
function raise(exc, str) {
  throw exc.m$new(null, str);
}

opal.arg_error = function(given, expected) {
  raise(RubyArgError, 'wrong number of arguments(' + given + ' for ' + expected + ')');
};

// Inspect object or class
function inspect_object(obj) {
  if (obj.$flags & T_OBJECT) {
    return "#<" + class_real(obj.$klass).__classid__ + ":0x" + (obj.$id * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}
