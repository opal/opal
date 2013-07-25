module Kernel
  def Native(obj)
    Native::Object.new(obj)
  end
end

class Native
  def self.try_convert(value)
    %x{
      if (value == null) {
        return null;
      }

      if (value.$to_n) {
        return value.$to_n()
      }
      else if (!value.$object_id) {
        return value;
      }
      else {
        return null;
      }
    }
  end

  def initialize(native)
    native = Native.try_convert(native)

    if `#{native} == null`
      raise ArgumentError, "the passed value isn't a native"
    end

    @native = native
  end

  def to_n
    @native
  end

  class Object < Native
    def [](key)
      %x{
        var obj = #@native[key];

        if (!obj._klass) {
          return #{ Object.new(`obj`) };
        }

        return obj;
      }
    end

    def []=(key, value)
      `#@native[key] = #{Native.try_convert(value)}`
    end

    def method_missing(mid, *args)
      %x{
        var obj  = #@native,
            prop = obj[mid];

        if (mid.charAt(mid.length - 1) === '=') {
          prop = mid.slice(0, mid.length - 1);

          if (args[0] === nil) {
            obj[prop] = null;
            return nil;
          }

          return obj[prop] = args[0];
        }

        if (prop == null) {
          return nil;
        }

        if (!prop._klass) {
          return #{Object.new(`prop`)};
        }

        return prop;
      }
    end
  end
end
