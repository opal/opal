# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, Object, allocate_module, const_get_name, const_lookup_ancestors, const_set

module ::Opal
  %x{
    function find_existing_module(scope, name) {
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
  }

  def self.module(scope = undefined, name = undefined)
    %x{
      var module;

      if (scope == null || scope === '::') {
        // Global scope
        scope = $Object;
      } else if (!scope.$$is_class && !scope.$$is_module) {
        // Scope is an object, use its class
        scope = scope.$$class;
      }

      module = find_existing_module(scope, name);

      if (module == null) {
        // Module doesnt exist, create a new one...
        module = $allocate_module(name);
        $const_set(scope, name, module);
      }

      if (Opal.trace_class) { invoke_tracers_for_class(module); }

      return module;
    }
  end
end

::Opal
