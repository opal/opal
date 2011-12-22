O = opal = {};

var VM = opal.runtime = {};

// Minify common function calls
var ArrayProto          = Array.prototype,
    ObjectProto         = Object.prototype,
    $slice = ArraySlice = ArrayProto.slice,
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
var rb_hash_yield = 0;

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

// Returns new hash with values passed from ruby
VM.hash = VM.H = function() {
  var hash   = new RubyHash.$a(), key, val, args = $slice.call(arguments);
  var assocs = hash.map = {};
  hash.none = nil;

  for (var i = 0, ii = args.length; i < ii; i++) {
    key = args[i];
    val = args[i + 1];
    i++;
    assocs[key.m$hash()] = [key, val];
  }

  return hash;
};

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
VM.jump = VM.R = function(value, func) {
  rb_eReturnInstance.$value = value;
  rb_eReturnInstance.$func  = func;

  throw rb_eReturnInstance;
};

// Get constant with given id
VM.const_get = VM.cg = function(base, id) {
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

  rb_raise(RubyNameError, 'uninitialized constant ' + id);
};

// Set constant with given id
VM.const_set = VM.cs = function(base, id, val) {
  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }

  return base.$c[id] = val;
};

// Table holds all class variables
VM.class_variables = VM.c = {};

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
VM.globals = VM.g = {};

// Define a method alias
var rb_alias_method = VM.alias = function(klass, new_name, old_name) {
  new_name = mid_to_jsid(new_name);
  old_name = mid_to_jsid(old_name);

  var body = klass.$a.prototype[old_name];

  if (!body) {
    rb_raise(RubyNameError, "undefined method `" + old_name + "' for class `" + klass.__classid__ + "'");
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

  // super uses this
  if (!body.$rbName) {
    body.$rbName = id;
  }

  klass.$a.prototype[id] = body;
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

function define_method_bridge(klass, target, id, name, filename, linenumber) {
  define_method(klass, id, function() {
    return target.apply(this, $slice.call(arguments, 1));
  }, filename, linenumber);
}

// Define multiple methods for the given bridged class
function define_bridge_methods(klass, methods) {
  var proto  = klass.$a.prototype,
      table  = klass.$m,
      bridge = klass.$bridge_prototype,
      body;

  for (var mid in methods) {
    body = proto[mid] = table[mid] = bridge[mid] = methods[mid];

    if (!body.$rbName) {
      body.$rbKlass = klass;
      body.$rbName  = mid;
    }
  }
}

// Define normal class methods
function define_methods(klass, methods) {
  var proto = klass.$a.prototype,
      table = klass.$m,
      body;

  for (var mid in methods) {
    body = proto[mid] = table[mid] = methods[mid];

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
VM.no_proc = VM.P = function() {
  rb_raise(RubyLocalJumpError, "no block given");
};

// Create a new Range instance
VM.range = VM.G = function(beg, end, exc) {
  var range         = new rb_cRange.$a();
      range.begin   = beg;
      range.end     = end;
      range.exclude = exc;

  return range;
};


function define_module(base, id) {
  var module;

  if (base.$c.hasOwnProperty(id)) {
    return base.$c[id];
  }


  module             = boot_class(rb_cModule);
  module.__classid__ = (base === rb_cObject ? id : base.__classid__ + '::' + id)

  rb_make_metaclass(module, rb_cModule);

  module.$f           = T_MODULE;
  module.$included_in = [];

  base.$c[id]    = module;
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
        define_method(klass, method, module.$m[method]);
      }
    }
  }
}

VM.define_class = function(id, superklass, base) {
  base || (base = rb_cObject);
  return define_class(base, id, superklass);
};

// VM define class. 0: regular, 1: module, 2: shift class.
VM.klass = VM.k = function(base, superklass, id, body, type) {
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

VM.slice = VM.as = $slice;

// Regexp match data
VM.match_data = VM.X = null;

VM.define_method = VM.m = define_method;

VM.define_singleton_method = VM.M = function(base, id, body) {
  return define_method(rb_singleton_class(base), id, body);
};

var define_singleton_method = VM.M;

// Undefine one or more methods
VM.undef_method = VM.um = function(klass) {
  var args = $slice.call(arguments, 1);

  for (var i = 0, length = args.length; i < length; i++) {
    var mid = args[i], id = STR_TO_ID_TBL[mid];

    klass.$m_tbl[id] = rb_make_method_missing_stub(id, mid);
  }
};

// Calls a super method.
VM.zuper = VM.S = function(callee, self, args) {
  var mid  = callee.$rbName,
      func = rb_super_find(self.$k, callee, mid);

  if (!func) {
    rb_raise(RubyNoMethodError, "super: no superclass method `" + mid + "'"
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
function rb_raise(exc, str) {
  throw exc.m$new(null, str);
}

VM.arg_error = function(given, expected) {
  rb_raise(RubyArgError, 'wrong number of arguments(' + given + ' for ' + expected + ')');
};

// Inspect object or class
function rb_inspect_object(obj) {
  if (obj.$f & T_OBJECT) {
    return "#<" + rb_class_real(obj.$k).__classid__ + ":0x" + (obj.$id * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}
