# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: apply_blockopts, jsid, raise, prepend_ary, get_ancestors

module ::Opal
  # Calls passed method on a ruby object with arguments and block:
  #
  # Can take a method or a method name.
  #
  # 1. When method name gets passed it invokes it by its name
  #    and calls 'method_missing' when object doesn't have this method.
  #    Used internally by Opal to invoke method that takes a block or a splat.
  # 2. When method (i.e. method body) gets passed, it doesn't trigger 'method_missing'
  #    because it doesn't know the name of the actual method.
  #    Used internally by Opal to invoke 'super'.
  #
  # @example
  #   var my_array = [1, 2, 3, 4]
  #   Opal.send(my_array, 'length')                    # => 4
  #   Opal.send(my_array, my_array.$length)            # => 4
  #
  #   Opal.send(my_array, 'reverse!')                  # => [4, 3, 2, 1]
  #   Opal.send(my_array, my_array['$reverse!']')      # => [4, 3, 2, 1]
  #
  # @param recv [Object] ruby object
  # @param method [Function, String] method body or name of the method
  # @param args [Array] arguments that will be passed to the method call
  # @param block [Function] ruby block
  # @param blockopts [Object, Number] optional properties to set on the block
  # @return [Object] returning value of the method call
  def self.send(recv, method, args, block, blockopts)
    %x{
      var body;

      if (typeof(method) === 'function') {
        body = method;
        method = null;
      } else if (typeof(method) === 'string') {
        body = recv[$jsid(method)];
      } else {
        $raise(Opal.NameError, "Passed method should be a string or a function");
      }

      return Opal.send2(recv, body, method, args, block, blockopts);
    }
  end

  def self.send2(recv, body, method, args, block, blockopts)
    %x{
      if (body == null && method != null && recv.$method_missing) {
        body = recv.$method_missing;
        args = $prepend_ary(method, args);
      }

      $apply_blockopts(block, blockopts);

      if (typeof block === 'function') body.$$p = block;
      return body.apply(recv, args);
    }
  end

  def self.refined_send(refinement_groups, recv, method, args, block, blockopts)
    %x{
      var i, j, k, ancestors, ancestor, refinements, refinement, refine_modules, refine_module, body;

      ancestors = $get_ancestors(recv);

      // For all ancestors that there are, starting from the closest to the furthest...
      for (i = 0; i < ancestors.length; i++) {
        ancestor = Opal.id(ancestors[i]);

        // For all refinement groups there are, starting from the closest scope to the furthest...
        for (j = 0; j < refinement_groups.length; j++) {
          refinements = refinement_groups[j];

          // For all refinements there are, starting from the last `using` call to the furthest...
          for (k = refinements.length - 1; k >= 0; k--) {
            refinement = refinements[k];
            if (typeof refinement.$$refine_modules === 'undefined') continue;

            // A single module being given as an argument of the `using` call contains multiple
            // refinement modules
            refine_modules = refinement.$$refine_modules;

            // Does this module refine a given call for a given ancestor module?
            if (typeof refine_modules[ancestor] === 'undefined') continue;
            refine_module = refine_modules[ancestor];

            // Does this module define a method we want to call?
            if (typeof refine_module.$$prototype[$jsid(method)] !== 'undefined') {
              body = refine_module.$$prototype[$jsid(method)];
              return Opal.send2(recv, body, method, args, block, blockopts);
            }
          }
        }
      }

      return Opal.send(recv, method, args, block, blockopts);
    }
  end
end

::Opal
