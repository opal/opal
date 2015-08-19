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

  fails "Complex#rationalize raises RangeError if self has 0.0 imaginary part"
  fails "Complex#eql? returns false when the real parts are of different classes"
  fails "Complex#eql? returns false when the imaginary parts are of different classes"
  fails "Complex#to_i when the imaginary part is Float 0.0 raises RangeError"
  fails "Complex#/ with Fixnum raises a ZeroDivisionError when given zero"
  fails "Complex#to_s returns 1+0.0i for Complex(1, 0.0)"
  fails "Complex#to_s returns 1-0.0i for Complex(1, -0.0)"
  fails "Complex#to_f when the imaginary part is Float 0.0 raises RangeError"
  fails "Complex#to_r when the imaginary part is Float 0.0 raises RangeError"
  fails "Complex#quo with Fixnum raises a ZeroDivisionError when given zero"

  fails "BasicObject#__id__ returns a different value for two Float literals"

  fails "Fixnum#% raises a ZeroDivisionError when the given argument is 0 and a Float"
  fails "Fixnum#% raises a ZeroDivisionError when the given argument is 0"
  fails "Fixnum#& raises a TypeError when passed a Float"
  fails "Fixnum#^ raises a TypeError when passed a Float"
  fails "Fixnum#coerce when given a String returns  an array containing two Floats"
  fails "Fixnum#div coerces self and the given argument to Floats and returns self divided by other as Fixnum"
  fails "Fixnum#| raises a TypeError when passed a Float"

  # precision error
  fails "Math.gamma returns approximately (n-1)! given n for n between 24 and 30"
end
