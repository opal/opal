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

  unless defined?(`Math.acosh`)
    %x{
      Math.acosh = function(x) {
        return Math.log(x + Math.sqrt(x * x - 1));
      }
    }
  end

  def acosh(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.acosh(x);
    }
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

  unless defined?(`Math.atanh`)
    %x{
      Math.atanh = function(x) {
        return 0.5 * Math.log((1 + x) / (1 - x));
      }
    }
  end

  def atanh(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      if (x < -1 || x > 1) {
        #{raise DomainError, :atanh};
      }

      return Math.atanh(x);
    }
  end

  # TODO: reimplement this when unavailable
  def cbrt(x)
    `Math.cbrt(x)`
  end

  def cos(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.cos(x);
    }
  end

  unless defined?(`Math.cosh`)
    %x{
      Math.cosh = function(x) {
        return (Math.exp(x) + Math.exp(-x)) / 2;
      }
    }
  end

  def cosh(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.cosh(x);
    }
  end

  def erf(x)
    raise NotImplementedError
  end

  def erfc(x)
    raise NotImplementedError
  end

  def exp(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.exp(x);
    }
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

  def log(num, base = E, method = nil)
    %x{
      if (!#{Numeric === num}) {
        #{raise Opal.type_error(num, Float)};
      }

      if (!#{Numeric === base}) {
        #{raise Opal.type_error(base, Float)};
      }

      num  = #{num.to_f};
      base = #{base.to_f};

      if (num < 0) {
        #{raise DomainError, method || :log};
      }

      num = Math.log(num);

      if (base != Math.E) {
        num /= Math.log(base);
      }

      return num
    }
  end

  if defined?(`Math.log10`)
    def log10(num)
      %x{
        if (!#{Numeric === num}) {
          #{raise Opal.type_error(num, Float)};
        }

        num = #{num.to_f};

        if (num < 0) {
          #{raise DomainError, :log2};
        }

        return Math.log10(num);
      }
    end
  else
    def log10(num)
      log(num, 10, :log10)
    end
  end

  if defined?(`Math.log2`)
    def log2(num)
      %x{
        if (!#{Numeric === num}) {
          #{raise Opal.type_error(num, Float)};
        }

        num = #{num.to_f};

        if (num < 0) {
          #{raise DomainError, :log2};
        }

        return Math.log2(num);
      }
    end
  else
    def log2(num)
      log(num, 2, :log2)
    end
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

  unless defined?(`Math.sinh`)
    %x{
      Math.sinh = function(x) {
        return (Math.exp(x) - Math.exp(-x)) / 2;
      }
    }
  end

  def sinh(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.sinh(x);
    }
  end

  def sqrt(x)
    %x{
      if (!#{Numeric === x}) {
        #{raise Opal.type_error(x, Float)};
      }

      x = #{x.to_f};

      return Math.sqrt(x);
    }
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
