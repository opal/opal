
/**
  Root of all classes and objects (except for bridged).
*/
var boot_base_class = function() {};

boot_base_class.$hash = function() {
  return this.$id;
};

boot_base_class.prototype.$r = true;

/**
  Boot a base class (only used for very core object classes)
*/
function boot_defclass(id, super_klass) {
  var cls = function() {
    this.$id = yield_hash();
  };

  if (super_klass) {
    var ctor = function() {};
    ctor.prototype = super_klass.prototype;
    cls.prototype = new ctor();
  } else {
    cls.prototype = new boot_base_class();
  }

  cls.prototype.constructor = cls;
  cls.prototype.$flags = T_OBJECT;

  cls.prototype.$hash = function() { return this.$id; };
  cls.prototype.$r = true;
  return cls;
};

// make the actual classes themselves (Object, Class, etc)
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.$id = yield_hash();
  };

  var ctor = function() {};
  ctor.prototype = superklass.prototype;
  meta.prototype = new ctor();

  var proto = meta.prototype;
  proto.$included_in = [];
  proto.$method_table = {};
  proto.$methods = [];
  proto.allocator = klass;
  proto.constructor = meta;
  proto.__classid__ = id;
  proto.$super = superklass;
  proto.$flags = T_CLASS;

  // constants
  if (superklass.prototype.$constants_alloc) {
    proto.$c = new superklass.prototype.$constants_alloc();
    proto.$constants_alloc = function() {};
    proto.$constants_alloc.prototype = proto.$c;
  } else {
    proto.$constants_alloc = function() {};
    proto.$c = proto.$constants_alloc.prototype;
  }

  var result = new meta();
  klass.prototype.$klass = result;
  return result;
};

function boot_defmetameta(klass, meta) {
  klass.$klass = meta;
}

function class_boot(superklass) {
  // instances
  var cls = function() {
    this.$id = yield_hash();
  };

  var ctor = function() {};
  ctor.prototype = superklass.allocator.prototype;
  cls.prototype = new ctor();

  var proto = cls.prototype;
  proto.constructor = cls;
  proto.$flags = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = yield_hash();
  };

  var mtor = function() {};
  mtor.prototype = superklass.constructor.prototype;
  meta.prototype = new mtor();

  proto = meta.prototype;
  proto.allocator = cls;
  proto.$flags = T_CLASS;
  proto.$method_table = {};
  proto.$methods = [];
  proto.constructor = meta;
  proto.$super = superklass;

  // constants
  proto.$c = new superklass.$constants_alloc();
  proto.$constants_alloc = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();
  cls.prototype.$klass = result;
  return result;
};

function class_real(klass) {
  while (klass.$flags & FL_SINGLETON) { klass = klass.$super; }
  return klass;
};

Rt.class_real = class_real;

/**
  Name the class with the given id.
*/
function name_class(klass, id) {
  klass.__classid__ = id;
};

/**
  Make metaclass for the given class
*/
function make_metaclass(klass, super_class) {
  if (klass.$flags & T_CLASS) {
    if ((klass.$flags & T_CLASS) && (klass.$flags & FL_SINGLETON)) {
      return make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = class_boot(super_class);
      // remove this??!
      meta.allocator.prototype = klass.constructor.prototype;
      meta.$c = meta.$klass.$c_prototype;
      meta.$flags |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      klass.$klass = meta;
      meta.$c = klass.$c;
      singleton_class_attached(meta, klass);
      // console.log("meta id: " + klass.__classid__);
      return meta;
    }
  } else {
    // if we want metaclass of an object, do this
    return make_singleton_class(klass);
  }
};

function make_singleton_class(obj) {
  var orig_class = obj.$klass;
  var klass = class_boot(orig_class);

  klass.$flags |= FL_SINGLETON;

  obj.$klass = klass;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  singleton_class_attached(klass, obj);

  klass.$klass = class_real(orig_class).$klass;
  klass.__classid__ = "#<Class:#<" + orig_class.__classid__ + ":" + klass.$id + ">>";

  return klass;
};

