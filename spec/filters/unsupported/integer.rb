opal_unsupported_filter "Integer" do
  fails "Integer#even? returns true for a Bignum when it is an even number"
  fails "Integer#% bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
  fails "Integer#& bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
  fails "Integer#& bignum returns self bitwise AND other when both operands are negative" # Expected 0 to equal -13835058055282164000
  fails "Integer#& bignum returns self bitwise AND other when one operand is negative" # Expected 0 to equal 18446744073709552000
  fails "Integer#& bignum returns self bitwise AND other" # Expected 0 to equal 1
  fails "Integer#& fixnum returns self bitwise AND a bignum" # Expected 0 to equal 18446744073709552000
  fails "Integer#& fixnum returns self bitwise AND other" # Actually uses Bignums
  fails "Integer#* bignum returns self multiplied by the given Integer" # Expected 8.507059173023462e+37 to equal 8.507059173023463e+37
  fails "Integer#** fixnum can raise -1 to a bignum safely" # Expected 1 to have same value and type as -1
  fails "Integer#- bignum returns self minus the given Integer" # Expected 0 to equal 272
  fails "Integer#/ bignum raises a ZeroDivisionError if other is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#/ bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
  fails "Integer#< bignum returns true if self is less than the given argument" # Expected false to equal true
  fails "Integer#<< (with n << m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 2.3611832414348226e+21
  fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n < 0, m > 0" # Expected 0 to equal -7.555786372591432e+22
  fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n > 0, m > 0" # Expected 0 to equal 2.3611832414348226e+21
  fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n < 0, m < 0" # Expected 0 to equal -36893488147419103000
  fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n > 0, m < 0" # Expected 0 to equal 73786976294838210000
  fails "Integer#<< (with n << m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
  fails "Integer#<< (with n << m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
  fails "Integer#<< (with n << m) fixnum returns 0 when m < 0 and m is a Bignum" # Expected 3 to equal 0
  fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max << 1 and n > 0" # Expected 2147483646 (Number) to be an instance of Bignum
  fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min << 1 and n < 0" # Expected -2147483648 (Number) to be an instance of Bignum
  fails "Integer#<= bignum returns false if compares with near float" # Expected true to equal false
  fails "Integer#<=> bignum with a Bignum when other is negative returns -1 when self is negative and other is larger" # Expected 0 to equal -1
  fails "Integer#<=> bignum with a Bignum when other is negative returns 1 when self is negative and other is smaller" # Expected 0 to equal 1
  fails "Integer#<=> bignum with a Bignum when other is positive returns -1 when self is positive and other is larger" # Expected 0 to equal -1
  fails "Integer#<=> bignum with a Bignum when other is positive returns 1 when other is smaller" # Expected 0 to equal 1
  fails "Integer#<=> bignum with an Object returns -1 if the coerced value is larger" # Expected 0 to equal -1
  fails "Integer#<=> bignum with an Object returns nil if #coerce does not return an Array" # Expected 0 to be nil
  fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
  fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
  fails "Integer#== bignum returns true if self has the same value as the given argument" # Expected true to equal false
  fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
  fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
  fails "Integer#=== bignum returns true if self has the same value as the given argument" # Expected true to equal false
  fails "Integer#> bignum returns true if self is greater than the given argument" # Expected false to equal true
  fails "Integer#>= bignum returns true if self is greater than or equal to other" # Expected true to equal false
  fails "Integer#>> (with n >> m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 36893488147419103000
  fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting for very large values" # Expected 0 to equal 2.2204460502842888e+66
  fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting" # Expected 101376 to equal -2621440001220703000
  fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n < 0, m < 0" # Expected 0 to equal -1.1805916207174113e+21
  fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n > 0, m < 0" # Expected 0 to equal 590295810358705700000
  fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n < 0, m > 0" # Expected 0 to equal -36893488147419103000
  fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n > 0, m > 0" # Expected 0 to equal 73786976294838210000
  fails "Integer#>> (with n >> m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
  fails "Integer#>> (with n >> m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
  fails "Integer#>> (with n >> m) fixnum returns 0 when m is a bignum" # Expected 3 to equal 0
  fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max >> -1 and n > 0" # NameError: uninitialized constant Bignum
  fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min >> -1 and n < 0" # NameError: uninitialized constant Bignum
  fails "Integer#[] bignum returns the nth bit in the binary representation of self" # Expected 0 to equal 1
  fails "Integer#[] bignum tries to convert the given argument to an Integer using #to_int" # Expected 0 to equal 1
  fails "Integer#^ bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (14 was returned)
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when all bits are 1 and other value is negative" # Expected -1 to equal -9.903520314283042e+27
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when both operands are negative" # Expected 0 to equal 64563604257983430000
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other" # Expected 2 to equal 9223372036854776000
  fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR a bignum" # Expected -1 to equal -18446744073709552000
  fails "Integer#bit_length bignum returns the position of the leftmost 0 bit of a negative number" # NoMethodError: undefined method `bit_length` for -Infinity:Float
  fails "Integer#bit_length bignum returns the position of the leftmost bit of a positive number" # Expected 1 to equal 1000
  fails "Integer#coerce bignum coerces other to a Bignum and returns [other, self] when passed a Fixnum" # NameError: uninitialized constant Bignum
  fails "Integer#coerce bignum raises a TypeError when not passed a Fixnum or Bignum" # ArgumentError: invalid value for Float(): "test"
  fails "Integer#coerce bignum returns [other, self] when passed a Bignum" # NameError: uninitialized constant Bignum
  fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
  fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
  fails "Integer#div bignum looses precision if passed Float argument" # Expected 9223372036854776000 not to equal 9223372036854776000
  fails "Integer#div bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
  fails "Integer#divmod bignum raises a TypeError when the given argument is not an Integer" # NoMethodError: undefined method `nan?' for main
  fails "Integer#divmod bignum returns an Array containing quotient and modulus obtained from dividing self by the given argument" # Expected [2305843009213694000, 0] to equal [2305843009213694000, 3]
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b < 0 and |a| < |b|" # Expected [1, 0] to equal [0, -9223372036854776000]
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b > 0 and |a| < b" # Expected [-1, 0] to equal [-1, 1]
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a < |b|" # Expected [-1, 0] to equal [-1, -1]
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a > |b|" # Expected [-1, 0] to equal [-2, -9223372036854776000]
  fails "Integer#even? fixnum returns true for a Bignum when it is an even number" # Expected true to be false
  fails "Integer#modulo bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
  fails "Integer#odd? bignum returns false if self is even and negative" # Expected true to be false
  fails "Integer#odd? bignum returns true if self is odd and positive" # Expected false to be true
  fails "Integer#pow one argument is passed bignum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `pow' for 9223372036854776000
  fails "Integer#pow one argument is passed bignum returns a complex number when negative and raised to a fractional power" # NoMethodError: undefined method `pow' for -9223372036854776000
  fails "Integer#pow one argument is passed bignum returns self raised to other power" # NoMethodError: undefined method `pow' for 9223372036854776000
  fails "Integer#pow one argument is passed bignum switch to a Float when the values is too big" # NoMethodError: undefined method `pow' for 9223372036854776000
  fails "Integer#pow one argument is passed fixnum can raise -1 to a bignum safely" # NoMethodError: undefined method `pow' for -1
  fails "Integer#pow one argument is passed fixnum can raise 1 to a bignum safely" # NoMethodError: undefined method `pow' for 1
  fails "Integer#pow one argument is passed fixnum overflows the answer to a bignum transparently" # NoMethodError: undefined method `pow' for 2
  fails "Integer#pow two arguments are passed works well with bignums" # NoMethodError: undefined method `pow' for 2
  fails "Integer#remainder bignum does raises ZeroDivisionError if other is zero and a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
  fails "Integer#remainder bignum raises a ZeroDivisionError if other is zero and not a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
  fails "Integer#remainder bignum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 9223372036854776000
  fails "Integer#size bignum returns the number of bytes required to hold the unsigned bignum data" # Expected 4 to equal 8
  fails "Integer#| bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (9 was returned)
  fails "Integer#| bignum returns self bitwise OR other when both operands are negative" # Expected 0 to equal -1
  fails "Integer#| bignum returns self bitwise OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
  fails "Integer#| bignum returns self bitwise OR other" # Expected 2 to equal 9223372036854776000
  fails "Integer#~ bignum returns self with each bit flipped" # Expected -1 to equal -9223372036854776000
  fails "Integer#pow one argument is passed fixnum returns Float::INFINITY for 0 ** -1.0" # Depends on the difference between Integer and Float
  fails "Integer#pow two arguments are passed ensures all arguments are integers" # Depends on the difference between Integer and Float
end
