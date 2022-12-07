# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Integer" do
  fails "Integer#% bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 == 18446744073709552000 to be truthy but was false
  fails "Integer#& bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
  fails "Integer#& bignum returns self bitwise AND other when both operands are negative" # Expected 0 == -23058430092136940000 to be truthy but was false
  fails "Integer#& bignum returns self bitwise AND other when one operand is negative" # Expected 0 == 36893488147419103000 to be truthy but was false
  fails "Integer#& bignum returns self bitwise AND other" # Expected 0 == 1 to be truthy but was false
  fails "Integer#& fixnum returns self bitwise AND a bignum" # Expected 0 == 18446744073709552000 to be truthy but was false
  fails "Integer#& fixnum returns self bitwise AND other" # Expected 0 == 65535 to be truthy but was false
  fails "Integer#** fixnum can raise -1 to a bignum safely" # Expected 1 to have same value and type as -1
  fails "Integer#- bignum returns self minus the given Integer" # Expected 0 == 272 to be truthy but was false
  fails "Integer#/ bignum raises a ZeroDivisionError if other is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#/ bignum returns self divided by other" # Expected 10000000000 == 9999999999 to be truthy but was false
  fails "Integer#< bignum returns true if self is less than the given argument" # Expected false == true to be truthy but was false
  fails "Integer#<< (with n << m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 == 2.3611832414348226e+21 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n < 0, m > 0" # Expected 0 == -7.555786372591432e+22 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n > 0, m > 0" # Expected 0 == 2.3611832414348226e+21 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n < 0, m < 0" # Expected 0 == -36893488147419103000 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n > 0, m < 0" # Expected 0 == 73786976294838210000 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n when n < 0, m == 0" # Expected 0 == -147573952589676410000 to be truthy but was false
  fails "Integer#<< (with n << m) bignum returns n when n > 0, m == 0" # Expected 0 == 147573952589676410000 to be truthy but was false
  fails "Integer#<< (with n << m) fixnum returns 0 when m < 0 and m is a Bignum" # Expected 3 == 0 to be truthy but was false
  fails "Integer#<= bignum returns false if compares with near float" # Expected true == false to be truthy but was false
  fails "Integer#<=> bignum returns -1 when self is -Infinity and other is negative" # Expected 0 == -1 to be truthy but was false
  fails "Integer#<=> bignum returns 1 when self is Infinity and other is a Bignum" # Expected 0 == 1 to be truthy but was false
  fails "Integer#<=> bignum returns 1 when self is negative and other is -Infinity" # Expected 0 == 1 to be truthy but was false
  fails "Integer#<=> bignum with a Bignum when other is negative returns -1 when self is negative and other is larger" # Expected 0 == -1 to be truthy but was false
  fails "Integer#<=> bignum with a Bignum when other is negative returns 1 when self is negative and other is smaller" # Expected 0 == 1 to be truthy but was false
  fails "Integer#<=> bignum with a Bignum when other is positive returns -1 when self is positive and other is larger" # Expected 0 == -1 to be truthy but was false
  fails "Integer#<=> bignum with a Bignum when other is positive returns 1 when other is smaller" # Expected 0 == 1 to be truthy but was false
  fails "Integer#<=> bignum with an Object returns -1 if the coerced value is larger" # Expected 0 == -1 to be truthy but was false
  fails "Integer#<=> bignum with an Object returns nil if #coerce does not return an Array" # Expected 0 to be nil
  fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Expected "woot" == true to be truthy but was false
  fails "Integer#== bignum returns true if self has the same value as the given argument" # Expected true == false to be truthy but was false
  fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Expected "woot" == true to be truthy but was false
  fails "Integer#=== bignum returns true if self has the same value as the given argument" # Expected true == false to be truthy but was false
  fails "Integer#> bignum returns true if self is greater than the given argument" # Expected false == true to be truthy but was false
  fails "Integer#>= bignum returns true if self is greater than or equal to other" # Expected true == false to be truthy but was false
  fails "Integer#>> (with n >> m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 == 36893488147419103000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting for very large values" # Expected 0 == 2.2204460502842888e+66 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting" # Expected 101376 == -2621440001220703000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n < 0, m < 0" # Expected 0 == -1.1805916207174113e+21 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n > 0, m < 0" # Expected 0 == 590295810358705700000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n < 0, m > 0" # Expected 0 == -36893488147419103000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n > 0, m > 0" # Expected 0 == 73786976294838210000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n when n < 0, m == 0" # Expected 0 == -147573952589676410000 to be truthy but was false
  fails "Integer#>> (with n >> m) bignum returns n when n > 0, m == 0" # Expected 0 == 147573952589676410000 to be truthy but was false
  fails "Integer#[] bignum returns the nth bit in the binary representation of self" # Expected 0 == 1 to be truthy but was false
  fails "Integer#[] bignum tries to convert the given argument to an Integer using #to_int" # Expected 0 == 1 to be truthy but was false
  fails "Integer#^ bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (14 was returned)
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when all bits are 1 and other value is negative" # Expected -1 == -9.903520314283042e+27 to be truthy but was false
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when both operands are negative" # Expected 0 == 55340232221128655000 to be truthy but was false
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when one operand is negative" # Expected 0 == -55340232221128655000 to be truthy but was false
  fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other" # Expected 2 == 18446744073709552000 to be truthy but was false
  fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR a bignum" # Expected -1 == -18446744073709552000 to be truthy but was false
  fails "Integer#bit_length bignum returns the position of the leftmost 0 bit of a negative number" # NoMethodError: undefined method `bit_length` for -Infinity:Float
  fails "Integer#bit_length bignum returns the position of the leftmost bit of a positive number" # Expected 1 == 1000 to be truthy but was false
  fails "Integer#coerce bignum raises a TypeError when not passed a Fixnum or Bignum" # Expected TypeError but got: ArgumentError (invalid value for Float(): "test")
  fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(#<MockObject:0x4098c @name="y" @null=nil>) exactly 1 times but received it 0 times
  fails "Integer#div bignum looses precision if passed Float argument" # Expected 18446744073709552000 == 18446744073709552000 to be falsy but was true
  fails "Integer#div bignum returns self divided by other" # Expected 10000000000 == 9999999999 to be truthy but was false
  fails "Integer#divmod bignum raises a TypeError when the given argument is not an Integer" # Expected TypeError but got: NoMethodError (undefined method `nan?' for #<MockObject:0x438bc @name="10" @null=nil>)
  fails "Integer#divmod bignum returns an Array containing quotient and modulus obtained from dividing self by the given argument" # Expected [4611686018427388000, 0] == [4611686018427388000, 3] to be truthy but was false
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b < 0 and |a| < |b|" # Expected [1, -0.0] == [0, -18446744073709552000] to be truthy but was false
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b > 0 and |a| < b" # Expected [-1, 0] == [-1, 1] to be truthy but was false
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a < |b|" # Expected [-1, -0.0] == [-1, -1] to be truthy but was false
  fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a > |b|" # Expected [-1, -0.0] == [-2, -18446744073709552000] to be truthy but was false
  fails "Integer#even? fixnum returns true for a Bignum when it is an even number" # Expected true to be false
  fails "Integer#modulo bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 == 18446744073709552000 to be truthy but was false
  fails "Integer#odd? bignum returns false if self is even and negative" # Expected true to be false
  fails "Integer#odd? bignum returns true if self is odd and positive" # Expected false to be true
  fails "Integer#pow one argument is passed bignum switch to a Float when the values is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#pow one argument is passed fixnum can raise -1 to a bignum safely" # Expected 1 to have same value and type as -1
  fails "Integer#pow one argument is passed fixnum returns Float::INFINITY for 0 ** -1.0" # ZeroDivisionError: divided by 0
  fails "Integer#pow two arguments are passed ensures all arguments are integers" # Expected TypeError (/2nd argument not allowed unless all arguments are integers/) but no exception was raised (8 was returned)
  fails "Integer#remainder bignum does raises ZeroDivisionError if other is zero and a Float" # Expected ZeroDivisionError but no exception was raised (NaN was returned)
  fails "Integer#remainder bignum raises a ZeroDivisionError if other is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (NaN was returned)
  fails "Integer#remainder bignum returns the remainder of dividing self by other" # Expected 0 == 1 to be truthy but was false
  fails "Integer#size bignum returns the number of bytes required to hold the unsigned bignum data" # Expected 4 == 8 to be truthy but was false
  fails "Integer#| bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (9 was returned)
  fails "Integer#| bignum returns self bitwise OR other when both operands are negative" # Expected 0 == -1 to be truthy but was false
  fails "Integer#| bignum returns self bitwise OR other when one operand is negative" # Expected 0 == -55340232221128655000 to be truthy but was false
  fails "Integer#| bignum returns self bitwise OR other" # Expected 2 == 18446744073709552000 to be truthy but was false
  fails "Integer#~ bignum returns self with each bit flipped" # Expected -1 == -18446744073709552000 to be truthy but was false
  fails "Numeric#quo raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "String#to_r ignores underscores between numbers" # Expected (-5228919960423629/274877906944) == (-190227/10) to be truthy but was false
  fails "String#to_r understands a forward slash as separating the numerator from the denominator" # Expected (-896028675862255/140737488355328) == (-191/30) to be truthy but was false
  fails "String#to_r understands decimal points" # Expected (1874623344892969/562949953421312) == (333/100) to be truthy but was false
end
