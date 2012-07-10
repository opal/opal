class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = boot_class(sup, AnonClass)
      klass._name = nil;

      #{ sup.inherited `klass` };

      if (block !== nil) {
        block(klass, '');
      }

      return klass;
    }
  end

  def allocate
    %x{
      var obj = [];
      obj._id = unique_id++;
      return obj;
    }
  end

  def new(*args, &block)
    %x{
      var obj = new self;
      obj._id = unique_id++;
      obj._p  = block;

      obj.$m.initialize.apply(null, [obj, 'initialize'].concat(args));
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

      return sup;
    }
  end
end