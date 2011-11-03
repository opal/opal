/**
  All 'vm' methods and properties stored here. These are available to ruby
  sources at runtime through the +VM+ js variable.

  Not really a VM, more like a collection of useful functions/methods.
*/
var VM = Rt;

VM.opal = Op;

/**
  Define a class.

      VM.dc(self, VM.Object, 'Subclass', function(self) { ... });

  Returns last statement evaluated in the body.

  @param {RObject} base
  @param {RClass} superklass
  @param {String} id
  @param {Function} body
  @return {Object}
*/
VM.dc = function(base, superklass, id, body) {
  var klass;

  if (base.$flags & T_OBJECT) {
    base = rb_class_real(base.$klass);
  }

  if (superklass == null) {
    superklass = rb_cObject;
  }

  klass = rb_define_class_under(base, id, superklass);

  return body(klass);
};

VM.define_class = rb_define_class;

/**
  Define a module.

      module Kernel
        # ...
      end

  Will compile into:

      VM.md(self, 'Kernel', function(self) { return nil; });

  Returns last statement evaluated in body.

  @param {RObject} base
  @param {String} id
  @param {Function} body
  @return {Object}
*/
VM.md = function(base, id, body) {
  var klass;

  if (base.$flags & T_OBJECT) {
    base = rb_class_real(base.$klass);
  }

  klass = rb_define_module_under(base, id);

  return body(klass);
};

VM.define_module = rb_define_module;

/**
  'Shift-class' to evaluate in the singleton class of the given +obj+.

  @param {RObject} base
  @param {Function} body
  @return {RObject}
*/
VM.sc = function(base, body) {
  return body(rb_singleton_class(base));
};

/**
  Method missing register - used to register fake methods to make the
  method_missing system work.

  @param {Array<String>} methods an array of strings
*/
VM.mm = function(methods) {
  var tbl = rb_cBasicObject.$m_tbl, method;

  for (var i = 0, ii = methods.length; i < ii; i++) {
    method = methods[i];

    if (!tbl[method]) {
      tbl[method] = rb_method_missing_caller;
    }
  }
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
  Symbol creation.

  Usage:

      VM.Y('foo')
      # => :foo

  @param {String} id
  @return {Symbol}
*/
VM.Y = rb_symbol;

/**
  Returns an array of all symbols created inside opal.

  @return {Array<Symbol>}
*/
VM.symbols = function() {
  var symbols = [];

  for (var sym in rb_symbol_tbl) {
    if (rb_symbol_tbl.hasOwnProperty(sym)) {
      symbols.push(rb_symbol_tbl[sym]);
    }
  }

  return symbols;
};

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
VM.dm = VM.define_method = function(klass, id, body) {
  // if an object, make sure to use its class
  if (klass.$flags & T_OBJECT) {
    klass = klass.$klass;
  }

  // add useful debug info
  if (!body.$rbName) {
    body.$rbKlass = klass;
    body.$rbName  = id;
  }

  rb_define_raw_method(klass, id, body);
  klass.$methods.push(id);

  return null;
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
    klass.$m_tbl[args[i]] = rb_method_missing_caller;
  }

  return null;
};

/**
  Define a singleton method on the receiver.

  Usage:

      VM.dc(rb_cObject, 'foo', function() { ... });

  @param {RObject} base
  @param {String} name
  @param {Function} body
  @return {nil}
*/
VM.ds = rb_define_singleton_method;

/**
  Calls a super method.

  @param {Function} callee current method calling super()
  @param {RObject} self self value calling super()
  @param {Array} args arguments to pass to super
  @return {RObject} return value from call
*/
VM.S = function(callee, self, args) {
  var mid = callee.$rbName;
  var func = rb_super_find(self.$klass, callee, mid);

  if (!func) {
    rb_raise(rb_eNoMethodError, "super: no superclass method `" + mid + "'"
             + " for " + self.$m.inspect(self, 'inspect'));
  }

  var send_args = [self, mid].concat(args);
  return func.apply(null, send_args);
};

/**
  Will cause a ruby break statement with the given value.

  @param {RObject} value
*/
VM.B = function(value) {
  rb_eBreakInstance.$value = value;
  rb_raise_exc(rb_eBreakInstance);
};

