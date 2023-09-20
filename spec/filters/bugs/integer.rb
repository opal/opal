# NOTE: run bin/format-filters after changing this file
opal_filter "Integer" do
  fails "Integer is the class of both small and large integers" # Expected Number to be identical to Integer
  fails "Integer#& fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
  fails "Integer#** bignum switch to a Float when the values is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#** fixnum raises a ZeroDivisionError for 0 ** -1" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#** fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#** fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
  fails "Integer#+ can be redefined" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x41850 @method="+" @object=nil>
  fails "Integer#/ fixnum coerces fixnum and return self divided by other" # Expected 5.421010862427522e-20 == 0 to be truthy but was false
  fails "Integer#/ fixnum raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#/ fixnum returns result the same class as the argument" # Expected 1.5 == 1 to be truthy but was false
  fails "Integer#/ fixnum returns self divided by the given argument" # Expected 1.5 == 1 to be truthy but was false
  fails "Integer#/ fixnum supports dividing negative numbers" # Expected -0.1 == -1 to be truthy but was false
  fails "Integer#<< (with n << m) fixnum calls #to_int to convert the argument to an Integer" # Expected 3 == 0 to be truthy but was false
  fails "Integer#<< (with n << m) fixnum returns -1 when n < 0, m < 0 and n > -(2**-m)" # Expected -7 == -1 to be truthy but was false
  fails "Integer#<< (with n << m) fixnum returns 0 when n > 0, m < 0 and n < 2**-m" # Expected 7 == 0 to be truthy but was false
  fails "Integer#<< (with n << m) when m is a bignum or larger than int raises RangeError when m > 0 and n != 0" # Expected RangeError (shift width too big) but no exception was raised (1 was returned)
  fails "Integer#<< (with n << m) when m is a bignum or larger than int returns -1 when m < 0 and n < 0" # Expected 0 == -1 to be truthy but was false
  fails "Integer#<< (with n << m) when m is a bignum or larger than int returns 0 when m < 0 and n >= 0" # Expected 1 == 0 to be truthy but was false
  fails "Integer#>> (with n >> m) fixnum calls #to_int to convert the argument to an Integer" # Expected 8 == 0 to be truthy but was false
  fails "Integer#>> (with n >> m) fixnum returns -1 when n < 0, m > 0 and n > -(2**m)" # Expected -7 == -1 to be truthy but was false
  fails "Integer#>> (with n >> m) fixnum returns 0 when n > 0, m > 0 and n < 2**m" # Expected 7 == 0 to be truthy but was false
  fails "Integer#>> (with n >> m) when m is a bignum or larger than int raises RangeError when m < 0 and n != 0" # Expected RangeError (shift width too big) but no exception was raised (1 was returned)
  fails "Integer#>> (with n >> m) when m is a bignum or larger than int returns -1 when m > 0 and n < 0" # Expected 0 == -1 to be truthy but was false
  fails "Integer#>> (with n >> m) when m is a bignum or larger than int returns 0 when m > 0 and n >= 0" # Expected 1 == 0 to be truthy but was false
  fails "Integer#[] fixnum when index and length passed ensures n[i, len] equals to (n >> i) & ((1 << len) - 1)" # ArgumentError: [Number#[]] wrong number of arguments (given 2, expected 1)
  fails "Integer#[] fixnum when index and length passed ignores negative length" # ArgumentError: [Number#[]] wrong number of arguments (given 2, expected 1)
  fails "Integer#[] fixnum when index and length passed moves start position to the most significant bits when negative index passed" # ArgumentError: [Number#[]] wrong number of arguments (given 2, expected 1)
  fails "Integer#[] fixnum when index and length passed returns specified number of bits from specified position" # ArgumentError: [Number#[]] wrong number of arguments (given 2, expected 1)
  fails "Integer#[] fixnum when range passed ensures n[i..] equals to (n >> i)" # TypeError: no implicit conversion of Range into Integer
  fails "Integer#[] fixnum when range passed ensures n[i..j] equals to (n >> i) & ((1 << (j - i + 1)) - 1)" # TypeError: no implicit conversion of Range into Integer
  fails "Integer#[] fixnum when range passed ignores upper boundary smaller than lower boundary" # TypeError: no implicit conversion of Range into Integer
  fails "Integer#[] fixnum when range passed moves lower boundary to the most significant bits when negative value passed" # ArgumentError: [Number#[]] wrong number of arguments (given 2, expected 1)
  fails "Integer#[] fixnum when range passed raises FloatDomainError if any boundary is infinity" # Expected FloatDomainError (/Infinity/) but got: TypeError (no implicit conversion of Range into Integer)
  fails "Integer#[] fixnum when range passed returns bits specified by range" # TypeError: no implicit conversion of Range into Integer
  fails "Integer#[] fixnum when range passed when passed (..i) raises ArgumentError if any of i bit equals 1" # Expected ArgumentError (/The beginless range for Integer#\[\] results in infinity/) but got: TypeError (no implicit conversion of Range into Integer)
  fails "Integer#[] fixnum when range passed when passed (..i) returns 0 if all i bits equal 0" # TypeError: no implicit conversion of Range into Integer
  fails "Integer#^ fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
  fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR other" # Expected 5 == 18446744078004520000 to be truthy but was false
  fails "Integer#^ fixnum returns self bitwise XOR other when one operand is negative" # Expected -3 == -8589934593 to be truthy but was false
  fails "Integer#ceildiv returns a quotient of division which is rounded up to the nearest integer" # NoMethodError: undefined method `ceildiv' for 0
  fails "Integer#chr with an encoding argument accepts a String as an argument" # Expected to not get Exception but got: ArgumentError (unknown encoding name - euc-jp)
  fails "Integer#chr with an encoding argument raises RangeError if self is invalid as a codepoint in the specified encoding" # Expected RangeError but no exception was raised ("\x80" was returned)
  fails "Integer#chr with an encoding argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
  fails "Integer#chr with an encoding argument raises a RangeError is self is less than 0" # Expected RangeError but no exception was raised ("\uFFFF" was returned)
  fails "Integer#chr with an encoding argument returns a String encoding self interpreted as a codepoint in the CESU-8 encoding" # NameError: uninitialized constant Encoding::CESU_8
  fails "Integer#chr with an encoding argument returns a String encoding self interpreted as a codepoint in the specified encoding" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "Integer#chr with an encoding argument returns a String with the specified encoding" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "Integer#chr with an encoding argument returns a new String for each call" # Expected " " not to be identical to " "
  fails "Integer#chr without argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
  fails "Integer#chr without argument raises a RangeError is self is less than 0" # Expected RangeError but no exception was raised ("\uFFFF" was returned)
  fails "Integer#chr without argument returns a new String for each call" # Expected "R" not to be identical to "R"
  fails "Integer#chr without argument when Encoding.default_internal is nil and self is between 0 and 127 (inclusive) returns a US-ASCII String" # Expected #<Encoding:ASCII-8BIT> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Integer#chr without argument when Encoding.default_internal is nil raises a RangeError is self is greater than 255" # Expected RangeError but no exception was raised ("Ā" was returned)
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 0 and 127 (inclusive) returns a String encoding self interpreted as a US-ASCII codepoint" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 0 and 127 (inclusive) returns a US-ASCII String" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 128 and 255 (inclusive) returns a String containing self interpreted as a byte" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 128 and 255 (inclusive) returns a binary String" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 raises RangeError if self is invalid as a codepoint in the default internal encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 returns a String encoding self interpreted as a codepoint in the default internal encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 returns a String with the default internal encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#coerce bigdecimal produces Floats" # Expected Number == Float to be truthy but was false
  fails "Integer#coerce fixnum raises a TypeError when given an Object that does not respond to #to_f" # Expected TypeError but got: ArgumentError (invalid value for Float(): "test")
  fails "Integer#coerce fixnum when given a Fixnum returns an array containing two Fixnums" # Expected [Number, Number] == [Integer, Integer] to be truthy but was false
  fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(#<MockObject:0x22a30 @name="y" @null=nil>) exactly 1 times but received it 0 times
  fails "Integer#divmod fixnum raises a TypeError when given a non-Integer" # Expected TypeError but got: NoMethodError (undefined method `nan?' for #<MockObject:0x270c8 @name="10" @null=nil>)
  fails "Integer#fdiv performs floating-point division between self bignum and a bignum" # Expected NaN == 500 to be truthy but was false
  fails "Integer#fdiv rounds to the correct float for bignum denominators" # Expected 0 == 1e-323 to be truthy but was false
  fails "Integer#fdiv rounds to the correct value for bignums" # Expected NaN == 11.11111111111111 to be truthy but was false
  fails "Integer#odd? fixnum returns true when self is an odd number" # Expected false to be true
  fails "Integer#pow one argument is passed fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#pow one argument is passed fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
  fails "Integer#pow two arguments are passed raises a RangeError when the first argument is negative and the second argument is present" # Expected RangeError but got: TypeError (Integer#pow() 1st argument cannot be negative when 2nd argument specified)
  fails "Integer#round raises ArgumentError for an unknown rounding mode" # Expected ArgumentError (/invalid rounding mode: foo/) but got: ArgumentError ([Number#round] wrong number of arguments (given 2, expected -1))
  fails "Integer#round returns different rounded values depending on the half option" # ArgumentError: [Number#round] wrong number of arguments (given 2, expected -1)
  fails "Integer#round returns itself if passed a positive precision and the half option" # ArgumentError: [Number#round] wrong number of arguments (given 2, expected -1)
  fails "Integer#round returns itself rounded to nearest if passed a negative value" # Expected 0 to have same value and type as 2.9999999999999996e+71
  fails "Integer#zero? Integer#zero? overrides Numeric#zero?" # Expected Number == Integer to be truthy but was false
  fails "Integer#| fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
  fails "Integer#| fixnum returns self bitwise OR other when one operand is negative" # Expected -3 == -8589934593 to be truthy but was false
  fails "Integer#| fixnum returns self bitwise OR other" # Expected 65535 == 18446744073709617000 to be truthy but was false
  fails "Integer.sqrt returns the integer square root of the argument" # TypeError: can't convert Number into Integer (Number#to_int gives Number)
  fails "Integer.try_convert responds with a different error message when it raises a TypeError, depending on the type of the non-Integer object :to_int returns" # Expected TypeError (can't convert MockObject to Integer (MockObject#to_int gives String)) but got: TypeError (can't convert MockObject into Integer (MockObject#to_int gives String))
  fails "Integer.try_convert sends #to_int to the argument and raises TypeError if it's not a kind of Integer" # Expected TypeError (can't convert MockObject to Integer (MockObject#to_int gives Object)) but got: TypeError (can't convert MockObject into Integer (MockObject#to_int gives Object))
end
