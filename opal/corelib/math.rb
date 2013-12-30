module Math
  class DomainError < StandardError
    def self.new(method)
      super "Numerical argument is out of domain - \"#{method}\""
    end
  end

  E  = `Math.E`
  PI = `Math.PI`

  def acos(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      if (x < -1 || x > 1) {
        #{raise DomainError, :acos};
      }

      return Math.acos(x);
    }
  end

  # TODO: reimplement this when unavailable
  def acosh(x)
    `Math.acosh(x)`
  end

  def asin(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      if (x < -1 || x > 1) {
        #{raise DomainError, :asin};
      }

      return Math.asin(x);
    }
  end

  # TODO: reimplement this when unavailable
  def asinh(x)
    `Math.asinh(x)`
  end

  def atan(x)
    `Math.atan(x)`
  end

  def atan2(x, y)
    `Math.atan2(x, y)`
  end

  # TODO: reimplement this when unavailable
  def atanh(x)
    `Math.atanh(x)`
  end

  # TODO: reimplement this when unavailable
  def cbrt(x)
    `Math.cbrt(x)`
  end

  def cos(x)
    `Math.cos(x)`
  end

  # TODO: reimplement this when unavailable
  def cosh(x)
    `Math.cosh(x)`
  end

  def erf(x)
    raise NotImplementedError
  end

  def erfc(x)
    raise NotImplementedError
  end

  def exp(x)
    `Math.exp(x)`
  end

  def frexp(x)
    raise NotImplementedError
  end

  def gamma(x)
    raise NotImplementedError
  end

  def hypot(x, y)
    `Math.hypot(x, y)`
  end

  def ldexp(flt, int)
    raise NotImplementedError
  end

  def lgamma(x)
    raise NotImplementedError
  end

  def log(num, base = undefined)
    if `base !== undefined`
      raise NotImplementedError
    end

    `Math.log(num)`
  end

  # TODO: reimplement this when unavailable
  def log10(num)
    `Math.log10(num)`
  end

  # TODO: reimplement this when unavailable
  def log2(num)
    `Math.log2(num)`
  end

  def sin(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.sin(x);
    }
  end

  # TODO: reimplement this when unavailable
  def sinh(x)
    `Math.sinh(x)`
  end

  def sqrt(x)
    `Math.sqrt(x)`
  end

  def tan(x)
    `Math.tan(x)`
  end

  # TODO: reimplement this when unavailable
  def tanh(x)
    `Math.tanh(x)`
  end

  class << self
    include Math
  end
end
