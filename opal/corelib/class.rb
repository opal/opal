require 'corelib/module'

class Class
  def self.new(superclass = Object, &block)
    %x{
      if (!superclass.$$is_class) {
        throw Opal.TypeError.$new("superclass must be a Class");
      }

      var klass = Opal.allocate_class(nil, superclass);
      superclass.$inherited(klass);
      #{`klass`.class_eval(&block) if block_given?}
      return klass;
    }
  end

  %x{
    if (typeof OPAL_DEVTOOLS_OBJECT_REGISTRY !== "undefined" && OPAL_DEVTOOLS_OBJECT_REGISTRY) {
      console.warn("Using Opal Developer Tools Object Registry");
      if (typeof Opal.opal_devtools_object_registry ==="undefined") {
        Opal.opal_devtools_object_registry = {};
      }
       #{
        def allocate
          %x{
            var obj = new self.$$constructor();
            obj.$$id = Opal.uid();
            var full_name = obj.constructor.$$full_name;
            if (!full_name) { full_name = obj.constructor.$$name; }
            if (full_name && full_name !== Opal.nil) {
              if (!Opal.opal_devtools_object_registry[full_name]) {
                Opal.opal_devtools_object_registry[full_name] = {};
              }
              Opal.opal_devtools_object_registry[full_name][obj.$$id.toString()] = obj;
            }
            return obj;
          }
        end
      }
    } else {
      #{
        def allocate
          %x{
            var obj = new self.$$constructor();
            obj.$$id = Opal.uid();
            return obj;
          }
        end
      }
    }
  }

  def inherited(cls)
  end

  def initialize_dup(original)
    initialize_copy(original)
    %x{
      self.$$name = null;
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
    `self.$$super || nil`
  end

  def to_s
    %x{
      var singleton_of = self.$$singleton_of;

      if (singleton_of && singleton_of.$$is_a_module) {
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
