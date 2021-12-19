# helpers: type_error, coerce_to

module ::Opal
  def self.bridge(constructor, klass)
    `Opal.bridge(constructor, klass)`
  end

  def self.coerce_to!(object, type, method, *args)
    coerced = `$coerce_to(object, type, method, args)`

    unless type === coerced
      ::Kernel.raise `$type_error(object, type, method, coerced)`
    end

    coerced
  end

  def self.coerce_to?(object, type, method, *args)
    return unless object.respond_to? method

    coerced = `$coerce_to(object, type, method, args)`

    return if coerced.nil?

    unless type === coerced
      ::Kernel.raise `$type_error(object, type, method, coerced)`
    end

    coerced
  end

  def self.try_convert(object, type, method)
    return object if type === object

    if object.respond_to? method
      object.__send__ method
    end
  end

  def self.compare(a, b)
    compare = a <=> b

    if `compare === nil`
      ::Kernel.raise ::ArgumentError, "comparison of #{a.class} with #{b.class} failed"
    end

    compare
  end

  def self.destructure(args)
    %x{
      if (args.length == 1) {
        return args[0];
      }
      else if (args.$$is_array) {
        return args;
      }
      else {
        var args_ary = new Array(args.length);
        for(var i = 0, l = args_ary.length; i < l; i++) { args_ary[i] = args[i]; }

        return args_ary;
      }
    }
  end

  def self.respond_to?(obj, method, include_all = false)
    %x{
      if (obj == null || !obj.$$class) {
        return false;
      }
    }

    obj.respond_to?(method, include_all)
  end

  def self.instance_variable_name!(name)
    name = ::Opal.coerce_to!(name, ::String, :to_str)

    unless `/^@[a-zA-Z_][a-zA-Z0-9_]*?$/.test(name)`
      ::Kernel.raise ::NameError.new("'#{name}' is not allowed as an instance variable name", name)
    end

    name
  end

  def self.class_variable_name!(name)
    name = ::Opal.coerce_to!(name, ::String, :to_str)

    if `name.length < 3 || name.slice(0,2) !== '@@'`
      ::Kernel.raise ::NameError.new("`#{name}' is not allowed as a class variable name", name)
    end

    name
  end

  def self.const_name?(const_name)
    %x{
      if (typeof const_name !== 'string') {
        #{const_name = ::Opal.coerce_to!(const_name, ::String, :to_str)}
      }

      return #{const_name}[0] === #{const_name}[0].toUpperCase()
    }
  end

  def self.const_name!(const_name)
    const_name = ::Opal.coerce_to!(const_name, ::String, :to_str)

    if const_name[0] != const_name[0].upcase
      ::Kernel.raise ::NameError, "wrong constant name #{const_name}"
    end

    const_name
  end

  # @private
  # Mark some methods as pristine in order to apply optimizations when they
  # are still in their original form. This could probably be moved to
  # the `Opal.def()` JS API, but for now it will stay manual.
  #
  # @example
  #
  #   Opal.pristine Array, :allocate, :copy_instance_variables, :initialize_dup
  #
  #   class Array
  #     def dup
  #       %x{
  #         if (
  #           self.$allocate.$$pristine &&
  #           self.$copy_instance_variables.$$pristine &&
  #           self.$initialize_dup.$$pristine
  #         ) return self.slice(0);
  #       }
  #
  #       super
  #     end
  #   end
  #
  # @param owner_class [Class] the class owning the methods
  # @param method_names [Array<Symbol>] the list of methods names to mark
  # @return [nil]
  def self.pristine(owner_class, *method_names)
    %x{
      var method_name, method;
      for (var i = method_names.length - 1; i >= 0; i--) {
        method_name = method_names[i];
        method = owner_class.$$prototype['$'+method_name];

        if (method && !method.$$stub) {
          method.$$pristine = true;
        }
      }
    }
    nil
  end

  `var inspect_stack = []`

  # Performs a safe call to inspect for any value, whether
  # native or Opal-wrapped.
  #
  # @param value [Object]
  # @return [String]
  def self.inspect(value = undefined)
    `var pushed = false`
    begin
      %x{
        if (value === null) {
          // JS null value
          return 'null';
        }
        else if (value === undefined) {
          // JS undefined value
          return 'undefined';
        }
        else if (typeof value.$$class === 'undefined') {
          // JS object / other value that is not bridged
          return Object.prototype.toString.apply(value);
        }
        else if (typeof value.$inspect !== 'function' || value.$inspect.$$stub) {
          // BasicObject and friends
          return #{"#<#{`value.$$class`}:0x#{value.__id__.to_s(16)}>"}
        }
        else if (inspect_stack.indexOf(#{value.__id__}) !== -1) {
          // inspect recursing inside inspect to find out about the
          // same object
          return #{"#<#{`value.$$class`}:0x#{value.__id__.to_s(16)}>"}
        }
        else {
          // anything supporting Opal
          inspect_stack.push(#{value.__id__});
          pushed = true;
          return value.$inspect();
        }
      }
      nil
    rescue ::Exception => e # rubocop:disable Lint/RescueException
      "#<#{`value.$$class`}:0x#{value.__id__.to_s(16)}>"
    ensure
      `if (pushed) inspect_stack.pop()`
    end
  end
end
