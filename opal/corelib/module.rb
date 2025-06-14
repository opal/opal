# helpers: truthy, coerce_to, const_set, Object, return_ivar, assign_ivar, ivar, deny_frozen_access, freeze, prop, jsid, each_ivar
# backtick_javascript: true
# use_strict: true

class ::Module
  %x{
    function ensure_symbol_or_string(name) {
      if (name.$$is_string) {
        return name;
      };
      var converted_name = #{::Opal.try_convert(`name`, ::String, :to_str)};
      if (converted_name.$$is_string) {
        return converted_name;
      } else if (converted_name === nil) {
        #{::Kernel.raise ::TypeError, "#{`name`} is not a symbol nor a string"}
      } else {
        #{::Kernel.raise ::TypeError, "can't convert #{`name`.class} to String (#{`name`.class}#to_str gives #{`converted_name`.class}"}
      }
    }
  }

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
    unless ::Module === other
      ::Kernel.raise ::TypeError, 'compared with non class/module'
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
    unless ::Module === other
      ::Kernel.raise ::TypeError, 'compared with non class/module'
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

    unless ::Module === other
      return nil
    end

    lt = self < other
    return nil if lt.nil?
    lt ? -1 : 1
  end

  def alias_method(newname, oldname)
    `$deny_frozen_access(self)`

    newname = `$coerce_to(newname, #{::String}, 'to_str')`
    oldname = `$coerce_to(oldname, #{::String}, 'to_str')`
    `Opal.alias(self, newname, oldname)`

    self
  end

  def alias_native(mid, jsid = mid)
    `$deny_frozen_access(self)`

    `Opal.alias_native(self, mid, jsid)`

    self
  end

  def ancestors
    `Opal.ancestors(self)`
  end

  def append_features(includer)
    `$deny_frozen_access(includer)`

    `Opal.append_features(self, includer)`
    self
  end

  def attr_accessor(*names)
    attr_reader(*names)
    attr_writer(*names)
  end

  def attr(*args)
    %x{
      if (args.length == 2 && (args[1] === true || args[1] === false)) {
        #{warn 'optional boolean argument is obsoleted', uplevel: 1}

        args[1] ? #{attr_accessor(`args[0]`)} : #{attr_reader(`args[0]`)};
        return nil;
      }
    }

    attr_reader(*args)
  end

  def attr_reader(*names)
    %x{
      $deny_frozen_access(self);

      var proto = self.$$prototype;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = $jsid(name),
            ivar = $ivar(name);

        var body = $return_ivar(ivar);

        // initialize the instance variable as nil
        Opal.prop(proto, ivar, nil);

        body.$$parameters = [];
        body.$$arity = 0;

        Opal.defn(self, id, body);
      }
    }

    nil
  end

  def attr_writer(*names)
    %x{
      $deny_frozen_access(self);

      var proto = self.$$prototype;

      for (var i = names.length - 1; i >= 0; i--) {
        var name = names[i],
            id   = $jsid(name + '='),
            ivar = $ivar(name);

        var body = $assign_ivar(ivar)

        body.$$parameters = [['req']];
        body.$$arity = 1;

        // initialize the instance variable as nil
        Opal.prop(proto, ivar, nil);

        Opal.defn(self, id, body);
      }
    }

    nil
  end

  def autoload(const, path)
    %x{
      $deny_frozen_access(self);

      if (!#{Opal.const_name?(const)}) {
        #{::Kernel.raise ::NameError, "autoload must be constant name: #{const}"}
      }

      if (path == "") {
        #{::Kernel.raise ::ArgumentError, 'empty file name'}
      }

      if (!self.$$const.hasOwnProperty(#{const})) {
        if (!self.$$autoload) {
          self.$$autoload = {};
        }
        Opal.const_cache_version++;
        self.$$autoload[#{const}] = { path: #{path}, loaded: false, required: false, success: false, exception: false };

        if (self.$const_added && !self.$const_added.$$pristine) {
          self.$const_added(#{const});
        }
      }
      return nil;
    }
  end

  def autoload?(const)
    %x{
      if (self.$$autoload && self.$$autoload[#{const}] && !self.$$autoload[#{const}].required && !self.$$autoload[#{const}].success) {
        return self.$$autoload[#{const}].path;
      }

      var ancestors = self.$ancestors();

      for (var i = 0, length = ancestors.length; i < length; i++) {
        if (ancestors[i].$$autoload && ancestors[i].$$autoload[#{const}] && !ancestors[i].$$autoload[#{const}].required && !ancestors[i].$$autoload[#{const}].success) {
          return ancestors[i].$$autoload[#{const}].path;
        }
      }
      return nil;
    }
  end

  def class_variables
    `Object.keys(Opal.class_variables(self))`
  end

  def class_variable_get(name)
    name = ::Opal.class_variable_name!(name)

    `Opal.class_variable_get(self, name, false)`
  end

  def class_variable_set(name, value)
    `$deny_frozen_access(self)`

    name = ::Opal.class_variable_name!(name)

    `Opal.class_variable_set(self, name, value)`
  end

  def class_variable_defined?(name)
    name = ::Opal.class_variable_name!(name)

    `Opal.class_variables(self).hasOwnProperty(name)`
  end

  def const_added(name)
  end
  ::Opal.pristine self, :const_added

  def remove_class_variable(name)
    `$deny_frozen_access(self)`

    name = ::Opal.class_variable_name!(name)

    %x{
      if (Opal.hasOwnProperty.call(self.$$cvars, name)) {
        var value = self.$$cvars[name];
        delete self.$$cvars[name];
        return value;
      } else {
        #{::Kernel.raise ::NameError, "cannot remove #{name} for #{self}"}
      }
    }
  end

  def constants(inherit = true)
    `Opal.constants(self, inherit)`
  end

  def self.constants(inherit = undefined)
    %x{
      if (inherit == null) {
        var nesting = (self.$$nesting || []).concat($Object),
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

    if `Opal.CONST_NAME_REGEXP`
      ::Kernel.raise ::NameError.new("wrong constant name #{name}", name) unless name =~ ::Opal::CONST_NAME_REGEXP
    end

    %x{
      var module, modules = [self], module_constants, i, ii;

      // Add up ancestors if inherit is true
      if (inherit) {
        modules = modules.concat(Opal.ancestors(self));

        // Add Object's ancestors if it's a module – modules have no ancestors otherwise
        if (self.$$is_module) {
          modules = modules.concat([$Object]).concat(Opal.ancestors($Object));
        }
      }

      for (i = 0, ii = modules.length; i < ii; i++) {
        module = modules[i];
        if (module.$$const[#{name}] != null) { return true; }
        if (
          module.$$autoload &&
          module.$$autoload[#{name}] &&
          !module.$$autoload[#{name}].required &&
          !module.$$autoload[#{name}].success
        ) {
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

    if `Opal.CONST_NAME_REGEXP`
      ::Kernel.raise ::NameError.new("wrong constant name #{name}", name) unless name =~ ::Opal::CONST_NAME_REGEXP
    end

    %x{
      if (inherit) {
        return Opal.$$([self], name);
      } else {
        return Opal.const_get_local(self, name);
      }
    }
  end

  def const_missing(name)
    full_const_name = self == ::Object ? name : "#{self.name}::#{name}"

    ::Kernel.raise ::NameError.new("uninitialized constant #{full_const_name}", name)
  end

  def const_set(name, value)
    `$deny_frozen_access(self)`

    name = ::Opal.const_name!(name)

    if (`Opal.CONST_NAME_REGEXP` && name !~ ::Opal::CONST_NAME_REGEXP) || name.start_with?('::')
      ::Kernel.raise ::NameError.new("wrong constant name #{name}", name)
    end

    `$const_set(self, name, value)`

    value
  end

  def public_constant(const_name)
  end

  def define_method(name, method = undefined, &block)
    %x{
      $deny_frozen_access(self);

      if (method === undefined && block === nil)
        #{::Kernel.raise ::ArgumentError, 'tried to create a Proc object without a block'}

      name = ensure_symbol_or_string(name);
    }

    if `method !== undefined`
      block = case method
              when ::Proc
                method

              when ::Method
                `#{method.to_proc}.$$unbound`

              when ::UnboundMethod
                `Opal.wrap_method_body(method.$$method)`

              else
                ::Kernel.raise ::TypeError, "wrong argument type #{method.class} (expected Proc/Method/UnboundMethod)"
              end

      if `!method.$$is_proc`
        owner = method.owner
        if `owner.$$is_class` && !(self <= owner) # rubocop:disable Style/InverseMethods
          message = `owner.$$is_singleton` ? "can't bind singleton method to a different class" : "bind argument must be a subclass of #{owner}"
          ::Kernel.raise ::TypeError, message
        end
      end
    end

    %x{
      if (typeof(Proxy) !== 'undefined') {
        var meta = Object.create(null)

        block.$$proxy_target = block
        block = new Proxy(block, {
          apply: function(target, self, args) {
            var old_name = target.$$jsid, old_lambda = target.$$is_lambda;
            target.$$jsid = name;
            target.$$is_lambda = true;
            try {
              return target.apply(self, args);
            } catch(e) {
              if (e === target.$$brk || e === target.$$ret) return e.$v;
              throw e;
            } finally {
              target.$$jsid = old_name;
              target.$$is_lambda = old_lambda;
            }
          }
        })
      }

      block.$$jsid        = name;
      block.$$s           = null;
      block.$$def         = block;
      block.$$define_meth = true;

      return Opal.defn(self, $jsid(name), block);
    }
  end

  def freeze
    # Specialized version of freeze, because the $$base_module property needs to be
    # accessible despite the frozen status

    return self if frozen?

    %x{
      if (!self.hasOwnProperty('$$base_module')) { $prop(self, '$$base_module', null); }

      return $freeze(self);
    }
  end

  def remove_method(*names)
    %x{
      for (var i = 0; i < names.length; i++) {
        var name = ensure_symbol_or_string(names[i]);
        $deny_frozen_access(self);

        Opal.rdef(self, "$" + name);
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
          #{::Kernel.raise ::TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
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
        #{::Kernel.raise ::TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
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
      var meth = self.$$prototype[$jsid(name)];

      if (!meth || meth.$$stub) {
        #{::Kernel.raise ::NameError.new("undefined method `#{name}' for class `#{self.name}'", name)};
      }

      return #{::UnboundMethod.new(self, `meth.$$owner || #{self}`, `meth`, name)};
    }
  end

  def instance_methods(include_super = true)
    %x{
      if ($truthy(#{include_super})) {
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
    `$deny_frozen_access(object)`
    nil
  end

  def method_added(*)
  end

  def method_removed(*)
  end

  def method_undefined(*)
  end

  def module_eval(*args, &block)
    if block.nil? && `!!Opal.compile`
      ::Kernel.raise ::ArgumentError, 'wrong number of arguments (0 for 1..3)' unless (1..3).cover? args.size

      string, file, _lineno = *args
      default_eval_options = { file: file || '(eval)', eval: true }
      compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
      compiled = ::Opal.compile string, compiling_options
      block = ::Kernel.proc do
        %x{new Function("Opal,self", "return " + compiled)(Opal, self)}
      end
    elsif args.any?
      ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.size} for 0)" \
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

  def module_exec(*args, &block)
    %x{
      if (block === nil) {
        #{::Kernel.raise ::LocalJumpError, 'no block given'}
      }

      var block_self = block.$$s, result;

      block.$$s = null;
      result = block.apply(self, args);
      block.$$s = block_self;

      return result;
    }
  end

  def method_defined?(method)
    %x{
      var body = self.$$prototype[$jsid(method)];
      return (!!body) && !body.$$stub;
    }
  end

  def module_function(*methods)
    %x{
      $deny_frozen_access(self);

      if (methods.length === 0) {
        self.$$module_function = true;
        return nil;
      }
      else {
        for (var i = 0, length = methods.length; i < length; i++) {
          var meth = methods[i],
              id   = $jsid(meth),
              func = self.$$prototype[id];

          Opal.defs(self, id, func);
        }
        return methods.length === 1 ? methods[0] : methods;
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

        if (base === $Object) {
          break;
        }
      }

      if (result.length === 0) {
        return nil;
      }

      return self.$$full_name = result.join('::').toString();
    }
  end

  def prepend(*mods)
    %x{
      if (mods.length === 0) {
        #{::Kernel.raise ::ArgumentError, 'wrong number of arguments (given 0, expected 1+)'}
      }

      for (var i = mods.length - 1; i >= 0; i--) {
        var mod = mods[i];

        if (!mod.$$is_module) {
          #{::Kernel.raise ::TypeError, "wrong argument type #{`mod`.class} (expected Module)"};
        }

        #{`mod`.prepend_features self};
        #{`mod`.prepended self};
      }
    }

    self
  end

  def prepend_features(prepender)
    %x{
      $deny_frozen_access(prepender);

      if (!self.$$is_module) {
        #{::Kernel.raise ::TypeError, "wrong argument type #{self.class} (expected Module)"};
      }

      Opal.prepend_features(self, prepender)
    }
    self
  end

  def prepended(mod)
  end

  def remove_const(name)
    `$deny_frozen_access(self)`

    `Opal.const_remove(self, name)`
  end

  def to_s
    `Opal.Module.$name.call(self)` || "#<#{`self.$$is_module ? 'Module' : 'Class'`}:0x#{__id__.to_s(16)}>"
  end

  def undef_method(*names)
    %x{
      for (var i = 0; i < names.length; i++) {
        var name = ensure_symbol_or_string(names[i]);
        $deny_frozen_access(self);

        Opal.udef(self, "$" + name);
      }
    }

    self
  end

  def instance_variables
    consts = constants
    %x{
      var result = [];

      $each_ivar(self, function(name) {
        if (name !== 'constructor' && !#{consts.include?(`name`)}) {
          result.push('@' + name);
        }
      });

      return result;
    }
  end

  %x{
    function copyInstanceMethods(from, to) {
      var i, method_names = Opal.own_instance_methods(from);
      for (i = 0; i < method_names.length; i++) {
        var name = method_names[i],
            jsid = $jsid(name),
            body = from.$$prototype[jsid],
            wrapped = Opal.wrap_method_body(body);

        wrapped.$$jsid = name;
        Opal.defn(to, jsid, wrapped);
      }
    }

    function copyIncludedModules(from, to) {
      var modules = from.$$own_included_modules;
      for (var i = modules.length - 1; i >= 0; i--) {
        Opal.append_features(modules[i], to);
      }
    }

    function copyPrependedModules(from, to) {
      var modules = from.$$own_prepended_modules;
      for (var i = modules.length - 1; i >= 0; i--) {
        Opal.prepend_features(modules[i], to);
      }
    }
  }

  def initialize_copy(other)
    %x{
      copyInstanceMethods(other, self);
      copyIncludedModules(other, self);
      copyPrependedModules(other, self);
      self.$$cloned_from = other.$$cloned_from.concat(other);
    }
    copy_class_variables(other)
    copy_constants(other)
  end

  def initialize_dup(other)
    super
    # Unlike other classes, Module's singleton methods are copied on Object#dup.
    copy_singleton_methods(other)
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
        $const_set(self, name, other_constants[name]);
      }
    }
  end

  def refine(klass, &block)
    refinement_module, m, klass_id = self, nil, nil
    %x{
      klass_id = Opal.id(klass);
      if (typeof self.$$refine_modules === "undefined") {
        self.$$refine_modules = Object.create(null);
      }
      if (typeof self.$$refine_modules[klass_id] === "undefined") {
        m = self.$$refine_modules[klass_id] = #{::Refinement.new};
      }
      else {
        m = self.$$refine_modules[klass_id];
      }
      m.refinement_module = refinement_module
      m.refined_class = klass
    }
    m.class_exec(&block)
    m
  end

  def refinements
    %x{
      var refine_modules = self.$$refine_modules, hash = #{{}};;
      if (typeof refine_modules === "undefined") return hash;
      for (var id in refine_modules) {
        hash['$[]='](refine_modules[id].refined_class, refine_modules[id]);
      }
      return hash;
    }
  end

  # Compiler overrides this method
  def using(mod)
    ::Kernel.raise 'Module#using is not permitted in methods'
  end

  alias class_eval module_eval
  alias class_exec module_exec
  alias inspect to_s
end

class ::Refinement < ::Module
  attr_reader :refined_class

  def inspect
    if @refinement_module
      "#<refinement:#{@refined_class.inspect}@#{@refinement_module.inspect}>"
    else
      super
    end
  end
end
