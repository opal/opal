# NOTE: run bin/format-filters after changing this file
opal_filter "BigDecimal" do
  fails "BidDecimal#hash two BigDecimal objects with numerically equal values should have the same hash value" # Expected 417830 == 417834 to be truthy but was false
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for NaNs" # Expected 417786 == 417790 to be truthy but was false
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for infinite values" # Expected 417742 == 417746 to be truthy but was false
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for ordinary values" # Expected 417698 == 417702 to be truthy but was false
  fails "BidDecimal#hash two BigDecimal objects with the same value should have the same hash for zero values" # Expected 417654 == 417658 to be truthy but was false
  fails "BigDecimal constants exception-related constants has a EXCEPTION_ALL value" # NameError: uninitialized constant BigDecimal::EXCEPTION_ALL
  fails "BigDecimal constants exception-related constants has a EXCEPTION_INFINITY value" # NameError: uninitialized constant BigDecimal::EXCEPTION_INFINITY
  fails "BigDecimal constants exception-related constants has a EXCEPTION_NaN value" # NameError: uninitialized constant BigDecimal::EXCEPTION_NaN
  fails "BigDecimal constants exception-related constants has a EXCEPTION_OVERFLOW value" # NameError: uninitialized constant BigDecimal::EXCEPTION_OVERFLOW
  fails "BigDecimal constants exception-related constants has a EXCEPTION_UNDERFLOW value" # NameError: uninitialized constant BigDecimal::EXCEPTION_UNDERFLOW
  fails "BigDecimal constants exception-related constants has a EXCEPTION_ZERODIVIDE value" # NameError: uninitialized constant BigDecimal::EXCEPTION_ZERODIVIDE
  fails "BigDecimal constants has a BASE value" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal constants has a NaN value" # NameError: uninitialized constant BigDecimal::NAN
  fails "BigDecimal constants has an INFINITY value" # NameError: uninitialized constant BigDecimal::INFINITY
  fails "BigDecimal constants rounding-related constants has a ROUND_CEILING value" # Expected 2 == 5 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_DOWN value" # Expected 1 == 2 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_FLOOR value" # Expected 3 == 6 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_DOWN value" # Expected 5 == 4 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_EVEN value" # Expected 6 == 7 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_HALF_UP value" # Expected 4 == 3 to be truthy but was false
  fails "BigDecimal constants rounding-related constants has a ROUND_UP value" # Expected 0 == 1 to be truthy but was false
  fails "BigDecimal is not defined unless it is required" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x1bb6a>
  fails "BigDecimal#% returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#% returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#% returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 18446744073709552000
  fails "BigDecimal#% returns the dividend if the divisor is Infinity" # Expected NaN == 1 to be truthy but was false
  fails "BigDecimal#% with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#* with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3e-20001) exactly 1 times but received it 0 times
  fails "BigDecimal#* with Rational produces a BigDecimal" # TypeError: Rational can't be coerced into BigDecimal
  fails "BigDecimal#** powers of self" # Expected 0 == 5e-40002 to be truthy but was false
  fails "BigDecimal#+ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#- with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#-@ properly handles special values" # Expected 1 == -1 to be truthy but was false
  fails "BigDecimal#/ returns a / b" # Expected 0 == -5e-5556 to be truthy but was false
  fails "BigDecimal#/ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#/ with Rational produces a BigDecimal" # TypeError: Rational can't be coerced into BigDecimal
  fails "BigDecimal#< properly handles infinity values" # NoMethodError: undefined method `nan?' for #<MockObject:0x26d44 @name="123" @null=nil>
  fails "BigDecimal#<= properly handles infinity values" # NoMethodError: undefined method `nan?' for #<MockObject:0x66d8a @name="123" @null=nil>
  fails "BigDecimal#<=> returns -1 if a < b" # Expected nil == -1 to be truthy but was false
  fails "BigDecimal#<=> returns 1 if a > b" # Expected nil == 1 to be truthy but was false
  fails "BigDecimal#> properly handles infinity values" # NoMethodError: undefined method `nan?' for #<MockObject:0x21ba0 @name="123" @null=nil>
  fails "BigDecimal#>= properly handles infinity values" # NoMethodError: undefined method `nan?' for #<MockObject:0x1b650 @name="123" @null=nil>
  fails "BigDecimal#add with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#add with Rational produces a BigDecimal" # TypeError: Rational can't be coerced into BigDecimal
  fails "BigDecimal#ceil returns the smallest integer greater or equal to self, if n is unspecified" # Expected Infinity == 2e+5555 to be truthy but was false
  fails "BigDecimal#ceil sets n digits left of the decimal point to 0, if given n < 0" # Expected 13346 == 13400 to be truthy but was false
  fails "BigDecimal#coerce returns [other, self] both as BigDecimal" # Exception: new BigNumber() number type has more than 15 significant digits: 32434234234234233000
  fails "BigDecimal#div returns a / b with optional precision" # Expected "0.33333333333333333333" == "0.333333333333333333333" to be truthy but was false
  fails "BigDecimal#div with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#div with precision set to 0 returns a / b" # Expected 0 == -5e-5556 to be truthy but was false
  fails "BigDecimal#div with precision set to 0 with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#divmod array contains quotient and modulus as BigDecimal" # Expected [0, 1] == [-1, -1] to be truthy but was false
  fails "BigDecimal#divmod can be reversed with * and +" # Expected 0 == -1 to be truthy but was false
  fails "BigDecimal#divmod returns an array of Infinity and NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#divmod returns an array of two NaNs if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#divmod returns an array of zero and the dividend if the divisor is Infinity" # Expected NaN == 1 to be truthy but was false
  fails "BigDecimal#exponent is n if number can be represented as 0.xxx*10**n" # NoMethodError: undefined method `exponent' for 2e+1000
  fails "BigDecimal#exponent returns 0 if self is 0" # NoMethodError: undefined method `exponent' for 0
  fails "BigDecimal#exponent returns an Integer" # NoMethodError: undefined method `exponent' for Infinity
  fails "BigDecimal#floor raise exception, if self is special value" # Expected FloatDomainError but no exception was raised (Infinity was returned)
  fails "BigDecimal#floor returns the greatest integer smaller or equal to self" # Expected Infinity == 2e+5555 to be truthy but was false
  fails "BigDecimal#floor sets n digits left of the decimal point to 0, if given n < 0" # Expected -9.999999999999999e+29 == -1e+30 to be truthy but was false
  fails "BigDecimal#frac correctly handles special values" # NoMethodError: undefined method `frac' for Infinity
  fails "BigDecimal#frac returns 0 if the value is 0" # NoMethodError: undefined method `frac' for 0
  fails "BigDecimal#frac returns 0 if the value is an integer" # NoMethodError: undefined method `frac' for 2e+5555
  fails "BigDecimal#frac returns a BigDecimal" # NoMethodError: undefined method `frac' for 2e+5555
  fails "BigDecimal#frac returns the fractional part of the absolute value" # NoMethodError: undefined method `frac' for 1.23456789
  fails "BigDecimal#inspect does not add an exponent for zero values" # Expected "0" == "0.0" to be truthy but was false
  fails "BigDecimal#inspect looks like this" # Expected "1234.5678" == "0.12345678e4" to be truthy but was false
  fails "BigDecimal#mod_part_of_divmod returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#mod_part_of_divmod returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#mod_part_of_divmod returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 18446744073709552000
  fails "BigDecimal#mod_part_of_divmod returns the dividend if the divisor is Infinity" # Expected NaN == 1 to be truthy but was false
  fails "BigDecimal#mod_part_of_divmod with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#modulo returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#modulo returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#modulo returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 18446744073709552000
  fails "BigDecimal#modulo returns the dividend if the divisor is Infinity" # Expected NaN == 1 to be truthy but was false
  fails "BigDecimal#modulo with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#mult with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3e-20001) exactly 1 times but received it 0 times
  fails "BigDecimal#power powers of self" # Expected 0 == 5e-40002 to be truthy but was false
  fails "BigDecimal#precs returns Integers as array values" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal#precs returns array of two values" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal#precs returns the current value of significant digits as the first value" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal#precs returns the maximum number of significant digits as the second value" # NameError: uninitialized constant BigDecimal::BASE
  fails "BigDecimal#quo returns a / b" # Expected 0 == -5e-5556 to be truthy but was false
  fails "BigDecimal#quo with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#remainder coerces arguments to BigDecimal if possible" # NoMethodError: undefined method `remainder' for 3
  fails "BigDecimal#remainder it equals modulo, if both values are of same sign" # NoMethodError: undefined method `remainder' for 1.234567890123456789012345679e+27
  fails "BigDecimal#remainder means self-arg*(self/arg).truncate" # NoMethodError: undefined method `remainder' for 1.23456789
  fails "BigDecimal#remainder raises TypeError if the argument cannot be coerced to BigDecimal" # Expected TypeError but got: NoMethodError (undefined method `remainder' for 1)
  fails "BigDecimal#remainder returns NaN if Infinity is involved" # NoMethodError: undefined method `remainder' for Infinity
  fails "BigDecimal#remainder returns NaN if NaN is involved" # NoMethodError: undefined method `remainder' for NaN
  fails "BigDecimal#remainder returns NaN used with zero" # NoMethodError: undefined method `remainder' for 1.23456789
  fails "BigDecimal#remainder returns zero if used on zero" # NoMethodError: undefined method `remainder' for 0
  fails "BigDecimal#remainder with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3) exactly 1 times but received it 0 times
  fails "BigDecimal#round :banker rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :ceil rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :ceiling rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :default rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :down rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :floor rounds values towards -infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :half_down rounds values > 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :half_even rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :half_up rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :truncate rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round :up rounds values away from zero" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_CEILING rounds values towards +infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_DOWN rounds values towards zero" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_FLOOR rounds values towards -infinity" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_DOWN rounds values > 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_EVEN rounds values > 5 up, < 5 down and == 5 towards even neighbor" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_HALF_UP rounds values >= 5 up, otherwise down" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round BigDecimal::ROUND_UP rounds values away from zero" # ArgumentError: [BigDecimal#round] wrong number of arguments (given 2, expected -1)
  fails "BigDecimal#round raise for a non-existent round mode" # Expected ArgumentError (invalid rounding mode) but got: ArgumentError ([BigDecimal#round] wrong number of arguments (given 2, expected -1))
  fails "BigDecimal#round uses default rounding method unless given" # Expected -1 == -2 to be truthy but was false
  fails "BigDecimal#sign returns negative value if BigDecimal less than 0" # Expected nil == -2 to be truthy but was false
  fails "BigDecimal#sign returns positive value if BigDecimal greater than 0" # Expected nil == 2 to be truthy but was false
  fails "BigDecimal#split first value: -1 for numbers < 0" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split first value: 0 if BigDecimal is NaN" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split first value: 1 for numbers > 0" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split fourth value: the exponent" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split second value: a string with the significant digits" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split splits BigDecimal in an array with four values" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#split third value: the base (currently always ten)" # NoMethodError: undefined method `split' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "BigDecimal#sqrt raises ArgumentError if 2 arguments are given" # Expected ArgumentError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt raises ArgumentError if a negative number is given" # Expected ArgumentError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt raises ArgumentError when no argument is given" # Expected ArgumentError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt raises FloatDomainError for NaN" # Expected FloatDomainError but got: NoMethodError (undefined method `sqrt' for NaN)
  fails "BigDecimal#sqrt raises FloatDomainError for negative infinity" # Expected FloatDomainError but got: NoMethodError (undefined method `sqrt' for -Infinity)
  fails "BigDecimal#sqrt raises FloatDomainError on negative values" # Expected FloatDomainError but got: NoMethodError (undefined method `sqrt' for -1)
  fails "BigDecimal#sqrt raises TypeError if a plain Object is given" # Expected TypeError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt raises TypeError if a string is given" # Expected TypeError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt raises TypeError if nil is given" # Expected TypeError but got: NoMethodError (undefined method `sqrt' for 1)
  fails "BigDecimal#sqrt returns 0 for 0, +0.0 and -0.0" # NoMethodError: undefined method `sqrt' for 0
  fails "BigDecimal#sqrt returns 1 if precision is 0 or 1" # NoMethodError: undefined method `sqrt' for 1
  fails "BigDecimal#sqrt returns positive infinity for infinity" # NoMethodError: undefined method `sqrt' for Infinity
  fails "BigDecimal#sqrt returns square root of 0.9E-99999 with desired precision" # NoMethodError: undefined method `sqrt' for 9e-100000
  fails "BigDecimal#sqrt returns square root of 121 with desired precision" # NoMethodError: undefined method `sqrt' for 121
  fails "BigDecimal#sqrt returns square root of 2 with desired precision" # NoMethodError: undefined method `sqrt' for 2
  fails "BigDecimal#sqrt returns square root of 3 with desired precision" # NoMethodError: undefined method `sqrt' for 3
  fails "BigDecimal#sub with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#sub with Rational produces a BigDecimal" # TypeError: Rational can't be coerced into BigDecimal
  fails "BigDecimal#to_f properly handles special values" # Expected "0" == "0.0" to be truthy but was false
  fails "BigDecimal#to_i raises FloatDomainError if BigDecimal is infinity or NaN" # Expected FloatDomainError but got: NoMethodError (undefined method `to_i' for Infinity)
  fails "BigDecimal#to_i returns Integer otherwise" # NoMethodError: undefined method `to_i' for 3e-20001
  fails "BigDecimal#to_int raises FloatDomainError if BigDecimal is infinity or NaN" # Expected FloatDomainError but got: NoMethodError (undefined method `to_i' for Infinity)
  fails "BigDecimal#to_int returns Integer otherwise" # NoMethodError: undefined method `to_i' for 3e-20001
  fails "BigDecimal#to_r returns a Rational from a BigDecimal with an exponent" # NoMethodError: undefined method `to_r' for 100
  fails "BigDecimal#to_r returns a Rational from a negative BigDecimal with an exponent" # NoMethodError: undefined method `to_r' for -100
  fails "BigDecimal#to_r returns a Rational with bignum values" # NoMethodError: undefined method `to_r' for 3.141592653589793238462643
  fails "BigDecimal#to_r returns a Rational" # NoMethodError: undefined method `to_r' for 3.14159
  fails "BigDecimal#to_s can return a leading space for values > 0" # Expected "3.14159265358979323846264338327950288419716939937" =~ /\ .*/ to be truthy but was nil
  fails "BigDecimal#to_s can use conventional floating point notation" # Expected "123.4567890123456789" == "+123.45678901 23456789" to be truthy but was false
  fails "BigDecimal#to_s can use engineering notation" # Expected "3.14159265358979323846264338327950288419716939937" =~ /^0\.[0-9]*E[0-9]*$/i to be truthy but was nil
  fails "BigDecimal#to_s does not add an exponent for zero values" # Expected "0" == "0.0" to be truthy but was false
  fails "BigDecimal#to_s inserts a space every n chars to fraction part, if integer n is supplied" # Expected "3.14159265358979323846264338327950288419716939937" =~ /\A0\.314 159 265 358 979 323 846 264 338 327 950 288 419 716 939 937E1\z/i to be truthy but was nil
  fails "BigDecimal#to_s removes trailing spaces in floating point notation" # Expected "0" == "0.0" to be truthy but was false
  fails "BigDecimal#to_s returns a String in US-ASCII encoding when Encoding.default_internal is nil" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:US-ASCII>
  fails "BigDecimal#to_s returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:US-ASCII>
  fails "BigDecimal#to_s starts with + if + is supplied and value is positive" # Expected "3.14159265358979323846264338327950288419716939937" =~ /^\+.*/ to be truthy but was nil
  fails "BigDecimal#to_s the default format looks like 0.xxxxenn" # Expected "3.14159265358979323846264338327950288419716939937" =~ /^0\.[0-9]*e[0-9]*$/ to be truthy but was nil
  fails "BigDecimal#truncate returns Infinity if self is infinite" # ArgumentError: [BigDecimal#fix] wrong number of arguments (given 1, expected 0)
  fails "BigDecimal#truncate returns NaN if self is NaN" # ArgumentError: [BigDecimal#fix] wrong number of arguments (given 1, expected 0)
  fails "BigDecimal#truncate returns the same value if self is special value" # Expected FloatDomainError but no exception was raised (NaN was returned)
  fails "BigDecimal#truncate returns value of given precision otherwise" # ArgumentError: [BigDecimal#fix] wrong number of arguments (given 1, expected 0)
  fails "BigDecimal#truncate returns value of type Integer." # Expected false == true to be truthy but was false
  fails "BigDecimal#truncate sets n digits left of the decimal point to 0, if given n < 0" # ArgumentError: [BigDecimal#fix] wrong number of arguments (given 1, expected 0)
  fails "BigDecimal.double_fig returns the number of digits a Float number is allowed to have" # NoMethodError: undefined method `double_fig' for BigDecimal
  fails "BigDecimal.limit picks the global precision when limit 0 specified" # Expected 0.8888 == 0.889 to be truthy but was false
  fails "BigDecimal.limit picks the specified precision over global limit" # Expected 0.888 == 0.89 to be truthy but was false
  fails "BigDecimal.limit returns the value before set if the passed argument is nil or is not specified" # Expected 1 == 0 to be truthy but was false
  fails "BigDecimal.limit uses the global limit if no precision is specified" # Expected 0.888 == 0.9 to be truthy but was false
  fails "BigDecimal.mode raise an exception if the flag is true" # NameError: uninitialized constant BigDecimal::EXCEPTION_NaN
  fails "BigDecimal.mode returns Infinity when too big" # NameError: uninitialized constant BigDecimal::EXCEPTION_NaN
  fails "BigDecimal.mode returns the appropriate value and continue the computation if the flag is false" # NameError: uninitialized constant BigDecimal::EXCEPTION_NaN
  fails "Float#to_d returns appropriate BigDecimal zero for signed zero" # NoMethodError: undefined method `to_d' for -0.0
  fails "Kernel#BigDecimal BigDecimal(Rational) with bigger-than-double numerator" # Expected 1000000000000000000 > 18446744073709552000 to be truthy but was false
  fails "Kernel#BigDecimal accepts significant digits >= given precision" # NoMethodError: undefined method `precs' for 3.1415923
  fails "Kernel#BigDecimal allows for [eEdD] as exponent separator" # Exception: new BigNumber() not a number: 12345.67d89
  fails "Kernel#BigDecimal coerces the value argument with #to_str" # Exception: new BigNumber() not a number: #<MockObject:0x1bc20>
  fails "Kernel#BigDecimal creates a new object of class BigDecimal" # Expected 1 == (1/1) to be truthy but was false
  fails "Kernel#BigDecimal determines precision from initial value" # NoMethodError: undefined method `precs' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "Kernel#BigDecimal does not call to_s when calling inspect" # Expected "44.44" == "0.4444e2" to be truthy but was false
  fails "Kernel#BigDecimal does not ignores trailing garbage" # Expected ArgumentError but got: Exception (new BigNumber() not a number: 123E45ruby)
  fails "Kernel#BigDecimal pre-coerces long integers" # Expected 262000 == 1130000000000000 to be truthy but was false
  fails "Kernel#BigDecimal process underscores as Float()" # Exception: new BigNumber() not a number: 12_345.67E89
  fails "Kernel#BigDecimal raises ArgumentError for invalid strings" # Expected ArgumentError but got: Exception (new BigNumber() not a number: ruby)
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
end
