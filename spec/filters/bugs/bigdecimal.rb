# NOTE: run bin/format-filters after changing this file
opal_filter "BigDecimal" do
  fails "BidDecimal#hash two BigDecimal objects with numerically equal values should have the same hash value" # Exception: self.$BigDecimal(...).$hash is not a function
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for NaNs" # Exception: self.$BigDecimal(...).$hash is not a function
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for infinite values" # Exception: self.$BigDecimal(...).$hash is not a function
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for ordinary values" # Exception: self.$BigDecimal(...).$hash is not a function
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for zero values" # Exception: self.$BigDecimal(...).$hash is not a function
  fails "BigDecimal constants defines a VERSION value" # Expected false to be true
  fails "BigDecimal constants exception-related constants has a EXCEPTION_ALL value" # NameError: uninitialized constant BigDecimal::EXCEPTION_ALL
  fails "BigDecimal constants exception-related constants has a EXCEPTION_INFINITY value" # NameError: uninitialized constant BigDecimal::EXCEPTION_INFINITY
  fails "BigDecimal constants exception-related constants has a EXCEPTION_NaN value" # NameError: uninitialized constant BigDecimal::EXCEPTION_NaN
  fails "BigDecimal constants exception-related constants has a EXCEPTION_OVERFLOW value" # NameError: uninitialized constant BigDecimal::EXCEPTION_OVERFLOW
  fails "BigDecimal constants exception-related constants has a EXCEPTION_UNDERFLOW value" # NameError: uninitialized constant BigDecimal::EXCEPTION_UNDERFLOW
  fails "BigDecimal constants exception-related constants has a EXCEPTION_ZERODIVIDE value" # NameError: uninitialized constant BigDecimal::EXCEPTION_ZERODIVIDE
  fails "BigDecimal constants has a BASE value" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal constants has a NaN value" # NameError: uninitialized constant BigDecimal::NAN
  fails "BigDecimal constants has an INFINITY value" # NameError: uninitialized constant BigDecimal::INFINITY
  fails "BigDecimal constants rounding-related constants has a ROUND_CEILING value" # Expected 2 to equal 5
  fails "BigDecimal constants rounding-related constants has a ROUND_DOWN value" # Expected 1 to equal 2
  fails "BigDecimal constants rounding-related constants has a ROUND_FLOOR value" # Expected 3 to equal 6
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_DOWN value" # Expected 5 to equal 4
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_EVEN value" # Expected 6 to equal 7
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_UP value" # Expected 4 to equal 3
  fails "BigDecimal constants rounding-related constants has a ROUND_UP value" # Expected 0 to equal 1
  fails "BigDecimal is not defined unless it is required" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xbe6e>
  fails "BigDecimal#% returns NaN if NaN is involved"
  fails "BigDecimal#% returns NaN if the dividend is Infinity"
  fails "BigDecimal#% returns self modulo other"
  fails "BigDecimal#% returns the dividend if the divisor is Infinity"
  fails "BigDecimal#% with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#* with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3e-20001) exactly 1 times but received it 0 times
  fails "BigDecimal#* with Rational produces a BigDecimal" # Exception: lhs.$* is not a function
  fails "BigDecimal#** 0 to power of 0 is 1"
  fails "BigDecimal#** 0 to powers < 0 is Infinity"
  fails "BigDecimal#** other powers of 0 are 0"
  fails "BigDecimal#** powers of 1 equal 1"
  fails "BigDecimal#** powers of self"
  fails "BigDecimal#** returns 0.0 if self is infinite and argument is negative"
  fails "BigDecimal#** returns NaN if self is NaN"
  fails "BigDecimal#** returns infinite if self is infinite and argument is positive"
  fails "BigDecimal#+ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#- with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#-@ properly handles special values"
  fails "BigDecimal#/ returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#/ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#/ with Rational produces a BigDecimal" # Exception: lhs.$/ is not a function
  fails "BigDecimal#< properly handles infinity values" #fails only with mock object
  fails "BigDecimal#<= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#<=> returns -1 if a < b" #fails only with mock object
  fails "BigDecimal#<=> returns 1 if a > b" #fails only with mock object
  fails "BigDecimal#> properly handles infinity values" #fails only with mock object
  fails "BigDecimal#>= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#add with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#add with Rational produces a BigDecimal" # Exception: lhs.$+ is not a function
  fails "BigDecimal#ceil returns the smallest integer greater or equal to self, if n is unspecified"
  fails "BigDecimal#ceil sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#coerce returns [other, self] both as BigDecimal"
  fails "BigDecimal#div returns a / b with optional precision" #fails the case of > 20 decimal places for to_s('F')
  fails "BigDecimal#div with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#div with precision set to 0 returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#div with precision set to 0 with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#divmod array contains quotient and modulus as BigDecimal"
  fails "BigDecimal#divmod can be reversed with * and +" # Expected 0 to equal -1
  fails "BigDecimal#divmod returns an array of Infinity and NaN if the dividend is Infinity"
  fails "BigDecimal#divmod returns an array of two NaNs if NaN is involved"
  fails "BigDecimal#divmod returns an array of zero and the dividend if the divisor is Infinity"
  fails "BigDecimal#exponent is n if number can be represented as 0.xxx*10**n"
  fails "BigDecimal#exponent returns 0 if self is 0"
  fails "BigDecimal#exponent returns an Integer"
  fails "BigDecimal#fix correctly handles special values"
  fails "BigDecimal#fix does not allow any arguments"
  fails "BigDecimal#fix returns 0 if the absolute value is < 1"
  fails "BigDecimal#fix returns a BigDecimal"
  fails "BigDecimal#fix returns the integer part of the absolute value"
  fails "BigDecimal#floor raise exception, if self is special value"
  fails "BigDecimal#floor returns the greatest integer smaller or equal to self"
  fails "BigDecimal#floor sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#frac correctly handles special values"
  fails "BigDecimal#frac returns 0 if the value is 0"
  fails "BigDecimal#frac returns 0 if the value is an integer"
  fails "BigDecimal#frac returns a BigDecimal"
  fails "BigDecimal#frac returns the fractional part of the absolute value"
  fails "BigDecimal#inspect does not add an exponent for zero values" # Exception: self.$BigDecimal(...).$inspect is not a function
  fails "BigDecimal#inspect looks like this"
  fails "BigDecimal#mod_part_of_divmod returns NaN if NaN is involved"
  fails "BigDecimal#mod_part_of_divmod returns NaN if the dividend is Infinity"
  fails "BigDecimal#mod_part_of_divmod returns self modulo other"
  fails "BigDecimal#mod_part_of_divmod returns the dividend if the divisor is Infinity"
  fails "BigDecimal#mod_part_of_divmod with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#modulo returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#modulo returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#modulo returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 9223372036854776000
  fails "BigDecimal#modulo returns the dividend if the divisor is Infinity" # Expected NaN to equal 1
  fails "BigDecimal#modulo with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#mult with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3e-20001) exactly 1 times but received it 0 times
  fails "BigDecimal#power 0 to power of 0 is 1"
  fails "BigDecimal#power 0 to powers < 0 is Infinity"
  fails "BigDecimal#power other powers of 0 are 0"
  fails "BigDecimal#power powers of 1 equal 1"
  fails "BigDecimal#power powers of self"
  fails "BigDecimal#power returns 0.0 if self is infinite and argument is negative"
  fails "BigDecimal#power returns NaN if self is NaN"
  fails "BigDecimal#power returns infinite if self is infinite and argument is positive"
  fails "BigDecimal#precs returns Integers as array values"
  fails "BigDecimal#precs returns array of two values"
  fails "BigDecimal#precs returns the current value of significant digits as the first value"
  fails "BigDecimal#precs returns the maximum number of significant digits as the second value"
  fails "BigDecimal#quo returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#quo with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#remainder coerces arguments to BigDecimal if possible"
  fails "BigDecimal#remainder it equals modulo, if both values are of same sign"
  fails "BigDecimal#remainder means self-arg*(self/arg).truncate"
  fails "BigDecimal#remainder raises TypeError if the argument cannot be coerced to BigDecimal"
  fails "BigDecimal#remainder returns NaN if Infinity is involved"
  fails "BigDecimal#remainder returns NaN if NaN is involved"
  fails "BigDecimal#remainder returns NaN used with zero"
  fails "BigDecimal#remainder returns zero if used on zero"
  fails "BigDecimal#remainder with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3) exactly 1 times but received it 0 times
  fails "BigDecimal#round :banker rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :ceil rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :ceiling rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :default rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :down rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :floor rounds values towards -infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :half_down rounds values > 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :half_even rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :half_up rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :truncate rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round :up rounds values away from zero" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_CEILING rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_DOWN rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_FLOOR rounds values towards -infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_DOWN rounds values > 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_EVEN rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_UP rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round BigDecimal::ROUND_UP rounds values away from zero" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round raise for a non-existent round mode" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round uses default rounding method unless given"
  fails "BigDecimal#sign returns negative value if BigDecimal less than 0"
  fails "BigDecimal#sign returns positive value if BigDecimal greater than 0"
  fails "BigDecimal#split first value: -1 for numbers < 0" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split first value: 0 if BigDecimal is NaN" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split first value: 1 for numbers > 0" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split fourth value: the exponent" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split second value: a string with the significant digits" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split splits BigDecimal in an array with four values"
  fails "BigDecimal#split third value: the base (currently always ten)" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#sqrt raises ArgumentError if 2 arguments are given"
  fails "BigDecimal#sqrt raises ArgumentError if a negative number is given"
  fails "BigDecimal#sqrt raises ArgumentError when no argument is given"
  fails "BigDecimal#sqrt raises FloatDomainError for NaN"
  fails "BigDecimal#sqrt raises FloatDomainError for negative infinity"
  fails "BigDecimal#sqrt raises FloatDomainError on negative values"
  fails "BigDecimal#sqrt raises TypeError if a plain Object is given"
  fails "BigDecimal#sqrt raises TypeError if a string is given"
  fails "BigDecimal#sqrt raises TypeError if nil is given"
  fails "BigDecimal#sqrt returns 0 for 0, +0.0 and -0.0"
  fails "BigDecimal#sqrt returns 1 if precision is 0 or 1"
  fails "BigDecimal#sqrt returns positive infinity for infinity" # NoMethodError: undefined method `sqrt' for Infinity
  fails "BigDecimal#sqrt returns square root of 0.9E-99999 with desired precision"
  fails "BigDecimal#sqrt returns square root of 121 with desired precision"
  fails "BigDecimal#sqrt returns square root of 2 with desired precision"
  fails "BigDecimal#sqrt returns square root of 3 with desired precision"
  fails "BigDecimal#sub with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#sub with Rational produces a BigDecimal" # Exception: lhs.$- is not a function
  fails "BigDecimal#to_f properly handles special values"
  fails "BigDecimal#to_i raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_i returns Integer otherwise" # NoMethodError: undefined method `to_i' for 3e-20001
  fails "BigDecimal#to_int raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_int returns Integer otherwise" # NoMethodError: undefined method `to_i' for 3e-20001
  fails "BigDecimal#to_r returns a Rational with bignum values" # NoMethodError: undefined method `to_r' for 3.141592653589793238462643
  fails "BigDecimal#to_r returns a Rational" # NoMethodError: undefined method `to_r' for 3.14159
  fails "BigDecimal#to_s can return a leading space for values > 0"
  fails "BigDecimal#to_s can use conventional floating point notation"
  fails "BigDecimal#to_s can use engineering notation"
  fails "BigDecimal#to_s does not add an exponent for zero values" # Exception: self.$BigDecimal(...).$to_s is not a function
  fails "BigDecimal#to_s inserts a space every n chars, if integer n is supplied"
  fails "BigDecimal#to_s removes trailing spaces in floating point notation"
  fails "BigDecimal#to_s return type is of class String" # Exception: self.bigdec.$to_s is not a function
  fails "BigDecimal#to_s returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "BigDecimal#to_s returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "BigDecimal#to_s starts with + if + is supplied and value is positive"
  fails "BigDecimal#to_s takes an optional argument" # Expected to not get Exception
  fails "BigDecimal#to_s the default format looks like 0.xxxxenn" # Expected "3.14159265358979323846264338327950288419716939937" to match /^0\.[0-9]*e[0-9]*$/
  fails "BigDecimal#truncate returns Infinity if self is infinite"
  fails "BigDecimal#truncate returns the same value if self is special value"
  fails "BigDecimal#truncate returns value of given precision otherwise"
  fails "BigDecimal.double_fig returns the number of digits a Float number is allowed to have"
  fails "BigDecimal.limit picks the global precision when limit 0 specified" # Expected 0.8888 to equal 0.889
  fails "BigDecimal.limit picks the specified precision over global limit" # Expected 0.888 to equal 0.89
  fails "BigDecimal.limit returns the value before set if the passed argument is nil or is not specified"
  fails "BigDecimal.limit uses the global limit if no precision is specified" # Expected 0.888 to equal 0.9
  fails "BigDecimal.mode raise an exception if the flag is true"
  fails "BigDecimal.mode returns Infinity when too big"
  fails "BigDecimal.mode returns the appropriate value and continue the computation if the flag is false"
  fails "Float#to_d returns appropriate BigDecimal zero for signed zero" # NoMethodError: undefined method `to_d' for 0
  fails "Kernel#BigDecimal BigDecimal(Rational) with bigger-than-double numerator" # Expected 1000000000000000000 > 18446744073709552000 to be truthy but was false
  fails "Kernel#BigDecimal accepts significant digits >= given precision" # NoMethodError: undefined method `precs' for 3.1415923
  fails "Kernel#BigDecimal allows for [eEdD] as exponent separator" # Exception: new BigNumber() not a number: 12345.67d89
  fails "Kernel#BigDecimal coerces the value argument with #to_str" # Exception: new BigNumber() not a number: #<MockObject:0x666>
  fails "Kernel#BigDecimal creates a new object of class BigDecimal" # Expected 1 to equal (1/1)
  fails "Kernel#BigDecimal determines precision from initial value" # NoMethodError: undefined method `precs' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "Kernel#BigDecimal does not call to_s when calling inspect" # Expected "44.44" == "0.4444e2" to be truthy but was false
  fails "Kernel#BigDecimal does not ignores trailing garbage" # Expected ArgumentError but got: Exception (new BigNumber() not a number: 123E45ruby)
  fails "Kernel#BigDecimal pre-coerces long integers" # Expected 262000 == 1130000000000000 to be truthy but was false
  fails "Kernel#BigDecimal process underscores as Float()" # Exception: new BigNumber() not a number: 12_345.67E89
  fails "Kernel#BigDecimal raises ArgumentError for invalid strings" # Exception: new BigNumber() not a number: ruby
  fails "Kernel#BigDecimal raises ArgumentError when Float is used without precision" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "Kernel#BigDecimal when interacting with Rational BigDecimal maximum precision is nine more than precision except for abnormals" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational BigDecimal precision is the number of digits rounded up to a multiple of nine" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational BigDecimal(Rational, 18) produces the result we expect" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational BigDecimal(Rational, BigDecimal.precs[0]) produces the result we expect" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational has the LHS print as expected" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational has the RHS print as expected" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational has the expected maximum precision on the LHS" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational has the expected precision on the LHS" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational produces a BigDecimal" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational produces the correct class for other arithmetic operators" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational produces the expected result when done via Float" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational produces the expected result when done via to_f" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal when interacting with Rational produces the expected result" # TypeError: Rational can't be coerced into BigDecimal
  fails "Kernel#BigDecimal with exception: false returns nil for invalid strings" # Exception: new BigNumber() not a number: invalid
  fails "Kernel#Pathname is a private instance method" # Expected Kernel to have private instance method 'Pathname' but it does not
end
