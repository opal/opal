
/**
  Define a top level module with the given id
*/
function rb_define_module(id) {
  return rb_define_module_under(rb_cObject, id);
};

function rb_define_module_under(base, id) {
  var module;

  if (rb_const_defined(base, id)) {
    module = rb_const_get(base, id);
    if (module.$flags & T_MODULE) {
      return module;
    }

    rb_raise(rb_eException, id + " is not a module");
  }

  module = rb_define_module_id(id);

  if (base == rb_cObject) {
    rb_name_class(module, id);
  } else {
    rb_name_class(module, base.__classid__ + '::' + id);
  }

  rb_const_set(base, id, module);
  module.$parent = base;
  return module;
};

function rb_define_module_id(id) {
  var module = rb_class_create(rb_cModule);
  rb_make_metaclass(module, rb_cModule);

  module.$flags = T_MODULE;
  module.$included_in = [];
  return module;
};

function rb_mod_create() {
  return rb_class_boot(rb_cModule);
};

var rb_include_module = Rt.im = function(klass, module) {

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
};

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
};

