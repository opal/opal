/**
  All methods and properties available to ruby/js sources at runtime. These
  are kept in their own namespace to keep the opal namespace clean.
*/
var Rt = Op.runtime = {};

Rt.opal = Op;

/**
  Opal platform - this is overriden in gem context and nodejs context. These
  are the default values used in the browser, `opal-browser'.
*/
var PLATFORM_PLATFORM = "opal";
var PLATFORM_ENGINE   = "opal-browser";
var PLATFORM_VERSION  = "1.9.2";
var PLATFORM_ARGV     = [];

// Minimize js types
var ArrayProto     = Array.prototype,
    ObjectProto    = Object.prototype,

    ArraySlice     = ArrayProto.slice,

    hasOwnProperty = ObjectProto.hasOwnProperty;

/**
  Core runtime classes, objects and literals.
*/
var rb_cBasicObject,  rb_cObject,       rb_cModule,       rb_cClass,
    rb_cNativeObject, rb_mKernel,       rb_cNilClass,     rb_cBoolean,
    rb_cArray,        rb_cNumeric,      rb_cString,       rb_cSymbol,
    rb_cRegexp,       rb_cMatch,        rb_top_self,      Qnil,
    rb_cDir;

/**
  Special objects' prototypes.. saves allocating them each time they
  are needed.
*/
var NativeObjectProto, NilClassProto;

/**
  Core object type flags. Added as local variables, and onto runtime.
*/
var T_CLASS       = 0x0001,
    T_MODULE      = 0x0002,
    T_OBJECT      = 0x0004,
    T_BOOLEAN     = 0x0008,
    T_STRING      = 0x0010,
    T_ARRAY       = 0x0020,
    T_NUMBER      = 0x0040,
    T_PROC        = 0x0080,
    T_SYMBOL      = 0x0100,
    T_HASH        = 0x0200,
    T_RANGE       = 0x0400,
    T_ICLASS      = 0x0800,
    FL_SINGLETON  = 0x1000;

/**
  Define a class

  @param {RubyObject} base
  @param {RClass} super_class
  @param {String} id
  @param {Function} body
*/
Rt.dc = function(base, super_class, id, body) {
  var klass;

  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }

  if (super_class === Qnil) {
    super_class = rb_cObject;
  }

  klass = rb_define_class_under(base, id, super_class);

  return body(klass);
};

/**
  Define modules
*/
Rt.md = function(base, id, body) {
  var klass;

  if (base.$f & T_OBJECT) {
    base = rb_class_real(base.$k);
  }

  klass = rb_define_module_under(base, id);

  return body(klass);
};

/*
  Shift class
*/
Rt.sc = function(base, body) {
  // native class <<
  if (!base.$k || (typeof(base)=="function" && !base.$S)) {
    base.$k = rb_cNativeClassShift;
    rb_cNativeClassShift.$k.$a.prototype = base;
    rb_cNativeClassShift.$a.prototype = base.prototype;
    base.$f = T_OBJECT;
    var res = body(base);
    delete base.$k;
    delete base.$f;

    return res;
  }

  return body(rb_singleton_class(base));
};

/**
  Method missing support.

  If the receiver doesnt respond to #method_missing, then it must
  be a native js object as the VM is hardcoded to ensure every true
  ruby object responds to method_missing.

  If the receiver is null, then method_missing from NilClass should be
  used.

  Otherwise method_missing is called as normal.
*/
Rt.mm = function(recv, mid) {
  var args = ArraySlice.call(arguments, 2), tbl;

  if (recv != null && !recv.$k) {
    if (NativeObjectProto['m$' + mid]) {
      return NativeObjectProto['m$' + mid].apply(null, [recv, mid].concat(args));
    }

    var ref = recv[mid];

    if (typeof ref !== 'function') {
      rb_raise(rb_eNoMethodError, "undefined method `" + mid + "` for "
               + "#<NativeObject: " + recv.toString() + ">");
    }
    else {
      return ref.apply(recv, args);
    }
  }

  return recv.m$method_missing(recv, "method_missing", mid);
  // throw new Error("method missing for " + mid);
};

/**
  Method missing dispatcher for methods taking 0 arguments.

  Eg:

      foo.bar
      baz.biz()

  This function will then look at the receiver, and if it is a
  nativeobject then it will just return the literal property with
  the method id. If the property is a function then it is called
  with 0 arguments.

  If the receiver is a true ruby object then
  method_missing is called on it. The receiver may be nil.
*/
Rt.mn = function(recv, mid) {
  if (recv != Qnil && !recv.$k) {
    // if NativeObject (or BasicObject) define a matching method,
    // then call that - it gives us some useful methods.
    if (NativeObjectProto['m$' + mid]) {
      return NativeObjectProto['m$' + mid](recv, mid);
    }
    if (typeof recv[mid] === 'function') {
      return recv[mid]();
    }
    else {
      return recv[mid];
    }
  }

  throw new Error("need method missing in MN");
};

