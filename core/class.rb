class Class
  def self.new(sup = Object, &block)
    %x{
      var klass        = boot_class(sup);
          klass.o$name = "AnonClass";

      make_metaclass(klass, sup.o$klass);

      #{sup.inherited `klass`};

      return block !== nil ? block.call(klass, null) : klass;
    }
  end

  def bridge_class(constructor)
    %x{
      var prototype = constructor.prototype,
          klass     = this;

      klass.$allocator = constructor;
      klass.$proto     = prototype;

      bridged_classes.push(klass);

      prototype.o$klass = klass;
      prototype.o$flags  = T_OBJECT;

      var donator = RubyObject.$proto;
      for (var method in donator) {
        if (donator.hasOwnProperty(method)) {
          if (!prototype[method]) {
            prototype[method] = donator[method];
          }
        }
      }

      return klass;
    }
  end

  def allocate
    `new this.$allocator()`
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
      var sup = this.$s;

      if (!sup) {
        if (this === RubyObject) {
          return nil;
        }

        raise(RubyRuntimeError, 'uninitialized class');
      }

      while (sup && (sup.o$flags & T_ICLASS)) {
        sup = sup.$s;
      }

      if (!sup) {
        return nil;
      }

      return sup;
    }
  end
end
