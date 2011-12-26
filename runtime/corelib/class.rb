class Class
  def self.new(sup = Object, &block)
    %x{
      var klass             = boot_class(sup);
          klass.__classid__ = "AnonClass";

      make_metaclass(klass, sup.$klass);

      #{sup.inherited `klass`};

      return block !== nil ? block.call(klass, null) : klass;
    }
  end

  def allocate
    `new self.$allocator()`
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
        if (self === RubyObject) {
          return nil;
        }

        raise(RubyRuntimeError, 'uninitialized class');
      }

      return sup;
    }
  end
end
