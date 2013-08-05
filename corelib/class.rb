class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = Opal.boot(sup, AnonClass)
      klass._name = nil;
      klass._scope = sup._scope;

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
      if (#{self}._proto.$initialize) {
        var obj = new #{self}._alloc;
        obj._id = Opal.uid();

        obj.$initialize._p = block;
        obj.$initialize.apply(obj, args);
        return obj;
      }
      else {
        var cons = function() {};
        cons.prototype = #{self}.prototype;
        var obj = new cons;
        #{self}.apply(obj, args);
        return obj;
      }
    }
  end

  def superclass
    `#{self}._super || nil`
  end
end