/**
  Method missing dispatcher for method calls which are setters.

  Eg:

    foo.bar = baz

  Will disptach to this function. We know then how to handle outcomes;
  If the receiver is a native object then do a literal property set, if
  not then we must dispatch method_missing to a real ruby object which
  may be nil.

  NOTE: +mid+ will be the setter id, i.e. the method name excluding
  '='. This makes it easier/faster to do property access. When resorting
  to passing the method onto method_missing, the '=' is then added
  before sending.

  @param {Object} recv object message sent to
  @param {String} mid method id sent, excluding '=' suffix
  @param {Object} arg assignable arg. We will only ever have 1 arg
*/
Rt.ms = function(recv, mid, arg) {
  var arg = arguments[2];

  if (recv != Qnil && !recv.$k) {
    return recv[mid] = arg;
  }
  else {
    var tbl = (recv == Qnil ? NilClassProto : recv), meth;

    meth = tbl.m$method_missing || NativeObjectProto.m$method_missing;

    return meth(recv, 'method_missing', mid + '=', arg);
  }
};

/**
  @param [Array<String>] ivars array of ivar names.
*/
Rt.iv = function(ivars) {
  var proto = rb_boot_root.prototype;

  for (var i = 0, ii = ivars.length; i < ii; i++) {
    proto[ivars[i]] = Qnil;
  }
};

/**
  Expose Array.prototype.slice to the runtime. This saves generating
  lots of code each time.
*/
Rt.as = ArraySlice;

/**
  Regexp object. This holds the results of last regexp match.
  X for regeXp.
*/
Rt.X = null;

/**
  Symbol table - all created symbols are stored here, symbol id =>
  symbol literal.
*/
var rb_symbol_tbl = {};

/**
  Symbol creation. Checks the symbol table and creates a new symbol
  if one doesnt exist for the given id, otherwise returns existing
  one.

  @param {String} id symbol id
  @return {Symbol}
*/
var rb_intern = Rt.Y = function(id) {
  var sym = rb_symbol_tbl[id];

  if (!sym) {
    sym = new rb_cSymbol.$a();
    sym.sym = id;
  }

  return sym;
};

/**
  Undefine methods
*/
Rt.um = function(kls) {
  var args = [].slice.call(arguments, 1);

  for (var i = 0, ii = args.length; i < ii; i++) {
    (function(mid) {
      var func = function() {
        rb_raise(rb_eNoMethodError, "undefined method `" + mid + "' for " + this.m$inspect());
      };

      kls.o$a.prototype['m$' + mid] = func;

    })(args[i].m$to_s());
  }

  return Qnil;
};

/**
  Define methods. Public method for defining a method on the given base.

  @param {Object} klass The base to define method on
  @param {String} name Ruby mid
  @param {Function} body The method implementation
  @param {Number} arity Method arity
  @return {Qnil}
*/
var rb_define_method = Rt.dm = function(klass, name, body, arity) {
  if (klass.$f & T_OBJECT) {
    klass = klass.$k;
  }

  if (!body.$rbName) {
    body.$rbKlass = klass;
    body.$rbName = name;
    body.$arity = arity;
  }

  rb_define_raw_method(klass, 'm$' + name, body);
  klass.$methods.push(name);

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
  return Rt.dm(rb_singleton_class(base), method_id, body, arity);
};

/**
  Call a super method.

  callee is the function that actually called super(). We use this to find
  the right place in the tree to find the method that actually called super.
  This is actually done in super_find.
*/
Rt.S = function(callee, self, args) {
  var mid = 'm$' + callee.$rbName;
  var func = rb_super_find(self.$k, callee, mid);

  if (!func) {
    rb_raise(rb_eNoMethodError, "super: no super class method `" + mid + "`" +
      " for " + self.m$inspect(self));
  }

  // var args_to_send = [self].concat(args);
  var args_to_send = [self, callee.$rbName].concat(args);
  return func.apply(null, args_to_send);
};

/**
  Actually find super impl to call.  Returns null if cannot find it.
*/
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

  return null;
};

/**
  Exception classes. Some of these are used by runtime so they are here for
  convenience.
*/
var rb_eException,       rb_eStandardError,   rb_eLocalJumpError,  rb_eNameError,
    rb_eNoMethodError,   rb_eArgError,        rb_eScriptError,     rb_eLoadError,
    rb_eRuntimeError,    rb_eTypeError,       rb_eIndexError,      rb_eKeyError,
    rb_eRangeError,      rb_eNotImplementedError;

var rb_eExceptionInstance;

/**
  Standard jump exceptions to save re-creating them everytime they are needed
*/
var rb_eReturnInstance,
    rb_eBreakInstance,
    rb_eNextInstance;

/**
  Ruby break statement with the given value. When no break value is needed, nil
  should be passed here. An undefined/null value is not valid and will cause an
  internal error.

  @param {RubyObject} value The break value.
*/
Rt.B = function(value) {
  rb_eBreakInstance.$value = value;
  rb_raise_exc(rb_eBreakInstance);
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
  // make sure we dont fail if it turns out our base is null or a js obj
  if (base == null || !base.$f) {
    base = rb_cObject;
  }

  if (base.$f & T_OBJECT) {
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
  Get global by id
*/
Rt.gg = function(id) {
  return rb_gvar_get(id);
};

/**
  Set global by id
*/
Rt.gs = function(id, value) {
  return rb_gvar_set(id, value);
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

function rb_regexp_match_getter(id) {
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
  An array of procs to call for at_exit()

  @param {Function} proc implementation
*/
var rb_end_procs = Rt.end_procs = [];

/**
  Called upon exit: we need to run all of our registered procs
  in reverse order: i.e. call last ones first.

  FIXME: do we need to try/catch this??
*/
Rt.do_at_exit = function() {
  Op.run(function() {
    var proc;

    while (proc = rb_end_procs.pop()) {
      proc(proc.$S, Qnil);
    }

    return null;
  });
};

