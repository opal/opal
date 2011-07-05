/**
  All methods and properties available to ruby/js sources at runtime. These
  are kept in their own namespace to keep the opal namespace clean.
*/
Op.runtime = {};

// for minimizng
var Rt = Op.runtime;
Rt.opal = Op;

/**
  Opal platform - this is overriden in gem context and nodejs context. These
  are the default values used in the browser, `opal-browser'.
*/
Op.platform = {
  platform: "opal",
  engine: "opal-browser",
  version: "1.9.2",
  argv: []
};

/**
  Core runtime classes, objects and literals.
*/
var cBasicObject,     cObject,          cModule,          cClass,
    mKernel,          cNilClass,        cTrueClass,       cFalseClass,
    cArray,
    cRegexp,          cMatch,           top_self,            Qnil,
    Qfalse,           Qtrue,

    cDir;

/**
  Core object type flags. Added as local variables, and onto runtime.
*/
var T_CLASS       = Rt.T_CLASS       = 1,
    T_MODULE      = Rt.T_MODULE      = 2,
    T_OBJECT      = Rt.T_OBJECT      = 4,
    T_BOOLEAN     = Rt.T_BOOLEAN     = 8,
    T_STRING      = Rt.T_STRING      = 16,
    T_ARRAY       = Rt.T_ARRAY       = 32,
    T_NUMBER      = Rt.T_NUMBER      = 64,
    T_PROC        = Rt.T_PROC        = 128,
    T_SYMBOL      = Rt.T_SYMBOL      = 256,
    T_HASH        = Rt.T_HASH        = 512,
    T_RANGE       = Rt.T_RANGE       = 1024,
    T_ICLASS      = Rt.T_ICLASS      = 2056,
    FL_SINGLETON  = Rt.FL_SINGLETON  = 4112;

/**
  Method visibility modes
 */
var FL_PUBLIC  = 0,
    FL_PRIVATE = 1;

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
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
      }

      if (super_class == Qnil) {
        super_class = cObject;
      }

      klass = define_class_under(base, id, super_class);
      break;

    case 1:
      klass = singleton_class(base);
      break;

    case 2:
      if (base.$flags & T_OBJECT) {
        base = class_real(base.$klass);
      }
      klass = define_module_under(base, id);
      break;

    default:
      raise(eException, "define_class got a unknown flag " + flag);
  }

  // when reopening a class always set it back to public
  klass.$mode = FL_PUBLIC;

  var res = body(klass);

  return res;
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
        raise(eNoMethodError, "undefined method `" + mid + "' for " + this.m$inspect());
      };

      kls.allocator.prototype['m$' + mid] = func;

      if (kls.$bridge_prototype) {
        kls.$bridge_prototype['m$' + mid] = func;
      }
    })(args[i].m$to_s());
  }

  return Qnil;
};

/**
  Method missing support - used in debug mode (opt in).
*/
Rt.mm = function(method_ids) {
  var prototype = boot_base_class.prototype;

  for (var i = 0, ii = method_ids.length; i < ii; i++) {
    var mid = 'm$' + method_ids[i];

    if (!prototype[mid]) {
      var imp = (function(mid, method_id) {
        return function() {
          var args = [].slice.call(arguments, 0);
          args.unshift(Rt.Y(method_id));
          return this.m$method_missing.apply(this, args);
        };
      })(mid, method_ids[i]);

      imp.$rbMM = true;

      prototype[mid] = prototype['$' + mid] = imp;
    }
  }
};

/**
  Define methods. Public method for defining a method on the given base.

  @param {Object} klass The base to define method on
  @param {String} name Ruby mid
  @param {Function} public_body The method implementation
  @param {Number} arity Method arity
  @return {Qnil}
*/
Rt.dm = function(klass, name, public_body, arity) {
  if (klass.$flags & T_OBJECT) {
    klass = klass.$klass;
  }

  var mode = klass.$mode;
  var private_body = public_body;

  if (mode == FL_PRIVATE) {
    public_body = function() {
      raise(eNoMethodError, "private method `" + name +
        "' called for " + this.$m$inspect());
    };
    public_body.$arity = -1;
  }

  if (!private_body.$rbName) {
    private_body.$rbName = name;
    private_body.$rbArity = arity;
  }

  klass.$methods.push(intern(name));
  define_raw_method(klass, 'm$' + name, private_body, public_body);

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
  return Rt.dm(singleton_class(base), method_id, body);
};

/**
  Call a super method.

  callee is the function that actually called super(). We use this to find
  the right place in the tree to find the method that actually called super.
  This is actually done in super_find.
*/
Rt.S = function(callee, self, args) {
  var mid = 'm$' + callee.$rbName;
  var func = super_find(self.$klass, callee, mid);

  if (!func) {
    raise(eNoMethodError, "super: no super class method `" + mid + "`" +
      " for " + self.m$inspect());
  }

  // var args_to_send = [self].concat(args);
  var args_to_send = [].concat(args);
  return func.apply(self, args_to_send);
};

/**
  Actually find super impl to call.  Returns null if cannot find it.
*/
function super_find(klass, callee, mid) {
  var cur_method;

  while (klass) {
    if (klass.$method_table[mid]) {
      if (klass.$method_table[mid] == callee) {
        cur_method = klass.$method_table[mid];
        break;
      }
    }
    klass = klass.$super;
  }

  if (!(klass && cur_method)) { return null; }

  klass = klass.$super;

  while (klass) {
    if (klass.$method_table[mid]) {
      return klass.$method_table[mid];
    }

    klass = klass.$super;
  }

  return null;
};

/**
  Exception classes. Some of these are used by runtime so they are here for
  convenience.
*/
var eException,       eStandardError,   eLocalJumpError,  eNameError,
    eNoMethodError,   eArgError,        eScriptError,     eLoadError,
    eRuntimeError,    eTypeError,       eIndexError,      eKeyError,
    eRangeError;

var eExceptionInstance;

/**
  Standard jump exceptions to save re-creating them everytime they are needed
*/
var eReturnInstance,
    eBreakInstance,
    eNextInstance;

/**
  Ruby break statement with the given value. When no break value is needed, nil
  should be passed here. An undefined/null value is not valid and will cause an
  internal error.

  @param {RubyObject} value The break value.
*/
Rt.B = function(value) {
  eBreakInstance.$value = value;
  raise_exc(eBreakInstance);
};

/**
  Ruby return, with the given value. The func is the reference function which
  represents the method that this statement must return from.
*/
Rt.R = function(value, func) {
  eReturnInstance.$value = value;
  eReturnInstance.$func = func;
  throw eReturnInstance;
};

/**
  Get the given constant name from the given base
*/
Rt.cg = function(base, id) {
  if (base.$flags & T_OBJECT) {
    base = class_real(base.$klass);
  }
  return const_get(base, id);
};

/**
  Set constant from runtime
*/
Rt.cs = function(base, id, val) {
  if (base.$flags & T_OBJECT) {
    base = class_real(base.$klass);
  }
  return const_set(base, id, val);
};

/**
  Get global by id
*/
Rt.gg = function(id) {
  return gvar_get(id);
};

/**
  Set global by id
*/
Rt.gs = function(id, value) {
  return gvar_set(id, value);
};

function regexp_match_getter(id) {
  var matched = Rt.X;

  if (matched) {
    if (matched.$md) {
      return matched.$md;
    } else {
      var res = new cMatch.allocator();
      res.$data = matched;
      matched.$md = res;
      return res;
    }
  } else {
    return Qnil;
  }
}

