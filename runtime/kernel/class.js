// Root of all objects and classes inside opal
function RootObject() {};

RootObject.prototype.toString = function() {
  if (this.$f & T_OBJECT) {
    return "#<" + (this.$k).__classid__ + ":0x" + this.$id + ">";
  }
  else {
    return '<' + this.__classid__ + ' ' + this.$id + '>';
  }
};

// Boot a base class (makes instances).
function boot_defclass(superklass) {
  var cls = function() {
    this.$id = rb_hash_yield++;

    return this;
  };

  if (superklass) {
    var ctor           = function() {};
        ctor.prototype = superklass.prototype;

    cls.prototype = new ctor();
  }
  else {
    cls.prototype = new RootObject();
  }

  cls.prototype.constructor = cls;
  cls.prototype.$f          = T_OBJECT;

  return cls;
}

// Boot actual (meta classes) of core objects.
function boot_makemeta(id, klass, superklass) {
  var meta = function() {
    this.$id = rb_hash_yield++;

    return this;
  };

  var ctor           = function() {};
      ctor.prototype = superklass.prototype;

  meta.prototype = new ctor();

  var proto              = meta.prototype;
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
    proto.$c                         = new superklass.prototype.$constants_alloc();
    proto.$constants_alloc           = function() {};
    proto.$constants_alloc.prototype = proto.$c;
  }
  else {
    proto.$constants_alloc = function() {};
    proto.$c               = proto.$constants_alloc.prototype;
  }

  var result = new meta();

  klass.prototype.$k = result;

  return result;
}

// Create generic class with given superclass.
function boot_class(superklass) {
  // instances
  var cls = function() {
    this.$id = rb_hash_yield++;

    return this;
  };

  var ctor = function() {};
      ctor.prototype = superklass.$a.prototype;

  cls.prototype = new ctor();

  var proto             = cls.prototype;
      proto.constructor = cls;
      proto.$f          = T_OBJECT;

  // class itself
  var meta = function() {
    this.$id = rb_hash_yield++;

    return this;
  };

  var mtor = function() {};
      mtor.prototype = superklass.constructor.prototype;

  meta.prototype = new mtor();

  proto                            = meta.prototype;
  proto.$a                         = cls;
  proto.$f                         = T_CLASS;
  proto.$m                         = {};
  proto.$methods                   = [];
  proto.constructor                = meta;
  proto.$s                         = superklass;
  proto.$c                         = new superklass.$constants_alloc();
  proto.$constants_alloc           = function() {};
  proto.$constants_alloc.prototype = proto.$c;

  var result = new meta();

  cls.prototype.$k = result;

  return result;
}

// Get actual class ignoring singleton classes and iclasses.
function rb_class_real(klass) {
  while (klass.$f & FL_SINGLETON) {
    klass = klass.$s;
  }

  return klass;
}

// Make metaclass for the given class
function rb_make_metaclass(klass, superklass) {
  if (klass.$f & T_CLASS) {
    if ((klass.$f & T_CLASS) && (klass.$f & FL_SINGLETON)) {
      rb_raise(RubyException, "too much meta: return klass?");
    }
    else {
      var class_id = "#<Class:" + klass.__classid__ + ">",
          meta     = boot_class(superklass);

      meta.__classid__ = class_id;
      meta.$a.prototype = klass.constructor.prototype;
      meta.$c = meta.$k.$c_prototype;
      meta.$f |= FL_SINGLETON;
      meta.__classname__ = klass.__classid__;

      klass.$k = meta;

      meta.$c = klass.$c;
      meta.__attached__ = klass;

      return meta;
    }
  }
  else {
    return rb_make_singleton_class(klass);
  }
}

function rb_make_singleton_class(obj) {
  var orig_class = obj.$k,
      class_id   = "#<Class:#<" + orig_class.__classid__ + ":" + orig_class.$id + ">>";

  klass             = boot_class(orig_class);
  klass.__classid__ = class_id;

  klass.$f                |= FL_SINGLETON;
  klass.$bridge_prototype  = obj;

  obj.$k = klass;

  klass.__attached__ = obj;

  klass.$k = rb_class_real(orig_class).$k;

  return klass;
}

var bridged_classes = []

function rb_bridge_class(constructor, flags, id) {
  var klass     = define_class(rb_cObject, id, rb_cObject),
      prototype = constructor.prototype;

  klass.$bridge_prototype = prototype;
  bridged_classes.push(prototype);

  prototype.$k = klass;
  prototype.$f = flags;

  return klass;
}

// Define new ruby class
function define_class(base, id, superklass) {
  var klass;

  if (base.$c.hasOwnProperty(id)) {
    return base.$c[id];
  }

  var class_id = (base === rb_cObject ? id : base.__classid__ + '::' + id);

  klass             = boot_class(superklass);
  klass.__classid__ = class_id;

  rb_make_metaclass(klass, superklass.$k);

  base.$c[id]   = klass;
  klass.$parent = base;

  if (superklass.m$inherited) {
    superklass.m$inherited(null, klass);
  }

  return klass;
}

// Get singleton class of obj
function rb_singleton_class(obj) {
  var klass;

  if (obj.$f & T_OBJECT) {
    if ((obj.$f & T_NUMBER) || (obj.$f & T_STRING)) {
      rb_raise(RubyTypeError, "can't define singleton");
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
}
