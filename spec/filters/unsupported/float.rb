opal_filter "Float" do
  fails "Float#to_s emits '-' for -0.0"
  fails "Float#to_s emits a trailing '.0' for a whole number"
  fails "Float#to_s emits a trailing '.0' for the mantissa in e format"
  fails "Float#to_s returns '0.0' for 0.0"

  fails "Float#coerce returns [other, self] both as Floats"
  fails "Float#eql? returns false if other is not a Float"

  fails "Float#CONSTANTS the MAX_10_EXP is 308"
  fails "Float#CONSTANTS the MAX_EXP is 1024"
  fails "Float#CONSTANTS the MIN is 2.2250738585072e-308"
  fails "Float#CONSTANTS the MIN_10_EXP is -308"
  fails "Float#CONSTANTS the MIN_EXP is -1021"

  fails "Fixnum#divmod raises a TypeError when given a non-Integer"

  fails "Rational#coerce returns the passed argument, self as Float, when given a Float"
  fails "Rational#/ when passed an Integer raises a ZeroDivisionError when passed 0"
  fails "Rational#divmod when passed an Integer returns the quotient as Integer and the remainder as Rational"
  fails "Rational#** raises ZeroDivisionError for Rational(0, 1) passed a negative Integer"
  fails "Rational#** when passed Integer returns the Rational value of self raised to the passed argument"
  fails "Rational#% returns a Float value when the argument is Float"

  # precision error
  fails "Math.gamma returns approximately (n-1)! given n for n between 24 and 30"
end
