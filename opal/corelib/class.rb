require 'corelib/module'

class Class
  # TODO: use runtime helpers
  def self.new(sup = Object, &block)
    %x{
      if (!sup.$$is_class) {
        #{raise TypeError, "superclass must be a Class"};
      }

      function AnonClass(){};
      var klass      = Opal.boot(sup, AnonClass)
      klass.$$name   = nil;
      klass.$$parent = sup;

      // inherit scope from parent
      Opal.create_scope(sup.$$scope, klass);

      sup.$inherited(klass);

      if (block !== nil) {
        var block_self = block.$$s;
        block.$$s = null;
        block.call(klass);
        block.$$s = block_self;
      }

      return klass;
    }
  end

  def allocate
    %x{
      var obj = new self.$$alloc;
      obj.$$id = Opal.uid();
      return obj;
    }
  end

  def inherited(cls)
  end

  def new(*args, &block)
    %x{
      var obj = #{allocate};

      obj.$initialize.$$p = block;
      obj.$initialize.apply(obj, args);
      return obj;
    }
  end

  def superclass
    `self.$$super || nil`
  end
end
