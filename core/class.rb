class Class
  def self.new(sup = Object, &block)
    %x{
      var klass        = boot_class(sup);
          klass._name = "AnonClass";

      make_metaclass(klass, sup._klass);

      #{sup.inherited `klass`};

      if (block !== nil) {
        block.call(klass, null);
      }

      return klass;
    }
  end

  def bridge_class(constructor)
    %x{
      var prototype = constructor.prototype,
          klass     = this;

      klass._alloc = constructor;
      klass._proto     = prototype;

      bridged_classes.push(klass);

      prototype._klass = klass;
      prototype._flags  = T_OBJECT;

      var donator = RubyObject._proto;
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
    `new this._alloc()`
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
      var sup = this._super;

      if (!sup) {
        if (this === RubyObject) {
          return nil;
        }

        throw RubyRuntimeError.$new('uninitialized class');
      }

      while (sup && (sup._flags & T_ICLASS)) {
        sup = sup._super;
      }

      if (!sup) {
        return nil;
      }

      return sup;
    }
  end
end
