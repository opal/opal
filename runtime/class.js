/**
 * Root of every object and class inside opal (except for toll-free
 * bridged classes.
 */
var rb_boot_root = function() {};

/**
 * Minimizable prototype for adding ivars, method stubs etc.
 */
var BOOT_ROOT_PROTO = rb_boot_root.prototype;

//BOOT_ROOT_PROTO.toString = function() {
//  return this[id_to_s]();
//};

/**
 * Boot a base class. This is only used for the very core ruby objects and
 * classes (Object, Module, Class). This returns what will become the
 * actual instances of the root classes.
 *
 * @param {RClass} superklass The superclass
 * @return {RClass}
 */
function rb_boot_defclass(superklass) {
  var cls = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  if (superklass) {
    var ctor = function() {};
    ctor.prototype = superklass.prototype;
    cls.prototype = new ctor();
  }
  else {
    cls.prototype = new rb_boot_root();
  }

  cls.prototype.constructor = cls;
  cls.prototype.o$f = T_OBJECT;

  return cls;
}

/**
 * Make the actual (meta) classes: Object, Module, Class.
 *
 * @param {String} name The class name
 * @param {RClass} klass The class of the result
 * @param {RClass} superklass The superclass
 * @return {RClass}
 */
function rb_boot_makemeta(name, klass, superklass) {
  var meta = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.prototype;
  meta.prototype = new ctor();

  var proto = meta.prototype;
  proto.$included_in = [];
  proto.o$m           = {};
  proto.$methods     = [];

  proto.o$a          = klass;
  proto.o$f          = T_CLASS;
  proto.__classid__ = name;
  proto.o$s          = superklass;
  proto.constructor = meta;

  // constants
  if (superklass.prototype.$constants_alloc) {
    proto.$c = new superklass.prototype.$constants_alloc();
    proto.$constants_alloc = function() {};
    proto.$constants_alloc.prototype = proto.$c;
  }
  else {
    proto.$constants_alloc = function() {};
    proto.$c = proto.$constants_alloc.prototype;
  }

  var result = new meta();
  klass.prototype.o$k = result;
  return result;
}

/**
 * Boot a new class with the given superclass.
 *
 * @param {RClass} superklass
 * @return {RClass}
 */
function rb_class_boot(superklass) {
  // instances
  var cls = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.o$a.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.o$f = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.o$a = cls;
  proto.o$f = T_CLASS;
  proto.o$m = {};
  proto.$methods = [];

  proto.constructor = meta;
  proto.o$s = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.o$k = result;
  return result;
}

/**
  Get actual class ignoring singleton classes and iclasses.
*/
var rb_class_real = Rt.class_real = function(klass) {
  while (klass.o$f & FL_SINGLETON) { klass = klass.o$s; }
  return klass;
};

/**
  Name the class with the given id.
*/
function rb_name_class(klass, id) {
  klass.__classid__ = id;
};

/**
  Make metaclass for the given class
*/
function rb_make_metaclass(klass, superklass) {
  if (klass.o$f & T_CLASS) {
    if ((klass.o$f & T_CLASS) && (klass.o$f & FL_SINGLETON)) {
      return rb_make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = rb_class_boot(superklass);
      meta.o$a.prototype = klass.constructor.prototype;
      meta.$c = meta.o$k.$c_prototype;
      meta.o$f |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      meta.__classname__ = klass.__classid__;
      klass.o$k = meta;
      meta.$c = klass.$c;
      rb_singleton_class_attached(meta, klass);
      return meta;
    }
  } else {
    // if we want metaclass of an object, do this
    return rb_make_singleton_class(klass);
  }
};

