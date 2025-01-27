# backtick_javascript: true
# use_strict: true
# opal_runtime_mode: true
# helpers: raise, prop, set_proto

module ::Opal
  # For performance, some core Ruby classes are toll-free bridged to their
  # native JavaScript counterparts (e.g. a Ruby Array is a JavaScript Array).
  #
  # This method is used to setup a native constructor (e.g. Array), to have
  # its prototype act like a normal Ruby class. Firstly, a new Ruby class is
  # created using the native constructor so that its prototype is set as the
  # target for the new class. Note: all bridged classes are set to inherit
  # from Object.
  #
  # Example:
  #
  #    Opal.bridge(self, Function);
  #
  # @param klass       [Class] the Ruby class to bridge
  # @param constructor [JS.Function] native JavaScript constructor to use
  # @return [Class] returns the passed Ruby class
  #
  def self.bridge(native_klass, klass)
    %x{
      if (native_klass.hasOwnProperty('$$bridge')) {
        $raise(Opal.ArgumentError, "already bridged");
      }

      // constructor is a JS function with a prototype chain like:
      // - constructor
      //   - super
      //
      // What we need to do is to inject our class (with its prototype chain)
      // between constructor and super. For example, after injecting ::Object
      // into JS String we get:
      //
      // - constructor (window.String)
      //   - Opal.Object
      //     - Opal.Kernel
      //       - Opal.BasicObject
      //         - super (window.Object)
      //           - null
      //
      $prop(native_klass, '$$bridge', klass);

      // native_klass may be a subclass of a subclass of a ... so look for either
      // Object.prototype in its prototype chain and inject there or inject at the
      // end of the chain. Also, there is a chance we meet some Ruby Class on the
      // way, if a bridged class has been subclassed or its protype has been
      // otherwise modified. Then we assume that the prototype is already modified
      // correctly and we dont need to inject anything.
      let prototype = native_klass.prototype, next_prototype;
      while (true) {
        if (prototype.$$bridge ||
            prototype.$$class  || prototype.$$is_class ||
            prototype.$$module || prototype.$$is_module) {
          // hit a bridged class, a Ruby Class or Module
          break;
        }
        next_prototype = Object.getPrototypeOf(prototype);
        if (next_prototype === Object.prototype || !next_prototype)  {
          // found the right spot, inject!
          $set_proto(prototype, (klass.$$super || Opal.Object).$$prototype);
          break;
        }
        prototype = next_prototype;
      }

      $prop(klass, '$$prototype', native_klass.prototype);

      $prop(klass.$$prototype, '$$class', klass);
      $prop(klass, '$$constructor', native_klass);
      $prop(klass, '$$bridge', true);
    }
  end
end

::Opal
