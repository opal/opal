module Kernel
  def Native(obj)
    Native::Object.new(obj)
  end
end

class Native
  def self.===(value)
    if self == Native
      `value == null || !value._klass`
    else
      super
    end
  end

  def self.try_convert(value)
    %x{
      if (#{self === value}) {
        return value;
      }
      else if (value.$to_n) {
        return value.$to_n();
      }
      else {
        return nil;
      }
    }
  end

  def self.convert(value)
    native = try_convert(value)

    if `#{native} === nil`
      raise ArgumentError, "the passed value isn't a native"
    end

    native
  end

  def self.alias_native(new, old)
    define_method new do |*args|
      Native.call(@native, old, *args)
    end
  end

  def self.call(obj, key, *args)
    %x{
      var prop = #{obj}[#{key}];

      if (prop == null) {
        return nil;
      }
      else if (typeof(prop) == "function") {
        var result = prop.apply(null, args);

        return (result == null) ? nil : result;
      }
      else if (#{self === `prop`}) {
        return #{Native(`prop`)};
      }
      else {
        return prop;
      }
    }
  end

  def self.new(native)
    if self == Native
      raise ArgumentError, "cannot instantiate non derived Native"
    else
      super(native)
    end
  end

  def initialize(native)
    @native = Native.convert(native)
  end

  def to_n
    @native
  end
end

class Native::Object < BasicObject
  def initialize(native)
    @native = ::Native.convert(native)
  end

  def to_n
    @native
  end

  def nil?
    `#@native == null`
  end

  def [](key)
    raise 'cannot get value from nil native' if nil?

    %x{
      var prop = #@native[key];

      if (typeof(prop) == "function" && prop._klass) {
        return prop;
      }
      else {
        return #{::Native.call(@native, key)}
      }
    }
  end

  def []=(key, value)
    raise 'cannot set value on nil native' if nil?

    native = Native.try_convert(value)

    if `#{native} === nil`
      `#@native[key] = #{value}`
    else
      `#@native[key] = #{native}`
    end
  end

  def method_missing(mid, *args)
    raise 'cannot call method from nil native' if nil?

    %x{
      if (mid.charAt(mid.length - 1) === '=') {
        return #{self[mid.slice(0, mid.length - 1)] = args[0]};
      }
      else {
        return #{::Native.call(@native, mid, *args)};
      }
    }
  end
end
