class Class
  def self.new(sup = Object, &block)
    %x{
      if (!sup._isClass || sup.__mod__) {
        #{raise TypeError, "superclass must be a Class"};
      }

      function AnonClass(){};
      var klass       = Opal.boot(sup, AnonClass)
      klass._name     = nil;
      klass.__parent  = sup;

      // inherit scope from parent
      $opal.create_scope(sup._scope, klass);

      sup.$inherited(klass);

      if (block !== nil) {
        var block_self = block._s;
        block._s = null;
        block.call(klass);
        block._s = block_self;
      }

      return klass;
    }
  end

  def allocate
    %x{
      var obj = new #{self}._alloc;
      obj._id = Opal.uid();
      return obj;
    }
  end

  def inherited(cls)
  end

  def new(*args, &block)
    %x{
      var obj = #{allocate};

      obj.$initialize._p = block;
      obj.$initialize.apply(obj, args);
      return obj;
    }
  end

  def superclass
    `#{self}._super || nil`
  end
end
