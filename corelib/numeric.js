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
    'm$cmp$': num_cmp
  });
}