function singleton_class_attached(klass, obj) {
  if (klass.$flags & FL_SINGLETON) {
    klass.__attached__ = obj;
  }
};

function make_metametaclass(metaclass) {
  var metametaclass, super_of_metaclass;

  if (metaclass.$klass == metaclass) {
    metametaclass = class_boot(null);
    metametaclass.$klass = metametaclass;
  }
  else {
    metametaclass = class_boot(null);
    metametaclass.$klass = metaclass.$klass.$klass == metaclass.$klass
      ? make_metametaclass(metaclass.$klass)
      : metaclass.$klass.$klass;
  }

  metametaclass.$flags |= FL_SINGLETON;

  singleton_class_attached(metametaclass, metaclass);
  metaclass.$klass = metametaclass;
  metaclsss.$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.$super;

  metametaclass.$super = super_of_metaclass.$klass.__attached__
    == super_of_metaclass
    ? super_of_metaclass.$klass
    : make_metametaclass(super_of_metaclass);

  return metametaclass;
};

function boot_defmetametaclass(klass, metametaclass) {
  klass.$klass.$klass = metametaclass;
};

// Holds an array of all prototypes that are bridged. Any method defined on
// Object in ruby will also be added to the bridge classes.
var bridged_classes = [];

/**
  Define toll free bridged class
*/
function bridge_class(prototype, flags, id, super_class) {
  var klass = define_class(id, super_class);

  bridged_classes.push(prototype);
  klass.$bridge_prototype = prototype;

  for (var meth in cBasicObject.$method_table) {
    prototype[meth] = cBasicObject.$method_table[meth];
  }

  for (var meth in cObject.$method_table) {
    prototype[meth] = cObject.$method_table[meth];
  }

  prototype.$klass = klass;
  prototype.$flags = flags;
  prototype.$r = true;

  prototype.$hash = function() { return flags + '_' + this; };

  return klass;
};

/**
  Define a new class (normal way), with the given id and superclass. Will be
  top level.
*/
function define_class(id, super_klass) {
  return define_class_under(cObject, id, super_klass);
};

function define_class_under(base, id, super_klass) {
  var klass;

  if (const_defined(base, id)) {
    klass = const_get(base, id);

    if (!(klass.$flags & T_CLASS)) {
      throw new Error(id + " is not a class!");
    }

    if (klass.$super != super_klass && super_klass != cObject) {
      throw new Error("Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = define_class_id(id, super_klass);

  if (base == cObject) {
    name_class(klass, id);
  } else {
    name_class(klass, base.__classid__ + '::' + id);
  }

  const_set(base, id, klass);
  klass.$parent = base;

  // Class#inherited hook - here is a good place to call. We check method
  // is actually defined first (incase we are calling it during boot). We
  // can't do this earlier as an error will cause constant names not to be
  // set etc (this is the last place before returning back to scope).
  if (super_klass.m$inherited) {
    super_klass.m$inherited(klass);
  }

  return klass;
};

Rt.define_class_under = define_class_under;

/**
  Actually create class
*/
function define_class_id(id, super_klass) {
  var klass;

  if (!super_klass) {
    super_klass = cObject;
  }
  klass = class_create(super_klass);
  name_class(klass, id);
  make_metaclass(klass, super_klass.$klass);

  return klass;
};

function class_create(super_klass) {
  return class_boot(super_klass);
};

/**
  Get singleton class of obj
*/
function singleton_class(obj) {
  var klass;

  if (obj.$flags & T_OBJECT) {
    if ((obj.$flags & T_NUMBER) || (obj.$flags & T_SYMBOL)) {
      raise(eTypeError, "can't define singleton");
    }
  }

  if ((obj.$klass.$flags & FL_SINGLETON) && obj.$klass.__attached__ == obj) {
    klass = obj.$klass;
  }
  else {
    var class_id = obj.$klass.__classid__;
    klass = make_metaclass(obj, obj.$klass);
  }

  return klass;
};

Rt.singleton_class = singleton_class;
