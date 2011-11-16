/**
 * Very root object - every RClass and RObject inherits from this.
 */
function RBaseObject() {
  return this;
}

/**
 * BaseObject prototype.
 */
var base_object_proto = RBaseObject.prototype;

/**
 * Root method table.
 */
function RMethodTable() {}

/**
 * Method table prototoype/
 */
var base_method_table = RMethodTable.prototype;

/**
 * Every class/module in opal is an instance of RClass.
 *
 * @param {RClass} superklass The superclass.
 */
function RClass(superklass) {
  this.$id = rb_hash_yield++;
  this.o$s = superklass;
  this.$k = rb_cClass;

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
    var mtor = function(){};
    mtor.prototype = new RMethodTable();
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
}

RClass.prototype = new RBaseObject();

/**
 * RClass prototype for minimizing.
 */
var Rp = RClass.prototype;

/**
 * Every RClass is just a T_CLASS.
 */
Rp.$f = T_CLASS;

/**
 * Every object in opal (except toll-free native objects) are instances
 * of RObject.
 *
 * @param {RClass} klass The objects' class.
 */
function RObject(klass) {
  this.$id = rb_hash_yield++;
  this.$k  = klass;
  this.$m  = klass.$m_tbl;
  return this;
}

RObject.prototype = new RBaseObject();

/**
 * RObject prototype for minimizing.
 */
var Bp = RObject.prototype;

/**
 * Every RObject is just a T_OBJECT;
 */
Bp.$f = T_OBJECT;

/**
 * Get actual class ignoring singleton classes and iclasses.
 */
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) { klass = klass.o$s; }
  return klass;
};

/**
  Make metaclass for the given class
*/
function rb_make_metaclass(klass, superklass) {
  if (klass.$f & T_CLASS) {
    if ((klass.$f & T_CLASS) && (klass.$f & FL_SINGLETON)) {
      return rb_make_metametaclass(klass);
    }
    else {
      // FIXME this needs fixinfg to remove hacked stuff now in make_singleton_class
      var meta = new RClass(superklass);
      meta.$m = meta.$k.$m_tbl;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classid__ = "#<Class:" + klass.__classid__ + ">";
      meta.__classname__ = klass.__classid__;
      klass.$k = meta;
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
  var orig_class = obj.$k;
  var klass = new RClass(orig_class);

  klass.$f |= FL_SINGLETON;

  obj.$k = klass;
  obj.$m = klass.$m_tbl;

  rb_singleton_class_attached(klass, obj);

  klass.$k = rb_class_real(orig_class).$k;
  klass.$m = klass.$k.$m_tbl;
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
    metametaclass = new RClass();
    metametaclass.$k = metametaclass;
  }
  else {
    metametaclass = new RClass();
    metametaclass.$k = metaclass.$k.$k == metaclass.$k
      ? rb_make_metametaclass(metaclass.$k)
      : metaclass.$k.$k;
  }

  metametaclass.$f |= FL_SINGLETON;

  rb_singleton_class_attached(metametaclass, metaclass);
  rb_metaclass.$k = metametaclass;
  metaclass.o$m = metametaclass.$m_tbl;
  super_of_metaclass = metaclass.o$s;

  metametaclass.o$s = super_of_metaclass.$k.__attached__
    == super_of_metaclass
    ? super_of_metaclass.$k
    : rb_make_metametaclass(super_of_metaclass);

  return metametaclass;
};

/**
 *  Define toll free bridged class
 */
function rb_bridge_class(constructor, flags, id) {
  var klass = define_class(rb_cObject, id, rb_cObject);
  var prototype = constructor.prototype;

  prototype.$k = klass;
  prototype.$m = klass.$m_tbl;
  prototype.$f = flags;

  return klass;
};

/**
 * Define a class.
 *
 * @param {RClass} base Where to define under (e.g. rb_cObject).
 * @param {String} id Class name
 * @param {RClass} superklass The superclass.
 */
function define_class(base, id, superklass) {
  var klass;

  if (rb_const_defined(base, id)) {
    klass = rb_const_get(base, id);

    if (!(klass.$f & T_CLASS)) {
      rb_raise(rb_eException, id + " is not a class");
    }

    if (klass.o$s != superklass && superklass != rb_cObject) {
      rb_raise(rb_eException, "Wrong superclass given for " + id);
    }

    return klass;
  }

  klass = new RClass(superklass);
  klass.$m_tbl.toString = function() {
    return "<method table for: " + id + ">";
  };
  klass.__classid__ = id;

  rb_make_metaclass(klass, superklass.$k);
  klass.$parent = superklass;

  if (base == rb_cObject) {
    klass.__classid__ = id;
  } else {
    klass.__classid__ = base.__classid__ + '::' + id;
  }

  rb_const_set(base, id, klass);
  klass.$parent = base;

  // Class#inherited hook - here is a good place to call. We check method
  // is actually defined first (incase we are calling it during boot). We
  // can't do this earlier as an error will cause constant names not to be
  // set etc (this is the last place before returning back to scope).
  if (superklass.$m[id_inherited]) {
    superklass.$m[id_inherited](superklass, klass);
  }

  return klass;
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

  if (obj.$f & T_OBJECT) {
    if ((obj.$f & T_NUMBER) || (obj.$f & T_STRING)) {
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

