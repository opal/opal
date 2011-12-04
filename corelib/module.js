function mod_eqq(object) {
  return object.m$kind_of$p(this);
}

function mod_alias_method(new_name, old_name) {
  rb_alias_method(this, new_name.m$to_s(), old_name.m$to_s());
  return this;
}

function mod_ancestors() {
  var parent = this, ancestors = [];
  while (parent) {
    if (parent.$f & FL_SINGLETON) {}
    else ancestors.push(parent);

    parent = parent.$s;
  }
  return ancestors;
}

function define_attr(klass, name, getter, setter) {
  if (getter)
    define_method(klass, mid_to_jsid(name), function() {
      var res = this[name];
      return res == null ? nil : res;
    });
  if (setter)
    define_method(klass, mid_to_jsid(name + '='), function(val) {
      return this[name] = val;
    });
}

function mod_attr_accessor() {
  var attrs = ArraySlice.call(arguments);
  for (var i = 0, length = attrs.length; i < length; i++) {
    define_attr(this, attrs[i], true, true);
  }
  return nil;
}

function mod_attr_reader() {
  var attrs = ArraySlice.call(arguments);
  for (var i = 0, length = attrs.length; i < length; i++) {
    define_attr(this, attrs[i], true, false);
  }
  return nil;
}

function mod_attr_writer() {
  var attrs = ArraySlice.call(arguments);
  for (var i = 0, length = attrs.length; i < length; i++) {
    define_attr(this, attrs[i], false, true);
  }
  return nil;
}

function mod_attr(name, setter) {
  define_attr(this, name, true, setter);
  return this;
}

function mod_append_features(mod) {
  rb_include_module(mod, this);
  return this;
}

function mod_define_method(name) {
  var self = this, iterator = mod_define_method.proc;
  if (!iterator) rb_raise(RubyLocalJumpError, 'no block given');

  mod_define_method.proc = 0;
  define_method(self, mid_to_jsid(name), iterator);
  self.$methods.push(name);

  return nil;
}

function mod_include() {
  var mods = ArraySlice.call(arguments), i = mods.length - 1, mod;
  while (i >= 0) {
    mod = mods[i];
    mod.m$append_features(this);
    mod.m$included(this);
    i--;
  }
  return this;
}

function mod_included() {
  return nil;
}

function mod_instance_methods() {
  return this.$methods;
}

function mod_class_eval() {
  var iterator = mod_class_eval.proc;
  mod_class_eval.proc = 0;
  return iterator.call(this);
}

function mod_name() {
  return this.__classid__;
}

function init_module() {
  define_methods(rb_cModule, {
    'm$eqq$': mod_eqq,
    'm$alias_method': mod_alias_method,
    'm$ancestors': mod_ancestors,
    'm$attr_accessor': mod_attr_accessor,
    'm$attr_reader': mod_attr_reader,
    'm$attr_writer': mod_attr_writer,
    'm$attr': mod_attr,
    'm$append_features': mod_append_features,
    'm$define_method': mod_define_method,
    'm$include': mod_include,
    'm$included': mod_included,
    'm$instance_methods': mod_instance_methods,
    'm$class_eval': mod_class_eval,
    'm$module_eval': mod_class_eval,
    'm$name': mod_name,
    'm$public_instance_methods': mod_instance_methods,
    'm$to_s': mod_name
  });
}
