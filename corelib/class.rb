class Class
  def self.new(sup = Object, &block)
    cls = `new RClass(sup)`
    `cls.__classid__ = "AnonClass";`
    `rb_make_metaclass(cls, sup.$k);`
    `cls.$parent = sup;`

    sup.inherited cls

    if block_given?
      `return block(cls);`
    else
      cls
    end
  end

  def allocate
    `new RObject(self)`
  end

  def new(*args, &block)
    obj = allocate()
    obj.initialize *args, &block
    obj
  end

  def inherited(cls)
    nil
  end

  def superclass
    `
      var sup = self.o$s;

      if (!sup) {
        if (self === rb_cBasicObject) {
          return nil;
        }

        rb_raise(rb_eRuntimeError, "uninitialized class");
      }

      return sup;
    `
  end

  def from_native(obj)
    `
      obj.$id = rb_hash_yield++;
      obj.$k  = self;
      obj.$m  = self.$m_tbl;
      obj.$f  = T_OBJECT
      return obj;
    `
  end
end
