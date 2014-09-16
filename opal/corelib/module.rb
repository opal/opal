class Module
  def self.new(&block)
    %x{
      function AnonModule(){}
      var klass     = Opal.boot(Opal.Module, AnonModule);
      klass.$$name  = nil;
      klass.$$class = Opal.Module;
      klass.$$dep   = []
      klass.$$mod   = true;
      klass.$$proto = {};

      // inherit scope from parent
      $opal.create_scope(Opal.Module.$$scope, klass);

      if (block !== nil) {
        var block_self = block.$$s;
        block.$$s = null;
        block.call(klass);
        block.$$s = block_self;
      }

      return klass;
    }
  end

  def ===(object)
    return false if `object == null`

    `$opal.is_a(object, self)`
  end

  def <(other)
    %x{
      var working = self;

      while (working) {
        if (working === other) {
          return true;
        }

        working = working.$$parent;
      }

      return false;
    }
  end

  def alias_method(newname, oldname)
    %x{
      self.$$proto['$' + newname] = self.$$proto['$' + oldname];

      if (self.$$methods) {
        $opal.donate(self, ['$' + newname ])
      }
    }
    self
  end

  def alias_native(mid, jsid = mid)
    `self.$$proto['$' + mid] = self.$$proto[jsid]`
  end

  def ancestors
    %x{
      var parent = self,
          result = [];

      while (parent) {
        result.push(parent);
        result = result.concat(parent.$$inc);

        parent = parent.$$super;
      }

      return result;
    }
  end

  def append_features(klass)
    %x{
      var module   = self,
          included = klass.$$inc;

      // check if this module is already included in the klass
      for (var i = 0, length = included.length; i < length; i++) {
        if (included[i] === module) {
          return;
        }
      }

      included.push(module);
      module.$$dep.push(klass);

      // iclass
      var iclass = {
        name: module.$$name,

        $$proto:   module.$$proto,
        $$parent: klass.$$parent,
        __iclass: true
      };

      klass.$$parent = iclass;

      var donator   = module.$$proto,
          prototype = klass.$$proto,
          methods   = module.$$methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];

        if (prototype.hasOwnProperty(method) && !prototype[method].$$donated) {
          // if the target class already has a method of the same name defined
          // and that method was NOT donated, then it must be a method defined
          // by the class so we do not want to override it
        }
        else {
          prototype[method] = donator[method];
          prototype[method].$$donated = true;
        }
      }

      if (klass.$$dep) {
        $opal.donate(klass, methods.slice(), true);
      }

      $opal.donate_constants(module, klass);
    }

    self
  end

  def attr_accessor(*names)
    attr_reader(*names)
    attr_writer(*names)
  end

  def attr_reader(*names)
    %x{
      var proto = self.$$proto, cls = self;
      for (var i = 0, length = names.length; i < length; i++) {
        (function(name) {
          proto[name] = nil;
          var func = function() { return this[name] };

          if (cls.$$is_singleton) {
            proto.constructor.prototype['$' + name] = func;
          }
          else {
            proto['$' + name] = func;
            $opal.donate(self, ['$' + name ]);
          }
        })(names[i]);
      }
    }

    nil
  end

  def attr_writer(*names)
    %x{
      var proto = self.$$proto, cls = self;
      for (var i = 0, length = names.length; i < length; i++) {
        (function(name) {
          proto[name] = nil;
          var func = function(value) { return this[name] = value; };

          if (cls.$$is_singleton) {
            proto.constructor.prototype['$' + name + '='] = func;
          }
          else {
            proto['$' + name + '='] = func;
            $opal.donate(self, ['$' + name + '=']);
          }
        })(names[i]);
      }
    }
    nil
  end

  alias attr attr_accessor

  def autoload(const, path)
    %x{
      var autoloaders;

      if (!(autoloaders = self.$$autoload)) {
        autoloaders = self.$$autoload = {};
      }

      autoloaders[#{const}] = #{path};
      return nil;
    }
  end

  def constants
    `self.$$scope.constants`
  end

  # check for constant within current scope
  # if inherit is true or self is Object, will also check ancestors
  def const_defined?(name, inherit = true)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

    %x{
      scopes = [self.$$scope];
      if (inherit || self === Opal.Object) {
        var parent = self.$$super;
        while (parent !== Opal.BasicObject) {
          scopes.push(parent.$$scope);
          parent = parent.$$super;
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

  def const_get(name, inherit = true)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

    %x{
      var scopes = [self.$$scope];
      if (inherit || self == Opal.Object) {
        var parent = self.$$super;
        while (parent !== Opal.BasicObject) {
          scopes.push(parent.$$scope);
          parent = parent.$$super;
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
    %x{
      var autoloader;

      if (self.$$autoload && (autoloader = self.$$autoload[#{const}])) {
        self.$require(autoloader);
        return self.$$scope.get(#{const});
      }
    }

    name = `self.$$name`

    raise NameError, "uninitialized constant #{name}::#{const}"
  end

  def const_set(name, value)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

    begin
      name = name.to_str
    rescue
      raise TypeError, 'conversion with #to_str failed'
    end

    %x{
      $opal.casgn(self, name, value);
      return #{value}
    }
  end

  def define_method(name, method = undefined, &block)
    %x{
      if (method) {
        block = #{method.to_proc};
      }

      if (block === nil) {
        throw new Error("no block given");
      }

      var jsid    = '$' + name;
      block.$$jsid = name;
      block.$$s    = null;
      block.$$def  = block;

      self.$$proto[jsid] = block;
      $opal.donate(self, [jsid]);

      return name;
    }
  end

  def remove_method(name)
    %x{
      var jsid    = '$' + name;
      var current = self.$$proto[jsid];
      delete self.$$proto[jsid];

      // Check if we need to reverse $opal.donate
      // $opal.retire(self, [jsid]);
      return self;
    }
  end

  def include(*mods)
    %x{
      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (mod === self) {
          continue;
        }

        #{`mod`.append_features self};
        #{`mod`.included self};
      }
    }

    self
  end

  def include?(mod)
    %x{
      for (var cls = self; cls; cls = cls.parent) {
        for (var i = 0; i != cls.$$inc.length; i++) {
          var mod2 = cls.$$inc[i];
          if (mod === mod2) {
            return true;
          }
        }
      }
      return false;
    }
  end

  def instance_method(name)
    %x{
      var meth = self.$$proto['$' + name];

      if (!meth || meth.rb_stub) {
        #{raise NameError, "undefined method `#{name}' for class `#{self.name}'"};
      }

      return #{UnboundMethod.new(self, `meth`, name)};
    }
  end

  def instance_methods(include_super = false)
    %x{
      var methods = [], proto = self.$$proto;

      for (var prop in self.$$proto) {
        if (!include_super && !proto.hasOwnProperty(prop)) {
          continue;
        }

        if (!include_super && proto[prop].$$donated) {
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

  def extended(mod)
  end

  def module_eval(&block)
    raise ArgumentError, 'no block given' unless block

    %x{
      var old = block.$$s,
          result;

      block.$$s = null;
      result = block.call(self);
      block.$$s = old;

      return result;
    }
  end

  alias class_eval module_eval

  def module_exec(&block)
    %x{
      if (block === nil) {
        throw new Error("no block given");
      }

      var block_self = block.$$s, result;

      block.$$s = null;
      result = block.apply(self, $slice.call(arguments));
      block.$$s = block_self;

      return result;
    }
  end

  alias class_exec module_exec

  def method_defined?(method)
    %x{
      var body = self.$$proto['$' + method];
      return (!!body) && !body.rb_stub;
    }
  end

  def module_function(*methods)
    %x{
      for (var i = 0, length = methods.length; i < length; i++) {
        var meth = methods[i], func = self.$$proto['$' + meth];

        self.constructor.prototype['$' + meth] = func;
      }

      return self;
    }
  end

  def name
    %x{
      if (self.$$full_name) {
        return self.$$full_name;
      }

      var result = [], base = self;

      while (base) {
        if (base.$$name === nil) {
          return result.length === 0 ? nil : result.join('::');
        }

        result.unshift(base.$$name);

        base = base.$$base_module;

        if (base === $opal.Object) {
          break;
        }
      }

      if (result.length === 0) {
        return nil;
      }

      return self.$$full_name = result.join('::');
    }
  end

  def public(*)
  end

  alias private public
  alias protected public
  alias nesting public

  def private_class_method(name)
    `self['$' + name] || nil`
  end
  alias public_class_method private_class_method

  def private_method_defined?(obj)
    false
  end

  def private_constant(*)
  end

  alias protected_method_defined? private_method_defined?

  alias public_instance_methods instance_methods

  alias public_method_defined? method_defined?

  def remove_class_variable(*)
  end

  def remove_const(name)
    %x{
      var old = self.$$scope[name];
      delete self.$$scope[name];
      return old;
    }
  end

  def to_s
    name.to_s
  end

  def undef_method(symbol)
    `$opal.add_stub_for(self.$$proto, "$" + symbol)`
    self
  end
end
