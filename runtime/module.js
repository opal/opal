function define_module(base, id) {
  var module;

  if (rb_const_defined(base, id)) {
    module = rb_const_get(base, id);
    if (module.$f & T_MODULE) {
      return module;
    }

    rb_raise(rb_eException, id + " is not a module");
  }

  module = new RClass(rb_cModule);
  rb_make_metaclass(module, rb_cModule);

  module.$f = T_MODULE;
  module.$included_in = [];

  if (base == rb_cObject) {
    module.__classid__ = id;
  } else {
    module.__classid__ = base.__classid__ + '::' + id;
  }

  rb_const_set(base, id, module);
  module.$parent = base;
  return module;
};

function rb_include_module(klass, module) {

  if (!klass.$included_modules) {
    klass.$included_modules = [];
  }

  if (klass.$included_modules.indexOf(module) != -1) {
    return;
  }
  klass.$included_modules.push(module);

  if (!module.$included_in) {
    module.$included_in = [];
  }

  module.$included_in.push(klass);

  for (var method in module.$method_table) {
    if (hasOwnProperty.call(module.$method_table, method)) {
      rb_define_raw_method(klass, method,
                        module.$m_tbl[method]);
    }
  }

  // for (var constant in module.$c) {
    // if (hasOwnProperty.call(module.$c, constant)) {
      // const_set(klass, constant, module.$c[constant]);
    // }
  // }
}

function rb_extend_module(klass, module) {
  if (!klass.$extended_modules) {
    klass.$extended_modules = [];
  }

  if (klass.$extended_modules.indexOf(module) != -1) {
    return;
  }
  klass.$extended_modules.push(module);

  if (!module.$extended_in) {
    module.$extended_in = [];
  }

  module.$extended_in.push(klass);

  var meta = klass.$k;

  for (var method in module.o$m) {
    if (hasOwnProperty.call(module.o$m, method)) {
      rb_define_raw_method(meta, method,
                        module.o$a.prototype[method]);
    }
  }
}
