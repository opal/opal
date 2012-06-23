class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = boot_class(sup, AnonClass)
      klass._name = nil;

      sup.$inherited(klass);

      if (block !== nil) {
        block.call(klass);
      }

      return klass;
    }
  end

  def allocate
    %x{
      var obj = new this;
      obj._id = unique_id++;
      return obj;
    }
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