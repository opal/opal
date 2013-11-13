module Opal
  def self.coerce_to(object, type, method)
    return object if type === object

    unless object.respond_to? method
      raise TypeError, "no implicit conversion of #{object.class} into #{type}"
    end

    object.__send__ method
  end

  def self.coerce_to!(object, type, method)
    coerced = coerce_to(object, type, method)

    unless type === coerced
      raise TypeError, "can't convert #{object.class} into #{type} (#{object.class}##{method} gives #{coerced.class}"
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
      raise ArgumentError, "comparison of #{a.class.name} with #{b.class.name} failed"
    end

    compare
  end

  def self.fits_fixnum!(value)
    # since we have Fixnum#size as 32 bit, this is based on the int limits
    if `value > 2147483648`
      raise RangeError, "bignum too big to convert into `long'"
    end
  end

  def self.fits_array!(value)
    # this is the computed ARY_MAX_SIZE for 32 bit
    if `value >= 536870910`
      raise ArgumentError, "argument too big"
    end
  end

  def self.truthy?(value)
    if value
      true
    else
      false
    end
  end

  def self.falsy?(value)
    if value
      false
    else
      true
    end
  end

  def self.destructure(args)
    %x{
      if (args.length == 1) {
        return args[0];
      }
      else if (args._isArray) {
        return args;
      }
      else {
        return $slice.call(args);
      }
    }
  end
end
