class Module
  def self.allocate
    %x{
      var module = Opal.allocate_module(nil, function(){});
      // Link the prototype of Module subclasses
      if (self !== Opal.Module) Object.setPrototypeOf(module, self.$$prototype);
      return module;
    }
  end

  def initialize(&block)
    module_eval(&block) if block_given?
  end

  def ===(object)
    return false if `object == null`

    `Opal.is_a(object, self)`
  end

  def <(other)
    unless Module === other
      raise TypeError, 'compared with non class/module'
    end

    # class cannot be a descendant of itself
    %x{
      var working = self,
          ancestors,
          i, length;

      if (working === other) {
        return false;
      }

      for (i = 0, ancestors = Opal.ancestors(self), length = ancestors.length; i < length; i++) {
        if (ancestors[i] === other) {
          return true;
        }
      }

      for (i = 0, ancestors = Opal.ancestors(other), length = ancestors.length; i < length; i++) {
        if (ancestors[i] === self) {
          return false;
        }
      }

      return nil;
    }
  end

  def <=(other)
    equal?(other) || self < other
  end

  def >(other)
    unless Module === other
      raise TypeError, 'compared with non class/module'
    end

    other < self
  end

  def >=(other)
    equal?(other) || self > other
  end

  def <=>(other)
    %x{
      if (self === other) {
        return 0;
      }
    }

    unless Module === other
      return nil
    end

    lt = self < other
    return nil if lt.nil?
    lt ? -1 : 1
  end

  def alias_method(newname, oldname)
    `Opal.alias(self, newname, oldname)`

    self
  end

  def alias_native(mid, jsid = mid)
    `Opal.alias_native(self, mid, jsid)`

    self
  end

  def ancestors
    `Opal.ancestors(self)`
  end

  def append_features(includer)
    `Opal.append_features(self, includer)`
    self
  end

  def attr_accessor(*names)
    attr_reader(*names)
    attr_writer(*names)
  end

  alias attr attr_accessor

  def attr_reader(*names)
    %x{
      var proto = self.$$prototype;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name,
            ivar = Opal.ivar(name);

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(ivar) {
          return function() {
            if (this[ivar] == null) {
              return nil;
            }
            else {
              return this[ivar];
            }
          };
        })(ivar);

        // initialize the instance variable as nil
        Opal.defineProperty(proto, ivar, nil);

        body.$$parameters = [];
        body.$$arity = 0;

        Opal.defn(self, id, body);
      }
    }

    nil
  end

  def attr_writer(*names)
    %x{
      var proto = self.$$prototype;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = '$' + name + '=',
            ivar = Opal.ivar(name);

        // the closure here is needed because name will change at the next
        // cycle, I wish we could use let.
        var body = (function(ivar){
          return function(value) {
            return this[ivar] = value;
          }
        })(ivar);

        body.$$parameters = [['req']];
        body.$$arity = 1;

        // initialize the instance variable as nil
        Opal.defineProperty(proto, ivar, nil);

        Opal.defn(self, id, body);
      }
    }

    nil
  end

  def autoload(const, path)
    %x{
      if (self.$$autoload == null) self.$$autoload = {};
      Opal.const_cache_version++;
      self.$$autoload[#{const}] = #{path};
      return nil;
    }
  end

  def class_variables
    `Object.keys(Opal.class_variables(self))`
  end

  def class_variable_get(name)
    name = Opal.class_variable_name!(name)
    %x{
      var value = Opal.class_variables(self)[name];
      if (value == null) {
        #{raise NameError.new("uninitialized class variable #{name} in #{self}", name)}
      }
      return value;
    }
  end

  def class_variable_set(name, value)
    name = Opal.class_variable_name!(name)

    `Opal.class_variable_set(self, name, value)`
  end

  def class_variable_defined?(name)
    name = Opal.class_variable_name!(name)

    `Opal.class_variables(self).hasOwnProperty(name)`
  end

  def remove_class_variable(name)
    name = Opal.class_variable_name!(name)

    %x{
      if (Opal.hasOwnProperty.call(self.$$cvars, name)) {
        var value = self.$$cvars[name];
        delete self.$$cvars[name];
        return value;
      } else {
        #{raise NameError, "cannot remove #{name} for #{self}"}
      }
    }
  end

  def constants(inherit = true)
    `Opal.constants(self, inherit)`
  end

  def self.constants(inherit = undefined)
    %x{
      if (inherit == null) {
        var nesting = (self.$$nesting || []).concat(Opal.Object),
            constant, constants = {},
            i, ii;

        for(i = 0, ii = nesting.length; i < ii; i++) {
          for (constant in nesting[i].$$const) {
            constants[constant] = true;
          }
        }
        return Object.keys(constants);
      } else {
        return Opal.constants(self, inherit)
      }
    }
  end

  def self.nesting
    `self.$$nesting || []`
  end

  # check for constant within current scope
  # if inherit is true or self is Object, will also check ancestors
  def const_defined?(name, inherit = true)
    name = Opal.const_name!(name)

    raise NameError.new("wrong constant name #{name}", name) unless name =~ Opal::CONST_NAME_REGEXP

    %x{
      var module, modules = [self], module_constants, i, ii;

      // Add up ancestors if inherit is true
      if (inherit) {
        modules = modules.concat(Opal.ancestors(self));

        // Add Object's ancestors if it's a module – modules have no ancestors otherwise
        if (self.$$is_module) {
          modules = modules.concat([Opal.Object]).concat(Opal.ancestors(Opal.Object));
        }
      }

      for (i = 0, ii = modules.length; i < ii; i++) {
        module = modules[i];
        if (module.$$const[name] != null) {
          return true;
        }
      }

      return false;
    }
  end

  def const_get(name, inherit = true)
    name = Opal.const_name!(name)

    %x{
      if (name.indexOf('::') === 0 && name !== '::'){
        name = name.slice(2);
      }
    }

    if `name.indexOf('::') != -1 && name != '::'`
      return name.split('::').inject(self) { |o, c| o.const_get(c) }
    end

    raise NameError.new("wrong constant name #{name}", name) unless name =~ Opal::CONST_NAME_REGEXP

    %x{
      if (inherit) {
        return $$([self], name);
      } else {
        return Opal.const_get_local(self, name);
      }
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

    full_const_name = self == Object ? name : "#{self}::#{name}"

    raise NameError.new("uninitialized constant #{full_const_name}", name)
  end

  def const_set(name, value)
    name = Opal.const_name!(name)

    if name !~ Opal::CONST_NAME_REGEXP || name.start_with?('::')
      raise NameError.new("wrong constant name #{name}", name)
    end

    `Opal.const_set(self, name, value)`

    value
  end

  def public_constant(const_name)
  end

  def define_method(name, method = undefined, &block)
    if `method === undefined && block === nil`
      raise ArgumentError, 'tried to create a Proc object without a block'
    end

    block ||= case method
              when Proc
                method

              when Method
                `#{method.to_proc}.$$unbound`

              when UnboundMethod
                ->(*args) {
                  bound = method.bind(self)
                  bound.call(*args)
                }

              else
                raise TypeError, "wrong argument type #{block.class} (expected Proc/Method)"
              end

    %x{
      var id = '$' + name;

      block.$$jsid        = name;
      block.$$s           = null;
      block.$$def         = block;
      block.$$define_meth = true;

      Opal.defn(self, id, block);

      return name;
    }
  end

  def remove_method(*names)
    %x{
      for (var i = 0, length = names.length; i < length; i++) {
        Opal.rdef(self, "$" + names[i]);
      }
    }

    self
  end

  def singleton_class?
    `!!self.$$is_singleton`
  end

  def include(*mods)
    %x{
      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{raise TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.append_features self};
        #{`mod`.included self};
      }
    }

    self
  end

  def included_modules
    `Opal.included_modules(self)`
  end

  def include?(mod)
    %x{
      if (!mod.$$is_module) {
        #{raise TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
      }

      var i, ii, mod2, ancestors = Opal.ancestors(self);

      for (i = 0, ii = ancestors.length; i < ii; i++) {
        mod2 = ancestors[i];
        if (mod2 === mod && mod2 !== self) {
          return true;
        }
      }

      return false;
    }
  end

  def instance_method(name)
    %x{
      var meth = self.$$prototype['$' + name];

      if (!meth || meth.$$stub) {
        #{raise NameError.new("undefined method `#{name}' for class `#{self.name}'", name)};
      }

      return #{UnboundMethod.new(self, `meth.$$owner || #{self}`, `meth`, name)};
    }
  end

  def instance_methods(include_super = true)
    %x{
      if (#{Opal.truthy?(include_super)}) {
        return Opal.instance_methods(self);
      } else {
        return Opal.own_instance_methods(self);
      }
    }
  end

  def included(mod)
  end

  def extended(mod)
  end

  def extend_object(object)
  end

  def method_added(*)
  end

  def method_removed(*)
  end

  def method_undefined(*)
  end

  def module_eval(*args, &block)
    if block.nil? && `!!Opal.compile`
      Kernel.raise ArgumentError, 'wrong number of arguments (0 for 1..3)' unless (1..3).cover? args.size

      string, file, _lineno = *args
      default_eval_options = { file: (file || '(eval)'), eval: true }
      compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
      compiled = Opal.compile string, compiling_options
      block = Kernel.proc do
        %x{
          return (function(self) {
            return eval(compiled);
          })(self)
        }
      end
    elsif args.any?
      Kernel.raise ArgumentError, "wrong number of arguments (#{args.size} for 0)" \
                                  "\n\n  NOTE:If you want to enable passing a String argument please add \"require 'opal-parser'\" to your script\n"
    end

    %x{
      var old = block.$$s,
          result;

      block.$$s = null;
      result = block.apply(self, [self]);
      block.$$s = old;

      return result;
    }
  end

  alias class_eval module_eval

  def module_exec(*args, &block)
    %x{
      if (block === nil) {
        #{raise LocalJumpError, 'no block given'}
      }

      var block_self = block.$$s, result;

      block.$$s = null;
      result = block.apply(self, args);
      block.$$s = block_self;

      return result;
    }
  end

  alias class_exec module_exec

  def method_defined?(method)
    %x{
      var body = self.$$prototype['$' + method];
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
          var meth = methods[i],
              id   = '$' + meth,
              func = self.$$prototype[id];

          Opal.defs(self, id, func);
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
        // Give up if any of the ancestors is unnamed
        if (base.$$name === nil || base.$$name == null) return nil;

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

  def prepend(*mods)
    %x{
      if (mods.length === 0) {
        #{raise ArgumentError, 'wrong number of arguments (given 0, expected 1+)'}
      }

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{raise TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.prepend_features self};
        #{`mod`.prepended self};
      }
    }

    self
  end

  def prepend_features(prepender)
    %x{
      if (!self.$$is_module) {
        #{raise TypeError, "wrong argument type #{self.class} (expected Module)"};
      }

      Opal.prepend_features(self, prepender)
    }
    self
  end

  def prepended(mod)
  end

  def remove_const(name)
    `Opal.const_remove(self, name)`
  end

  def to_s
    `Opal.Module.$name.call(self)` || "#<#{`self.$$is_module ? 'Module' : 'Class'`}:0x#{__id__.to_s(16)}>"
  end

  def undef_method(*names)
    %x{
      for (var i = 0, length = names.length; i < length; i++) {
        Opal.udef(self, "$" + names[i]);
      }
    }

    self
  end

  def instance_variables
    consts = constants
    %x{
      var result = [];

      for (var name in self) {
        if (self.hasOwnProperty(name) && name.charAt(0) !== '$' && name !== 'constructor' && !#{consts.include?(`name`)}) {
          result.push('@' + name);
        }
      }

      return result;
    }
  end

  def dup
    copy = super
    copy.copy_class_variables(self)
    copy.copy_constants(self)
    copy
  end

  def copy_class_variables(other)
    %x{
      for (var name in other.$$cvars) {
        self.$$cvars[name] = other.$$cvars[name];
      }
    }
  end

  def copy_constants(other)
    %x{
      var name, other_constants = other.$$const;

      for (name in other_constants) {
        Opal.const_set(self, name, other_constants[name]);
      }
    }
  end
end
