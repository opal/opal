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
    `rb_alias_method(self, #{new.to_s}, #{old.to_s});`

    self
  end

  def ancestors
    `
      var result = [], parent = self;

      while (parent) {
        if (parent.o$f & FL_SINGLETON) {
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
    `
      for (var i = 0, ii = attributes.length; i < ii; i++) {
        rb_attr(self, attributes[i], true, true);
      }
    `

    nil
  end

  def attr_reader(*attributes)
    `
      for (var i = 0, ii = attributes.length; i < ii; i++) {
        rb_attr(self, attributes[i], true, false);
      }
    `

    nil
  end

  def attr_writer(*attributes)
    `
      for (var i = 0, ii = attributes.length; i < ii; i++) {
        rb_attr(self, attributes[i], false, true);
      }
    `

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

    `rb_define_method(self, #{name.to_s}, block);`

    nil
  end

  def extend(*modules)
    modules.each {|mod|
      `rb_extend_module(self, mod);`
    }

    self
  end

  def include(*modules)
    `var i = modules.length - 1, mod;
    while (i >= 0) {
      mod = modules[i];
      #{`mod`.append_features self};
      #{`mod`.included self};
      i--;
    }
    return self;`
    self
  end

  def included(mod)
    nil
  end

  def instance_methods
    `self.$methods`
  end

  def class_eval(&block)
    `block.call(self)`
  end

  alias_method :module_eval, :class_eval

  def name
    `self.__classid__`
  end

  alias_method :public_instance_methods, :instance_methods

  alias_method :to_s, :name
end
