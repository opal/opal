require 'corelib/module'

class Class
  def self.new(sup = Object, &block)
    %x{
      if (!sup.$$is_class) {
        #{raise TypeError, "superclass must be a Class"};
      }

      function AnonClass(){};
      var klass        = Opal.boot_class(sup, AnonClass)
      klass.$$name     = nil;
      klass.$$parent   = sup;
      klass.$$is_class = true;

      // inherit scope from parent
      Opal.create_scope(sup.$$scope, klass);

      sup.$inherited(klass);

      #{`klass`.initialize(sup, &block)}

      return klass;
    }
  end

  def initialize(_sup = Object, &block)
    `Opal.module_initialize(self, block);`
  end

  def allocate
    %x{
      var obj = new self.$$alloc();
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
