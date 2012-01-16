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
        if (!(parent.o$flags & FL_SINGLETON)) {
          result.push(parent);
        }

        parent = parent.$s;
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

      var donator   = module.$allocator.prototype,
          prototype = klass.$proto,
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
        klass.$donate(methods);
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

          return res == null ? nil : res;
        });
      }

      if (setter) {
        define_method(klass, mid_to_jsid(name + '='), function(block, val) {
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

  def attr_writer(*attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr(this, attrs[i], false, true);
      }

      return nil;
    }
  end

  def attr(name, setter = false)
    `define_attr(this, name, true, setter)`

    self
  end

  def define_method(name, &body)
    %x{
      if (body === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      define_method(this, mid_to_jsid(name), body);

      return nil;
    }
  end

  # FIXME: this could do with a better name
  def donate(methods)
    %x{
      var included_in = this.$included_in, includee, method, table = this.$proto, dest;

      if (included_in) {
        for (var i = 0, length = included_in.length; i < length; i++) {
          includee = included_in[i];
          dest = includee.$proto;
          for (var j = 0, jj = methods.length; j < jj; j++) {
            method = methods[j];
            // if (!dest[method]) {
              dest[method] = table[method];
            // }
          }
          // if our includee is itself included in another module/class then it
          // should also donate its new methods
          if (includee.$included_in) {
            includee.$donate(methods);
          }
        }
      }
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

  # FIXME
  def instance_methods
    []
  end

  def included(mod)
  end

  def module_eval(&block)
    %x{
      if (block === nil) {
        raise(RubyLocalJumpError, 'no block given');
      }

      return block.call(this, null);
    }
  end

  alias class_eval module_eval

  def name
    `this.o$name`
  end

  alias public_instance_methods instance_methods

  alias to_s name
end
