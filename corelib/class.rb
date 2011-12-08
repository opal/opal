class Class
  def self.new(sup = Object, &block)
    `
      var klass = boot_class(sup);
      klass.__classid__ = "AnonClass";
      rb_make_metaclass(klass, sup.$k);
      klass.$parent = sup;
      #{sup.inherited `klass`};

      return block !== nil ? block.call(klass, null) : klass;
    `
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
        if (self === rb_cObject) return nil;
        rb_raise(RubyRuntimeError, 'uninitialized class');
      }
      return sup;
    `
  end
end
