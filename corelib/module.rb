class Module
  def self.new(&block)
    %x{
      function AnonModule(){}
      var klass     = Opal.boot(Module, AnonModule);
      klass._name   = nil;
      klass._scope  = Module._scope;
      klass._klass  = Module;
      klass.__dep__ = []
      klass.__mod__ = true;

      if (block !== nil) {
        var block_self = block._s;
        block._s = null;
        block.call(klass);
        block._s = block_self;
      }

      return klass;
    }
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

  def <(other)
    %x{
      var working = self;

      while (working) {
        if (working === other) {
          return true;
        }

        working = working.__parent;
      }

      return false;
    }
  end

  def alias_method(newname, oldname)
    %x{
      #{self}._proto['$' + newname] = #{self}._proto['$' + oldname];

      if (self._methods) {
        $opal.donate(self, ['$' + newname ])
      }
    }
    self
  end

  def alias_native(mid, jsid = mid)
    `#{self}._proto['$' + mid] = #{self}._proto[jsid]`
  end

  def ancestors
    %x{
      var parent = #{self},
          result = [];

      while (parent) {
        result.push(parent);
        result = result.concat(parent.__inc__);

        parent = parent._super;
      }

      return result;
    }
  end

  def append_features(klass)
    %x{
      var module = #{self}, included = klass.__inc__;

      // check if this module is already included in the klass
      for (var idx = 0, length = included.length; idx < length; idx++) {
        if (included[idx] === module) {
          return;
        }
      }

      included.push(module);

      module.__dep__.push(klass);

      // iclass
      var iclass = {
        _proto: module._proto,
        __parent: klass.__parent,
        name: module._name,
        __iclass: true
      };

      klass.__parent = iclass;

      var donator   = module._proto,
          prototype = klass._proto,
          methods   = module._methods;

      for (var i = 0, length = methods.length; i < length; i++) {
        var method = methods[i];

        if (prototype.hasOwnProperty(method) && !prototype[method]._donated) {
          // if the target class already has a method of the same name defined
          // and that method was NOT donated, then it must be a method defined
          // by the class so we do not want to override it
        }
        else {
          prototype[method] = donator[method];
          prototype[method]._donated = true;
        }
      }

      if (klass.__dep__) {
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
            $opal.donate(self, ['$' + name ]);
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
            $opal.donate(self, ['$' + name + '=']);
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
    `#{self}._scope.constants`
  end

  # check for constant within current scope
  # if inherit is true or self is Object, will also check ancestors
  def const_defined?(name, inherit = true)
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

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
    raise NameError, "wrong constant name #{name}" unless name =~ /^[A-Z]\w*$/

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
        block = method;
      }

      if (block === nil) {
        throw new Error("no block given");
      }

      var jsid    = '$' + name;
      block._jsid = jsid;
      block._sup  = #{self}._proto[jsid];
      block._s    = null;

      #{self}._proto[jsid] = block;
      $opal.donate(#{self}, [jsid]);

      return null;
    }
  end

  def remove_method(name)
    %x{
      var jsid    = '$' + name;
      var current = #{self}._proto[jsid];
      var _sup = current._sup;
      #{self}._proto[jsid] = _sup;

      // Check if we need to reverse $opal.donate
      // $opal.retire(#{self}, [jsid]);
      return #{self};
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

  def instance_method(name)
    %x{
      var meth = self._proto['$' + name];

      if (!meth || meth.rb_stub) {
        #{raise NameError, "undefined method `#{name}' for class `#{self.name}'"};
      }

      return #{UnboundMethod.new(self, `meth`, name)};
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

  def module_eval(&block)
    %x{
      if (block === nil) {
        throw new Error("no block given");
      }

      var block_self = block._s, result;

      block._s = null;
      result = block.call(#{self});
      block._s = block_self;

      return result;
    }
  end

  alias class_eval module_eval
  alias class_exec module_eval
  alias module_exec module_eval

  def method_defined?(method)
    %x{
      var body = #{self}._proto['$' + method];
      return (!!body) && !body.rb_stub;
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

  def public(*)
  end

  def private_class_method(name)
    `self['$' + name] || nil`
  end

  alias private public
  alias protected public

  alias public_instance_methods instance_methods

  alias public_method_defined? method_defined?

  def remove_class_variable(*)

  end

  def remove_const(name)
    %x{
      var old = #{self}._scope[name];
      delete #{self}._scope[name];
      return old;
    }
  end

  def to_s
    `#{self}._name`
  end

  def undef_method(symbol)
    `$opal.add_stub_for(#{self}._proto, "$" + symbol)`
    self
  end
end
