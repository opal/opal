
/**
  Define a top level module with the given id
*/
function define_module(id) {
  return define_module_under(cObject, id);
};

function define_module_under(base, id) {
  var module;

  if (const_defined(base, id)) {
    module = const_get(base, id);
    if (module.$flags & T_MODULE) {
      return module;
    }

    throw new Error(id + " is not a module.");
  }

  module = define_module_id(id);

  if (base == cObject) {
    name_class(module, id);
  } else {
    name_class(module, base.__classid__ + '::' + id);
  }

  const_set(base, id, module);
  module.$parent = base;
  return module;
};

function define_module_id(id) {
  var module = class_create(cModule);
  make_metaclass(module, cModule);

  module.$flags = T_MODULE;
  module.$included_in = [];
  return module;
};

function mod_create() {
  return class_boot(cModule);
};

function include_module(klass, module) {

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
    if (module.$method_table.hasOwnProperty(method)) {
      define_raw_method(klass, method,
                        module.$m_tbl[method],
                        module.$m_tbl['$' + method]);
    }
  }

  for (var constant in module.$c) {
    if (module.$c.hasOwnProperty(constant)) {
      const_set(klass, constant, module.$c[constant]);
    }
  }
};

Rt.include_module = include_module;

function extend_module(klass, module) {
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

  var meta = klass.$klass;

  for (var method in module.$method_table) {
    if (module.$method_table.hasOwnProperty(method)) {
      define_raw_method(meta, method,
                        module.$m_tbl[method],
                        module.$m_tbl['$' + method]);
    }
  }
};

Rt.extend_module = extend_module;

