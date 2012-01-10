module Native
  class Object
    include Native

    def [](name)
      `#@native[name]`
    end

    def []=(name, value)
      `#@native[name] = value`
    end

    def nil?
      `#@native === null || #@native === undefined`
    end

    def method_missing(name, *args)
      return super unless Opal.function? `#@native[name]`

      __native_send__ name, *args
    end
  end

  def self.included (klass)
    class << klass
      def from_native (object)
        instance = allocate
        instance.instance_variable_set :@native, object

        instance
      end
    end
  end

  def initialize(native)
    @native = native
  end

  def to_native
    @native
  end

  def native_send(name, *args)
    return method_missing(name, *args) unless Opal.function? `#@native[name]`

    `#@native[name].apply(#@native, args)`
  end

  alias_method :__native_send__, :native_send
end

class Module
  def attr_accessor_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], true, true);
      }

      return nil;
    }
  end

  def attr_reader_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], true, false);
      }

      return nil;
    }
  end

  def attr_reader_bridge(target, *attrs)
    %x{
      for (var i = 0, length = attrs.length; i < length; i++) {
        define_attr_bridge(this, target, attrs[i], false, true);
      }

      return nil;
    }
  end

  def attr_bridge(target, name, setter = false)
    `define_attr_bridge(this, target, name, true, setter)`

    self
  end

  def define_method_bridge(object, name, ali = nil)
    %x{
      define_method_bridge(this, object, mid_to_jsid(#{ali || name}), name);
      this.$methods.push(name);

      return nil;
    }
  end
end

class Array
  def to_native
    map { |obj| Opal.object?(obj) ? obj.to_native : obj }
  end
end

class Boolean
  def to_native
    `this == true`
  end
end

class Hash
  def to_native
    %x{
      var map    = this.map,
          result = {};

      for (var assoc in map) {
        var key   = map[assoc][0],
            value = map[assoc][1];

        result[key] = #{Opal.native?(`value`)} ? value : #{`value`.to_native};
      }

      return result;
    }
  end
end

module Kernel
  def Object(object)
    Opal.native?(object) ? Native::Object.new(object) : object
  end
end

class MatchData
  alias to_native to_a
end

class NilClass
  def to_native
    `var result; return result;`
  end
end

class Numeric
  def to_native
    `this.valueOf()`
  end
end

class Object
  def to_native
    raise TypeError, 'no specialized #to_native has been implemented'
  end
end

class Proc
  def to_native
    %x{
      return function() {
        var args = Array.slice.call(arguments);
            args.unshift(null); // block

        return this.apply(this.$S, args);
      };
    }
  end
end

class Regexp
  def to_native
    self
  end
end

class String
  def to_native
    `this.valueOf()`
  end
end
