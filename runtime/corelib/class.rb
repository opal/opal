class Class
  def self.new(sup = Object, &block)
    %x{
      var klass             = boot_class(sup);
          klass.__classid__ = "AnonClass";
          klass.$parent     = sup;

      rb_make_metaclass(klass, sup.$k);

      #{sup.inherited `klass`};

      return block !== nil ? block.call(klass, null) : klass;
    }
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
  end

  def superclass
    %x{
      var sup = self.$s;

      if (!sup) {
        if (self === rb_cObject) {
          return nil;
        }

        rb_raise(RubyRuntimeError, 'uninitialized class');
      }

      return sup;
    }
  end
end
