module Math
  E  = `Math.E`
  PI = `Math.PI`

  DomainError = Class.new(StandardError)

  %x{
    var G = 4.7421875;

    var P = [
       0.99999999999999709182,
       57.156235665862923517,
      -59.597960355475491248,
       14.136097974741747174,
      -0.49191381609762019978,
       0.33994649984811888699e-4,
       0.46523628927048575665e-4,
      -0.98374475304879564677e-4,
       0.15808870322491248884e-3,
      -0.21026444172410488319e-3,
       0.21743961811521264320e-3,
      -0.16431810653676389022e-3,
       0.84418223983852743293e-4,
      -0.26190838401581408670e-4,
       0.36899182659531622704e-5
    ];
  }

  def self.checked(method, *args)
    %x{
      if (isNaN(args[0]) || (args.length == 2 && isNaN(args[1]))) {
        return NaN;
      }

      var result = Math[method].apply(null, args);

      if (isNaN(result)) {
        #{raise DomainError, "Numerical argument is out of domain - \"#{method}\""};
      }

      return result;
    }
  end

  def self.coerce!(value)
    begin
      Float(value)
    rescue ArgumentError
      raise Opal.type_error(value, Float)
    end
  end

  module_function

  def acos(x)
    Math.checked :acos, Math.coerce!(x)
  end

  unless defined?(`Math.acosh`)
    %x{
      Math.acosh = function(x) {
        return Math.log(x + Math.sqrt(x * x - 1));
      }
    }
  end

  def acosh(x)
    Math.checked :acosh, Math.coerce!(x)
  end

  def asin(x)
    Math.checked :asin, Math.coerce!(x)
  end

  unless defined?(`Math.asinh`)
    %x{
      Math.asinh = function(x) {
        return Math.log(x + Math.sqrt(x * x + 1))
      }
    }
  end

  def asinh(x)
    Math.checked :asinh, Math.coerce!(x)
  end

  def atan(x)
    Math.checked :atan, Math.coerce!(x)
  end

  def atan2(y, x)
    Math.checked :atan2, Math.coerce!(y), Math.coerce!(x)
  end

  unless defined?(`Math.atanh`)
    %x{
      Math.atanh = function(x) {
        return 0.5 * Math.log((1 + x) / (1 - x));
      }
    }
  end

  def atanh(x)
    Math.checked :atanh, Math.coerce!(x)
  end

  def cbrt(x)
    Math.checked :cbrt, Math.coerce!(x)
  end

  def cos(x)
    Math.checked :cos, Math.coerce!(x)
  end

  unless defined?(`Math.cosh`)
    %x{
      Math.cosh = function(x) {
        return (Math.exp(x) + Math.exp(-x)) / 2;
      }
    }
  end

  def cosh(x)
    Math.checked :cosh, Math.coerce!(x)
  end

  def erf(x)
    Math.checked :erf, Math.coerce!(x)
  end

  def erfc(x)
    Math.checked :erfc, Math.coerce!(x)
  end

  def exp(x)
    Math.checked :exp, Math.coerce!(x)
  end

  def frexp(x)
    %x{
      var ex   = Math.floor(Math.log(Math.abs(x)) / Math.log(2)) + 1,
          frac = x / Math.pow(2, ex);

      return [frac, ex];
    }
  end

  def gamma(n)
    %x{
      var i, t, x, value, result, twoN, threeN, fourN, fiveN;

      if (#{Integer === n}) {
        if (n <= 0) {
          return isFinite(n) ? Infinity : NaN;
        }

        if (n > 171) {
          return Infinity;
        }

        value  = n - 2;
        result = n - 1;

        while (value > 1) {
          result *= value;
          value--;
        }

        if (result == 0) {
          result = 1;
        }

        return result;
      }

      if (n < 0.5) {
        return Math.PI / (Math.sin(Math.PI * n) * #{Math.gamma(1 - n)});
      }

      if (n >= 171.35) {
        return Infinity;
      }

      if (n > 85.0) {
        twoN   = n * n;
        threeN = twoN * n;
        fourN  = threeN * n;
        fiveN  = fourN * n;

        return Math.sqrt(2 * Math.PI / n) * Math.pow((n / Math.E), n) *
          (1 + 1 / (12 * n) + 1 / (288 * twoN) - 139 / (51840 * threeN) -
          571 / (2488320 * fourN) + 163879 / (209018880 * fiveN) +
          5246819 / (75246796800 * fiveN * n));
      }

      n -= 1;
      x  = P[0];

      for (i = 1; i < P.length; ++i) {
        x += P[i] / (n + i);
      }

      t = n + G + 0.5;

      return Math.sqrt(2 * Math.PI) * Math.pow(t, n + 0.5) * Math.exp(-t) * x;
    }
  end

  unless defined?(`Math.hypot`)
    %x{
      Math.hypot = function(x, y) {
        return Math.sqrt(x * x + y * y)
      }
    }
  end

  def hypot(x, y)
    Math.checked :hypot, Math.coerce!(x), Math.coerce!(y)
  end

  def ldexp(mantissa, exponent)
    %x{
      return exponent > 1023
          ? mantissa * Math.pow(2, 1023) * Math.pow(2, exponent - 1023)
          : exponent < -1074
          ? mantissa * Math.pow(2, -1074) * Math.pow(2, exponent + 1074)
          : mantissa * Math.pow(2, exponent);
    }
  end

  def lgamma(n)
    `[Math.log(Math.abs(#{Math.gamma(n)})), #{Math.gamma(n)} < 0 ? -1 : 1]`
  end

  def log(x, base = undefined)
    if String === x
      raise Opal.type_error(x, Float)
    end

    if `base == null`
      Math.checked :log, Math.coerce!(x)
    else
      if String === base
        raise Opal.type_error(base, Float)
      end

      Math.checked(:log, Math.coerce!(x)) / Math.checked(:log, Math.coerce!(base))
    end
  end

  unless defined?(`Math.log10`)
    %x{
      Math.log10 = function(x) {
        return Math.log(x) / Math.LN10;
      }
    }
  end

  def log10(x)
    if String === x
      raise Opal.type_error(x, Float)
    end

    Math.checked :log10, Math.coerce!(x)
  end

  unless defined?(`Math.log2`)
    %x{
      Math.log2 = function(x) {
        return Math.log(x) / Math.LN2;
      }
    }
  end

  def log2(x)
    if String === x
      raise Opal.type_error(x, Float)
    end

    Math.checked :log2, Math.coerce!(x)
  end

  def sin(x)
    Math.checked :sin, Math.coerce!(x)
  end

  unless defined?(`Math.sinh`)
    %x{
      Math.sinh = function(x) {
        return (Math.exp(x) - Math.exp(-x)) / 2;
      }
    }
  end

  def sinh(x)
    Math.checked :sinh, Math.coerce!(x)
  end

  def sqrt(x)
    Math.checked :sqrt, Math.coerce!(x)
  end

  def tan(x)
    x = Math.coerce!(x)

    if x.infinite?
      return Float::NAN
    end

    Math.checked :tan, Math.coerce!(x)
  end

  unless defined?(`Math.tanh`)
    %x{
      Math.tanh = function(x) {
        if (x == Infinity) {
          return 1;
        }
        else if (x == -Infinity) {
          return -1;
        }
        else {
          return (Math.exp(x) - Math.exp(-x)) / (Math.exp(x) + Math.exp(-x));
        }
      }
    }
  end

  def tanh(x)
    Math.checked :tanh, Math.coerce!(x)
  end
end
