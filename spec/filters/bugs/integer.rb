# NOTE: run bin/format-filters after changing this file
opal_filter "Integer" do
  fails "A singleton class raises a TypeError for Integer's" # Expected TypeError but no exception was raised (#<Class:#<Number:0x3>> was returned)
  fails "Bignum is deprecated" # NameError: uninitialized constant Bignum
  fails "Bignum is unified into Integer" # NameError: uninitialized constant Bignum
  fails "Fixnum is deprecated" # Expected warning to match: /constant ::Fixnum is deprecated/ but got: ""
  fails "Fixnum is unified into Integer" # Expected Number to be identical to Integer
  fails "Integer is the class of both small and large integers" # Expected Number to be identical to Integer
  fails "Integer#& fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
  fails "Integer#** bignum switch to a Float when the values is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#** fixnum raises a ZeroDivisionError for 0 ** -1" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#** fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#** fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
  fails "Integer#/ fixnum coerces fixnum and return self divided by other" # Expected 1.0842021724855044e-19 to equal 0
  fails "Integer#/ fixnum raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Integer#/ fixnum returns result the same class as the argument" # Expected 1.5 to equal 1
  fails "Integer#/ fixnum returns self divided by the given argument" # Expected 1.5 to equal 1
  fails "Integer#/ fixnum supports dividing negative numbers" # Expected -0.1 to equal -1
  fails "Integer#<< (with n << m) fixnum calls #to_int to convert the argument to an Integer" # Expected 3 == 0 to be truthy but was false
  fails "Integer#<< (with n << m) fixnum returns -1 when n < 0, m < 0 and n > -(2**-m)" # Expected -7 to equal -1
  fails "Integer#<< (with n << m) fixnum returns 0 when n > 0, m < 0 and n < 2**-m" # Expected 7 to equal 0
  fails "Integer#>> (with n >> m) fixnum calls #to_int to convert the argument to an Integer" # Expected 8 == 0 to be truthy but was false
  fails "Integer#>> (with n >> m) fixnum returns -1 when n < 0, m > 0 and n > -(2**m)" # Expected -7 to equal -1
  fails "Integer#>> (with n >> m) fixnum returns 0 when n > 0, m > 0 and n < 2**m" # Expected 7 to equal 0
  fails "Integer#^ fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
  fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR other" # Expected 5 to equal 9223372041149743000
  fails "Integer#chr with an encoding argument raises RangeError if self is invalid as a codepoint in the specified encoding"
  fails "Integer#chr with an encoding argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
  fails "Integer#chr with an encoding argument raises a RangeError is self is less than 0"
  fails "Integer#chr with an encoding argument returns a String encoding self interpreted as a codepoint in the specified encoding"
  fails "Integer#chr with an encoding argument returns a String with the specified encoding"
  fails "Integer#chr with an encoding argument returns a new String for each call"
  fails "Integer#chr without argument raises a RangeError is self is less than 0"
  fails "Integer#chr without argument returns a new String for each call"
  fails "Integer#chr without argument when Encoding.default_internal is nil and self is between 0 and 127 (inclusive) returns a US-ASCII String"
  fails "Integer#chr without argument when Encoding.default_internal is nil and self is between 128 and 255 (inclusive) returns a String containing self interpreted as a byte"
  fails "Integer#chr without argument when Encoding.default_internal is nil and self is between 128 and 255 (inclusive) returns a binary String" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Integer#chr without argument when Encoding.default_internal is nil and self is between 128 and 255 (inclusive) returns an ASCII-8BIT String"
  fails "Integer#chr without argument when Encoding.default_internal is nil raises a RangeError is self is greater than 255"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 0 and 127 (inclusive) returns a String encoding self interpreted as a US-ASCII codepoint"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 0 and 127 (inclusive) returns a US-ASCII String"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 128 and 255 (inclusive) returns a String containing self interpreted as a byte"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 128 and 255 (inclusive) returns a binary String" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is between 128 and 255 (inclusive) returns an ASCII-8BIT String"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 raises RangeError if self is invalid as a codepoint in the default internal encoding"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 returns a String encoding self interpreted as a codepoint in the default internal encoding"
  fails "Integer#chr without argument when Encoding.default_internal is not nil and self is greater than 255 returns a String with the default internal encoding"
  fails "Integer#coerce bigdecimal produces Floats" # Exception: other.$respond_to? is not a function
  fails "Integer#coerce fixnum raises a TypeError when given an Object that does not respond to #to_f" # depends on the difference between string/symbol
  fails "Integer#coerce fixnum when given a Fixnum returns an array containing two Fixnums" # Expected [Number, Number] == [Integer, Integer] to be truthy but was false
  fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(#<MockObject:0x16c22>) exactly 1 times but received it 0 times
  fails "Integer#divmod fixnum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nan?' for #<MockObject:0x1df78>
  fails "Integer#odd? fixnum returns true when self is an odd number" # Expected false to be true
  fails "Integer#pow one argument is passed fixnum returns Float::INFINITY when the number is too big" # Expected warning to match: /warning: in a\*\*b, b may be too big/ but got: ""
  fails "Integer#pow one argument is passed fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
  fails "Integer#pow two arguments are passed raises a RangeError when the first argument is negative and the second argument is present" # Expected RangeError but got: TypeError (Integer#pow() 1st argument cannot be negative when 2nd argument specified)
  fails "Integer#round raises ArgumentError for an unknown rounding mode" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
  fails "Integer#round raises a RangeError when passed a big negative value" # Expected RangeError but no exception was raised (0 was returned)
  fails "Integer#round returns different rounded values depending on the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
  fails "Integer#round returns itself if passed a positive precision and the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
  fails "Integer#round returns itself rounded to nearest if passed a negative value" # Expected NaN to have same value and type as 300
  fails "Integer#| fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
  fails "Integer#| fixnum returns self bitwise OR other" # Expected 65535 to equal 9223372036854841000
  fails "Integer.sqrt returns the integer square root of the argument" # Number overflow, 10**400
end
