class Class
  def self.new(sup = Object, &block)
    %x{
      function AnonClass(){};
      var klass   = Opal.boot(sup, AnonClass)
      klass._name = nil;
      klass._scope = sup._scope;

      sup.$inherited(klass);

      if (block !== nil) {
        var block_self = block._s;
        block._s = null;
        block.call(klass);
        block._s = block_self;
      }

      return klass;
    }
  end

  def self.bridge_class(name, constructor)
    `__opal.bridge(name, constructor)`
  end

  def ===(object)
    %x{
      if (object == null) {
        return false;
      }

      var search = object._klass;

      while (search) {
        if (search === #{self}) {
          return true;
        }

        search = search._super;
      }

      return false;
    }
  end

  def allocate
    %x{
      var obj = new #{self}._alloc;
      obj._id = Opal.uid();
      return obj;
    }
  end

  def alias_method(newname, oldname)
    `#{self}._proto['$' + newname] = #{self}._proto['$' + oldname]`
    self
  end

  def alias_native(mid, jsid)
    `#{self}._proto['$' + mid] = #{self}._proto[jsid]`
  end

  def ancestors
    %x{
      var parent = #{self},
          result = [];

      while (parent) {
        result.push(parent);
        parent = parent._super;
      }

      return result;
    }
  end

  def append_features(klass)
    %x{
      var module = #{self};

      if (!klass.$included_modules) {
        klass.$included_modules = [];
      }

      for (var idx = 0, length = klass.$included_modules.length; idx < length; idx++) {
        if (klass.$included_modules[idx] === module) {
          return;
        }
      }

      klass.$included_modules.push(module);

      if (!module._included_in) {
        module._included_in = [];
      }

      module._included_in.push(klass);

      var donator   = module._proto,
          prototype = klass._proto,
          methods   = module._methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];
        prototype[method] = donator[method];
      }

      // if (prototype._smethods) {
      //  prototype._smethods.push.apply(prototype._smethods, methods);
      //}

      if (klass._included_in) {
        __opal.donate(klass, methods.slice(), true);
      }
    }

    self
  end

  def attr_accessor(*names)
    attr_reader *names
    attr_writer *names
  end

  def attr_reader(*names)
    %x{
      var proto = #{self}._proto, cls = #{self};
      for (var i = 0, length = names.length; i < length; i++) {
        (function(name) {
          proto[name] = nil;
          var func = function() { return this[name] };

          if (cls._isSingleton) {
            proto.constructor.prototype['$' + name] = func;
          }
          else {
            proto['$' + name] = func;
          }
        })(names[i]);
      }
    }

    nil
  end

  def attr_writer(*names)
    %x{
      var proto = #{self}._proto, cls = #{self};
      for (var i = 0, length = names.length; i < length; i++) {
        (function(name) {
          proto[name] = nil;
          var func = function(value) { return this[name] = value; };

          if (cls._isSingleton) {
            proto.constructor.prototype['$' + name + '='] = func;
          }
          else {
            proto['$' + name + '='] = func;
          }
        })(names[i]);
      }
    }
    nil
  end

  alias attr attr_accessor

  # when self is Module (or Class), implement 1st form:
  # - global constants, classes and modules in global scope
  # when self is not Module (or Class), implement 2nd form:
  # - constants, classes and modules scoped to instance
  def constants
    %x{
      var result = [];
      var name_re = /^[A-Z][A-Za-z0-9_]+$/;
      var scopes = [#{self}._scope];
      var own_only;
      if (#{self} === Opal.Class) {
        own_only = false;
      }
      else {
        own_only = true;
        var parent = #{self}._super;
        while (parent !== Opal.Object) {
          scopes.push(parent._scope);
          parent = parent._super;
        }
      }
      for (var i = 0, len = scopes.length; i < len; i++) {
        var scope = scopes[i]; 
        for (name in scope) {
          if ((!own_only || scope.hasOwnProperty(name)) && name_re.test(name)) {
            result.push(name);
          }
        }
      }

      return result;
    }
  end

  # check for constant within current scope
  # if inherit is true or self is Object, will also check ancestors
  def const_defined?(name, inherit = true)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w+$/
    %x{
      scopes = [#{self}._scope];
      if (inherit || #{self} === Opal.Object) {
        var parent = #{self}._super;
        while (parent !== Opal.BasicObject) {
          scopes.push(parent._scope);
          parent = parent._super;
        }
      }

      for (var i = 0, len = scopes.length; i < len; i++) {
        if (scopes[i].hasOwnProperty(name)) {
          return true;
        }
      }

      return false;
    }
  end

  # check for constant within current scope
  # if inherit is true or self is Object, will also check ancestors
  def const_get(name, inherit = true)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w+$/
    %x{
      var scopes = [#{self}._scope];
      if (inherit || #{self} == Opal.Object) {
        var parent = #{self}._super;
        while (parent !== Opal.BasicObject) {
          scopes.push(parent._scope);
          parent = parent._super;
        }
      }

      for (var i = 0, len = scopes.length; i < len; i++) {
        if (scopes[i].hasOwnProperty(name)) {
          return scopes[i][name];
        }
       }

      return #{const_missing name};
    }
  end

  def const_missing(const)
    name = `#{self}._name`
    raise NameError, "uninitialized constant #{name}::#{const}"
  end

  def const_set(name, value)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w+$/
    begin
      name = name.to_str
    rescue
      raise TypeError, 'conversion with #to_str failed'
    end
    %x{
      #{self}._scope[name] = #{value};

      if (value._isClass && value._name === nil) {
        value._name = #{self.name} + '::' + name;
      }

      return #{value}
    }
  end

  def define_method(name, method = undefined, &block)
    %x{
      if (method) {
        block = method;
      }

      if (block === nil) {
        no_block_given();
      }

      var jsid    = '$' + name;
      block._jsid = jsid;
      block._sup  = #{self}._proto[jsid];
      block._s    = null;

      #{self}._proto[jsid] = block;
      __opal.donate(#{self}, [jsid]);

      return null;
    }
  end

  def include(*mods)
    %x{
      var i = mods.length - 1, mod;
      while (i >= 0) {
        mod = mods[i];
        i--;

        if (mod === #{self}) {
          continue;
        }

        #{ `mod`.append_features self };
        #{ `mod`.included self };
      }

      return #{self};
    }
  end

  def instance_methods(include_super = false)
    %x{
      var methods = [], proto = #{self}._proto;

      for (var prop in #{self}._proto) {
        if (!include_super && !proto.hasOwnProperty(prop)) {
          continue;
        }

        if (prop.charAt(0) === '$') {
          methods.push(prop.substr(1));
        }
      }

      return methods;
    }
  end

  def included(mod)
  end

  def inherited(cls)
  end

  def module_eval(&block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      var block_self = block._s, result;

      block._s = null;
      result = block.call(#{self});
      block._s = block_self;

      return result;
    }
  end

  alias class_eval module_eval

  def method_defined?(method)
    %x{
      if (typeof(#{self}._proto['$' + method]) === 'function') {
        return true;
      }

      return false;
    }
  end

  def module_function(*methods)
    %x{
      for (var i = 0, length = methods.length; i < length; i++) {
        var meth = methods[i], func = #{self}._proto['$' + meth];

        #{self}.constructor.prototype['$' + meth] = func;
      }

      return #{self};
    }
  end

  def name
    `#{self}._name`
  end

  def new(*args, &block)
    %x{
      if (#{self}._proto.$initialize) {
        var obj = new #{self}._alloc;
        obj._id = Opal.uid();

        obj.$initialize._p = block;
        obj.$initialize.apply(obj, args);
        return obj;
      }
      else {
        var cons = function() {};
        cons.prototype = #{self}.prototype;
        var obj = new cons;
        #{self}.apply(obj, args);
        return obj;
      }
    }
  end

  def public(*)
  end

  alias private public
  alias protected public

  def superclass
    `#{self}._super || nil`
  end

  def to_s
    `#{self}._name`
  end

  def undef_method(symbol)
    `#{self}._proto['$' + symbol] = undefined`
    self
  end
end
