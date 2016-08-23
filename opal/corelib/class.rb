require 'corelib/module'

class Class
  def self.new(superclass = Object, &block)
    %x{
      if (!superclass.$$is_class) {
        throw Opal.TypeError.$new("superclass must be a Class");
      }

      var alloc = Opal.boot_class_alloc(null, function(){}, superclass)
      var klass = Opal.setup_class_object(null, alloc, superclass.$$name, superclass.constructor);

      klass.$$super  = superclass;
      klass.$$parent = superclass;
      klass.$$entry  = klass;

      // inherit scope from parent
      Opal.create_scope(superclass.$$scope, klass);

      superclass.$inherited(klass);
      Opal.module_initialize(klass, block);

      return klass;
    }
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

  def to_s
    %x{
      var singleton_of = self.$$singleton_of;

      if (singleton_of && (singleton_of.$$is_class || singleton_of.$$is_module)) {
        return #{"#<Class:#{`singleton_of`.name}>"};
      }
      else if (singleton_of) {
        // a singleton class created from an object
        return #{"#<Class:#<#{`singleton_of.$$class`.name}:0x#{`Opal.id(singleton_of)`.to_s(16)}>>"};
      }
      return #{super()};
    }
  end
end
