class Class
  def self.new(sup = Object, &block)
    cls = `rb_define_class_id("AnonClass", sup)`
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

        rb_raise(rb_eRuntimeError, "uninitialized clasS");
      }

      return sup;
    `
  end

  def from_native(obj)
    `rb_from_native(self, obj)`
  end
end
