/**
  Root of all objects and classes inside opalscript, except for
  native toll free bridges.
*/
var rb_boot_root = function() {};

/**
  Returns the hash value for the receiver. By default on regular
  objects this is just the objects' id
*/
rb_boot_root.prototype.$h = function() {
  return this.$id;
};

/**
  To benefit javascript debug consoles, the toString of any ruby
  object is its' #to_s method.
*/
rb_boot_root.prototype.toString = function() {
  return this.m$to_s(this, "to_s");
};

/**
  Boot a base class. This is only used for the very core ruby
  objects and classes (Object, Module, Class). This returns
  what will be the actual instances of our root classes.

  @param {String} id The class id
  @param {RubyClass} superklass The super
*/
function rb_boot_defclass(id, superklass) {
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
  cls.prototype.$f = T_OBJECT;

  cls.prototype.$h = function() {
    return this.$id;
  };

  return cls;
};

/**
  Make the actual (meta) classes: Object, Class, Module.

  @param {String} id The class id
  @param {RubyClass} klass The class of the result
  @param {RubyClass} superklass The superklass
*/
function rb_boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.prototype;
  meta.prototype = new ctor();

  var proto = meta.prototype;
  proto.$included_in = [];
  proto.$m           = {};
  proto.$methods     = [];

  proto.$a           = klass;
  proto.$f           = T_CLASS;
  proto.__classid__  = id;
  proto.$s           = superklass;
  proto.constructor  = meta;

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
  klass.prototype.$k = result;
  return result;
};

/**
  Fixes the class of boot classes to their meta.
*/
function rb_boot_defmetameta(klass, meta) {
  klass.$k = meta;
};

/**
  Boot class

  @param {RubyClass} superklass Class to inherit from
*/
function rb_class_boot(superklass) {
  // instances
  var cls = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var ctor = function() {};
  ctor.prototype = superklass.$a.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.$f = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = rb_yield_hash();
    return this;
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.$a = cls;
  proto.$f = T_CLASS;
  proto.$m = {};
  proto.$methods = [];

  proto.constructor = meta;
  proto.$s = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.$k = result;
  return result;
};

/**
  Get actual class ignoring singleton classes and iclasses.
*/
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) { klass = klass.$s; }
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
function rb_make_metaclass(klass, super_class) {
  if (klass.$f & T_CLASS) {
    if ((klass.$f & T_CLASS) && (klass.$f & FL_SINGLETON)) {
      return rb_make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = rb_class_boot(super_class);
      // remove this??!
      meta.$a.prototype = klass.constructor.prototype;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      klass.$k = meta;
      meta.$c = klass.$c;
      rb_singleton_class_attached(meta, klass);
      // console.log("meta id: " + klass.__classid__);
      return meta;
    }
  } else {
    // if we want metaclass of an object, do this
    return rb_make_singleton_class(klass);
  }
};

function rb_make_singleton_class(obj) {
  var orig_class = obj.$k;
  var klass = rb_class_boot(orig_class);

  klass.$f |= FL_SINGLETON;

  obj.$k = klass;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  rb_singleton_class_attached(klass, obj);

  klass.$k = rb_class_real(orig_class).$k;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function rb_singleton_class_attached(klass, obj) {
  if (klass.$f & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function rb_make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.$k == metaclass) {
    metametaclass = rb_class_boot(null);
    metametaclass.$k = metametaclass;
  }
  else {
    metametaclass = rb_class_boot(null);
    metametaclass.$k = metaclass.$k.$k == metaclass.$k
      ? rb_make_metametaclass(metaclass.$k)
      : metaclass.$k.$k;
  }

  metametaclass.$f |= FL_SINGLETON;

  rb_singleton_class_attached(metametaclass, metaclass);
  rb_metaclass.$k = metametaclass;
  metaclass.$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.$s;

  metametaclass.$s = super_of_metaclass.$k.__attached__
    == super_of_metaclass
    ? super_of_metaclass.$k
    : rb_make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function rb_boot_defmetametaclass(klass, metametaclass) {
  klass.$k.$k = metametaclass;
};

// Holds an array of all prototypes that are bridged. Any method defined on
// Object in ruby will also be added to the bridge classes.
var rb_bridged_classes = [];

/**
  Define toll free bridged class
*/
function rb_bridge_class(prototype, flags, id, super_class) {
  var klass = rb_define_class(id, super_class);

  klass.$bridge_prototype = prototype;
  rb_bridged_classes.push(prototype);

  prototype.$k = klass;
  prototype.$m = klass.$m_tbl;
  prototype.$f = flags;
  prototype.$r = true;

  prototype.$h = function() { return flags + '_' + this; };

  return klass;
};

// make native prototype from class
function rb_native_prototype(cls, proto) {
  var sup = cls.$s;

  if (sup != rb_cObject) {
    rb_raise(rb_eRuntimeError, "native_error must be used on subclass of Object only");
  }

  proto.$k = cls;
  proto.$f = T_OBJECT;

  proto.$h = function() { return this.$id || (this.$id = rb_yield_hash()); };

  return cls;
}

/**
  Define a new class (normal way), with the given id and superclass. Will be
  top level.
*/
function rb_define_class(id, super_klass) {
  return rb_define_class_under(rb_cObject, id, super_klass);
};

function rb_define_class_under(base, id, super_klass) {
  var klass;

  if (rb_const_defined(base, id)) {
    klass = rb_const_get(base, id);

    if (!(klass.$f & T_CLASS)) {
      rb_raise(rb_eException, id + " is not a class");
    }

    if (klass.$s != super_klass && super_klass != rb_cObject) {
      rb_raise(rb_eException, "Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = rb_define_class_id(id, super_klass);

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
  if (super_klass.m$inherited) {
    super_klass.m$inherited(super_klass, klass);
  }

  return klass;
};

/**
  Actually create class
*/
function rb_define_class_id(id, super_klass) {
  var klass;

  if (!super_klass) {
    super_klass = rb_cObject;
  }
  klass = rb_class_create(super_klass);
  rb_name_class(klass, id);
  rb_make_metaclass(klass, super_klass.$k);

  return klass;
};

function rb_class_create(super_klass) {
  return rb_class_boot(super_klass);
};

/**
  Get singleton class of obj
*/
function rb_singleton_class(obj) {
  var klass;

  // we cant use singleton nil
  if (obj == Qnil) {
    rb_raise(rb_eTypeError, "can't define singleton");
  }

  // not a ruby object, must be native..
  if (!obj.$f) {
    return rb_cNativeObject;
  }

  if (obj.$f & T_OBJECT) {
    if ((obj.$f & T_NUMBER) || (obj.$f & T_SYMBOL)) {
      rb_raise(rb_eTypeError, "can't define singleton");
    }
  }

  if ((obj.$k.$f & FL_SINGLETON) && obj.$k.__attached__ == obj) {
    klass = obj.$k;
  }
  else {
    var class_id = obj.$k.__classid__;
    klass = rb_make_metaclass(obj, obj.$k);
  }

  return klass;
};

