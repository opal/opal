var RubyString;

function str_s_new(str) {
  return new String(str || '');
}

function str_to_s() {
  return this.toString();
}

function str_equal(other) {
  return this.valueOf() === other.valueOf();
}

function str_lt(other) {
  return this < other;
}

function str_le(other) {
  return this <= other;
}

function str_gt(other) {
  return this > other;
}

function str_ge(other) {
  return this >= other;
}

function str_plus(other) {
  return this + other;
}

function str_capitalize() {
  return this.charAt(0).toUpperCase() + this.substr(1).toLowerCase();
}

function str_downcase() {
  return this.toLowerCase();
}

function str_upcase() {
  return this.toUpperCase();
}

function str_hash() {
  return this.$f + '_' + self;
}

function str_inspect() {
  return rb_string_inspect(this);
}

function str_length() {
  return this.length;
}

function str_to_proc() {
  var str = this;
  return function(arg) {
    return arg['m$' + str]();
  }
}

function str_to_sym() {
  return this;
}

function str_reverse() {
  return this.split('').reverse().join('');
}

function str_succ() {
  return String.fromCharCode(this.charCodeAt(0));
}

function str_aref(index, length) {
  return this.substr(index, length);
}

function str_sub(pattern, replace) {
  var self = this, iterator = str_sub.proc;

  if (iterator) {
    var context = iterator.$S, val;
    str_sub.proc = 0;

    return self.replace(pattern, function(str) {
      return iterator.call(context, str);
    });
  }
  else {
    return self.replace(pattern, replace);
  }
}

function str_gsub(pattern, replace) {
  str_sub.proc = str_gsub.proc;
  str_gsub.proc = 0;

  var re = pattern.toString();
  re = re.substr(1, re.lastIndexOf('/') - 1);
  re = new RegExp(re, 'g');

  return str_sub.call(this, re, replace);
}

function str_split(split, limit) {
  return this.split(split, limit);
}

function str_cmp(other) {
  if (typeof other !== 'string') return nil;
  return self > other ? 1 : (self < other ? -1 : 0);
}

function str_match(other) {
  if (typeof other === 'string') rb_raise(rb_eTypeError, 'type mismatch: string given');
  return object.m$match$(this);
}

function str_casecmp(other) {
  if (typeof other !== 'string') return other;
  var a = this.toLowerCase(), b = other.toLowerCase();
  return a > b ? 1 : (a < b ? -1 : 0);
}

function str_empty_p() {
  return this.length === 0;
}

function str_end_with_p(suffix) {
  return this.lastIndexOf(suffix) === this.length - suffix.length;
}

function str_include_p(other) {
  return this.indexOf(other) !== -1;
}

function str_index(substr) {
  var result = this.indexOf(substr);
  return result === -1 ? nil : result;
}

function str_lstrip() {
  return this.replace(/^\s*/, '');
}

function str_to_i(base) {
  return parseInt(this, base || 10);
}

function str_to_f() {
  return parseFloat(this);
}

function str_to_s() {
  return this.toString()
}

function init_string() {
  RubyString = rb_bridge_class(String, T_OBJECT | T_STRING, 'String');
  rb_cObject.$c.Symbol = RubyString; // alias Symbol class to String

  define_singleton_method(RubyString, 'm$new', str_s_new);

  define_bridge_methods(RubyString, {
    'm$to_s': str_to_s,
    'm$eq$': str_equal,
    'm$lt$': str_lt,
    'm$le$': str_le,
    'm$gt$': str_gt,
    'm$ge$': str_ge,
    'm$plus$': str_plus,
    'm$capitalize': str_capitalize,
    'm$downcase': str_downcase,
    'm$upcase': str_upcase,
    'm$hash': str_hash,
    'm$inspect': str_inspect,
    'm$length': str_length,
    'm$to_proc': str_to_proc,
    'm$to_sym': str_to_sym,
    'm$intern': str_to_sym,
    'm$reverse': str_reverse,
    'm$succ': str_succ,
    'm$aref$': str_aref,
    'm$sub': str_sub,
    'm$gsub': str_gsub,
    'm$slice': str_aref,
    'm$split': str_split,
    'm$cmp$': str_cmp,
    'm$match$': str_match,
    'm$casecmp': str_casecmp,
    'm$empty$p': str_empty_p,
    'm$end_with$p': str_end_with_p,
    'm$eql$p': str_equal,
    'm$include$p': str_include_p,
    'm$index': str_index,
    'm$lstrip': str_lstrip,
    'm$to_i': str_to_i,
    'm$to_f': str_to_f,
    'm$to_s': str_to_s
  });
}
