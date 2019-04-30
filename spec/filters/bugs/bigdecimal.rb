opal_filter "BigDecimal" do
  fails "BigDecimal#% returns NaN if NaN is involved"
  fails "BigDecimal#% returns NaN if the dividend is Infinity"
  fails "BigDecimal#% returns self modulo other"
  fails "BigDecimal#% returns the dividend if the divisor is Infinity"
  fails "BigDecimal#** 0 to power of 0 is 1"
  fails "BigDecimal#** 0 to powers < 0 is Infinity"
  fails "BigDecimal#** other powers of 0 are 0"
  fails "BigDecimal#** powers of 1 equal 1"
  fails "BigDecimal#** powers of self"
  fails "BigDecimal#** returns 0.0 if self is infinite and argument is negative"
  fails "BigDecimal#** returns NaN if self is NaN"
  fails "BigDecimal#** returns infinite if self is infinite and argument is positive"
  fails "BigDecimal#-@ properly handles special values"
  fails "BigDecimal#/ returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#< properly handles infinity values" #fails only with mock object
  fails "BigDecimal#<= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#<=> returns -1 if a < b" #fails only with mock object
  fails "BigDecimal#<=> returns 1 if a > b" #fails only with mock object
  fails "BigDecimal#> properly handles infinity values" #fails only with mock object
  fails "BigDecimal#>= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#ceil returns the smallest integer greater or equal to self, if n is unspecified"
  fails "BigDecimal#ceil sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#coerce returns [other, self] both as BigDecimal"
  fails "BigDecimal#div returns a / b with optional precision" #fails the case of > 20 decimal places for to_s('F')
  fails "BigDecimal#div with precision set to 0 returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
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
  fails "BigDecimal#floor returns n digits right of the decimal point if given n > 0"
  fails "BigDecimal#floor returns the greatest integer smaller or equal to self"
  fails "BigDecimal#floor sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#frac correctly handles special values"
  fails "BigDecimal#frac returns 0 if the value is 0"
  fails "BigDecimal#frac returns 0 if the value is an integer"
  fails "BigDecimal#frac returns a BigDecimal"
  fails "BigDecimal#frac returns the fractional part of the absolute value"
  fails "BigDecimal#inspect encloses information in angle brackets"
  fails "BigDecimal#inspect is comma separated list of three items"
  fails "BigDecimal#inspect last part is number of significant digits"
  fails "BigDecimal#inspect looks like this"
  fails "BigDecimal#inspect returns String starting with #"
  fails "BigDecimal#inspect value after first comma is value as string"
  fails "BigDecimal#mod_part_of_divmod returns NaN if NaN is involved"
  fails "BigDecimal#mod_part_of_divmod returns NaN if the dividend is Infinity"
  fails "BigDecimal#mod_part_of_divmod returns self modulo other"
  fails "BigDecimal#mod_part_of_divmod returns the dividend if the divisor is Infinity"
  fails "BigDecimal#modulo returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#modulo returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#modulo returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 9223372036854776000
  fails "BigDecimal#modulo returns the dividend if the divisor is Infinity" # Expected NaN to equal 1
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
  fails "BigDecimal#remainder coerces arguments to BigDecimal if possible"
  fails "BigDecimal#remainder it equals modulo, if both values are of same sign"
  fails "BigDecimal#remainder means self-arg*(self/arg).truncate"
  fails "BigDecimal#remainder raises TypeError if the argument cannot be coerced to BigDecimal"
  fails "BigDecimal#remainder returns NaN if Infinity is involved"
  fails "BigDecimal#remainder returns NaN if NaN is involved"
  fails "BigDecimal#remainder returns NaN used with zero"
  fails "BigDecimal#remainder returns zero if used on zero"
  fails "BigDecimal#round BigDecimal::ROUND_CEILING rounds values towards +infinity"
  fails "BigDecimal#round BigDecimal::ROUND_DOWN rounds values towards zero"
  fails "BigDecimal#round BigDecimal::ROUND_FLOOR rounds values towards -infinity"
  fails "BigDecimal#round BigDecimal::ROUND_HALF_DOWN rounds values > 5 up, otherwise down"
  fails "BigDecimal#round BigDecimal::ROUND_HALF_EVEN rounds values > 5 up, < 5 down and == 5 towards even neighbor"
  fails "BigDecimal#round BigDecimal::ROUND_HALF_UP rounds values >= 5 up, otherwise down"
  fails "BigDecimal#round BigDecimal::ROUND_UP rounds values away from zero"
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
  fails "BigDecimal#sqrt returns positive infitinity for infinity"
  fails "BigDecimal#sqrt returns square root of 0.9E-99999 with desired precision"
  fails "BigDecimal#sqrt returns square root of 121 with desired precision"
  fails "BigDecimal#sqrt returns square root of 2 with desired precision"
  fails "BigDecimal#sqrt returns square root of 3 with desired precision"
  fails "BigDecimal#to_f properly handles special values"
  fails "BigDecimal#to_f remembers negative zero when converted to float"
  fails "BigDecimal#to_i raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_i returns Integer or Bignum otherwise"
  fails "BigDecimal#to_int raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_int returns Integer or Bignum otherwise"
  fails "BigDecimal#to_r returns a Rational with bignum values" # NoMethodError: undefined method `to_r' for 3.141592653589793238462643
  fails "BigDecimal#to_r returns a Rational" # NoMethodError: undefined method `to_r' for 3.14159
  fails "BigDecimal#to_s can return a leading space for values > 0"
  fails "BigDecimal#to_s can use conventional floating point notation"
  fails "BigDecimal#to_s can use engineering notation"
  fails "BigDecimal#to_s inserts a space every n chars, if integer n is supplied"
  fails "BigDecimal#to_s removes trailing spaces in floating point notation"
  fails "BigDecimal#to_s starts with + if + is supplied and value is positive"
  fails "BigDecimal#to_s the default format looks like 0.xxxxEnn"
  fails "BigDecimal#to_s the default format looks like 0.xxxxenn" # Expected "3.14159265358979323846264338327950288419716939937" to match /^0\.[0-9]*e[0-9]*$/
  fails "BigDecimal#truncate returns Infinity if self is infinite"
  fails "BigDecimal#truncate returns NaN if self is NaN"
  fails "BigDecimal#truncate returns the same value if self is special value"
  fails "BigDecimal#truncate returns value of given precision otherwise"
  fails "BigDecimal#truncate sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal.double_fig returns the number of digits a Float number is allowed to have"
  fails "BigDecimal.limit picks the global precision when limit 0 specified" # Expected 0.8888 to equal 0.889
  fails "BigDecimal.limit picks the specified precision over global limit" # Expected 0.888 to equal 0.89
  fails "BigDecimal.limit returns the value before set if the passed argument is nil or is not specified"
  fails "BigDecimal.limit use the global limit if no precision is specified"
  fails "BigDecimal.limit uses the global limit if no precision is specified" # Expected 0.888 to equal 0.9
  fails "BigDecimal.mode raise an exception if the flag is true"
  fails "BigDecimal.mode returns Infinity when too big"
  fails "BigDecimal.mode returns the appropriate value and continue the computation if the flag is false"
  fails "BigDecimal.new accepts significant digits >= given precision" # NoMethodError: undefined method `precs' for 3.1415923
  fails "BigDecimal.new allows for [eEdD] as exponent separator"
  fails "BigDecimal.new allows for underscores in all parts"
  fails "BigDecimal.new creates a new object of class BigDecimal"
  fails "BigDecimal.new determines precision from initial value"
  fails "BigDecimal.new ignores trailing garbage"
  fails "BigDecimal.new raises ArgumentError for invalid strings" # Exception: new BigNumber() not a number: ruby
  fails "BigDecimal.new raises ArgumentError when Float is used without precision"
  fails "BigDecimal.new treats invalid strings as 0.0"
  fails "BigDecimal.ver returns the Version number"
  fails "Kernel#BigDecimal accepts significant digits >= given precision" # NoMethodError: undefined method `precs' for 3.1415923
  fails "Kernel#BigDecimal allows for [eEdD] as exponent separator" # Exception: new BigNumber() not a number: 12345.67d89
  fails "Kernel#BigDecimal allows for underscores in all parts" # Exception: new BigNumber() not a number: 12_345.67E89
  fails "Kernel#BigDecimal creates a new object of class BigDecimal" # Expected 1 to equal (1/1)
  fails "Kernel#BigDecimal determines precision from initial value" # NoMethodError: undefined method `precs' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "Kernel#BigDecimal ignores trailing garbage" # Exception: new BigNumber() not a number: 123E45ruby
  fails "Kernel#BigDecimal raises ArgumentError for invalid strings" # Exception: new BigNumber() not a number: ruby
  fails "Kernel#BigDecimal raises ArgumentError when Float is used without precision" # Expected ArgumentError but no exception was raised (1 was returned)
end
