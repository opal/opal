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
var rb_cBasirb_cObject,     rb_cObject,          rb_cModule,          rb_cClass,
    rb_mKernel,          rb_cNilClass,        rb_cBoolean,
    rb_cArray,           rb_cNumeric,
    rb_cRegexp,          rb_cMatch,           rb_top_self,            Qnil,

    rb_cDir;

/**
  Core object type flags. Added as local variables, and onto runtime.
*/
var T_CLASS       = 1,
    T_MODULE      = 2,
    T_OBJECT      = 4,
    T_BOOLEAN     = 8,
    T_STRING      = 16,
    T_ARRAY       = 32,
    T_NUMBER      = 64,
    T_PROC        = 128,
    T_SYMBOL      = 256,
    T_HASH        = 512,
    T_RANGE       = 1024,
    T_ICLASS      = 2056,
    FL_SINGLETON  = 4112;

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
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      if (super_class == Qnil) {
        super_class = rb_cObject;
      }

      klass = rb_define_class_under(base, id, super_class);
      break;

    case 1:
      klass = rb_singleton_class(base);
      break;

    case 2:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }
      klass = rb_define_module_under(base, id);
      break;

    default:
      rb_raise(rb_eException, "define_class got a unknown flag " + flag);
  }

  var res = body(klass);

  return res;
};

/**
  Dynamic method invocation. This is used for calling dynamic methods,
  usually in debug mode. It will call method_missing if the given method
  is not present on the receiver.

  Note: mid includes 'm$' as a prefix, so it is not needed to add to the
  method name. It needs to be removed before calling method missing.

  The rest of the args are addition parameters for the method.

  @param [Object] recv the receiver to call
  @param [String] mid the method id to call (with 'm$')
  @return [Object] method result.
*/
Rt.sm = function(recv, mid) {
  var method = recv[mid];

  if (method) {
    return method.apply(recv, ArraySlice.call(arguments, 2));
  }

  var missing = recv['m$method_missing'];

  if (missing) {
    return missing.apply(recv, [mid.substr(2)].concat(ArraySlice.call(arguments, 2)));
  }

  throw new Error("Cannot call method missing: " + mid);
};

/**
  Register instance variables accessed for the class given by `klass`. This
  method will set all these variables to `nil` on the allocators prototype.

  Also, if this is a method then they must be stored on $iv so that when it is
  included into another module/class then these ivars will also be copied.

  @param [Array<String>] ivars array of ivar names.
*/
Rt.iv = function(klass, ivars) {
  var proto = klass.$a.prototype;

  for (var i = 0, ii = ivars.length; i < ii; i++) {
    proto[ivars[i]] = Qnil;
  }

  klass.$iv = klass.$iv.concat(ivars);
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
Rt.dm = function(klass, name, body, arity) {
  if (klass.$f & T_OBJECT) {
    klass = klass.$k;
  }

  if (!body.$rbName) {
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
  return Rt.dm(rb_singleton_class(base), method_id, body);
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
      " for " + self.m$inspect());
  }

  // var args_to_send = [self].concat(args);
  var args_to_send = [].concat(args);
  return func.apply(self, args_to_send);
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
    rb_eRangeError;

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
var rb_end_procs = [];

/**
  Called upon exit: we need to run all of our registered procs
  in reverse order: i.e. call last ones first.

  FIXME: do we need to try/catch this??
*/
Rt.do_at_exit = function() {
  var proc;

  while (proc = rb_end_procs.pop()) {
    proc.call(proc.$self);
  }

  return null;
};

