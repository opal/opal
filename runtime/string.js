function rb_str_to_s(str) {
  return str.toString();
}

function rb_sym_to_s(sym) {
  return sym.toString();
}

function Init_String() {
  rb_define_method(rb_cString, "to_s", rb_str_to_s);
  rb_define_method(rb_cSymbol, "to_s", rb_sym_to_s);
}
