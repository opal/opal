class Module
  def self.new(&block)
    %x{
      function AnonModule(){}
      var klass      = Opal.boot(Opal.Module, AnonModule);
      klass.$$name   = nil;
      klass.$$class  = Opal.Module;
      klass.$$dep    = []
      klass.$$is_mod = true;
      klass.$$proto  = {};

      // inherit scope from parent
      Opal.create_scope(Opal.Module.$$scope, klass);

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

    `Opal.is_a(object, self)`
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
      var newjsid = '$' + newname,
          body    = self.$$proto['$' + oldname];

      if (self.$$is_singleton) {
        self.$$proto[newjsid] = body;
      }
      else {
        Opal.defn(self, newjsid, body);
      }

      return self;
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
    `Opal.append_features(self, klass)`
    self
  end

  def attr_accessor(*names)
    attr_reader(*names)
    attr_writer(*names)
  end

  alias attr attr_accessor

  def attr_reader(*names)
    %x{
      var proto = self.$$proto;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name;

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(name) {
          return function() {
            return this[name];
          };
        })(name);

        // initialize the instance variable as nil
        proto[name] = nil;

        if (self.$$is_singleton) {
          proto.constructor.prototype[id] = body;
        }
        else {
          Opal.defn(self, id, body);
        }
      }
    }

    nil
  end

  def attr_writer(*names)
    %x{
      var proto = self.$$proto;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name + '=';

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(name){
          return function(value) {
            return this[name] = value;
          }
        })(name);

        // initialize the instance variable as nil
        proto[name] = nil;

        if (self.$$is_singleton) {
          proto.constructor.prototype[id] = body;
        }
        else {
          Opal.defn(self, id, body);
        }
      }
    }

    nil
  end

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

  def class_variable_get(name)
    name = Opal.coerce_to!(name, String, :to_str)
    raise NameError, 'class vars should start with @@' if `name.length < 3 || name.slice(0,2) !== '@@'`
    %x{
      var value = Opal.cvars[name.slice(2)];
      #{raise NameError, 'uninitialized class variable @@a in' if `value == null`}
      return value;
    }
  end

  def class_variable_set(name, value)
    name = Opal.coerce_to!(name, String, :to_str)
    raise NameError if `name.length < 3 || name.slice(0,2) !== '@@'`
    %x{
      Opal.cvars[name.slice(2)] = value;
      return value;
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

      for (var i = 0, length = scopes.length; i < length; i++) {
        if (scopes[i].hasOwnProperty(name)) {
          return true;
        }
      }

      return false;
    }
  end

  def const_get(name, inherit = true)
    if name['::'] && name != '::'
      return name.split('::').inject(self){|o, c| o.const_get(c)}
    end
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

      for (var i = 0, length = scopes.length; i < length; i++) {
        if (scopes[i].hasOwnProperty(name)) {
          return scopes[i][name];
        }
      }

      return #{const_missing name};
    }
  end

  def const_missing(name)
    %x{
      if (self.$$autoload) {
        var file = self.$$autoload[name];

        if (file) {
          self.$require(file);

          return #{const_get name};
        }
      }
    }

    raise NameError, "uninitialized constant #{self}::#{name}"
  end

  def const_set(name, value)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

    begin
      name = name.to_str
    rescue
      raise TypeError, 'conversion with #to_str failed'
    end

    `Opal.casgn(self, name, value)`

    value
  end

  def define_method(name, method = undefined, &block)
    if `method === undefined && !#{block_given?}`
      raise ArgumentError, "tried to create a Proc object without a block"
    end

    block ||= case method
              when Proc
                method
              when Method
                method.to_proc
              when UnboundMethod
                lambda do |*args|
                  bound = method.bind(self)
                  bound.call *args
                end
              else
                raise TypeError, "wrong argument type #{block.class} (expected Proc/Method)"
              end

    %x{
      var id = '$' + name;

      block.$$jsid = name;
      block.$$s    = null;
      block.$$def  = block;

      if (self.$$is_singleton) {
        self.$$proto[id] = block;
      }
      else {
        Opal.defn(self, id, block);
      }

      return name;
    }
  end

  def remove_method(name)
    `Opal.undef(self, '$' + name)`

    self
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
      for (var cls = self; cls; cls = cls.$$super) {
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

      if (!meth || meth.$$stub) {
        #{raise NameError, "undefined method `#{name}' for class `#{self.name}'"};
      }

      return #{UnboundMethod.new(self, `meth`, name)};
    }
  end

  def instance_methods(include_super = true)
    %x{
      var methods = [],
          proto   = self.$$proto;

      for (var prop in proto) {
        if (!(prop.charAt(0) === '$')) {
          continue;
        }

        if (!(typeof(proto[prop]) === "function")) {
          continue;
        }

        if (proto[prop].$$stub) {
          continue;
        }

        if (!self.$$is_mod) {
          if (self !== Opal.BasicObject && proto[prop] === Opal.BasicObject.$$proto[prop]) {
            continue;
          }

          if (!include_super && !proto.hasOwnProperty(prop)) {
            continue;
          }

          if (!include_super && proto[prop].$$donated) {
            continue;
          }
        }

        methods.push(prop.substr(1));
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
      return (!!body) && !body.$$stub;
    }
  end

  def module_function(*methods)
    %x{
      if (methods.length === 0) {
        self.$$module_function = true;
      }
      else {
        for (var i = 0, length = methods.length; i < length; i++) {
          var meth = methods[i], func = self.$$proto['$' + meth];

          self.constructor.prototype['$' + meth] = func;
        }
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

        if (base === Opal.Object) {
          break;
        }
      }

      if (result.length === 0) {
        return nil;
      }

      return self.$$full_name = result.join('::');
    }
  end

  def public(*methods)
    %x{
      if (methods.length === 0) {
        self.$$module_function = false;
      }

      return nil;
    }
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
    name || "#<#{`self.$$is_mod ? 'Module' : 'Class'`}:0x#{__id__.to_s(16)}>"
  end

  def undef_method(symbol)
    `Opal.add_stub_for(self.$$proto, "$" + symbol)`

    self
  end
end
