/**
  Every class in opal is an instance of RClass.

  @param [RClass] superklass
*/
var RClass = Rt.RClass = function(superklass) {
  this.$id    = rb_yield_hash();
  this.$super = superklass;

  if (superklass) {
    var mtor = function(){};
    mtor.prototype = new superklass.$m_tor();
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var cctor = function(){};
    cctor.prototype = superklass.$c_prototype;

    var ctor = function(){};
    ctor.prototype = new cctor();

    this.$c = new ctor();
    this.$c_prototype = ctor.prototype;
  }
  else {
    console.log("Making root");
    var mtor = function(){};
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var ctor = function(){};
    this.$c = new ctor();
    this.$c_prototype = ctor.prototype;
  }

  this.$methods      = [];
  this.$method_table = {};
  this.$const_table  = {};

  return this;
};

/**
  RClass prototype for minimizing
*/
var Rp = RClass.prototype;

/**
  Every RClass is just a T_CLASS;
*/
Rp.$flags = T_CLASS;

/**
  Every Object in opal (except native bridged) are instances of
  RObject.

  @param [RClass] klass The objects' class.
*/
var RObject = Rt.RObject = function(klass) {
  this.$id = rb_yield_hash();
  this.$klass = klass;
  this.$m     = klass.$m_tbl;
  return this;
};

/**
  RObject prototype for minimizing.
*/
var Bp = RObject.prototype;

/**
  Every RObject is just a T_OBJECT
*/
Bp.$flags = T_OBJECT;

/**
  Boots a root object, i.e. BasicObject.
*/
function boot_defrootclass(id) {
  var cls = new RClass(null);
  cls.$flags = T_CLASS;
  rb_name_class(cls, id);
  rb_const_set(rb_cObject || cls, id, cls);

  return cls;
}

/**
  Boots a core object - Object, Module and Class.
*/
function boot_defclass(id, superklass) {
  var cls = rb_class_boot(superklass);
  rb_name_class(cls, id);
  rb_const_set(rb_cObject || cls, id, cls);

  return cls;
}

/**
  Boot class

  @param {RubyClass} superklass Class to inherit from
*/
function rb_class_boot(superklass) {
  if (superklass) {
    var klass = new RClass(superklass);
    klass.$klass = rb_cClass;
    return klass;
  }
  else {
    var klass = new RClass(null);
    return klass;
  }
}

/**
  Get actual class ignoring singleton classes and iclasses.
*/
var rb_class_real = Rt.class_real = function(klass) {
  while (klass.$flags & FL_SINGLETON) { klass = klass.$super; }
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
  if (klass.$flags & T_CLASS) {
    if ((klass.$flags & T_CLASS) && (klass.$flags & FL_SINGLETON)) {
      return rb_make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = rb_class_boot(superklass);
      // remove this??!
      meta.$m = meta.$klass.$m_tbl
      meta.$c = meta.$klass.$c_prototype;
      meta.$flags |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      meta.__classname__ = klass.__classid__;
      klass.$klass = meta;
      klass.$m = meta.$m_tbl;
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
  var orig_class = obj.$klass;
  var klass = rb_class_boot(orig_class);

  klass.$flags |= FL_SINGLETON;

  obj.$klass = klass;
  obj.$m = klass.$m_tbl;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  rb_singleton_class_attached(klass, obj);

  klass.$klass = rb_class_real(orig_class).$klass;
  klass.$m = klass.$klass.$m_tbl;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function rb_singleton_class_attached(klass, obj) {
  if (klass.$flags & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function rb_make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.$k == metaclass) {
    metametaclass = rb_class_boot(null);
    metametaclass.$klass = metametaclass;
  }
  else {
    metametaclass = rb_class_boot(null);
    metametaclass.$k = metaclass.$klass.$klass == metaclass.$klass
      ? rb_make_metametaclass(metaclass.$klass)
      : metaclass.$klass.$klass;
  }

  metametaclass.$flass |= FL_SINGLETON;

  rb_singleton_class_attached(metametaclass, metaclass);
  rb_metaclass.$klass = metametaclass;
  metaclass.$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.$super;

  metametaclass.$super = super_of_metaclass.$klass.__attached__
    == super_of_metaclass
    ? super_of_metaclass.$klass
    : rb_make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function rb_boot_defmetametaclass(klass, metametaclass) {
  klass.$klass.$klass = metametaclass;
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

  prototype.$klass = klass;
  prototype.$m = klass.$m_tbl;
  prototype.$flags = flags;

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

    if (!(klass.$flags & T_CLASS)) {
      rb_raise(rb_eException, id + " is not a class");
    }

    if (klass.$super != superklass && superklass != rb_cObject) {
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
  // if (super_klass.m$inherited) {
    // super_klass.m$inherited(super_klass, "inherited", klass);
  // }

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
  rb_make_metaclass(klass, superklass.$klass);

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

  if (obj.$flags & T_OBJECT) {
    if ((obj.$flags & T_NUMBER) || (obj.$flags & T_SYMBOL)) {
      rb_raise(rb_eTypeError, "can't define singleton");
    }
  }

  if ((obj.$klass.$flags & FL_SINGLETON) && obj.$klass.__attached__ == obj) {
    klass = obj.$klass;
  }
  else {
    var class_id = obj.$klass.__classid__;
    klass = rb_make_metaclass(obj, obj.$klass);
  }

  return klass;
};

