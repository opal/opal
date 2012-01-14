class Class
  def self.new(sup = Object, &block)
    %x{
      var klass       = boot_class(sup);
          klass.$name = "AnonClass";

      make_metaclass(klass, sup.$klass);

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

      prototype.$klass = klass;
      prototype.$flags = T_OBJECT;

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

      return sup;
    }
  end
end
