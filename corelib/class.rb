class Class
  def self.new(sup = Object, &block)
    cls = `boot_class(sup)`
    `cls.__classid__ = "AnonClass";`
    `rb_make_metaclass(cls, sup.$k);`
    `cls.$parent = sup;`

    sup.inherited cls

    if block_given?
      `return block.call(cls);`
    else
      cls
    end
  end

  def allocate
    `new self.$a()`
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
      var sup = self.$s;

      if (!sup) {
        if (self === rb_cObject) {
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
