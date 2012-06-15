class Class
  def self.new(sup = Object, &block)
    %x{
      var klass        = boot_class(sup);
          klass._name = nil;

      //make_metaclass(klass, sup._klass);

      sup.$inherited(klass);

      if (block !== nil) {
        block.call(klass);
      }

      return klass;
    }
  end

  def allocate
    `new this`
  end

  def new(*args, &block)
    %x{
      var obj = this.$allocate();
      obj._p  = block;
      obj.$initialize.apply(obj, args);
      return obj;
    }
  end

  def inherited(cls)
  end

  def superclass
    %x{
      var sup = this._super;

      if (!sup) {
        return nil;
      }

      while (sup && (sup._isIClass)) {
        sup = sup._super;
      }

      if (!sup) {
        return nil;
      }

      return sup;
    }
  end
end