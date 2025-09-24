# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Float" do
  fails "Complex#/ with Fixnum raises a ZeroDivisionError when given zero" # Expected ZeroDivisionError but no exception was raised ((Infinity+Infinity*i) was returned)
  fails "Complex#eql? returns false when the imaginary parts are of different classes" # Expected true to be false
  fails "Complex#eql? returns false when the real parts are of different classes" # Expected true to be false
  fails "Complex#quo with Fixnum raises a ZeroDivisionError when given zero" # Expected ZeroDivisionError but no exception was raised ((Infinity+Infinity*i) was returned)
  fails "Complex#rationalize raises RangeError if self has 0.0 imaginary part" # Expected RangeError but no exception was raised ((1/1) was returned)
  fails "Complex#to_f when the imaginary part is Float 0.0 raises RangeError" # Expected RangeError but no exception was raised (0 was returned)
  fails "Complex#to_i when the imaginary part is Float 0.0 raises RangeError" # Expected RangeError but no exception was raised (0 was returned)
  fails "Complex#to_r when the imaginary part is Float 0.0 raises RangeError" # Expected RangeError but no exception was raised ((0/1) was returned)
  fails "Complex#to_s returns 1+0.0i for Complex(1, 0.0)" # Expected "1+0i" == "1+0.0i" to be truthy but was false
  fails "Complex#to_s returns 1-0.0i for Complex(1, -0.0)" # Expected "1+0i" == "1-0.0i" to be truthy but was false
  fails "Float constant MAX_10_EXP is 308" # NameError: uninitialized constant Float::MAX_10_EXP
  fails "Float constant MAX_EXP is 1024" # NameError: uninitialized constant Float::MAX_EXP
  fails "Float constant MIN_10_EXP is -308" # NameError: uninitialized constant Float::MIN_10_EXP
  fails "Float constant MIN_EXP is -1021" # NameError: uninitialized constant Float::MIN_EXP
  fails "Float#<=> returns -1 when self is -Infinity and other is negative" # Expected 0 == -1 to be truthy but was false
  fails "Float#<=> returns 1 when self is Infinity and other is an Integer" # Expected 0 == 1 to be truthy but was false
  fails "Float#<=> returns 1 when self is negative and other is -Infinity" # Expected 0 == 1 to be truthy but was false
  fails "Float#eql? returns false if other is not a Float" # Expected true to be false
  fails "Float#to_s emits a trailing '.0' for a whole number" # Expected "50" == "50.0" to be truthy but was false
  fails "Float#to_s emits a trailing '.0' for the mantissa in e format" # Expected "100000000000000000000" == "1.0e+20" to be truthy but was false
  fails "Float#to_s returns '0.0' for 0.0" # Expected "0" == "0.0" to be truthy but was false
  fails "Math.gamma returns approximately (n-1)! given n for n between 24 and 30" # Expected 1.5511210043330984e+25 to be within 1.5511210043330986e+25 +/- 330986
  fails "Rational#% returns a Float value when the argument is Float" # Expected (3/4) (Rational) to be kind of Float
  fails "Rational#** raises ZeroDivisionError for Rational(0, 1) passed a negative Integer" # Expected ZeroDivisionError (divided by 0) but no exception was raised (Infinity was returned)
  fails "Rational#/ when passed an Integer raises a ZeroDivisionError when passed 0" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Rational#coerce returns the passed argument, self as Float, when given a Float" # Expected false to be true
  fails "Rational#divmod when passed an Integer returns the quotient as Integer and the remainder as Rational" # Expected [1537228672809129200, (0/1)] to have same value and type as [1537228672809129200, (1/1)]
  fails "Struct#eql? returns false if any corresponding elements are not #eql?" # Expected #<struct StructClasses::Car make="Honda", model="Accord", year=1998> not to have same value or type as #<struct StructClasses::Car make="Honda", model="Accord", year=1998>
end
