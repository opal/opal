var RubyNilClass, nil;

function nil_nil_p() {
  return true;
}

function nil_equal(other) {
  return this === other;
}

function nil_and() {
  return false;
}

function nil_or(other) {
  return other !== false && other !== nil;
}

function nil_xor(other) {
  return other !== false && other !== nil;
}

function nil_inspect() {
  return 'nil';
}

function nil_to_i() {
  return 0;
}

function nil_to_f() {
  return 0.0;
}

function nil_to_s() {
  return '';
}

function nil_to_a() {
  return [];
}

function init_nil() {
  RubyNilClass = define_class(rb_cObject, 'NilClass', rb_cObject);
  nil = VM.nil = new RubyNilClass.$a();

  define_methods(RubyNilClass, {
    'm$nil$p': nil_nil_p,
    'm$eq$': nil_equal,
    'm$and$': nil_and,
    'm$or$': nil_or,
    'm$xor$': nil_xor,
    'm$inspect': nil_inspect,
    'm$to_i': nil_to_i,
    'm$to_f': nil_to_f,
    'm$to_s': nil_to_s,
    'm$to_a': nil_to_a
  });

  rb_cObject.$c.NIL = nil;
}
