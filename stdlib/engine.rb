# backtick_javascript: true

%x{
  function camelize(str) {
    return str.replace(/^([A-Z])|[\s-_](\w)/g, function(match, p1, p2, offset) {
        if (p2) return p2.toUpperCase();
        return p1.toLowerCase();
    });
  }

  function property_for_message(scope, message) {
    if (message in scope) { return message; }
    else { return camelize(message); }
  }

  function get_property_value(scope, property) {
    property = property_for_message(scope, property);
    return scope[property];
  }

  function value_to_ruby(value) {
    if (value && typeof(value) === 'object') {
      // check if the values class has been rubyfied (see const_missing below)
      const name = value.constructor.name;
      if (typeof Opal.Engine[name] !== 'function') {
        // no
        Opal.Engine.$const_missing(name);
        if (typeof Opal.Engine[name] !== 'function') {
          // something went wrong
          #{raise(TypeError, "can't rubyfy '#{name}'")}
        }
      }
    }
    if (value === undefined || value === null) { return nil; }
    return value;
  }

  function get_property(scope, property) {
    var value = get_property_value(scope, property);
    return value_to_ruby(value);
  }

  function set_property(scope, property, value) {
    var native_value = (value && typeof value.$to_n === 'function' && !value.$to_n.$$stub) ? value.$to_n() : value;
    property = property_for_message(scope, property)
    scope[property] = native_value;
    return value;
  }

  function internal_method_missing(scope, message, args, block) {
    var func = get_property_value(scope, message);
    if (typeof(func) !== 'function') { return [false, null]; }
    #{args.map! { |arg| `arg && typeof arg.$to_n === 'function' && !value.$to_n.$$stub` ? arg.to_n : arg }}
    return [true, value_to_ruby(func.apply(scope, args))];
  }
}

class Engine
  module Delegate
    def [](property)
      `get_property(self, property)`
    end

    def []=(property, value)
      `set_property(self, property, value)`
    end

    def method_missing message, *args, &block
      %x{
        var val = internal_method_missing(self, message, args, block);
        if (val[0]) { return val[1]; }
        else { return #{super} }
      }
    end

    def respond_to_missing? message, include_all
      message = message.chop if message.end_with? '='
      %x{
        message = property_for_message(self, message)
        if (typeof self[property_name] === 'function') { return true; }
        return false;
      }
    end
  end

  class << self
    def const_missing(name)
      %x{
        const first_letter = name[0];
        // check if valid class name, must start with upper case letter
        if (first_letter !== first_letter.toUpperCase()) { #{super} }
        // check if class exists
        const js_class = globalThis[name]
        if (typeof js_class !== 'function') { #{super} }

        // at this stage we have a class name that should correspond to a class unter globalThis
        // now we need to build the ruby class
        try {
          const ruby_class = Opal.klass(self, js_class, name);
          ruby_class.$include(self.Delegate);
          return ruby_class;
        } catch(e) { #{super} }
      }
    end

    def [](property)
      `get_property(Opal.global, property)`
    end

    def []=(property, value)
      `set_property(Opal.global, property, value)`
    end

    def method_missing message, *args, &block
      %x{
        var val = internal_method_missing(Opal.global, message, args, block);
        if (val[0]) { return val[1]; }
        else { return #{super} }
      }
    end
  end
end
