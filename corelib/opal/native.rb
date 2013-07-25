module Kernel
  def Native(obj)
    Native::Object.new(obj)
  end
end

class Native
  def self.try_convert(value)
    %x{
      if (value == null || !value.$object_id) {
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
      var obj = #@native[key];

      if (obj == null) {
        return nil;
      }
      else if (!obj.$object_id) {
        return #{::Native::Object.new(`obj`)};
      }
      else {
        return obj;
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
        var obj  = #@native,
            prop = obj[mid];

        if (prop == null) {
          return nil;
        }
        else if (typeof(prop) == "function") {
          var result = prop.apply(null, args);

          return (result == null) ? nil : result;
        }
        else if (!prop.$object_id) {
          return #{::Native::Object.new(`prop`)};
        }
        else {
          return prop;
        }
      }
    }
  end
end
