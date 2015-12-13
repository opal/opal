require 'corelib/module'

class Class
  def self.new(superclass = Object, &block)
    %x{
      if (!superclass.$$is_class) {
        #{raise TypeError, "superclass must be a Class"};
      }

      var alloc = Opal.boot_class_alloc(null, function(){}, superclass)
      var klass = Opal.boot_class_object(null, superclass, alloc);

      klass.$$name     = nil;
      klass.$$parent   = superclass;
      klass.$$is_class = true;

      // inherit scope from parent
      Opal.create_scope(superclass.$$scope, klass);

      superclass.$inherited(klass);

      #{`klass`.initialize(superclass, &block)}

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