function rb_make_singleton_class(obj) {
  var orig_class = obj.o$k;
  var klass = rb_class_boot(orig_class);

  klass.o$f |= FL_SINGLETON;

  obj.o$k = klass;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  rb_singleton_class_attached(klass, obj);

  klass.o$k = rb_class_real(orig_class).o$k;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function rb_singleton_class_attached(klass, obj) {
  if (klass.o$f & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function rb_make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.o$k == metaclass) {
    metametaclass = rb_class_boot(null);
    metametaclass.o$k = metametaclass;
  }
  else {
    metametaclass = rb_class_boot(null);
    metametaclass.o$k = metaclass.o$k.o$k == metaclass.o$k
      ? rb_make_metametaclass(metaclass.o$k)
      : metaclass.o$k.o$k;
  }

  metametaclass.o$f |= FL_SINGLETON;

  rb_singleton_class_attached(metametaclass, metaclass);
  rb_metaclass.o$k = metametaclass;
  metaclass.o$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.o$s;

  metametaclass.o$s = super_of_metaclass.o$k.__attached__
    == super_of_metaclass
    ? super_of_metaclass.o$k
    : rb_make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function rb_boot_defmetametaclass(klass, metametaclass) {
  klass.o$k.o$k = metametaclass;
};

/**
  Holds an array of all prototypes that are bridged. Any method defined on
  Object in ruby will also be added to the bridge classes.
*/
var rb_bridged_classes = [];

/**
  Define toll free bridged class
*/
function rb_bridge_class(prototype, flags, id, superklass) {
  var klass = rb_define_class(id, superklass);

  klass.$bridge_prototype = prototype;
  rb_bridged_classes.push(prototype);

  prototype.o$k = klass;
  prototype.o$f = flags;

  return klass;
};

/**
  Define a new class (normal way), with the given id and superclass. Will be
  top level.
*/
function rb_define_class(id, superklass) {
  return rb_define_class_under(rb_cObject, id, superklass);
};

function rb_define_class_under(base, id, superklass) {
  var klass;

  if (rb_const_defined(base, id)) {
    klass = rb_const_get(base, id);

    if (!(klass.o$f & T_CLASS)) {
      rb_raise(rb_eException, id + " is not a class");
    }

    if (klass.o$s != superklass && superklass != rb_cObject) {
      rb_raise(rb_eException, "Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = rb_define_class_id(id, superklass);

  if (base == rb_cObject) {
    rb_name_class(klass, id);
  } else {
    rb_name_class(klass, base.__classid__ + '::' + id);
  }

  rb_const_set(base, id, klass);
  klass.$parent = base;

  // Class#inherited hook - here is a good place to call. We check method
  // is actually defined first (incase we are calling it during boot). We
  // can't do this earlier as an error will cause constant names not to be
  // set etc (this is the last place before returning back to scope).
  if (superklass[id_inherited]) {
    superklass[id_inherited](klass);
  }

  return klass;
};

/**
  Actually create class
*/
var rb_define_class_id = Rt.define_class_id = function(id, superklass) {
  var klass;

  if (!superklass) {
    superklass = rb_cObject;
  }
  klass = rb_class_create(superklass);
  rb_name_class(klass, id);
  rb_make_metaclass(klass, superklass.o$k);

  // Important! until we give it a proper parent, have same parent as 
  // superclass so we can access constants etc
  klass.$parent = superklass;

  return klass;
};

function rb_class_create(superklass) {
  return rb_class_boot(superklass);
};

/**
  Get singleton class of obj
*/
var rb_singleton_class = Rt.singleton_class = function(obj) {
  var klass;

  // we cant use singleton nil
  if (obj == Qnil) {
    rb_raise(rb_eTypeError, "can't define singleton");
  }

  if (obj.o$f & T_OBJECT) {
    if ((obj.o$f & T_NUMBER) || (obj.o$f & T_SYMBOL)) {
      rb_raise(rb_eTypeError, "can't define singleton");
    }
  }

  if ((obj.o$k.o$f & FL_SINGLETON) && obj.o$k.__attached__ == obj) {
    klass = obj.o$k;
  }
  else {
    var class_id = obj.o$k.__classid__;
    klass = rb_make_metaclass(obj, obj.o$k);
  }

  return klass;
};

