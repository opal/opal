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

  def self.coerce_to?(object, type, method)
    return unless object.respond_to? method

    coerced = coerce_to(object, type, method)

    return if coerced.nil?

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
