function rb_obj_dummy() {
  return null;
}

function rb_class_s_new(cls, _, sup) {
  sup = sup || rb_cObject;
  var block = rb_class_s_new.$B;

  var klass = rb_define_class_id('AnonClass', sup);

  if (sup.$m.inherited) {
    sup.$m.inherited(sup, 'inherited', klass);
  }

  if (block) {
    block(klass, null);
  }

  return klass;
}

/**
 * :call-seq:
 *  class.allocate()    -> obj
 */
function rb_obj_alloc(cls) {
  return new RObject(cls);
}

/**
 * :call-seq:
 *    class.new()      -> obj
 */
function rb_class_new_instance(cls, mid, args) {
  args = ArraySlice.call(arguments, 2);

  var block;

  var obj = cls.$m.allocate(cls, "allocate");
  var init = obj.$m.initialize;

  if (block = rb_class_new_instance.$B) {
    rb_class_new_instance.$B = null;
    init.$B = block;
  }

  init.apply(null, [obj, "initialize"].concat(args));

  return obj;
}

/**
 * :call-seq:
 *    class.superclass  -> a_super_class or nil
 */
function rb_class_superclass(klass) {
  var sup = klass.$super;

  if (!sup) {
    if (klass === rb_cBasicObject) {
      return null;
    }

    rb_raise(rb_eRuntimeError, "uninitialized class");
  }

  return sup;
}

/**
 * :call-seq:
 *    class.from_native(object)     -> object
 *
 * Returns the given +object+, adding the neccessary properties to make
 * it a true instance of the receiver class.
 *
 *    a = Object.from_native(`console`)     # => #<Object:0x00000>
 *    a.class     # => Object
 */
function rb_class_from_native(klass, mid, object) {
  return rb_from_native(klass, object);
}

function Init_Object() {
  rb_define_singleton_method(rb_cClass, "new", rb_class_s_new);
  rb_define_method(rb_cClass, "allocate", rb_obj_alloc);
  rb_define_method(rb_cClass, "new", rb_class_new_instance);
  rb_define_method(rb_cClass, "inherited", rb_obj_dummy);
  rb_define_method(rb_cClass, "superclass", rb_class_superclass);
  rb_define_method(rb_cClass, "from_native", rb_class_from_native);
}
