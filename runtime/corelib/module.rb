class Module
  def ===(object)
    object.kind_of? self
  end

  def alias_method(newname, oldname)
    `$opal.alias(this, newname, oldname)`

    self
  end

  def ancestors
    %x{
      var parent = this,
          result = [];

      while (parent) {
        if (!(parent.$flags & FL_SINGLETON)) {
          result.push(parent);
        }

        parent = parent.$s;
      }

      return result;
    }
  end

  def append_features(mod)
    `include_module(mod, this)`

    self
  end

  def attr_accessor(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return nil;
    }
  end

  def attr_accessor_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], true, true);
      }

      return nil;
    }
  end

  def attr_reader(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return nil;
    }
  end

  def attr_reader_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], true, false);
      }

      return nil;
    }
  end

  def attr_writer(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return nil;
    }
  end

  def attr_reader_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], false, true);
      }

      return nil;
    }
  end

  def attr(name, setter = false)
    `define_attr(this, name, true, setter)`

    self
  end

  def attr_bridge(target, name, setter = false)
    `define_attr_bridge(this, target, name, true, setter)`

    self
  end

  def define_method(name, &body)
    %x{
      if (body === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      define_method(this, mid_to_jsid(name), body);
      this.$methods.push(name);

      return nil;
    }
  end

  def define_method_bridge(object, name, ali = nil)
    %x{
      define_method_bridge(this, object, mid_to_jsid(#{ali || name}), name);
      this.$methods.push(name);

      return nil;
    }
  end

  def include(*mods)
    %x{
      var i = mods.length - 1, mod;
      while (i >= 0) {
        #{mod = `mods[i]`};
        #{mod.append_features self};
        #{mod.included self};

        i--;
      }

      return this;
    }
  end

  def instance_methods
    `this.$methods`
  end

  def included(mod)
    nil
  end

  def module_eval(&block)
    %x{
      if (block === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      return block.call(this, null);
    }
  end

  alias_method :class_eval, :module_eval

  def name
    `this.__classid__`
  end

  alias_method :public_instance_methods, :instance_methods

  alias_method :to_s, :name
end