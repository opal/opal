# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Bignum" do
  fails "BasicObject#__id__ returns a different value for two Bignum literals" # Expected 4e+100 == 4e+100 to be falsy but was true
  fails "Complex#== with Numeric returns true when self's imaginary part is 0 and the real part and other have numerical equality" # Expected (18446744073709552000+0i) == 18446744073709552000 to be falsy but was true
  fails "Complex#fdiv with an imaginary part sets the real part to self's real part fdiv'd with the argument" # Expected (9223372036854776000/5) == 1844674407370955300 to be truthy but was false
  fails "Complex#fdiv with no imaginary part sets the real part to self's real part fdiv'd with the argument" # Expected (9223372036854776000/5) == 1844674407370955300 to be truthy but was false
  fails "Enumerable#first raises a RangeError when passed a Bignum" # Expected RangeError but no exception was raised ([] was returned)
  fails "Float#round returns rounded values for big values" # Expected 0 to have same value and type as 200000000000000000000
  fails "Integer#gcd accepts a Bignum argument" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#gcd works if self is a Bignum" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#gcdlcm accepts a Bignum argument" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#gcdlcm works if self is a Bignum" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#lcm accepts a Bignum argument" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#lcm works if self is a Bignum" # Expected Infinity (Number) to be kind of Integer
  fails "Integer#rationalize returns a Rational object" # FloatDomainError: Infinity
  fails "Integer#rationalize uses 1 as the denominator" # FloatDomainError: Infinity
  fails "Integer#rationalize uses self as the numerator" # FloatDomainError: Infinity
  fails "Integer#round returns itself rounded if passed a negative value" # Expected 0 to have same value and type as 1.9999999999999998e+71
  fails "Integer#to_r works even if self is a Bignum" # Expected Infinity (Number) to be an instance of Integer
  fails "Marshal.dump with a Bignum dumps a Bignum" # Expected "\x04\bl-\tÿÿÿÿÿÿÿ?" to be computed by Marshal.dump from -4611686018427388000 (computed "\x04\bl-\t\x00\x00\x00\x00\x00\x00\x00@" instead)
  fails "Numeric#numerator converts self to a Rational object then returns its numerator" # Exception: Maximum call stack size exceeded
  fails "Numeric#quo raises a ZeroDivisionError when the given Integer is 0" # Expected ZeroDivisionError but no exception was raised (NaN was returned)
  fails "Rational#** when passed Bignum raises ZeroDivisionError when self is Rational(0) and the exponent is negative" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Rational#** when passed Bignum returns 0.0 when self is < -1 and the exponent is negative" # Exception: Maximum call stack size exceeded
  fails "Rational#** when passed Bignum returns 0.0 when self is > 1 and the exponent is negative" # Exception: Maximum call stack size exceeded
  fails "Rational#** when passed Bignum returns Rational(-1) when self is Rational(-1) and the exponent is positive and odd" # Expected (1/1) to have same value and type as (-1/1)
  fails "Rational#** when passed Bignum returns positive Infinity when self < -1" # Exception: Maximum call stack size exceeded
  fails "Rational#** when passed Bignum returns positive Infinity when self is > 1" # Exception: Maximum call stack size exceeded
  fails "Rational#round with a precision > 0 doesn't fail when rounding to an absurdly large positive precision" # FloatDomainError: Infinity
end
