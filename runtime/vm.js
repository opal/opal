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

      klass = rb_define_class_under(base, id, superklass);
      break;

    // module
    case 1:
      if (base.$f & T_OBJECT) {
        base = rb_class_real(base.$k);
      }

      klass = rb_define_module_under(base, id);
      break;

    // shift class
    case 2:
      klass = rb_singleton_class(base);
      break;
  }

  return body.call(klass);
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

/**
  Define a method.

  These definitions come from generated code, so the passed in ID
  will be a ruby id, not a real method name, so we can just define
  it using the required id.

  Usage:

      VM.dm(rb_cObject, 'id', function() { ... });

  @param {RObject} klass
  @param {String} id Opal id
  @param {Function} body
  @return {nil}
*/
VM.dm = VM.define_method = rb_define_raw_method;

/**
  Undefine the given methods from the receiver klass.

  Usage:

      VM.um(rb_cObject, 'foo', 'bar', 'baz');

  @param {RClass} klass
*/
VM.um = function(klass) {
  var args = ArraySlice.call(arguments, 1);

  for (var i = 0, ii = args.length; i < ii; i++) {
    klass.$m_tbl[args[i]] = rb_method_missing_caller;
  }

  return null;
};

/**
  Define a singleton method on the receiver.

  Usage:

      VM.dc(rb_cObject, 'foo', function() { ... });

  @param {RObject} base
  @param {String} id
  @param {Function} body
  @return {nil}
*/
VM.ds = function(base, id, body) {
  return VM.dm(rb_singleton_class(base), id, body);
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

  return func.apply(self, args);
};

/**
  Will cause a ruby break statement with the given value.

  @param {RObject} value
*/
VM.B = function(value) {
  rb_eBreakInstance.$value = value;
  throw rb_eBreakInstance;
};

