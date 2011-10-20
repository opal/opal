class Module
  def self.constants
    raise NotImplementedError, 'Module.constants not yet implemented'
  end

  def self.nesting
    raise NotImplementedError, 'Module.nesting not yet imlemented'
  end

  def self.new(&block)
    mod = `rb_define_module_id()`
    mod.instance_eval &block if block

    mod
  end

  def ===(object)
    object.kind_of? self
  end

  def alias_method(new, old)
    `VM.alias_method(self, #{new.to_s}, #{old.to_s});`

    self
  end

  def ancestors
    `
      var result = [], parent = self;

      while (parent) {
        if (parent.$f & FL_SINGLETON) {
          // nothing?
        }
        else {
          result.push(parent);
        }

        parent = parent.$super;
      }

      return result;
    `
  end

  def attr_accessor(*attributes)
    attr_reader *attributes
    attr_writer *attributes
  end

  def attr_reader(*attributes)
    attributes.each {|attr|
      `
        VM.dm(self, #{attr}, function (self, name) {
          return self[name];
        });
      `
    }

    nil
  end

  def attr_writer(*attributes)
    attributes.each {|attr|
      %x{
        VM.dm(self, #{attr} + '=', function (self, name, value) {
          return self[name.substr(0, name.length)] = value;
        });
      }
    }

    nil
  end

  def append_features(mod)
    `VM.im(mod, self)`

    self
  end

  def const_set(id, value)
    `return rb_const_set(self, #{id.to_s}, value);`
  end

  def define_method(name, &block)
    raise LocalJumpError, 'no block given' unless block_given?

    `VM.dm(self, #{name.to_s}, block)`

    nil
  end

  def extend (*modules)
    modules.each {|mod|
      `rb_extend_module(self, mod);`
    }

    self
  end

  def include(*modules)
    `for (var i = 0; i < modules.length; i++) {
      #{mod = `modules[i]`};
      #{mod.append_features self};
      #{mod.included self};
    }`

    self
  end

  def included (mod)
    nil
  end

  def instance_methods
    `self.$methods`
  end

  def class_eval(&block)
    `block(self, null)`
  end

  alias_method :module_eval, :class_eval

  def name
    `self.__classid__`
  end

  alias_method :public_instance_methods, :instance_methods

  alias_method :to_s, :name
end
