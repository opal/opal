var RubyNumeric;

function num_plus(other) {
  return this + other;
}

function num_uplus() {
  return +this;
}

function num_minus(other) {
  return this - other;
}

function num_uminus() {
  return -this;
}

function num_times(other) {
  return this * other;
}

function num_div(other) {
  return this / other;
}

function num_pow(other) {
  return Math.pow(this, other);
}

function num_equal(other) {
  return this.valueOf() === other.valueOf();
}

function num_lt(other) {
  return this < other;
}

function num_le(other) {
  return this <= other;
}

function num_gt(other) {
  return this > other;
}

function num_ge(other) {
  return this >= other;
}

function num_cmp(other) {
  if (typeof other !== 'number') return nil;
  return self < other ? -1 : (self > other ? 1 : 0);
}

function num_mod(other) {
  return this % other;
}

function num_and(other) {
  return this & other;
}

function num_or(other) {
  return this | other;
}

function num_tild(other) {
  return ~this;
}

function num_xor(other) {
  return this ^ other;
}

function num_lshft(count) {
  return this << count;
}

function num_rshft(count) {
  return this >> count;
}

function num_abs() {
  return Math.abs(self);
}

function num_hash() {
  return this.$f + '_' + this;
}

function num_even_p() {
  return this % 2 === 0;
}

function num_odd_p() {
  return this % 2 !== 0;
}

function num_succ() {
  return this + 1;
}

function num_pred() {
  return this - 1;
}

function num_upto(finish) {
  var iterator = num_upto.proc;
  if (!iterator) return this.m$enum_for("upto", finish);

  var context = iterator.$S;
  num_upto.proc = 0;

  for (var i = this; i <= finish; i++) {
    if (iterator.call(context, i) === breaker) return breaker.$v;
  }
  return this;
}

function num_downto(finish) {
  var iterator = num_downto.proc;
  if (!iterator) return this.m$enum_for("downto", finish);

  var context = iterator.$S;
  num_downto.proc = 0;

  for (var i = this; i >= finish; i--) {
    if (iterator.call(context, i) === breaker) return breaker.$v;
  }
  return this;
}

function num_times() {
  var iterator = num_times.proc;
  if (!iterator) return this.m$enum_for("times");

  var context = iterator.$S;
  num_times.proc = 0;

  for (var i = 0; i <= this; i++) {
    if (iterator.call(context, i) === breaker) return breaker.$v;
  }
  return this;
}

function num_zero_p() {
  return this == 0;
}

function num_nonzero_p() {
  return this == 0 ? nil : self;
}

function num_ceil() {
  return Math.ceil(this);
}

function num_floor() {
  return Math.floor(this);
}

function num_int_p() {
  return this % 1 === 0;
}

function num_to_s() {
  return this.toString();
}

function num_to_i() {
  return parseInt(this);
}

function num_to_f() {
  return parseFloat(this);
}

function int_eqq(other) {
  if (typeof other !== 'number') return false;
  return other % 1 === 0;
}

function flo_eqq(other) {
  if (typeof other !== 'number') return false;
  return other % 1 !== 0;
}

function init_numeric() {
  RubyNumeric = rb_bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');

  define_bridge_methods(RubyNumeric, {
    'm$plus$': num_plus,
    'm$uplus$': num_uplus,
    'm$minus': num_minus,
    'm$uminus$': num_uminus,
    'm$mul$': num_times,
    'm$div$': num_div,
    'm$pow$': num_pow,
    'm$eq$': num_equal,
    'm$lt$': num_lt,
    'm$le$': num_le,
    'm$gt$': num_gt,
    'm$ge$': num_ge,
    'm$cmp$': num_cmp,
    'm$mod$': num_mod,
    'm$modulo': num_mod,
    'm$and$': num_and,
    'm$or$': num_or,
    'm$tild$': num_tild,
    'm$xor$': num_xor,
    'm$lshft$': num_lshft,
    'm$rshft$': num_rshft,
    'm$abs': num_abs,
    'm$magnitude': num_abs,
    'm$hash': num_hash,
    'm$even$p': num_even_p,
    'm$odd$p': num_odd_p,
    'm$next': num_succ,
    'm$succ': num_succ,
    'm$pred': num_pred,
    'm$upto': num_upto,
    'm$downto': num_downto,
    'm$times': num_times,
    'm$zero$p': num_zero_p,
    'm$nonzero$p': num_nonzero_p,
    'm$ceil': num_ceil,
    'm$floor': num_floor,
    'm$integer$p': num_int_p,
    'm$to_s': num_to_s,
    'm$inspect': num_to_s,
    'm$to_i': num_to_i,
    'm$to_f': num_to_f
  });

  RubyInteger = define_class(rb_cObject, 'Integer', RubyNumeric);
  define_singleton_method(RubyInteger, 'm$eqq$', int_eqq);

  RubyFloat = define_class(rb_cObject, 'Float', RubyNumeric);
  define_singleton_method(RubyFloat, 'm$eqq$', flo_eqq);
}
