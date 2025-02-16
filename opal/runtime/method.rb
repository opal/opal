# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: deny_frozen_access, prop, has_own, jsid, raise, ancestors, get_ancestors

module ::Opal
  # Method creation/deletion
  # ------------------------

  # Used to define methods on an object. This is a helper method, used by the
  # compiled source to define methods on special case objects when the compiler
  # can not determine the destination object, or the object is a Module
  # instance. This can get called by `Module#define_method` as well.
  #
  # ## Modules
  #
  # Any method defined on a module will come through this runtime helper.
  # The method is added to the module body, and the owner of the method is
  # set to be the module itself. This is used later when choosing which
  # method should show on a class if more than 1 included modules define
  # the same method. Finally, if the module is in `module_function` mode,
  # then the method is also defined onto the module itself.
  #
  # ## Classes
  #
  # This helper will only be called for classes when a method is being
  # defined indirectly; either through `Module#define_method`, or by a
  # literal `def` method inside an `instance_eval` or `class_eval` body. In
  # either case, the method is simply added to the class' prototype. A special
  # exception exists for `BasicObject` and `Object`. These two classes are
  # special because they are used in toll-free bridged classes. In each of
  # these two cases, extra work is required to define the methods on toll-free
  # bridged class' prototypes as well.
  #
  # ## Objects
  #
  # If a simple ruby object is the object, then the method is simply just
  # defined on the object as a singleton method. This would be the case when
  # a method is defined inside an `instance_eval` block.
  #
  # @param obj  [Object, Class] the actual obj to define method for
  # @param jsid [String] the JavaScript friendly method name (e.g. '$foo')
  # @param body [JS.Function] the literal JavaScript function used as method
  # @param blockopts [Object, Number] optional properties to set on the body
  # @return [null]
  def self.def(obj, jsid, body, blockopts)
    %x{
      $apply_blockopts(body, blockopts);

      // Special case for a method definition in the
      // top-level namespace
      if (obj === Opal.top) {
        return Opal.defn(Opal.Object, jsid, body);
      }
      // if instance_eval is invoked on a module/class, it sets inst_eval_mod
      else if (!obj.$$eval && obj.$$is_a_module) {
        return Opal.defn(obj, jsid, body);
      }
      else {
        return Opal.defs(obj, jsid, body);
      }
    }
  end

  # Define method on a module or class (see Opal.def).
  def self.defn(mod, jsid, body)
    %x{
      $deny_frozen_access(mod);

      body.displayName = jsid;
      body.$$owner = mod;

      var name = jsid.substr(1);

      var proto = mod.$$prototype;
      if (proto.hasOwnProperty('$$dummy')) {
        proto = proto.$$define_methods_on;
      }
      $prop(proto, jsid, body);

      if (mod.$$is_module) {
        if (mod.$$module_function) {
          Opal.defs(mod, jsid, body)
        }

        for (var i = 0, iclasses = mod.$$iclasses, length = iclasses.length; i < length; i++) {
          var iclass = iclasses[i];
          $prop(iclass, jsid, body);
        }
      }

      var singleton_of = mod.$$singleton_of;
      if (mod.$method_added && !mod.$method_added.$$stub && !singleton_of) {
        mod.$method_added(name);
      }
      else if (singleton_of && singleton_of.$singleton_method_added && !singleton_of.$singleton_method_added.$$stub) {
        singleton_of.$singleton_method_added(name);
      }

      return name;
    }
  end

  # Define a singleton method on the given object (see Opal.def).
  def self.defs(obj, jsid, body, blockopts)
    %x{
      $apply_blockopts(body, blockopts);

      if (obj.$$is_string || obj.$$is_number) {
        $raise(Opal.TypeError, "can't define singleton");
      }
      return Opal.defn(Opal.get_singleton_class(obj), jsid, body);
    }
  end

  # Since JavaScript has no concept of modules, we create proxy classes
  # called `iclasses` that store copies of methods loaded. We need to
  # update them if we remove a method.
  def self.remove_method_from_iclasses(obj, jsid)
    %x{
      if (obj.$$is_module) {
        for (var i = 0, iclasses = obj.$$iclasses, length = iclasses.length; i < length; i++) {
          var iclass = iclasses[i];
          delete iclass[jsid];
        }
      }
    }
  end

  # Called from #remove_method.
  def self.rdef(obj, jsid)
    %x{
      if (!$has_own(obj.$$prototype, jsid)) {
        $raise(Opal.NameError, "method '" + jsid.substr(1) + "' not defined in " + obj.$name());
      }

      delete obj.$$prototype[jsid];

      Opal.remove_method_from_iclasses(obj, jsid);

      if (obj.$$is_singleton) {
        if (obj.$$prototype.$singleton_method_removed && !obj.$$prototype.$singleton_method_removed.$$stub) {
          obj.$$prototype.$singleton_method_removed(jsid.substr(1));
        }
      }
      else {
        if (obj.$method_removed && !obj.$method_removed.$$stub) {
          obj.$method_removed(jsid.substr(1));
        }
      }
    }
  end

  # Called from #undef_method.
  def self.udef(obj, jsid)
    %x{
      if (!obj.$$prototype[jsid] || obj.$$prototype[jsid].$$stub) {
        $raise(Opal.NameError, "method '" + jsid.substr(1) + "' not defined in " + obj.$name());
      }

      Opal.add_stub_for(obj.$$prototype, jsid);

      Opal.remove_method_from_iclasses(obj, jsid);

      if (obj.$$is_singleton) {
        if (obj.$$prototype.$singleton_method_undefined && !obj.$$prototype.$singleton_method_undefined.$$stub) {
          obj.$$prototype.$singleton_method_undefined(jsid.substr(1));
        }
      }
      else {
        if (obj.$method_undefined && !obj.$method_undefined.$$stub) {
          obj.$method_undefined(jsid.substr(1));
        }
      }
    }
  end

  def self.alias(obj, name, old)
    %x{
      function is_method_body(body) {
            return (typeof(body) === "function" && !body.$$stub);
      }

      var id     = $jsid(name),
          old_id = $jsid(old),
          body,
          alias;

      // Aliasing on main means aliasing on Object...
      if (typeof obj.$$prototype === 'undefined') {
        obj = Opal.Object;
      }

      body = obj.$$prototype[old_id];

      // When running inside #instance_eval the alias refers to class methods.
      if (obj.$$eval) {
        return Opal.alias(Opal.get_singleton_class(obj), name, old);
      }

      if (!is_method_body(body)) {
        var ancestor = obj.$$super;

        while (typeof(body) !== "function" && ancestor) {
          body     = ancestor[old_id];
          ancestor = ancestor.$$super;
        }

        if (!is_method_body(body) && obj.$$is_module) {
          // try to look into Object
          body = Opal.Object.$$prototype[old_id]
        }

        if (!is_method_body(body)) {
          $raise(Opal.NameError, "undefined method `" + old + "' for class `" + obj.$name() + "'")
        }
      }

      // If the body is itself an alias use the original body
      // to keep the max depth at 1.
      if (body.$$alias_of) body = body.$$alias_of;

      // We need a wrapper because otherwise properties
      // would be overwritten on the original body.
      alias = Opal.wrap_method_body(body);

      // Try to make the browser pick the right name
      alias.displayName  = name;
      alias.$$alias_of   = body;
      alias.$$alias_name = name;

      Opal.defn(obj, id, alias);

      return obj;
    }
  end

  def self.alias_native(obj, name, native_name)
    %x{
      var id   = $jsid(name),
          body = obj.$$prototype[native_name];

      if (typeof(body) !== "function" || body.$$stub) {
        $raise(Opal.NameError, "undefined native method `" + native_name + "' for class `" + obj.$name() + "'")
      }

      Opal.defn(obj, id, body);

      return obj;
    }
  end

  def self.wrap_method_body(body)
    %x{
      var wrapped = function() {
        var block = wrapped.$$p;

        wrapped.$$p = null;

        return Opal.send(this, body, arguments, block);
      };

      // Assign the 'length' value with defineProperty because
      // in strict mode the property is not writable.
      // It doesn't work in older browsers (like Chrome 38), where
      // an exception is thrown breaking Opal altogether.
      try {
        Object.defineProperty(wrapped, 'length', { value: body.length });
      } catch {}

      wrapped.$$arity           = body.$$arity == null ? body.length : body.$$arity;
      wrapped.$$parameters      = body.$$parameters;
      wrapped.$$source_location = body.$$source_location;

      return wrapped;
    }
  end

  # Method arguments
  # ----------------

  # Arity count error dispatcher for methods
  #
  # @param actual [Fixnum] number of arguments given to method
  # @param expected [Fixnum] expected number of arguments
  # @param object [Object] owner of the method +meth+
  # @param meth [String] method name that got wrong number of arguments
  # @raise [ArgumentError]
  def self.ac(actual, expected, object, meth)
    %x{
      var inspect = '';
      if (object.$$is_a_module) {
        inspect += object.$$name + '.';
      }
      else {
        inspect += object.$$class.$$name + '#';
      }
      inspect += meth;

      $raise(Opal.ArgumentError, '[' + inspect + '] wrong number of arguments (given ' + actual + ', expected ' + expected + ')');
    }
  end

  # Method iteration
  # ----------------

  # rubocop:disable Naming/PredicatePrefix
  def self.is_method(prop)
    `prop[0] === '$' && prop[1] !== '$'`
  end
  # rubocop:enable Naming/PredicatePrefix

  def self.instance_methods(mod)
    %x{
      var processed = Object.create(null), results = [], ancestors = $ancestors(mod);

      for (var i = 0, l = ancestors.length; i < l; i++) {
        var ancestor = ancestors[i],
            proto = ancestor.$$prototype;

        if (proto.hasOwnProperty('$$dummy')) {
          proto = proto.$$define_methods_on;
        }

        var props = Object.getOwnPropertyNames(proto);

        for (var j = 0, ll = props.length; j < ll; j++) {
          var prop = props[j];

          if (processed[prop]) {
            continue;
          }
          if (Opal.is_method(prop)) {
            var method = proto[prop];

            if (!method.$$stub) {
              var method_name = prop.slice(1);
              results.push(method_name);
            }
          }
          processed[prop] = true;
        }
      }

      return results;
    }
  end

  def self.own_instance_methods(mod)
    %x{
      var results = [],
          proto = mod.$$prototype;

      if (proto.hasOwnProperty('$$dummy')) {
        proto = proto.$$define_methods_on;
      }

      var props = Object.getOwnPropertyNames(proto);

      for (var i = 0, length = props.length; i < length; i++) {
        var prop = props[i];

        if (Opal.is_method(prop)) {
          var method = proto[prop];

          if (!method.$$stub) {
            var method_name = prop.slice(1);
            results.push(method_name);
          }
        }
      }

      return results;
    }
  end

  def self.methods(obj)
    `Opal.instance_methods(obj.$$meta || obj.$$class)`
  end

  def self.own_methods(obj)
    `obj.$$meta ? Opal.own_instance_methods(obj.$$meta) : []`
  end

  def self.receiver_methods(obj)
    %x{
      var mod = Opal.get_singleton_class(obj);
      var singleton_methods = Opal.own_instance_methods(mod);
      var instance_methods = Opal.own_instance_methods(mod.$$super);
      return singleton_methods.concat(instance_methods);
    }
  end

  # Super call
  # ----------

  # Super dispatcher
  def self.find_super(obj, mid, current_func, defcheck, allow_stubs)
    %x{
      var jsid = $jsid(mid), ancestors, ancestor, super_method, method_owner, current_index = -1, i;

      ancestors = $get_ancestors(obj);
      method_owner = current_func.$$owner;

      for (i = 0; i < ancestors.length; i++) {
        ancestor = ancestors[i];
        if (ancestor === method_owner || ancestor.$$cloned_from.indexOf(method_owner) !== -1) {
          current_index = i;
          break;
        }
      }

      for (i = current_index + 1; i < ancestors.length; i++) {
        ancestor = ancestors[i];
        var proto = ancestor.$$prototype;

        if (proto.hasOwnProperty('$$dummy')) {
          proto = proto.$$define_methods_on;
        }

        if (proto.hasOwnProperty(jsid)) {
          super_method = proto[jsid];
          break;
        }
      }

      if (!defcheck && super_method && super_method.$$stub && obj.$method_missing.$$pristine) {
        // method_missing hasn't been explicitly defined
        $raise(Opal.NoMethodError, 'super: no superclass method `'+mid+"' for "+obj, mid);
      }

      return (super_method.$$stub && !allow_stubs) ? null : super_method;
    }
  end

  # Iter dispatcher for super in a block
  def self.find_block_super(obj, jsid, current_func, defcheck, implicit)
    %x{
      var call_jsid = jsid;

      if (!current_func) {
        $raise(Opal.RuntimeError, "super called outside of method");
      }

      if (implicit && current_func.$$define_meth) {
        $raise(Opal.RuntimeError,
          "implicit argument passing of super from method defined by define_method() is not supported. " +
          "Specify all arguments explicitly"
        );
      }

      if (current_func.$$def) {
        call_jsid = current_func.$$jsid;
      }

      return Opal.find_super(obj, call_jsid, current_func, defcheck);
    }
  end

  def self.apply_blockopts(block, blockopts)
    %x{
      if (typeof(blockopts) === 'number') {
        block.$$arity = blockopts;
      }
      else if (typeof(blockopts) === 'object') {
        Object.assign(block, blockopts);
      }
    }
  end

  `var $apply_blockopts = Opal.apply_blockopts`
end

::Opal
