/**
  Every class in opal is an instance of RClass

  @param {RClass} klass
  @param {RClass} superklass
*/
var RClass = Rt.RClass = function(klass, superklass) {
  this.$id = yield_hash();
  this.$super = superklass;

  if (superklass) {
    var mtor = function() {};
    mtor.prototype = new superklass.$m_tor();
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var cctor = function() {};
    cctor.prototype = superklass.$c_prototype;

    var c_tor = function(){};
    c_tor.prototype = new cctor();

    this.$c = new c_tor();
    this.$c_prototype = c_tor.prototype;
  }
  else {
    var mtor = function() {};
    this.$m_tbl = mtor.prototype;
    this.$m_tor = mtor;

    var ctor = function() {};
    this.$c = new ctor();
    this.$c_prototype = ctor.prototype;
  }

  this.$method_table = {};
  this.$const_table = {};

  return this;
};

// RClass prototype for minimizing
var Rp = RClass.prototype;

/**
  Every RClass instance is just a T_CLASS.
*/
Rp.$flags = T_CLASS;

/**
  RClass truthiness
*/
Rp.$r = true;

/**
  Every object in opal (except toll free objects) are instances of RObject

  @param {RClass} klass
*/
var RObject = Rt.RObject = function(klass) {
  this.$id = yield_hash();
  this.$klass = klass;
  this.$m = klass.$m_tbl;
  return this;
};

// For minimizing
var Bp = RObject.prototype;

/**
  Every RObject is a T_OBJECT
*/
Bp.$flags = T_OBJECT;

/**
  RObject truthiness
*/
Bp.$r = true;

/**
  The hash of all objects and classes is sinple its id
*/
Bp.$hash = Rp.$hash = function() {
  return this.$id;
};

/**
  Like boot_defclass but for root object only (i.e. BasicObject)
*/
function boot_defrootclass(id) {
  var cls = new RClass(null, null);
  cls.$flags = T_CLASS;
  name_class(cls, id);
  const_set((cObject || cls), id, cls);
  return cls;
}

/**
  Boots core classes - Object, Module and Class
*/
function boot_defclass(id, superklass) {
  var cls = class_boot(superklass);
  name_class(cls, id);
  const_set((cObject || cls), id, cls);
  return cls;
}

function class_boot(superklass) {
  if (superklass) {
    var ctor = function() {};
    ctor.prototype = superklass.constructor.prototype;

    var result = function() {
      RClass.call(this, null, superklass);
      return this;
    };
    result.prototype = new ctor();

    var klass = new result();
    klass.$klass = cClass;
    return klass;
  }
  else {
    var result = new RClass(null, null);
    return result;
  }
}

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
      meta.$m = meta.$klass.$m_tbl;
      meta.$c = meta.$klass.$c_prototype;
      meta.$flags |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      klass.$klass = meta;
      klass.$m = meta.$m_tbl;
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
  obj.$m = klass.$m_tbl;

  // make methods we define here actually point to instance
  // FIXME: we could just take advantage of $bridge_prototype like we
  // use for bridged classes?? means we can make more instances...
  klass.$bridge_prototype = obj;

  singleton_class_attached(klass, obj);

  klass.$klass = class_real(orig_class).$klass;
  klass.$m = klass.$klass.$m_tbl;
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

  prototype.$klass = klass;
  prototype.$m = klass.$m_tbl;
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
