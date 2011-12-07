var RubyKernel;

function obj_hash() {
  return this.$id;
}

function obj_match() {
  return false;
}

function obj_id() {
  return this.$id || (this.$id = rb_hash_yield++);
}

function obj_class() {
  return rb_class_real(this.$k);
}

function obj_define_singleton_method(name) {
  var iterator = obj_define_singleton_method.proc;
  if (!iterator) return rb_raise(rb_eLocalJumpError, 'no block given');

  obj_define_singleton_method.proc = 0;
  VM.ds(this, name, iterator);
  return this;
}

function obj_extend() {
  var mods = ArraySlice.call(arguments);
  for (var i = 0, length = mods.length; i < length; i++) {
    rb_extend_module(rb_singleton_class(this), mods[i]);
  }
  return this;
}

function obj_ivar_defined(name) {
  return this.hasOwnProperty(name.substr(1));
}

function obj_ivar_get(name) {
  var ivar = this[name.substr(1)];
  return ivar == undefined ? nil : ivar;
}

function obj_ivar_set(name, val) {
  return this[name.substr(1)] = val;
}

function obj_instance_variables() {
  var ivars = [];
  for (var ivar in this) ivars.push(ivar);
  return ivars;
}

function obj_instance_of(klass) {
  return this.$k === klass;
}

function obj_kind_of(klass) {
  var search = this.$k;
  while (search) {
    if (search === klass) return true;
    search = search.$s;
  }
  return false;
}

function obj_nil_p() {
  return false;
}

function obj_puts() {
  var strs = ArraySlice.call(arguments), out = VM.g.$stdout;
  out.m$puts.apply(out, strs);
  return nil;
}

function obj_print() {
  var strs = ArraySlice.call(arguments), out = VM.g.$stdout;
  out.m$print.apply(out, strs);
  return nil;
}

function obj_respond_to(name) {
  var meth = this[mid_to_jsid(name)];
  if (meth && !meth.method_missing) return true;
  return false;
}

function obj_eqq(other) {
  return this == other;
}

function obj_equals(other) {
  return this === other;
}

function obj_singleton_class() {
  return rb_singleton_class(this);
}

function obj_rand(max) {
  return max === undefined ? Math.random() : Math.floor(Math.random() * max);
}

function obj_to_s() {
  return rb_inspect_object(this);
}

function obj_inspect() {
  return this.m$to_s();
}

function obj_raise(exception, string) {
  var msg, exc;
  if (typeof exception === 'string') {
    exc = RubyRuntimeError.m$new(exception);
  }
  else if (exception.m$is_a$p(RubyException)) {
    exc = exception;
  }
  else {
    if (string !== undefined) msg = string;
    exc = exception.m$new(msg);
  }
  throw exc;
}

function obj_require(path) {
  var resolved = rb_find_lib(path);
  if (!resolved) rb_raise(rb_eLoadError, 'no such file to load -- ' + path);
  if (LOADER_CACHE[resolved]) return false;
  LOADER_CACHE[resolved] = true;
  LOADER_FACTORIES[resolved](rb_top_self, resolved);
  return true;
}

function obj_loop() {
  var iterator = obj_loop.proc;
  if (!iterator) return this.m$enum_for("loop");

  var context = iterator.$s;
  obj_loop.proc = 0;

  while (true) {
    if (iterator.call(context) === breaker) return breaker.$v;
  }
  return this;
}

function obj_at_exit() {
  var iterator = obj_at_exit.proc;
  if (!iterator) rb_raise(RubyArgError, 'called without a block');
  obj_at_exit.proc = 0;
  rb_end_procs.push(iterator);
  return iterator;
}

function obj_proc() {
  var iterator = obj_proc.proc;
  if (!iterator) rb_raise(RubyArgError, 'tried to create Proc object without a block');
  obj_proc.proc = 0;
  return obj_proc;
}

function obj_lambda() {
  var iterator = obj_lambda.proc;
  if (!iterator) rb_raise(RubyArgError, 'tried to create a Proc object without a block');
  obj_lambda.proc = 0;
  if (iterator.$lambda) return iterator;

  var wrap = function() {
    return iterator.apply(iterator.$S, ArraySlice.call(arguments));
  };
  wrap.$lambda = true;
  wrap.$S = iterator.$S
  return wrap;
}

function obj_tap() {
  var iterator = obj_tap.proc;
  if (!iterator) rb_raise(RubyLocalJumpError, 'no block given');
  obj_tap.proc = 0;

  if (iterator.call(iterator.$S, this) === breaker) return breaker.$v;
  return this;
}

function init_object() {
  RubyKernel = define_module(rb_cObject, 'Kernel');

  define_method(RubyKernel, 'm$hash', obj_hash);
  define_method(RubyKernel, 'm$match$', obj_match);
  define_method(RubyKernel, 'm$object_id', obj_id);
  define_method(RubyKernel, 'm$class', obj_class);
  define_method(RubyKernel, 'm$define_singleton_method', obj_define_singleton_method);
  define_method(RubyKernel, 'm$extend', obj_extend);
  define_method(RubyKernel, 'm$instance_variable_defined$p', obj_ivar_defined);
  define_method(RubyKernel, 'm$instance_variable_get', obj_ivar_get);
  define_method(RubyKernel, 'm$instance_variable_set', obj_ivar_set);
  define_method(RubyKernel, 'm$instance_variables', obj_instance_variables);
  define_method(RubyKernel, 'm$instance_of$p', obj_instance_of);
  define_method(RubyKernel, 'm$kind_of$p', obj_kind_of);
  define_method(RubyKernel, 'm$is_a$p', obj_kind_of);
  define_method(RubyKernel, 'm$nil$p', obj_nil_p);
  define_method(RubyKernel, 'm$puts', obj_puts);
  define_method(RubyKernel, 'm$print', obj_print);
  define_method(RubyKernel, 'm$respond_to$p', obj_respond_to);
  define_method(RubyKernel, 'm$eqq$', obj_eqq);
  define_method(RubyKernel, 'm$equal$p', obj_equals);
  define_method(RubyKernel, 'm$singleton_class', obj_singleton_class);
  define_method(RubyKernel, 'm$rand', obj_rand);
  define_method(RubyKernel, 'm$to_s', obj_to_s);
  define_method(RubyKernel, 'm$inspect', obj_inspect);
  define_method(RubyKernel, 'm$raise', obj_raise);
  define_method(RubyKernel, 'm$fail', obj_raise);
  define_method(RubyKernel, 'm$require', obj_require);
  define_method(RubyKernel, 'm$loop', obj_loop);
  define_method(RubyKernel, 'm$at_exit', obj_at_exit);
  define_method(RubyKernel, 'm$proc', obj_proc);
  define_method(RubyKernel, 'm$lambda', obj_lambda);
  define_method(RubyKernel, 'm$tap', obj_tap);
}
