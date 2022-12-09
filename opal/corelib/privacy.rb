# helpers: jsid, Object, truthy

%x{
  function set_privacy(mod, methods, privacy) {
    var methods_array, methid, meth;

    if (methods.length === 0) {
      mod.$$module_function = false;
      mod.$$def_priv = privacy;
      return nil;
    }
    methods = (methods.length === 1) ? methods[0] : methods;
    methods_array = methods instanceof Array ? methods : [methods];
    for (var i = 0; i < methods_array.length; i++) {
      methid = methods_array[i];
      meth = mod.$$prototype[$jsid(methid)];

      if (meth == null && mod.$$is_module) {
        meth = Opal.Module.$$prototype[$jsid(methid)];
      }

      if (meth != null && !meth.$$stub) {
        meth.$$priv = privacy;
      }
      else {
        #{::Kernel.raise ::NameError, "undefined method `#{`methid`}' for class `#{`mod`}'"}
      }
    }
    return methods;
  }

  function get_privacy(mod, method) {
    return get_singleton_privacy(mod.$$prototype, method);
  }

  function get_singleton_privacy(mod, method) {
    var body = mod[$jsid(method)];
    return get_body_privacy(body);
  }

  function get_body_privacy(body) {
    if (body == null || body.$$stub) return;
    return body.$$priv;
  }

  function immediate_methods(obj, all) {
    if ($truthy(all)) {
      return Opal.methods(obj);
    } else {
      return Opal.receiver_methods(obj);
    }
  }
}

class ::Module
  `Opal.prop(#{self}.$$prototype, '$$def_priv', 'public')`

  def public(*methods)
    `set_privacy(self, methods, "public")`
  end

  def private(*methods)
    `set_privacy(self, methods, "private")`
  end

  def protected(*methods)
    `set_privacy(self, methods, "protected")`
  end

  def public_class_method(*methods)
    `set_privacy(#{singleton_class}, methods, "public")`
  end

  def private_class_method(*methods)
    `set_privacy(#{singleton_class}, methods, "private")`
  end

  def private_method_defined?(name, inherit = true)
    method_defined?(name, inherit) && `get_privacy(self, name) == "private"`
  end

  def protected_method_defined?(name, inherit = true)
    method_defined?(name, inherit) && `get_privacy(self, name) == "protected"`
  end

  def public_method_defined?(name, inherit = true)
    method_defined?(name, inherit) && `get_privacy(self, name) == "public"`
  end

  def public_instance_method(name)
    m = instance_method(name)
    privacy = `get_privacy(self, name)`
    ::Kernel.raise ::NameError, "method `#{name}' for class `#{self}' is #{privacy}" unless privacy == :public
    m
  end

  def public_instance_methods(inherit = true)
    instance_methods(inherit).select { |i| `get_privacy(self, i) == "public"` }
  end

  def private_instance_methods(inherit = true)
    instance_methods(inherit).select { |i| `get_privacy(self, i) == "private"` }
  end

  def protected_instance_methods(inherit = true)
    instance_methods(inherit).select { |i| `get_privacy(self, i) == "protected"` }
  end

  # Unsupported for now
  def private_constant(*)
  end

  # Unsupported for now
  alias nesting public
end

module ::Kernel
  def private_methods(inherit = true)
    `immediate_methods(self, inherit)`.select { |i| `get_singleton_privacy(self, i) == "private"` }
  end

  def protected_methods(inherit = true)
    `immediate_methods(self, inherit)`.select { |i| `get_singleton_privacy(self, i) == "protected"` }
  end

  def public_methods(inherit = true)
    `immediate_methods(self, inherit)`.select { |i| `get_singleton_privacy(self, i) == "public"` }
  end

  def public_method(name)
    m = method(name, false)
    privacy = `get_singleton_privacy(self, name)`
    ::Kernel.raise ::NameError, "method `#{name}' for class `#{singleton_class}' is #{privacy}" unless privacy == :public
    m
  end

  def public_send(symbol, *args, &block)
    privacy = `get_singleton_privacy(self, symbol)`
    if `privacy && privacy != "public"`
      ::Kernel.raise ::NoMethodError, "#{privacy} method `#{symbol}' called for #{self}:#{self.class}"
    end
    __send__(symbol, *args, &block)
  end

  private %i[sprintf format Integer String Array Hash print puts readline p caller_locations
             Complex fork caller Rational exit warn raise fail eval catch throw loop sleep rand
             srand at_exit load require require_relative autoload autoload? exit! system abort
             Float respond_to_missing? gets proc initialize_copy initialize_clone initialize_dup
             open printf]
end

class ::BasicObject
  private %i[initialize method_missing singleton_method_added singleton_method_removed
             singleton_method_undefined]
end

class ::Method
  def private?
    `get_body_privacy(#{@method}) == 'private'`
  end

  def public?
    `get_body_privacy(#{@method}) == 'public'`
  end

  def protected?
    `get_body_privacy(#{@method}) == 'protected'`
  end
end

def self.public(*methods)
  `set_privacy($Object, methods, "public")`
end

def self.private(*methods)
  `set_privacy($Object, methods, "private")`
end
