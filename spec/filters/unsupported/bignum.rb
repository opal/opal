opal_filter "Bignum" do
  fails "Rational#** when passed Bignum returns Rational(1) when self is Rational(-1) and the exponent is positive and even"
  fails "Rational#** when passed Bignum returns 0.0 when self is < -1 and the exponent is negative"
  fails "Rational#** when passed Bignum returns positive Infinity when self < -1"
  fails "Rational#** when passed Bignum returns 0.0 when self is > 1 and the exponent is negative"
  fails "Rational#** when passed Bignum returns positive Infinity when self is > 1"
  fails "Rational#** when passed Bignum returns Rational(-1) when self is Rational(-1) and the exponent is positive and odd"
  fails "Rational#** when passed Bignum raises ZeroDivisionError when self is Rational(0) and the exponent is negative"
  fails "Rational#round with a precision > 0 doesn't fail when rounding to an absurdly large positive precision"

  fails "Numeric#denominator returns 1"
  fails "Numeric#numerator converts self to a Rational object then returns its numerator"

  fails "Integer#rationalize returns a Rational object"
  fails "Integer#rationalize uses self as the numerator"
  fails "Integer#rationalize uses 1 as the denominator"
  fails "Integer#to_r works even if self is a Bignum"

  fails "Integer#gcd accepts a Bignum argument"
  fails "Integer#gcd works if self is a Bignum"
  fails "Integer#gcdlcm accepts a Bignum argument"

  fails "Integer#gcdlcm works if self is a Bignum"
  fails "Integer#lcm accepts a Bignum argument"
  fails "Integer#lcm works if self is a Bignum"
  fails "Integer#odd? returns true when self is an odd number"
end
