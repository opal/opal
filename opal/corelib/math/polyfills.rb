# Polyfills for browsers in the age of IE11

unless defined?(`Math.acosh`)
  %x{
    Math.acosh = function(x) {
      return Math.log(x + Math.sqrt(x * x - 1));
    }
  }
end

unless defined?(`Math.asinh`)
  %x{
    Math.asinh = function(x) {
      return Math.log(x + Math.sqrt(x * x + 1))
    }
  }
end

unless defined?(`Math.atanh`)
  %x{
    Math.atanh = function(x) {
      return 0.5 * Math.log((1 + x) / (1 - x));
    }
  }
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

unless defined?(`Math.cosh`)
  %x{
    Math.cosh = function(x) {
      return (Math.exp(x) + Math.exp(-x)) / 2;
    }
  }
end

unless defined?(`Math.hypot`)
  %x{
    Math.hypot = function(x, y) {
      return Math.sqrt(x * x + y * y)
    }
  }
end

unless defined?(`Math.log2`)
  %x{
    Math.log2 = function(x) {
      return Math.log(x) / Math.LN2;
    }
  }
end

unless defined?(`Math.log10`)
  %x{
    Math.log10 = function(x) {
      return Math.log(x) / Math.LN10;
    }
  }
end

unless defined?(`Math.sinh`)
  %x{
    Math.sinh = function(x) {
      return (Math.exp(x) - Math.exp(-x)) / 2;
    }
  }
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
