class Module
  def ===(object)
    %x{
      var search = object._klass;

      while (search) {
        if (search === this) {
          return true;
        }

        search = search._super;
      }

      return false;
    }
  end

  def alias_method(newname, oldname)
    `opal.alias(this, newname, oldname)`

    self
  end

  def ancestors
    %x{
      var parent = this,
          result = [];

      while (parent) {
        if (parent._flags & FL_SINGLETON) {
          continue;
        }
        else if (parent._flags & T_ICLASS)
          result.push(parent._klass);
        else {
          result.push(parent);
        }

        parent = parent._super;
      }

      return result;
    }
  end

  def append_features(klass)
    %x{
      var module = this;

      if (!klass.$included_modules) {
        klass.$included_modules = [];
      }

      if (klass.$included_modules.indexOf(module) != -1) {
        return;
      }

      klass.$included_modules.push(module);

      if (!module.$included_in) {
        module.$included_in = [];
      }

      module.$included_in.push(klass);

      var donator   = module._alloc.prototype,
          prototype = klass._proto,
          methods   = [];

      for (var method in donator) {
        if (hasOwnProperty.call(donator, method)) {
          if (!prototype.hasOwnProperty(method)) {
            prototype[method] = donator[method];
            methods.push(method);
          }
        }
      }

      if (klass.$included_in) {
        __donate(klass, methods);
      }
    }

    self
  end

  # Private helper function to define attributes
  %x{
    function define_attr(klass, name, getter, setter) {
      if (getter) {
        define_method(klass, mid_to_jsid(name), function() {
          var res = this[name];

          return res == null ? null : res;
        });
      }

      if (setter) {
        define_method(klass, mid_to_jsid(name + '='), function(val) {
          return this[name] = val;
        });
      }
    }
  }

  def attr_accessor(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, true);
      }

      return null;
    }
  end

  def attr_reader(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], true, false);
      }

      return null;
    }
  end

  def attr_writer(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return null;
    }
  end

  def attr(name, setter = false)
    `define_attr(this, name, true, setter)`

    self
  end

  def define_method(name, &body)
    %x{
      if (body === null) {
        throw RubyLocalJumpError.$new('no block given');
      }

      var jsid = mid_to_jsid(name);

      body.o$jsid = jsid;
      define_method(this, jsid, body);

      return null;
    }
  end

  def include(*mods)
    %x{
      var i = mods.length - 1, mod;
      while (i >= 0) {
        #{mod = `mods[i]`};

        define_iclass(this, mod);

        #{mod.append_features self};
        #{mod.included self};

        i--;
      }

      return this;
    }
  end

  # FIXME
  def instance_methods
    []
  end

  def included(mod)
  end

  def module_eval(&block)
    %x{
      if (block === nil) {
        throw RubyLocalJumpError.$new('no block given');
      }

      return block.call(this);
    }
  end

  alias class_eval module_eval

  def name
    `this._name`
  end

  alias public_instance_methods instance_methods

  alias to_s name
end
