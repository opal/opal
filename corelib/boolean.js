var RubyBoolean, RubyTrueClass, RubyFalseClass;

function bool_to_s() {
  return this.valueOf() ? 'true' : 'false';
}

function bool_equal(other) {
  return this.valueOf() === other.valueOf();
}

function bool_class() {
  return this.valueOf() ? RubyTrueClass : RubyFalseClass;
}

function bool_and(other) {
  return this.valueOf() ? (other !== false && other !== nil) : false;
}

function bool_or(other) {
  return this.valueOf() ? true : (other !== false && other !== nil);
}

function bool_xor(other) {
  return this.valueOf() ? (other === false || other === nil) : (other !== false && other !== nil);
}

function true_eqq(obj) {
  return obj === true;
}

function false_eqq(obj) {
  return obj === false;
}

function init_boolean() {
  RubyBoolean     = rb_bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
  RubyTrueClass   = define_class(rb_cObject, 'TrueClass', rb_cObject);
  RubyFalseClass  = define_class(rb_cObject, 'FalseClass', rb_cObject);

  define_bridge_methods(RubyBoolean, {
    'm$to_s': bool_to_s,
    'm$eq$': bool_equal,
    'm$class': bool_class,
    'm$and$': bool_and,
    'm$or$': bool_or,
    'm$xor$': bool_xor
  });

  define_singleton_method(RubyTrueClass, 'm$eqq$', true_eqq);
  define_singleton_method(RubyFalseClass, 'm$eqq$', false_eqq);

  rb_cObject.$c.TRUE = true;
  rb_cObject.$c.FALSE = false;
}
