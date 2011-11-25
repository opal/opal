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

  args.unshift(mid);
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
