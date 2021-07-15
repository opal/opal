require 'corelib/module'

class Class
  def self.new(superclass = Object, &block)
    %x{
      if (!superclass[Opal.s.$$is_class]) {
        throw Opal.TypeError[Opal.s.$new]("superclass must be a Class");
      }

      var klass = Opal.allocate_class(nil, superclass);
      superclass[Opal.s.$inherited](klass);
      #{`klass`.class_eval(&block) if block_given?}
      return klass;
    }
  end

  def allocate
    %x{
      var obj = new self[Opal.s.$$constructor]();
      obj[Opal.s.$$id] = Opal.uid();
      return obj;
    }
  end

  def inherited(cls)
  end

  def initialize_dup(original)
    initialize_copy(original)
    %x{
      self[Opal.s.$$name] = null;
      self[Opal.s.$$full_name] = null;
    }
  end

  def new(*args, &block)
    %x{
      var object = #{allocate};
      Opal.send(object, object[Opal.s.$initialize], args, block);
      return object;
    }
  end

  def superclass
    `self[Opal.s.$$super] || nil`
  end

  def to_s
    %x{
      var singleton_of = self[Opal.s.$$singleton_of];

      if (singleton_of && singleton_of[Opal.s.$$is_a_module]) {
        return #{"#<Class:#{`singleton_of`.name}>"};
      }
      else if (singleton_of) {
        // a singleton class created from an object
        return #{"#<Class:#<#{`singleton_of[Opal.s.$$class]`.name}:0x#{`Opal.id(singleton_of)`.to_s(16)}>>"};
      }

      return #{super()};
    }
  end
end
