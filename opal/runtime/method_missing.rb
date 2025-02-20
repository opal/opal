# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: BasicObject, jsid, prop, prepend_ary

module ::Opal
  # Method Missing
  # --------------

  # Methods stubs are used to facilitate method_missing in opal. A stub is a
  # placeholder function which just calls `method_missing` on the receiver.
  # If no method with the given name is actually defined on an object, then it
  # is obvious to say that the stub will be called instead, and then in turn
  # method_missing will be called.
  #
  # When a file in ruby gets compiled to javascript, it includes a call to
  # this function which adds stubs for every method name in the compiled file.
  # It should then be safe to assume that method_missing will work for any
  # method call detected.
  #
  # Method stubs are added to the BasicObject prototype, which every other
  # ruby object inherits, so all objects should handle method missing. A stub
  # is only added if the given property name (method name) is not already
  # defined.
  #
  # Note: all ruby methods have a `$` prefix in javascript, so all stubs will
  # have this prefix as well (to make this method more performant).
  #
  #    Opal.add_stubs("foo,bar,baz=");
  #
  # All stub functions will have a private `$$stub` property set to true so
  # that other internal methods can detect if a method is just a stub or not.
  # `Kernel#respond_to?` uses this property to detect a methods presence.
  #
  # @param stubs [Array] an array of method stubs to add
  # @return [undefined]
  def self.add_stubs(stubs)
    %x{
      var proto = $BasicObject.$$prototype;
      var stub, existing_method;
      stubs = stubs.split(',');

      for (var i = 0, length = stubs.length; i < length; i++) {
        stub = $jsid(stubs[i]), existing_method = proto[stub];

        if (existing_method == null || existing_method.$$stub) {
          Opal.add_stub_for(proto, stub);
        }
      }
    }
  end

  # Add a method_missing stub function to the given prototype for the
  # given name.
  #
  # @param prototype [Prototype] the target prototype
  # @param stub [String] stub name to add (e.g. "$foo")
  # @return [undefined]
  def self.add_stub_for(prototype, stub)
    # Opal.stub_for(stub) is the method_missing_stub
    `$prop(prototype, stub, Opal.stub_for(stub))`
  end

  # Generate the method_missing stub for a given method name.
  #
  # @param method_name [String] The js-name of the method to stub (e.g. "$foo")
  # @return [undefined]
  def self.stub_for(method_name)
    %x{
      function method_missing_stub() {
        // Copy any given block onto the method_missing dispatcher
        this.$method_missing.$$p = method_missing_stub.$$p;

        // Set block property to null ready for the next call (stop false-positives)
        method_missing_stub.$$p = null;

        // call method missing with correct args (remove '$' prefix on method name)
        return this.$method_missing.apply(this, $prepend_ary(method_name.slice(1), arguments));
      };

      method_missing_stub.$$stub = true;

      return method_missing_stub;
    }
  end

  `Opal.add_stubs("require,autoload")`
end

::Opal
