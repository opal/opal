# backtick_javascript: true

class Engine
  module Delegate
    def [](property)
      method_missing(property)
    end

    def method_missing message, *args, &block
      if message.end_with? '='
        message = message.chop
        property_name = ::Engine.property_for_message(message, self)
        arg = args[0]
        arg = arg.to_n if `arg && typeof arg.$to_n === 'function'`
        return `self[#{property_name}] = arg`
      else
        property_name = ::Engine.property_for_message(message, self)
        %x{
          let value = self[#{property_name}];
          let type = typeof(value);
          if (type === 'undefined') { return #{super}; }
          if (type === 'function') {
            #{args.map! { |arg| `arg && typeof arg.$to_n === 'function'` ? arg.to_n : arg }}
            value = value.apply(self, args);
          }

          type = typeof(value);
          if (type !== 'number' && type !== 'string') {
            // check if the values class has been rubyfied (see const_missing below)
            const name = value.constructor.name;
            if (typeof Opal.Engine[name] !== 'function') {
              // no
              Opal.Engine.$const_missing(name);
              if (typeof Opal.Engine[name] !== 'function') {
                // something went wrong
                #{raise "cant rubyfy #{name}"}
              }
            }
          }
          return value;
        }
      end
    end

    def respond_to_missing? message, include_all
      message = message.chop if message.end_with? '='
      property_name = property_for_message(message, self)
      return true if `#{property_name} in self`
      false
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
      method_missing(property)
    end

    def method_missing message, *args, &block
      if message.end_with? '='
        message = message.chop
        property_name = property_for_message(message, `globalThis`)
        arg = args[0]
        arg = arg.to_n if `arg && typeof arg.$to_n === 'function'`
        return `globalThis[#{property_name}] = arg`
      else
        property_name = property_for_message(message, `globalThis`)
        %x{
          let value = globalThis[#{property_name}];
          let type = typeof(value);
          if (type === 'undefined') { return #{super}; }
          if (type === 'function') {
            #{args.map! { |arg| `arg && typeof arg.$to_n === 'function'` ? arg.to_n : arg }}
            value = value.apply(self, args);
          }

          type = typeof(value);
          if (type !== 'number' && type !== 'string') {
            // check if the values class has been rubyfied (see const_missing below)
            const name = value.constructor.name;
            if (typeof Opal.Engine[name] !== 'function') {
              // no
              self.$const_missing(name);
              if (typeof Opal.Engine[name] !== 'function') {
                // something went wrong
                #{raise "cant rubyfy #{name}"}
              }
            }
          }
          return value;
        }
      end
    end

    %x{
      function camelize(str) {
        return str.replace(/^([A-Z])|[\s-_](\w)/g, function(match, p1, p2, offset) {
            if (p2) return p2.toUpperCase();
            return p1.toLowerCase();
        });
      };
    }
    def property_for_message(message, scope)
      %x{
        let camel_cased_message;
        if (typeof(scope[message]) !== 'undefined') { camel_cased_message = message; }
        else { camel_cased_message = camelize(message); }

        if (camel_cased_message.endsWith('?')) {
          camel_cased_message = camel_cased_message.substring(0, camel_cased_message.length - 2);
          if (typeof(scope[camel_cased_message]) === 'undefined') {
            camel_cased_message = 'is' + camel_cased_message[0].toUpperCase() + camel_cased_message.substring(0, camel_cased_message.length - 1);
          }
        }
        return camel_cased_message
      }
    end
  end
end
