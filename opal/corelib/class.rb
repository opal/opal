require 'corelib/module'

class Class
  def self.new(superclass = Object, &block)
    %x{
      if (!superclass[Opal.$$is_class_s]) {
        throw Opal.TypeError.$new("superclass must be a Class");
      }

      var klass = Opal.allocate_class(nil, superclass);
      superclass.$inherited(klass);
      #{`klass`.class_eval(&block) if block_given?}
      return klass;
    }
  end

  def allocate
    %x{
      var obj = new self[Opal.$$constructor_s]();
      obj[Opal.$$id_s] = Opal.uid();
      return obj;
    }
  end

  def inherited(cls)
  end

  def initialize_dup(original)
    initialize_copy(original)
    %x{
      self[Opal.$$name_s] = null;
      self.$$full_name = null;
    }
  end

  def new(*args, &block)
    %x{
      var object = #{allocate};
      Opal.send(object, object.$initialize, args, block);
      return object;
    }
  end

  def superclass
    `self[Opal.$$super_s] || nil`
  end

  def to_s
    %x{
      var singleton_of = self[Opal.$$singleton_of_s];

      if (singleton_of && singleton_of[Opal.$$is_a_module_s]) {
        return #{"#<Class:#{`singleton_of`.name}>"};
      }
      else if (singleton_of) {
        // a singleton class created from an object
        return #{"#<Class:#<#{`singleton_of[Opal.$$class_s]`.name}:0x#{`Opal.id(singleton_of)`.to_s(16)}>>"};
      }

      return #{super()};
    }
  end
end
