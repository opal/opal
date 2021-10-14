# helpers: type_error
# use_strict: true
# frozen_string_literal: true

module Math
  E  = `Math.E`
  PI = `Math.PI`

  DomainError = Class.new(StandardError)

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

  def self.float!(value)
    Float(value)
  rescue ArgumentError
    raise `$type_error(value, #{Float})`
  end

  def self.integer!(value)
    Integer(value)
  rescue ArgumentError
    raise `$type_error(value, #{Integer})`
  end

  module_function

  def acos(x)
    Math.checked :acos, Math.float!(x)
  end

  unless defined?(`Math.acosh`)
    %x{
      Math.acosh = function(x) {
        return Math.log(x + Math.sqrt(x * x - 1));
      }
    }
  end

  def acosh(x)
    Math.checked :acosh, Math.float!(x)
  end

  def asin(x)
    Math.checked :asin, Math.float!(x)
  end

  unless defined?(`Math.asinh`)
    %x{
      Math.asinh = function(x) {
        return Math.log(x + Math.sqrt(x * x + 1))
      }
    }
  end

  def asinh(x)
    Math.checked :asinh, Math.float!(x)
  end

  def atan(x)
    Math.checked :atan, Math.float!(x)
  end

  def atan2(y, x)
    Math.checked :atan2, Math.float!(y), Math.float!(x)
  end

  unless defined?(`Math.atanh`)
    %x{
      Math.atanh = function(x) {
        return 0.5 * Math.log((1 + x) / (1 - x));
      }
    }
  end

  def atanh(x)
    Math.checked :atanh, Math.float!(x)
  end

  unless defined?(`Math.cbrt`)
    %x{
      Math.cbrt = function(x) {
        if (x == 0) {
          return 0;
        }

        if (x < 0) {
          return -Math.cbrt(-x);
        }

        var r  = x,
            ex = 0;

        while (r < 0.125) {
          r *= 8;
          ex--;
        }

        while (r > 1.0) {
          r *= 0.125;
          ex++;
        }

        r = (-0.46946116 * r + 1.072302) * r + 0.3812513;

        while (ex < 0) {
          r *= 0.5;
          ex++;
        }

        while (ex > 0) {
          r *= 2;
          ex--;
        }

        r = (2.0 / 3.0) * r + (1.0 / 3.0) * x / (r * r);
        r = (2.0 / 3.0) * r + (1.0 / 3.0) * x / (r * r);
        r = (2.0 / 3.0) * r + (1.0 / 3.0) * x / (r * r);
        r = (2.0 / 3.0) * r + (1.0 / 3.0) * x / (r * r);

        return r;
      }
    }
  end

  def cbrt(x)
    Math.checked :cbrt, Math.float!(x)
  end

  def cos(x)
    Math.checked :cos, Math.float!(x)
  end

  unless defined?(`Math.cosh`)
    %x{
      Math.cosh = function(x) {
        return (Math.exp(x) + Math.exp(-x)) / 2;
      }
    }
  end

  def cosh(x)
    Math.checked :cosh, Math.float!(x)
  end

  unless defined?(`Math.erf`)
    %x{
      Opal.defineProperty(Math, 'erf', function(x) {
        var A1 =  0.254829592,
            A2 = -0.284496736,
            A3 =  1.421413741,
            A4 = -1.453152027,
            A5 =  1.061405429,
            P  =  0.3275911;

        var sign = 1;

        if (x < 0) {
            sign = -1;
        }

        x = Math.abs(x);

        var t = 1.0 / (1.0 + P * x);
        var y = 1.0 - (((((A5 * t + A4) * t) + A3) * t + A2) * t + A1) * t * Math.exp(-x * x);

        return sign * y;
      });
    }
  end

  def erf(x)
    Math.checked :erf, Math.float!(x)
  end

  unless defined?(`Math.erfc`)
    %x{
      Opal.defineProperty(Math, 'erfc', function(x) {
        var z = Math.abs(x),
            t = 1.0 / (0.5 * z + 1.0);

        var A1 = t * 0.17087277 + -0.82215223,
            A2 = t * A1 + 1.48851587,
            A3 = t * A2 + -1.13520398,
            A4 = t * A3 + 0.27886807,
            A5 = t * A4 + -0.18628806,
            A6 = t * A5 + 0.09678418,
            A7 = t * A6 + 0.37409196,
            A8 = t * A7 + 1.00002368,
            A9 = t * A8,
            A10 = -z * z - 1.26551223 + A9;

        var a = t * Math.exp(A10);

        if (x < 0.0) {
          return 2.0 - a;
        }
        else {
          return a;
        }
      });
    }
  end

  def erfc(x)
    Math.checked :erfc, Math.float!(x)
  end

  def exp(x)
    Math.checked :exp, Math.float!(x)
  end

  def frexp(x)
    x = Math.float!(x)

    %x{
      if (isNaN(x)) {
        return [NaN, 0];
      }

      var ex   = Math.floor(Math.log(Math.abs(x)) / Math.log(2)) + 1,
          frac = x / Math.pow(2, ex);

      return [frac, ex];
    }
  end

  def gamma(n)
    n = Math.float!(n)

    %x{
      var i, t, x, value, result, twoN, threeN, fourN, fiveN;

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


      if (isNaN(n)) {
        return NaN;
      }

      if (n === 0 && 1 / n < 0) {
        return -Infinity;
      }

      if (n === -1 || n === -Infinity) {
        #{raise DomainError, 'Numerical argument is out of domain - "gamma"'};
      }

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
    Math.checked :hypot, Math.float!(x), Math.float!(y)
  end

  def ldexp(mantissa, exponent)
    mantissa = Math.float!(mantissa)
    exponent = Math.integer!(exponent)

    %x{
      if (isNaN(exponent)) {
        #{raise RangeError, 'float NaN out of range of integer'};
      }

      return mantissa * Math.pow(2, exponent);
    }
  end

  def lgamma(n)
    %x{
      if (n == -1) {
        return [Infinity, 1];
      }
      else {
        return [Math.log(Math.abs(#{Math.gamma(n)})), #{Math.gamma(n)} < 0 ? -1 : 1];
      }
    }
  end

  def log(x, base = undefined)
    if String === x
      raise `$type_error(x, #{Float})`
    end

    if `base == null`
      Math.checked :log, Math.float!(x)
    else
      if String === base
        raise `$type_error(base, #{Float})`
      end

      Math.checked(:log, Math.float!(x)) / Math.checked(:log, Math.float!(base))
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
      raise `$type_error(x, #{Float})`
    end

    Math.checked :log10, Math.float!(x)
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
      raise `$type_error(x, #{Float})`
    end

    Math.checked :log2, Math.float!(x)
  end

  def sin(x)
    Math.checked :sin, Math.float!(x)
  end

  unless defined?(`Math.sinh`)
    %x{
      Math.sinh = function(x) {
        return (Math.exp(x) - Math.exp(-x)) / 2;
      }
    }
  end

  def sinh(x)
    Math.checked :sinh, Math.float!(x)
  end

  def sqrt(x)
    Math.checked :sqrt, Math.float!(x)
  end

  def tan(x)
    x = Math.float!(x)

    if x.infinite?
      return Float::NAN
    end

    Math.checked :tan, Math.float!(x)
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
    Math.checked :tanh, Math.float!(x)
  end
end
