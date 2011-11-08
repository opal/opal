class Class
  def self.new(sup = Object, &block)
    cls = `rb_define_class_id("AnonClass", sup)`
    sup.inherited cls

    `
      if (block) {
        block(cls, null);
      }
    `
    cls
  end

  def allocate
    `new self.o$a()`
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
      var sup = self.$super;

      if (!sup) {
        if (self === rb_cBasicObject) {
          return null;
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
