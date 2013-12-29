module Math
  E  = `Math.E`
  PI = `Math.PI`

  def self.acos(x)
    `Math.acos(x)`
  end

  # TODO: reimplement this when unavailable
  def self.acosh(x)
    `Math.acosh(x)`
  end

  def self.asin(x)
    `Math.asin(x)`
  end

  # TODO: reimplement this when unavailable
  def self.asinh(x)
    `Math.asinh(x)`
  end

  def self.atan(x)
    `Math.atan(x)`
  end

  def self.atan2(x, y)
    `Math.atan2(x, y)`
  end

  # TODO: reimplement this when unavailable
  def self.atanh(x)
    `Math.atanh(x)`
  end

  # TODO: reimplement this when unavailable
  def self.cbrt(x)
    `Math.cbrt(x)`
  end

  def self.cos(x)
    `Math.cos(x)`
  end

  # TODO: reimplement this when unavailable
  def self.cosh(x)
    `Math.cosh(x)`
  end

  def self.erf(x)
    raise NotImplementedError
  end

  def self.erfc(x)
    raise NotImplementedError
  end

  def self.exp(x)
    `Math.exp(x)`
  end

  def self.frexp(x)
    raise NotImplementedError
  end

  def self.gamma(x)
    raise NotImplementedError
  end

  def self.hypot(x, y)
    `Math.hypot(x, y)`
  end

  def self.ldexp(flt, int)
    raise NotImplementedError
  end

  def self.lgamma(x)
    raise NotImplementedError
  end

  def self.log(num, base = undefined)
    if `base !== undefined`
      raise NotImplementedError
    end

    `Math.log(num)`
  end

  # TODO: reimplement this when unavailable
  def self.log10(num)
    `Math.log10(num)`
  end

  # TODO: reimplement this when unavailable
  def self.log2(num)
    `Math.log2(num)`
  end

  def self.sin(x)
    `Math.sin(x)`
  end

  # TODO: reimplement this when unavailable
  def self.sinh(x)
    `Math.sinh(x)`
  end

  def self.sqrt(x)
    `Math.sqrt(x)`
  end

  def self.tan(x)
    `Math.tan(x)`
  end

  # TODO: reimplement this when unavailable
  def self.tanh(x)
    `Math.tanh(x)`
  end
end
