class Module
  def ===(object)
    object.kind_of? self
  end

  def alias_method(newname, oldname)
    `rb_alias_method(self, newname, oldname)`

    self
  end

  def ancestors
    `
      var parent = self,
          result = [];

      while (parent) {
        if (!(parent.$f & FL_SINGLETON)) {
          result.push(parent);
        }

        parent = parent.$s;
      }

      return result;
    `
  end

  def append_features(mod)
    `rb_include_module(mod, self)`

    self
  end

  def attr_accessor(*attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(self, attrs[i], true, true);
      }

      return nil;
    `
  end

  def attr_accessor_bridge(target, *attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(self, target, attrs[i], true, true);
      }

      return nil;
    `
  end

  def attr_reader(*attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(self, attrs[i], true, false);
      }

      return nil;
    `
  end

  def attr_reader_bridge(target, *attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(self, target, attrs[i], true, false);
      }

      return nil;
    `
  end

  def attr_writer(*attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(self, attrs[i], false, true);
      }

      return nil;
    `
  end

  def attr_reader_bridge(target, *attrs)
    `
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(self, target, attrs[i], false, true);
      }

      return nil;
    `
  end

  def attr(name, setter = false)
    `define_attr(self, name, true, setter)`

    self
  end

  def attr_bridge(target, name, setter = false)
    `define_attr_bridge(self, target, name, true, setter)`

    self
  end

  def define_method(name, &body)
    `
      if (body === nil) {
        rb_raise(RubyLocalJumpError, 'no block given');
      }

      define_method(self, mid_to_jsid(name), body);
      self.$methods.push(name);

      return nil;
    `
  end

  def define_method_bridge(object, name, ali = nil)
    `
      define_method_bridge(self, mid_to_jsid(#{ali || name}), name);
      self.$methods.push(name);

      return nil;
    `
  end

  def include(*mods)
    `
      var i = mods.length - 1, mod;
      while (i >= 0) {
        #{mod = `mods[i]`};
        #{mod.append_features self};
        #{mod.included self};

        i--;
      }

      return self;
    `
  end

  def instance_methods
    `self.$methods`
  end

  def included(mod)
    nil
  end

  def module_eval(&block)
    `
      if (block === nil) {
        rb_raise(RubyLocalJumpError, 'no block given');
      }

      return block.call(self, null);
    `
  end

  alias_method :class_eval, :module_eval

  def name
    `self.__classid__`
  end

  alias_method :public_instance_methods, :instance_methods

  alias_method :to_s, :name
end
