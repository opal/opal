# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: prop, raise, Object, allocate_module, const_get_name, const_lookup_ancestors, ancestors, const_set, set_proto, has_own

module ::Opal
  %x{
    // TracePoint support
    // ------------------
    //
    // Support for `TracePoint.trace(:class) do ... end`
    Opal.trace_class = false;
    Opal.tracers_for_class = [];
  }

  def self.invoke_tracers_for_class(klass_or_module)
    %x{
      var i, ii, tracer;

      for(i = 0, ii = Opal.tracers_for_class.length; i < ii; i++) {
        tracer = Opal.tracers_for_class[i];
        tracer.trace_object = klass_or_module;
        tracer.block.$call(tracer);
      }
    }
  end

  def self.find_existing_module(scope, name)
    %x{
      var module = $const_get_name(scope, name);
      if (module == null && scope === $Object)
        module = $const_lookup_ancestors($Object, name);

      if (module) {
        if (!module.$$is_module && module !== $Object) {
          $raise(Opal.TypeError, name + " is not a module");
        }
      }

      return module;
    }
  end

  def self.module(scope, name)
    %x{
      var module;

      if (scope == null || scope === '::') {
        // Global scope
        scope = $Object;
      } else if (!scope.$$is_class && !scope.$$is_module) {
        // Scope is an object, use its class
        scope = scope.$$class;
      }

      module = Opal.find_existing_module(scope, name);

      if (module == null) {
        // Module doesnt exist, create a new one...
        module = $allocate_module(name);
        $const_set(scope, name, module);
      }

      if (Opal.trace_class) { Opal.invoke_tracers_for_class(module); }

      return module;
    }
  end

  # Include & Prepend
  # -----------------

  def self.is_root(proto)
    `proto.hasOwnProperty('$$iclass') && proto.hasOwnProperty('$$root')`
  end

  def self.own_included_modules(mod)
    %x{
      var result = [], module, proto;
      if ($has_own(mod.$$prototype, '$$dummy')) {
        proto = Object.getPrototypeOf(mod.$$prototype.$$define_methods_on);
      } else {
        proto = Object.getPrototypeOf(mod.$$prototype);
      }

      while (proto) {
        if (proto.hasOwnProperty('$$class')) {
          // superclass
          break;
        }
        module = Opal.proto_to_module(proto);
        if (module) {
          result.push(module);
        }
        proto = Object.getPrototypeOf(proto);
      }

      return result;
    }
  end

  def self.own_prepended_modules(mod)
    %x{
      var result = [], module, proto = Object.getPrototypeOf(mod.$$prototype);

      if (mod.$$prototype.hasOwnProperty('$$dummy')) {
        while (proto) {
          if (proto === mod.$$prototype.$$define_methods_on) {
            break;
          }

          module = Opal.proto_to_module(proto);
          if (module) {
            result.push(module);
          }

          proto = Object.getPrototypeOf(proto);
        }
      }

      return result;
    }
  end

  # The actual inclusion of a module into a class.
  #
  # ## Class `$$parent` and `iclass`
  #
  # To handle `super` calls, every class has a `$$parent`. This parent is
  # used to resolve the next class for a super call. A normal class would
  # have this point to its superclass. However, if a class includes a module
  # then this would need to take into account the module. The module would
  # also have to then point its `$$parent` to the actual superclass. We
  # cannot modify modules like this, because it might be included in more
  # then one class. To fix this, we actually insert an `iclass` as the class'
  # `$$parent` which can then point to the superclass. The `iclass` acts as
  # a proxy to the actual module, so the `super` chain can then search it for
  # the required method.
  #
  # @param module [Module] the module to include
  # @param includer [Module] the target class to include module into
  # @return [null]

  def self.append_features(mod, includer)
    %x{
      var module_ancestors = $ancestors(mod);
      var iclasses = [];

      if (module_ancestors.indexOf(includer) !== -1) {
        $raise(Opal.ArgumentError, 'cyclic include detected');
      }

      for (var i = 0, length = module_ancestors.length; i < length; i++) {
        var ancestor = module_ancestors[i], iclass = Opal.create_iclass(ancestor);
        $prop(iclass, '$$included', true);
        iclasses.push(iclass);
      }
      var includer_ancestors = $ancestors(includer),
          chain = Opal.chain_iclasses(iclasses),
          start_chain_after,
          end_chain_on;

      if (includer_ancestors.indexOf(mod) === -1) {
        // first time include

        // includer -> chain.first -> ...chain... -> chain.last -> includer.parent
        start_chain_after = includer.$$prototype;
        if ($has_own(start_chain_after, '$$dummy')) {
          start_chain_after = start_chain_after.$$define_methods_on;
        }
        end_chain_on = Object.getPrototypeOf(start_chain_after);
      } else {
        // The module has been already included,
        // we don't need to put it into the ancestors chain again,
        // but this module may have new included modules.
        // If it's true we need to copy them.
        //
        // The simplest way is to replace ancestors chain from
        //          parent
        //            |
        //   `module` iclass (has a $$root flag)
        //            |
        //   ...previos chain of module.included_modules ...
        //            |
        //  "next ancestor" (has a $$root flag or is a real class)
        //
        // to
        //          parent
        //            |
        //    `module` iclass (has a $$root flag)
        //            |
        //   ...regenerated chain of module.included_modules
        //            |
        //   "next ancestor" (has a $$root flag or is a real class)
        //
        // because there are no intermediate classes between `parent` and `next ancestor`.
        // It doesn't break any prototypes of other objects as we don't change class references.

        var parent = includer.$$prototype, module_iclass = Object.getPrototypeOf(parent);

        while (module_iclass != null) {
          if (module_iclass.$$module === mod && Opal.is_root(module_iclass)) {
            break;
          }

          parent = module_iclass;
          module_iclass = Object.getPrototypeOf(module_iclass);
        }

        if (module_iclass) {
          // module has been directly included
          var next_ancestor = Object.getPrototypeOf(module_iclass);

          // skip non-root iclasses (that were recursively included)
          while (next_ancestor.hasOwnProperty('$$iclass') && !Opal.is_root(next_ancestor)) {
            next_ancestor = Object.getPrototypeOf(next_ancestor);
          }

          start_chain_after = parent;
          end_chain_on = next_ancestor;
        } else {
          // module has not been directly included but was in ancestor chain because it was included by another module
          // include it directly
          start_chain_after = includer.$$prototype;
          end_chain_on = Object.getPrototypeOf(includer.$$prototype);
        }
      }

      $set_proto(start_chain_after, chain.first);
      $set_proto(chain.last, end_chain_on);

      // recalculate own_included_modules cache
      includer.$$own_included_modules = Opal.own_included_modules(includer);

      Opal.const_cache_version++;
    }
  end

  def self.prepend_features(mod, prepender)
    %x{
      function flush_methods_in(mod) {
        var proto = mod.$$prototype,
            props = Object.getOwnPropertyNames(proto);

        for (var i = 0; i < props.length; i++) {
          var prop = props[i];
          if (Opal.is_method(prop)) {
            delete proto[prop];
          }
        }
      }

      // Here we change the ancestors chain from
      //
      //   prepender
      //      |
      //    parent
      //
      // to:
      //
      // dummy(prepender)
      //      |
      //  iclass(module)
      //      |
      // iclass(prepender)
      //      |
      //    parent
      var module_ancestors = $ancestors(mod);
      var iclasses = [];

      if (module_ancestors.indexOf(prepender) !== -1) {
        $raise(Opal.ArgumentError, 'cyclic prepend detected');
      }

      for (var i = 0, length = module_ancestors.length; i < length; i++) {
        var ancestor = module_ancestors[i], iclass = Opal.create_iclass(ancestor);
        $prop(iclass, '$$prepended', true);
        iclasses.push(iclass);
      }

      var chain = Opal.chain_iclasses(iclasses),
          dummy_prepender = prepender.$$prototype,
          previous_parent = Object.getPrototypeOf(dummy_prepender),
          prepender_iclass,
          start_chain_after,
          end_chain_on;

      if (dummy_prepender.hasOwnProperty('$$dummy')) {
        // The module already has some prepended modules
        // which means that we don't need to make it "dummy"
        prepender_iclass = dummy_prepender.$$define_methods_on;
      } else {
        // Making the module "dummy"
        prepender_iclass = Opal.create_dummy_iclass(prepender);
        flush_methods_in(prepender);
        $prop(dummy_prepender, '$$dummy', true);
        $prop(dummy_prepender, '$$define_methods_on', prepender_iclass);

        // Converting
        //   dummy(prepender) -> previous_parent
        // to
        //   dummy(prepender) -> iclass(prepender) -> previous_parent
        $set_proto(dummy_prepender, prepender_iclass);
        $set_proto(prepender_iclass, previous_parent);
      }

      var prepender_ancestors = $ancestors(prepender);

      if (prepender_ancestors.indexOf(mod) === -1) {
        // first time prepend

        start_chain_after = dummy_prepender;

        // next $$root or prepender_iclass or non-$$iclass
        end_chain_on = Object.getPrototypeOf(dummy_prepender);
        while (end_chain_on != null) {
          if (
            end_chain_on.hasOwnProperty('$$root') ||
            end_chain_on === prepender_iclass ||
            !end_chain_on.hasOwnProperty('$$iclass')
          ) {
            break;
          }

          end_chain_on = Object.getPrototypeOf(end_chain_on);
        }
      } else {
        $raise(Opal.RuntimeError, "Prepending a module multiple times is not supported");
      }

      $set_proto(start_chain_after, chain.first);
      $set_proto(chain.last, end_chain_on);

      // recalculate own_prepended_modules cache
      prepender.$$own_prepended_modules = Opal.own_prepended_modules(prepender);

      Opal.const_cache_version++;
    }
  end

  # iclasses are JavaScript classes that are injected into
  # the prototype chain, carrying all module methods.

  def self.create_iclass(mod)
    %x{
      var iclass = Opal.create_dummy_iclass(mod);

      if (mod.$$is_module) {
        mod.$$iclasses.push(iclass);
      }

      return iclass;
    }
  end

  # Dummy iclass doesn't receive updates when the module gets a new method.
  def self.create_dummy_iclass(mod)
    %x{
      var iclass = {},
          proto = mod.$$prototype;

      if (proto.hasOwnProperty('$$dummy')) {
        proto = proto.$$define_methods_on;
      }

      var props = Object.getOwnPropertyNames(proto),
          length = props.length, i;

      for (i = 0; i < length; i++) {
        var prop = props[i];
        $prop(iclass, prop, proto[prop]);
      }

      $prop(iclass, '$$iclass', true);
      $prop(iclass, '$$module', mod);

      return iclass;
    }
  end

  def self.chain_iclasses(iclasses)
    %x{
      var length = iclasses.length, first = iclasses[0];

      $prop(first, '$$root', true);

      if (length === 1) {
        return { first: first, last: first };
      }

      var previous = first;

      for (var i = 1; i < length; i++) {
        var current = iclasses[i];
        $set_proto(previous, current);
        previous = current;
      }

      return { first: iclasses[0], last: iclasses[length - 1] };
    }
  end

  def self.proto_to_module(proto)
    %x{
      if (proto.hasOwnProperty('$$dummy')) {
        return;
      } else if (proto.hasOwnProperty('$$iclass')) {
        return proto.$$module;
      } else if (proto.hasOwnProperty('$$class')) {
        return proto.$$class;
      }
    }
  end

  def self.included_modules(main_module)
    %x{
      var result = [], mod = null, proto = Object.getPrototypeOf(main_module.$$prototype);

      for (; proto && Object.getPrototypeOf(proto); proto = Object.getPrototypeOf(proto)) {
        mod = Opal.proto_to_module(proto);
        if (mod && mod.$$is_module && proto.$$iclass && proto.$$included) {
          result.push(mod);
        }
      }

      return result;
    }
  end
end

::Opal
