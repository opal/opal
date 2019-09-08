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
  fails "BigDecimal#% raises TypeError if the argument cannot be coerced to BigDecimal" # Exception: self.one.$send is not a function
  fails "BigDecimal#% raises ZeroDivisionError if other is zero" # Exception: bd5667.$send is not a function
  fails "BigDecimal#% returns NaN if NaN is involved"
  fails "BigDecimal#% returns NaN if the dividend is Infinity"
  fails "BigDecimal#% returns a [Float value] when the argument is Float" # Exception: self.two.$send is not a function
  fails "BigDecimal#% returns self modulo other"
  fails "BigDecimal#% returns the dividend if the divisor is Infinity"
  fails "BigDecimal#% with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#* multiply self with other" # Exception: lhs.$* is not a function
  fails "BigDecimal#* returns NaN if NaN is involved" # Exception: self.e.$sub is not a function
  fails "BigDecimal#* returns NaN if the result is undefined" # Exception: self.e.$sub is not a function
  fails "BigDecimal#* returns infinite value if self or argument is infinite" # Exception: self.e.$sub is not a function
  fails "BigDecimal#* returns zero if self or argument is zero" # Exception: self.e.$sub is not a function
  fails "BigDecimal#* returns zero of appropriate sign if self or argument is zero" # Exception: self.e.$sub is not a function
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
  fails "BigDecimal#+ returns Infinity or -Infinity if these are involved" # Exception: lhs.$+ is not a function
  fails "BigDecimal#+ returns NaN if Infinity + (- Infinity)" # Exception: lhs.$+ is not a function
  fails "BigDecimal#+ returns NaN if NaN is involved" # Exception: lhs.$+ is not a function
  fails "BigDecimal#+ returns a + b" # Exception: lhs.$+ is not a function
  fails "BigDecimal#+ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#+@ returns the same value with same sign (twos complement)" # Exception: first.$send is not a function
  fails "BigDecimal#- returns Infinity or -Infinity if these are involved" # Exception: lhs.$- is not a function
  fails "BigDecimal#- returns NaN both operands are infinite with the same sign" # Exception: lhs.$- is not a function
  fails "BigDecimal#- returns NaN if NaN is involved" # Exception: lhs.$- is not a function
  fails "BigDecimal#- returns a - b" # Exception: lhs.$- is not a function
  fails "BigDecimal#- with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#-@ negates self" # Exception: self.one.$send is not a function
  fails "BigDecimal#-@ properly handles special values"
  fails "BigDecimal#/ returns (+|-) Infinity if (+|-) Infinity divided by one" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#/ returns (+|-) Infinity if divided by zero" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#/ returns 0 if divided by Infinity" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#/ returns NaN if Infinity / ((+|-) Infinity)" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#/ returns NaN if zero is divided by zero" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#/ returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#/ with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#/ with Rational produces a BigDecimal" # Exception: lhs.$/ is not a function
  fails "BigDecimal#< properly handles Float infinity values" # Exception: lhs.$< is not a function
  fails "BigDecimal#< properly handles NaN values" # Exception: lhs.$< is not a function
  fails "BigDecimal#< properly handles infinity values" #fails only with mock object
  fails "BigDecimal#< raises an ArgumentError if the argument can't be coerced into a BigDecimal" # Exception: lhs.$< is not a function
  fails "BigDecimal#< returns true if a < b" # Exception: lhs.$< is not a function
  fails "BigDecimal#<= properly handles Float infinity values" # Exception: lhs.$<= is not a function
  fails "BigDecimal#<= properly handles NaN values" # Exception: lhs.$<= is not a function
  fails "BigDecimal#<= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#<= raises an ArgumentError if the argument can't be coerced into a BigDecimal" # Exception: lhs.$<= is not a function
  fails "BigDecimal#<= returns true if a <= b" # Exception: lhs.$<= is not a function
  fails "BigDecimal#<=> returns -1 if a < b" #fails only with mock object
  fails "BigDecimal#<=> returns 0 if a == b" # Exception: self.pos_int.$<=> is not a function
  fails "BigDecimal#<=> returns 1 if a > b" #fails only with mock object
  fails "BigDecimal#<=> returns nil if NaN is involved" # Exception: self.nan.$<=> is not a function
  fails "BigDecimal#<=> returns nil if the argument is nil" # Exception: self.zero.$<=> is not a function
  fails "BigDecimal#== returns false for NaN as it is never equal to any number" # Exception: self.nan.$send is not a function
  fails "BigDecimal#== returns false for infinity values with different signs" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#== returns false when compared objects that can not be coerced into BigDecimal" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#== returns false when infinite value compared to finite one" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#== returns true for infinity values with the same sign" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#== tests for equality" # Exception: self.bg6543_21.$send is not a function
  fails "BigDecimal#=== returns false for NaN as it is never equal to any number" # Exception: self.nan.$send is not a function
  fails "BigDecimal#=== returns false for infinity values with different signs" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#=== returns false when compared objects that can not be coerced into BigDecimal" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#=== returns false when infinite value compared to finite one" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#=== returns true for infinity values with the same sign" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#=== tests for equality" # Exception: self.bg6543_21.$send is not a function
  fails "BigDecimal#> properly handles Float infinity values" # Exception: lhs.$> is not a function
  fails "BigDecimal#> properly handles NaN values" # Exception: lhs.$> is not a function
  fails "BigDecimal#> properly handles infinity values" #fails only with mock object
  fails "BigDecimal#> raises an ArgumentError if the argument can't be coerced into a BigDecimal" # Exception: lhs.$> is not a function
  fails "BigDecimal#> returns true if a > b" # Exception: lhs.$> is not a function
  fails "BigDecimal#>= properly handles Float infinity values" # Exception: lhs.$>= is not a function
  fails "BigDecimal#>= properly handles NaN values" # Exception: lhs.$>= is not a function
  fails "BigDecimal#>= properly handles infinity values" #fails only with mock object
  fails "BigDecimal#>= returns nil if the argument is nil" # Exception: lhs.$>= is not a function
  fails "BigDecimal#>= returns true if a >= b" # Exception: lhs.$>= is not a function
  fails "BigDecimal#abs properly handles special values" # Exception: self.infinity.$abs is not a function
  fails "BigDecimal#abs returns the absolute value" # Exception: pos_int.$abs is not a function
  fails "BigDecimal#add favors the precision specified in the second argument over the global limit" # Exception: self.$BigDecimal(...).$add is not a function
  fails "BigDecimal#add raises ArgumentError when precision parameter is negative" # Exception: self.one.$add is not a function
  fails "BigDecimal#add raises TypeError when adds nil" # Exception: self.one.$add is not a function
  fails "BigDecimal#add raises TypeError when precision parameter is nil" # Exception: self.one.$add is not a function
  fails "BigDecimal#add returns Infinity or -Infinity if these are involved" # Exception: self.zero.$add is not a function
  fails "BigDecimal#add returns NaN if Infinity + (- Infinity)" # Exception: self.infinity.$add is not a function
  fails "BigDecimal#add returns NaN if NaN is involved" # Exception: self.one.$add is not a function
  fails "BigDecimal#add returns a + [Bignum value] with given precision" # Exception: self.dot_ones.$add is not a function
  fails "BigDecimal#add returns a + [Fixnum value] with given precision" # Exception: self.dot_ones.$add is not a function
  fails "BigDecimal#add returns a + b with given precision" # Exception: self.two.$add is not a function
  fails "BigDecimal#add uses the current rounding mode if rounding is needed" # Exception: self.$BigDecimal(...).$add is not a function
  fails "BigDecimal#add uses the default ROUND_HALF_UP rounding if it wasn't explicitly changed" # Exception: self.$BigDecimal(...).$add is not a function
  fails "BigDecimal#add with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#add with Rational produces a BigDecimal" # Exception: lhs.$+ is not a function
  fails "BigDecimal#ceil raise exception, if self is special value" # Exception: self.infinity.$ceil is not a function
  fails "BigDecimal#ceil returns a BigDecimal, if n is specified" # Exception: self.pos_int.$ceil is not a function
  fails "BigDecimal#ceil returns an Integer, if n is unspecified" # Exception: self.mixed.$ceil is not a function
  fails "BigDecimal#ceil returns n digits right of the decimal point if given n > 0" # Exception: self.mixed.$ceil is not a function
  fails "BigDecimal#ceil returns the smallest integer greater or equal to self, if n is unspecified"
  fails "BigDecimal#ceil sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#coerce returns [other, self] both as BigDecimal"
  fails "BigDecimal#div raises FloatDomainError if (+|-) Infinity divided by 1 and no precision given" # Exception: self.infinity_minus.$div is not a function
  fails "BigDecimal#div raises FloatDomainError if NaN is involved" # Exception: self.one.$div is not a function
  fails "BigDecimal#div raises ZeroDivisionError if divided by zero and no precision given" # Exception: self.one.$div is not a function
  fails "BigDecimal#div returns (+|-)Infinity if (+|-)Infinity by 1 and precision given" # Exception: self.infinity_minus.$div is not a function
  fails "BigDecimal#div returns 0 if divided by Infinity and no precision given" # Exception: self.zero.$div is not a function
  fails "BigDecimal#div returns 0 if divided by Infinity with given precision" # Exception: self.zero.$div is not a function
  fails "BigDecimal#div returns NaN if Infinity / ((+|-) Infinity)" # Exception: self.infinity.$div is not a function
  fails "BigDecimal#div returns NaN if zero is divided by zero" # Exception: self.zero.$div is not a function
  fails "BigDecimal#div returns a / b with optional precision" #fails the case of > 20 decimal places for to_s('F')
  fails "BigDecimal#div with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#div with precision set to 0 returns (+|-) Infinity if (+|-) Infinity divided by one" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#div with precision set to 0 returns (+|-) Infinity if divided by zero" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#div with precision set to 0 returns 0 if divided by Infinity" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#div with precision set to 0 returns NaN if Infinity / ((+|-) Infinity)" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#div with precision set to 0 returns NaN if zero is divided by zero" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#div with precision set to 0 returns a / b" #fails a single assertion: @one.send(@method, BigDecimal('-2E5555'), *@object).should == BigDecimal('-0.5E-5555')
  fails "BigDecimal#div with precision set to 0 with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(1) exactly 1 times but received it 0 times
  fails "BigDecimal#divmod array contains quotient and modulus as BigDecimal"
  fails "BigDecimal#divmod can be reversed with * and +" # Expected 0 to equal -1
  fails "BigDecimal#divmod divides value, returns an array" # Exception: self.a.$divmod is not a function
  fails "BigDecimal#divmod raises TypeError if the argument cannot be coerced to BigDecimal" # Exception: self.one.$divmod is not a function
  fails "BigDecimal#divmod raises ZeroDivisionError if the divisor is zero" # Exception: key.$hash is not a function
  fails "BigDecimal#divmod returns an array of Infinity and NaN if the dividend is Infinity"
  fails "BigDecimal#divmod returns an array of two NaNs if NaN is involved"
  fails "BigDecimal#divmod returns an array of two zero if the dividend is zero" # Exception: zero.$divmod is not a function
  fails "BigDecimal#divmod returns an array of zero and the dividend if the divisor is Infinity"
  fails "BigDecimal#dup returns self" # Exception: self.obj.$public_send is not a function
  fails "BigDecimal#eql? returns false for NaN as it is never equal to any number" # Exception: self.nan.$send is not a function
  fails "BigDecimal#eql? returns false for infinity values with different signs" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#eql? returns false when compared objects that can not be coerced into BigDecimal" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#eql? returns false when infinite value compared to finite one" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#eql? returns true for infinity values with the same sign" # Exception: self.infinity.$send is not a function
  fails "BigDecimal#eql? tests for equality" # Exception: self.bg6543_21.$send is not a function
  fails "BigDecimal#exponent is n if number can be represented as 0.xxx*10**n"
  fails "BigDecimal#exponent returns 0 if self is 0"
  fails "BigDecimal#exponent returns an Integer"
  fails "BigDecimal#finite? is false if Infinity or NaN" # Exception: self.infinity.$finite? is not a function
  fails "BigDecimal#finite? returns true for finite values" # Exception: val.$finite? is not a function
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
  fails "BigDecimal#infinite? returns -1 if self is -Infinity" # Exception: self.$BigDecimal(...).$infinite? is not a function
  fails "BigDecimal#infinite? returns 1 if self is Infinity" # Exception: self.$BigDecimal(...).$infinite? is not a function
  fails "BigDecimal#infinite? returns not true if self is NaN" # Exception: nan.$infinite? is not a function
  fails "BigDecimal#infinite? returns not true otherwise" # Exception: e3_minus.$infinite? is not a function
  fails "BigDecimal#inspect does not add an exponent for zero values" # Exception: self.$BigDecimal(...).$inspect is not a function
  fails "BigDecimal#inspect encloses information in angle brackets"
  fails "BigDecimal#inspect is comma separated list of three items"
  fails "BigDecimal#inspect last part is number of significant digits"
  fails "BigDecimal#inspect looks like this"
  fails "BigDecimal#inspect properly cases non-finite values" # Exception: self.$BigDecimal(...).$inspect is not a function
  fails "BigDecimal#inspect returns String starting with #"
  fails "BigDecimal#inspect returns String" # Exception: self.bigdec.$inspect is not a function
  fails "BigDecimal#inspect value after first comma is value as string"
  fails "BigDecimal#mod_part_of_divmod raises TypeError if the argument cannot be coerced to BigDecimal" # Exception: self.one.$send is not a function
  fails "BigDecimal#mod_part_of_divmod raises ZeroDivisionError if other is zero" # Exception: bd5667.$mod_part_of_divmod is not a function
  fails "BigDecimal#mod_part_of_divmod returns NaN if NaN is involved"
  fails "BigDecimal#mod_part_of_divmod returns NaN if the dividend is Infinity"
  fails "BigDecimal#mod_part_of_divmod returns a [Float value] when the argument is Float" # Exception: self.two.$send is not a function
  fails "BigDecimal#mod_part_of_divmod returns self modulo other"
  fails "BigDecimal#mod_part_of_divmod returns the dividend if the divisor is Infinity"
  fails "BigDecimal#mod_part_of_divmod with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#modulo raises TypeError if the argument cannot be coerced to BigDecimal" # Exception: self.one.$send is not a function
  fails "BigDecimal#modulo raises ZeroDivisionError if other is zero" # Exception: bd5667.$send is not a function
  fails "BigDecimal#modulo returns NaN if NaN is involved" # FloatDomainError: Computation results to 'NaN'(Not a Number)
  fails "BigDecimal#modulo returns NaN if the dividend is Infinity" # FloatDomainError: Computation results to 'Infinity'
  fails "BigDecimal#modulo returns a [Float value] when the argument is Float" # Exception: self.two.$send is not a function
  fails "BigDecimal#modulo returns self modulo other" # Exception: new BigNumber() number type has more than 15 significant digits: 9223372036854776000
  fails "BigDecimal#modulo returns the dividend if the divisor is Infinity" # Expected NaN to equal 1
  fails "BigDecimal#modulo with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(6543.21) exactly 1 times but received it 0 times
  fails "BigDecimal#mult multiply self with other with (optional) precision" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult returns NaN if NaN is involved" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult returns NaN if the result is undefined" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult returns infinite value if self or argument is infinite" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult returns zero if self or argument is zero" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult returns zero of appropriate sign if self or argument is zero" # Exception: self.e.$sub is not a function
  fails "BigDecimal#mult with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(3e-20001) exactly 1 times but received it 0 times
  fails "BigDecimal#nan? returns false if self is not a NaN" # Exception: self.$BigDecimal(...).$nan? is not a function
  fails "BigDecimal#nan? returns true if self is not a number" # Exception: self.$BigDecimal(...).$nan? is not a function
  fails "BigDecimal#nonzero? returns nil otherwise" # Exception: really_small_zero.$nonzero? is not a function
  fails "BigDecimal#nonzero? returns self if self doesn't equal zero" # Exception: infinity.$nonzero? is not a function
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
  fails "BigDecimal#quo returns (+|-) Infinity if (+|-) Infinity divided by one" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#quo returns (+|-) Infinity if divided by zero" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#quo returns 0 if divided by Infinity" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#quo returns NaN if Infinity / ((+|-) Infinity)" # Exception: Cannot read property 'apply' of undefined
  fails "BigDecimal#quo returns NaN if NaN is involved" # Exception: self.$BigDecimal(...).$quo is not a function
  fails "BigDecimal#quo returns NaN if zero is divided by zero" # Exception: Cannot read property 'apply' of undefined
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
  fails "BigDecimal#round do not raise exception, if self is special value and precision is given" # Exception: self.$BigDecimal(...).$round is not a function
  fails "BigDecimal#round raise exception, if self is special value" # Exception: self.$BigDecimal(...).$round is not a function
  fails "BigDecimal#round raise for a non-existent round mode" # ArgumentError: [BigDecimal#round] wrong number of arguments(2 for -1)
  fails "BigDecimal#round uses default rounding method unless given"
  fails "BigDecimal#sign returns BigDecimal::SIGN_NaN if BigDecimal is NaN" # Exception: self.$BigDecimal(...).$sign is not a function
  fails "BigDecimal#sign returns negative value if BigDecimal less than 0"
  fails "BigDecimal#sign returns negative zero if BigDecimal equals negative zero" # Exception: self.$BigDecimal(...).$sign is not a function
  fails "BigDecimal#sign returns positive value if BigDecimal greater than 0"
  fails "BigDecimal#sign returns positive zero if BigDecimal equals positive zero" # Exception: self.$BigDecimal(...).$sign is not a function
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
  fails "BigDecimal#sqrt returns positive infitinity for infinity"
  fails "BigDecimal#sqrt returns square root of 0.9E-99999 with desired precision"
  fails "BigDecimal#sqrt returns square root of 121 with desired precision"
  fails "BigDecimal#sqrt returns square root of 2 with desired precision"
  fails "BigDecimal#sqrt returns square root of 3 with desired precision"
  fails "BigDecimal#sub returns Infinity or -Infinity if these are involved" # Exception: self.infinity.$sub is not a function
  fails "BigDecimal#sub returns NaN if NaN is involved" # Exception: self.one.$sub is not a function
  fails "BigDecimal#sub returns NaN if both values are infinite with the same signs" # Exception: self.infinity.$sub is not a function
  fails "BigDecimal#sub returns a - b with given precision" # Exception: self.two.$sub is not a function
  fails "BigDecimal#sub with Object tries to coerce the other operand to self" # Mock 'Object' expected to receive coerce(123450000000000) exactly 1 times but received it 0 times
  fails "BigDecimal#sub with Rational produces a BigDecimal" # Exception: lhs.$- is not a function
  fails "BigDecimal#to_f properly handles special values"
  fails "BigDecimal#to_f remembers negative zero when converted to float"
  fails "BigDecimal#to_f returns number of type float" # Exception: self.$BigDecimal(...).$to_f is not a function
  fails "BigDecimal#to_f rounds correctly to Float precision" # Exception: bigdec.$to_f is not a function
  fails "BigDecimal#to_i raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_i returns Integer or Bignum otherwise"
  fails "BigDecimal#to_int raises FloatDomainError if BigDecimal is infinity or NaN"
  fails "BigDecimal#to_int returns Integer or Bignum otherwise"
  fails "BigDecimal#to_r returns a Rational with bignum values" # NoMethodError: undefined method `to_r' for 3.141592653589793238462643
  fails "BigDecimal#to_r returns a Rational" # NoMethodError: undefined method `to_r' for 3.14159
  fails "BigDecimal#to_s can return a leading space for values > 0"
  fails "BigDecimal#to_s can use conventional floating point notation"
  fails "BigDecimal#to_s can use engineering notation"
  fails "BigDecimal#to_s does not add an exponent for zero values" # Exception: self.$BigDecimal(...).$to_s is not a function
  fails "BigDecimal#to_s inserts a space every n chars, if integer n is supplied"
  fails "BigDecimal#to_s removes trailing spaces in floating point notation"
  fails "BigDecimal#to_s return type is of class String" # Exception: self.bigdec.$to_s is not a function
  fails "BigDecimal#to_s starts with + if + is supplied and value is positive"
  fails "BigDecimal#to_s takes an optional argument" # Expected to not get Exception
  fails "BigDecimal#to_s the default format looks like 0.xxxxEnn"
  fails "BigDecimal#to_s the default format looks like 0.xxxxenn" # Expected "3.14159265358979323846264338327950288419716939937" to match /^0\.[0-9]*e[0-9]*$/
  fails "BigDecimal#truncate returns Infinity if self is infinite"
  fails "BigDecimal#truncate returns NaN if self is NaN"
  fails "BigDecimal#truncate returns the integer part as a BigDecimal if no precision given" # Exception: self.$BigDecimal(...).$truncate is not a function
  fails "BigDecimal#truncate returns the same value if self is special value"
  fails "BigDecimal#truncate returns value of given precision otherwise"
  fails "BigDecimal#truncate returns value of type Integer." # Exception: self.$BigDecimal(...).$truncate is not a function
  fails "BigDecimal#truncate sets n digits left of the decimal point to 0, if given n < 0"
  fails "BigDecimal#zero? returns false otherwise" # Exception: self.$BigDecimal(...).$zero? is not a function
  fails "BigDecimal#zero? returns true if self does equal zero" # Exception: really_small_zero.$zero? is not a function
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
  fails "Float#to_d returns appropriate BigDecimal zero for signed zero" # NoMethodError: undefined method `to_d' for 0
  fails "Kernel#BigDecimal accepts NaN and [+-]Infinity as Float values works with an explicit precision" # Exception: self.$BigDecimal(...).$nan? is not a function
  fails "Kernel#BigDecimal accepts NaN and [+-]Infinity as Float values works without an explicit precision" # Exception: self.$BigDecimal(...).$nan? is not a function
  fails "Kernel#BigDecimal accepts NaN and [+-]Infinity" # Exception: self.$BigDecimal(...).$nan? is not a function
  fails "Kernel#BigDecimal accepts significant digits >= given precision" # NoMethodError: undefined method `precs' for 3.1415923
  fails "Kernel#BigDecimal allows for [eEdD] as exponent separator" # Exception: new BigNumber() not a number: 12345.67d89
  fails "Kernel#BigDecimal allows for underscores in all parts" # Exception: new BigNumber() not a number: 12_345.67E89
  fails "Kernel#BigDecimal allows for varying signs" # Exception: self.$BigDecimal(...).$should is not a function
  fails "Kernel#BigDecimal allows omitting the integer part" # Exception: self.$BigDecimal(...).$should is not a function
  fails "Kernel#BigDecimal creates a new object of class BigDecimal" # Expected 1 to equal (1/1)
  fails "Kernel#BigDecimal determines precision from initial value" # NoMethodError: undefined method `precs' for 3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593014782083152134043
  fails "Kernel#BigDecimal ignores leading whitespace" # Exception: self.$BigDecimal(...).$should is not a function
  fails "Kernel#BigDecimal ignores trailing garbage" # Exception: new BigNumber() not a number: 123E45ruby
  fails "Kernel#BigDecimal raises ArgumentError for invalid strings" # Exception: new BigNumber() not a number: ruby
  fails "Kernel#BigDecimal raises ArgumentError when Float is used without precision" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "Kernel#BigDecimal returns appropriate BigDecimal zero for signed zero" # Exception: self.$BigDecimal(...).$sign is not a function
end
