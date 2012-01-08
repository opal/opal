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
