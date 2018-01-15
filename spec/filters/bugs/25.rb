opal_filter "2.5" do

fails "A Symbol literal inherits the encoding of the magic comment and can have a binary encoding" # NoMethodError: undefined method `tmp' for main
fails "A Symbol literal with invalid bytes raises an EncodingError at parse time" # NameError: uninitialized constant EncodingError
fails "A method assigns local variables from method parameters for definition \n    def m(a, b = nil, c = nil, d, e: nil, **f)\n      [a, b, c, d, e, f]\n    end" # Exception: Cannot read property '$$is_array' of undefined
fails "An ensure block inside 'do end' block is executed even when a symbol is thrown in it's corresponding begin block" # Expected ["begin", "rescue", "ensure"] to equal ["begin", "ensure"]
fails "An ensure block inside a class is executed even when a symbol is thrown" # Expected ["class", "rescue", "ensure"] to equal ["class", "ensure"]
fails "Array#inspect does not call #to_str on the object returned from #inspect when it is not a String" # Expected "[main]" to match /^\[#<MockObject:0x[0-9a-f]+>\]$/
fails "Array#to_s does not call #to_str on the object returned from #inspect when it is not a String" # Expected "[main]" to match /^\[#<MockObject:0x[0-9a-f]+>\]$/
fails "BigDecimal.limit picks the specified precision over global limit" # Expected 0.888 to equal 0.89
fails "BigDecimal.limit uses the global limit if no precision is specified" # Expected 0.888 to equal 0.9
fails "Constant resolution within methods with ||= assigns a global constant if previously undefined" # NameError: uninitialized constant OpAssignGlobalUndefined
fails "Constant resolution within methods with ||= assigns a scoped constant if previously undefined" # NameError: uninitialized constant ConstantSpecs::OpAssignUndefined
fails "Enumerable#all? with no block given a pattern argument returns true iff all match that pattern" # ArgumentError: [Numerous#all?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument always returns false on empty enumeration" # ArgumentError: [Empty#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument any? should return false if the block never returns other than false or nil" # ArgumentError: [Array#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument calls `===` on the pattern the return value " # ArgumentError: [Array#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument calls the pattern with gathered array when yielded with multiple arguments" # ArgumentError: [YieldsMixed2#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument does not hide exceptions out of #each" # ArgumentError: [ThrowingEach#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument does not hide exceptions out of the block" # ArgumentError: [Numerous#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument ignores block" # ArgumentError: [Array#any?] wrong number of arguments(1 for 0)
fails "Enumerable#any? when given a pattern argument returns true if the pattern ever returns a truthy value" # ArgumentError: [Array#any?] wrong number of arguments(1 for 0)
fails "Enumerable#none? given a pattern argument returns true iff none match that pattern" # ArgumentError: [Numerous#none?] wrong number of arguments(1 for 0)
fails "Enumerable#one? when passed a block given a pattern argument returns true iff none match that pattern" # ArgumentError: [Numerous#one?] wrong number of arguments(1 for 0)
fails "Enumerable#uniq compares elements with matching hash codes with #eql?" # Expected false to equal true
fails "Enumerable#uniq uses eql? semantics" # Expected [1] to equal [1, 1]
fails "Float#* does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Float#+ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Float#- does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Float#/ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Float#< does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Float#<= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Float#> does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Float#>= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Float#ceil returns the smallest number greater than or equal to self with an optionally given precision" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Float#floor returns the largest number less than or equal to self with an optionally given precision" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Float#round returns different rounded values depending on the half option" # TypeError: no implicit conversion of Hash into Integer
fails "Float#truncate returns self truncated to an optionally given precision" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Global variable $VERBOSE converts truthy values to true" # Expected 1 to be true
fails "Hash#fetch when the key is not found sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch when the key is not found sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch_values with unmatched keys sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#fetch_values with unmatched keys sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Hash#slice returns a Hash instance, even on subclasses" # NoMethodError: undefined method `slice' for {"foo"=>42}
fails "Hash#slice returns a hash ordered in the order of the requested keys" # NoMethodError: undefined method `slice' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#slice returns new hash" # NoMethodError: undefined method `slice' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#slice returns only the keys of the original hash" # NoMethodError: undefined method `slice' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#slice returns the requested subset" # NoMethodError: undefined method `slice' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#transform_keys keeps last pair if new keys conflict" # NoMethodError: undefined method `transform_keys' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#transform_keys makes both hashes to share values" # NoMethodError: undefined method `transform_keys' for {"a"=>[1, 2, 3]}
fails "Hash#transform_keys returns a Hash instance, even on subclasses" # NoMethodError: undefined method `transform_keys' for {"foo"=>42}
fails "Hash#transform_keys returns new hash" # NoMethodError: undefined method `transform_keys' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#transform_keys sets the result as transformed keys with the given block" # NoMethodError: undefined method `transform_keys' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#transform_keys when no block is given returns a sized Enumerator" # NoMethodError: undefined method `transform_keys' for {"a"=>1, "b"=>2, "c"=>3}
fails "Hash#transform_keys! does not prevent conflicts between new keys and old ones" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! keeps later pair if new keys conflict" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! on frozen instance when no block is given does not raise an exception" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! partially modifies the contents if we broke from the block" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! returns self" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! updates self as transformed values with the given block" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Hash#transform_keys! when no block is given returns a sized Enumerator" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
fails "Integer is the class of both small and large integers" # Expected Number to be identical to Integer
fails "Integer is the class of both small and large integers" # Expected Number to be identical to Integer
fails "Integer#% bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
fails "Integer#% bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
fails "Integer#& bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
fails "Integer#& bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
fails "Integer#& bignum returns self bitwise AND other" # Expected 0 to equal 1
fails "Integer#& bignum returns self bitwise AND other" # Expected 0 to equal 1
fails "Integer#& bignum returns self bitwise AND other when both operands are negative" # Expected 0 to equal -13835058055282164000
fails "Integer#& bignum returns self bitwise AND other when both operands are negative" # Expected 0 to equal -13835058055282164000
fails "Integer#& bignum returns self bitwise AND other when one operand is negative" # Expected 0 to equal 18446744073709552000
fails "Integer#& bignum returns self bitwise AND other when one operand is negative" # Expected 0 to equal 18446744073709552000
fails "Integer#& fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#& fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#& fixnum returns self bitwise AND a bignum" # Expected 0 to equal 18446744073709552000
fails "Integer#& fixnum returns self bitwise AND a bignum" # Expected 0 to equal 18446744073709552000
fails "Integer#& fixnum returns self bitwise AND other" # Expected 0 to equal 65535
fails "Integer#& fixnum returns self bitwise AND other" # Expected 0 to equal 65535
fails "Integer#* bignum returns self multiplied by the given Integer" # Expected 8.507059173023462e+37 to equal 8.507059173023463e+37
fails "Integer#* bignum returns self multiplied by the given Integer" # Expected 8.507059173023462e+37 to equal 8.507059173023463e+37
fails "Integer#* does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#* does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#** fixnum can raise -1 to a bignum safely" # Expected 1 to have same value and type as -1
fails "Integer#** fixnum can raise -1 to a bignum safely" # Expected 1 to have same value and type as -1
fails "Integer#** fixnum raises a ZeroDivisionError for 0 ** -1" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#** fixnum raises a ZeroDivisionError for 0 ** -1" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#** fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
fails "Integer#** fixnum returns self raised to the given power" # Exception: Maximum call stack size exceeded
fails "Integer#+ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#+ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#- bignum returns self minus the given Integer" # Expected 0 to equal 272
fails "Integer#- bignum returns self minus the given Integer" # Expected 0 to equal 272
fails "Integer#- does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#- does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#/ bignum raises a ZeroDivisionError if other is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ bignum raises a ZeroDivisionError if other is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
fails "Integer#/ bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
fails "Integer#/ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#/ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Integer#/ fixnum coerces fixnum and return self divided by other" # Expected 1.0842021724855044e-19 to equal 0
fails "Integer#/ fixnum coerces fixnum and return self divided by other" # Expected 1.0842021724855044e-19 to equal 0
fails "Integer#/ fixnum raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ fixnum raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ fixnum returns result the same class as the argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum returns result the same class as the argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum returns self divided by the given argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum returns self divided by the given argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum supports dividing negative numbers" # Expected -0.1 to equal -1
fails "Integer#/ fixnum supports dividing negative numbers" # Expected -0.1 to equal -1
fails "Integer#< bignum returns true if self is less than the given argument" # Expected false to equal true
fails "Integer#< bignum returns true if self is less than the given argument" # Expected false to equal true
fails "Integer#< does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#< does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#<< (with n << m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 2.3611832414348226e+21
fails "Integer#<< (with n << m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 2.3611832414348226e+21
fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n < 0, m > 0" # Expected 0 to equal -7.555786372591432e+22
fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n < 0, m > 0" # Expected 0 to equal -7.555786372591432e+22
fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n > 0, m > 0" # Expected 0 to equal 2.3611832414348226e+21
fails "Integer#<< (with n << m) bignum returns n shifted left m bits when n > 0, m > 0" # Expected 0 to equal 2.3611832414348226e+21
fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n < 0, m < 0" # Expected 0 to equal -36893488147419103000
fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n < 0, m < 0" # Expected 0 to equal -36893488147419103000
fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n > 0, m < 0" # Expected 0 to equal 73786976294838210000
fails "Integer#<< (with n << m) bignum returns n shifted right m bits when n > 0, m < 0" # Expected 0 to equal 73786976294838210000
fails "Integer#<< (with n << m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
fails "Integer#<< (with n << m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
fails "Integer#<< (with n << m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
fails "Integer#<< (with n << m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
fails "Integer#<< (with n << m) fixnum returns -1 when n < 0, m < 0 and n > -(2**-m)" # Expected -7 to equal -1
fails "Integer#<< (with n << m) fixnum returns -1 when n < 0, m < 0 and n > -(2**-m)" # Expected -7 to equal -1
fails "Integer#<< (with n << m) fixnum returns 0 when m < 0 and m is a Bignum" # Expected 3 to equal 0
fails "Integer#<< (with n << m) fixnum returns 0 when m < 0 and m is a Bignum" # Expected 3 to equal 0
fails "Integer#<< (with n << m) fixnum returns 0 when n > 0, m < 0 and n < 2**-m" # Expected 7 to equal 0
fails "Integer#<< (with n << m) fixnum returns 0 when n > 0, m < 0 and n < 2**-m" # Expected 7 to equal 0
fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max << 1 and n > 0" # Expected 2147483646 (Number) to be an instance of Bignum
fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max << 1 and n > 0" # Expected 2147483646 (Number) to be an instance of Bignum
fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min << 1 and n < 0" # Expected -2147483648 (Number) to be an instance of Bignum
fails "Integer#<< (with n << m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min << 1 and n < 0" # Expected -2147483648 (Number) to be an instance of Bignum
fails "Integer#<= bignum returns false if compares with near float" # Expected true to equal false
fails "Integer#<= bignum returns false if compares with near float" # Expected true to equal false
fails "Integer#<= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#<= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#<=> bignum with a Bignum when other is negative returns -1 when self is negative and other is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with a Bignum when other is negative returns -1 when self is negative and other is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with a Bignum when other is negative returns 1 when self is negative and other is smaller" # Expected 0 to equal 1
fails "Integer#<=> bignum with a Bignum when other is negative returns 1 when self is negative and other is smaller" # Expected 0 to equal 1
fails "Integer#<=> bignum with a Bignum when other is positive returns -1 when self is positive and other is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with a Bignum when other is positive returns -1 when self is positive and other is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with a Bignum when other is positive returns 1 when other is smaller" # Expected 0 to equal 1
fails "Integer#<=> bignum with a Bignum when other is positive returns 1 when other is smaller" # Expected 0 to equal 1
fails "Integer#<=> bignum with an Object lets the exception go through if #coerce raises an exception" # Expected RuntimeError (my error) but no exception was raised (nil was returned)
fails "Integer#<=> bignum with an Object lets the exception go through if #coerce raises an exception" # Expected RuntimeError (my error) but no exception was raised (nil was returned)
fails "Integer#<=> bignum with an Object returns -1 if the coerced value is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with an Object returns -1 if the coerced value is larger" # Expected 0 to equal -1
fails "Integer#<=> bignum with an Object returns nil if #coerce does not return an Array" # Expected 0 to be nil
fails "Integer#<=> bignum with an Object returns nil if #coerce does not return an Array" # Expected 0 to be nil
fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
fails "Integer#== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
fails "Integer#== bignum returns true if self has the same value as the given argument" # Expected true to equal false
fails "Integer#== bignum returns true if self has the same value as the given argument" # Expected true to equal false
fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Expected "woot" to equal true
fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
fails "Integer#=== bignum returns the result of 'other == self' as a boolean" # Mock 'not integer' expected to receive ==("any_args") exactly 2 times but received it 1 times
fails "Integer#=== bignum returns true if self has the same value as the given argument" # Expected true to equal false
fails "Integer#=== bignum returns true if self has the same value as the given argument" # Expected true to equal false
fails "Integer#> bignum returns true if self is greater than the given argument" # Expected false to equal true
fails "Integer#> bignum returns true if self is greater than the given argument" # Expected false to equal true
fails "Integer#> does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#> does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#>= bignum returns true if self is greater than or equal to other" # Expected true to equal false
fails "Integer#>= bignum returns true if self is greater than or equal to other" # Expected true to equal false
fails "Integer#>= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#>= does not rescue exception raised in other#coerce" # ArgumentError: comparison of Number with MockObject failed
fails "Integer#>> (with n >> m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 36893488147419103000
fails "Integer#>> (with n >> m) bignum calls #to_int to convert the argument to an Integer" # Expected 0 to equal 36893488147419103000
fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting" # Expected 101376 to equal -2621440001220703000
fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting" # Expected 101376 to equal -2621440001220703000
fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting for very large values" # Expected 0 to equal 2.2204460502842888e+66
fails "Integer#>> (with n >> m) bignum respects twos complement signed shifting for very large values" # Expected 0 to equal 2.2204460502842888e+66
fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n < 0, m < 0" # Expected 0 to equal -1.1805916207174113e+21
fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n < 0, m < 0" # Expected 0 to equal -1.1805916207174113e+21
fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n > 0, m < 0" # Expected 0 to equal 590295810358705700000
fails "Integer#>> (with n >> m) bignum returns n shifted left m bits when  n > 0, m < 0" # Expected 0 to equal 590295810358705700000
fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n < 0, m > 0" # Expected 0 to equal -36893488147419103000
fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n < 0, m > 0" # Expected 0 to equal -36893488147419103000
fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n > 0, m > 0" # Expected 0 to equal 73786976294838210000
fails "Integer#>> (with n >> m) bignum returns n shifted right m bits when n > 0, m > 0" # Expected 0 to equal 73786976294838210000
fails "Integer#>> (with n >> m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
fails "Integer#>> (with n >> m) bignum returns n when n < 0, m == 0" # Expected 0 to equal -147573952589676410000
fails "Integer#>> (with n >> m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
fails "Integer#>> (with n >> m) bignum returns n when n > 0, m == 0" # Expected 0 to equal 147573952589676410000
fails "Integer#>> (with n >> m) fixnum returns -1 when n < 0, m > 0 and n > -(2**m)" # Expected -7 to equal -1
fails "Integer#>> (with n >> m) fixnum returns -1 when n < 0, m > 0 and n > -(2**m)" # Expected -7 to equal -1
fails "Integer#>> (with n >> m) fixnum returns 0 when m is a bignum" # Expected 3 to equal 0
fails "Integer#>> (with n >> m) fixnum returns 0 when m is a bignum" # Expected 3 to equal 0
fails "Integer#>> (with n >> m) fixnum returns 0 when n > 0, m > 0 and n < 2**m" # Expected 7 to equal 0
fails "Integer#>> (with n >> m) fixnum returns 0 when n > 0, m > 0 and n < 2**m" # Expected 7 to equal 0
fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max >> -1 and n > 0" # NameError: uninitialized constant Bignum
fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_max * 2 when fixnum_max >> -1 and n > 0" # NameError: uninitialized constant Bignum
fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min >> -1 and n < 0" # NameError: uninitialized constant Bignum
fails "Integer#>> (with n >> m) fixnum returns an Bignum == fixnum_min * 2 when fixnum_min >> -1 and n < 0" # NameError: uninitialized constant Bignum
fails "Integer#[] bignum returns the nth bit in the binary representation of self" # Expected 0 to equal 1
fails "Integer#[] bignum returns the nth bit in the binary representation of self" # Expected 0 to equal 1
fails "Integer#[] bignum tries to convert the given argument to an Integer using #to_int" # Expected 0 to equal 1
fails "Integer#[] bignum tries to convert the given argument to an Integer using #to_int" # Expected 0 to equal 1
fails "Integer#^ bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (14 was returned)
fails "Integer#^ bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (14 was returned)
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other" # Expected 2 to equal 9223372036854776000
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other" # Expected 2 to equal 9223372036854776000
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when all bits are 1 and other value is negative" # Expected -1 to equal -9.903520314283042e+27
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when all bits are 1 and other value is negative" # Expected -1 to equal -9.903520314283042e+27
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when both operands are negative" # Expected 0 to equal 64563604257983430000
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when both operands are negative" # Expected 0 to equal 64563604257983430000
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
fails "Integer#^ bignum returns self bitwise EXCLUSIVE OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
fails "Integer#^ fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
fails "Integer#^ fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR a bignum" # Expected -1 to equal -18446744073709552000
fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR a bignum" # Expected -1 to equal -18446744073709552000
fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR other" # Expected 5 to equal 9223372041149743000
fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR other" # Expected 5 to equal 9223372041149743000
fails "Integer#allbits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#allbits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#allbits? coerces the rhs using to_int" # NoMethodError: undefined method `allbits?' for 6
fails "Integer#allbits? coerces the rhs using to_int" # NoMethodError: undefined method `allbits?' for 6
fails "Integer#allbits? handles negative values using two's complement notation" # NoMethodError: undefined method `allbits?' for -2
fails "Integer#allbits? handles negative values using two's complement notation" # NoMethodError: undefined method `allbits?' for -2
fails "Integer#allbits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `allbits?' for 13
fails "Integer#allbits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `allbits?' for 13
fails "Integer#allbits? returns true iff all the bits of the argument are set in the receiver" # NoMethodError: undefined method `allbits?' for 42
fails "Integer#allbits? returns true iff all the bits of the argument are set in the receiver" # NoMethodError: undefined method `allbits?' for 42
fails "Integer#anybits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#anybits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#anybits? coerces the rhs using to_int" # NoMethodError: undefined method `anybits?' for 6
fails "Integer#anybits? coerces the rhs using to_int" # NoMethodError: undefined method `anybits?' for 6
fails "Integer#anybits? handles negative values using two's complement notation" # NoMethodError: undefined method `anybits?' for -43
fails "Integer#anybits? handles negative values using two's complement notation" # NoMethodError: undefined method `anybits?' for -43
fails "Integer#anybits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `anybits?' for 13
fails "Integer#anybits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `anybits?' for 13
fails "Integer#anybits? returns true iff all the bits of the argument are set in the receiver" # NoMethodError: undefined method `anybits?' for 42
fails "Integer#anybits? returns true iff all the bits of the argument are set in the receiver" # NoMethodError: undefined method `anybits?' for 42
fails "Integer#bit_length bignum returns the position of the leftmost 0 bit of a negative number" # NoMethodError: undefined method `bit_length` for -Infinity:Float
fails "Integer#bit_length bignum returns the position of the leftmost 0 bit of a negative number" # NoMethodError: undefined method `bit_length` for -Infinity:Float
fails "Integer#bit_length bignum returns the position of the leftmost bit of a positive number" # Expected 1 to equal 1000
fails "Integer#bit_length bignum returns the position of the leftmost bit of a positive number" # Expected 1 to equal 1000
fails "Integer#ceil precision argument specified as part of the ceil method is negative returns the smallest integer greater than self with at least precision.abs trailing zeros" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#ceil precision argument specified as part of the ceil method is negative returns the smallest integer greater than self with at least precision.abs trailing zeros" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#ceil returns itself if passed a positive precision" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#ceil returns itself if passed a positive precision" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#ceil returns self if passed a precision of zero" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#ceil returns self if passed a precision of zero" # ArgumentError: [Number#ceil] wrong number of arguments(1 for 0)
fails "Integer#chr with an encoding argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
fails "Integer#chr with an encoding argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
fails "Integer#coerce bignum coerces other to a Bignum and returns [other, self] when passed a Fixnum" # NameError: uninitialized constant Bignum
fails "Integer#coerce bignum coerces other to a Bignum and returns [other, self] when passed a Fixnum" # NameError: uninitialized constant Bignum
fails "Integer#coerce bignum raises a TypeError when not passed a Fixnum or Bignum" # ArgumentError: invalid value for Float(): "test"
fails "Integer#coerce bignum raises a TypeError when not passed a Fixnum or Bignum" # ArgumentError: invalid value for Float(): "test"
fails "Integer#coerce bignum returns [other, self] when passed a Bignum" # NameError: uninitialized constant Bignum
fails "Integer#coerce bignum returns [other, self] when passed a Bignum" # NameError: uninitialized constant Bignum
fails "Integer#coerce fixnum raises a TypeError when given an Object that does not respond to #to_f" # ArgumentError: invalid value for Float(): "test"
fails "Integer#coerce fixnum raises a TypeError when given an Object that does not respond to #to_f" # ArgumentError: invalid value for Float(): "test"
fails "Integer#digits converts the radix with #to_int" # NoMethodError: undefined method `arguments' for main
fails "Integer#digits converts the radix with #to_int" # NoMethodError: undefined method `arguments' for main
fails "Integer#digits converts the radix with #to_int" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits converts the radix with #to_int" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits raises ArgumentError when calling with a negative radix" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits raises ArgumentError when calling with a negative radix" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits raises ArgumentError when calling with a radix less than 2" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits raises ArgumentError when calling with a radix less than 2" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits raises Math::DomainError when calling digits on a negative number" # NoMethodError: undefined method `digits' for -12345
fails "Integer#digits raises Math::DomainError when calling digits on a negative number" # NoMethodError: undefined method `digits' for -12345
fails "Integer#digits returns [0] when called on 0, regardless of base" # NoMethodError: undefined method `digits' for 0
fails "Integer#digits returns [0] when called on 0, regardless of base" # NoMethodError: undefined method `digits' for 0
fails "Integer#digits returns an array of place values in base-10 by default" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits returns an array of place values in base-10 by default" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits returns digits by place value of a given radix" # NoMethodError: undefined method `digits' for 12345
fails "Integer#digits returns digits by place value of a given radix" # NoMethodError: undefined method `digits' for 12345
fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
fails "Integer#div bignum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
fails "Integer#div bignum looses precision if passed Float argument" # Expected 9223372036854776000 not to equal 9223372036854776000
fails "Integer#div bignum looses precision if passed Float argument" # Expected 9223372036854776000 not to equal 9223372036854776000
fails "Integer#div bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
fails "Integer#div bignum returns self divided by other" # Expected 10000000000 to equal 9999999999
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
fails "Integer#divmod bignum raises a TypeError when the given argument is not an Integer" # NoMethodError: undefined method `nan?' for main
fails "Integer#divmod bignum raises a TypeError when the given argument is not an Integer" # NoMethodError: undefined method `nan?' for main
fails "Integer#divmod bignum returns an Array containing quotient and modulus obtained from dividing self by the given argument" # Expected [2305843009213694000, 0] to equal [2305843009213694000, 3]
fails "Integer#divmod bignum returns an Array containing quotient and modulus obtained from dividing self by the given argument" # Expected [2305843009213694000, 0] to equal [2305843009213694000, 3]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b < 0 and |a| < |b|" # Expected [1, 0] to equal [0, -9223372036854776000]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b < 0 and |a| < |b|" # Expected [1, 0] to equal [0, -9223372036854776000]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b > 0 and |a| < b" # Expected [-1, 0] to equal [-1, 1]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b > 0 and |a| < b" # Expected [-1, 0] to equal [-1, 1]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a < |b|" # Expected [-1, 0] to equal [-1, -1]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a < |b|" # Expected [-1, 0] to equal [-1, -1]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a > |b|" # Expected [-1, 0] to equal [-2, -9223372036854776000]
fails "Integer#divmod bignum with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a > |b|" # Expected [-1, 0] to equal [-2, -9223372036854776000]
fails "Integer#divmod fixnum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nan?' for main
fails "Integer#divmod fixnum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nan?' for main
fails "Integer#even? fixnum returns true for a Bignum when it is an even number" # Expected true to be false
fails "Integer#even? fixnum returns true for a Bignum when it is an even number" # Expected true to be false
fails "Integer#floor precision argument specified as part of the floor method is negative returns the largest integer less than self with at least precision.abs trailing zeros" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#floor precision argument specified as part of the floor method is negative returns the largest integer less than self with at least precision.abs trailing zeros" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#floor returns itself if passed a positive precision" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#floor returns itself if passed a positive precision" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#floor returns self if passed a precision of zero" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#floor returns self if passed a precision of zero" # ArgumentError: [Number#floor] wrong number of arguments(1 for 0)
fails "Integer#modulo bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
fails "Integer#modulo bignum returns the modulus obtained from dividing self by the given argument" # Expected 0 to equal 9223372036854776000
fails "Integer#nobits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#nobits? coerces the rhs using to_int" # Mock 'the int 0b10' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Integer#nobits? coerces the rhs using to_int" # NoMethodError: undefined method `nobits?' for 6
fails "Integer#nobits? coerces the rhs using to_int" # NoMethodError: undefined method `nobits?' for 6
fails "Integer#nobits? handles negative values using two's complement notation" # NoMethodError: undefined method `nobits?' for -14
fails "Integer#nobits? handles negative values using two's complement notation" # NoMethodError: undefined method `nobits?' for -14
fails "Integer#nobits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nobits?' for 13
fails "Integer#nobits? raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nobits?' for 13
fails "Integer#nobits? returns true iff all no bits of the argument are set in the receiver" # NoMethodError: undefined method `nobits?' for 42
fails "Integer#nobits? returns true iff all no bits of the argument are set in the receiver" # NoMethodError: undefined method `nobits?' for 42
fails "Integer#odd? bignum returns false if self is even and negative" # Expected true to be false
fails "Integer#odd? bignum returns false if self is even and negative" # Expected true to be false
fails "Integer#odd? bignum returns true if self is odd and positive" # Expected false to be true
fails "Integer#odd? bignum returns true if self is odd and positive" # Expected false to be true
fails "Integer#odd? fixnum returns true when self is an odd number" # Expected false to be true
fails "Integer#odd? fixnum returns true when self is an odd number" # Expected false to be true
fails "Integer#pow one argument is passed bignum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed bignum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed bignum returns a complex number when negative and raised to a fractional power" # NoMethodError: undefined method `pow' for -9223372036854776000
fails "Integer#pow one argument is passed bignum returns a complex number when negative and raised to a fractional power" # NoMethodError: undefined method `pow' for -9223372036854776000
fails "Integer#pow one argument is passed bignum returns self raised to other power" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed bignum returns self raised to other power" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed bignum switch to a Float when the values is too big" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed bignum switch to a Float when the values is too big" # NoMethodError: undefined method `pow' for 9223372036854776000
fails "Integer#pow one argument is passed fixnum can raise -1 to a bignum safely" # NoMethodError: undefined method `pow' for -1
fails "Integer#pow one argument is passed fixnum can raise -1 to a bignum safely" # NoMethodError: undefined method `pow' for -1
fails "Integer#pow one argument is passed fixnum can raise 1 to a bignum safely" # NoMethodError: undefined method `pow' for 1
fails "Integer#pow one argument is passed fixnum can raise 1 to a bignum safely" # NoMethodError: undefined method `pow' for 1
fails "Integer#pow one argument is passed fixnum coerces power and calls #**" # Mock '2' expected to receive coerce(13) exactly 1 times but received it 0 times
fails "Integer#pow one argument is passed fixnum coerces power and calls #**" # Mock '2' expected to receive coerce(13) exactly 1 times but received it 0 times
fails "Integer#pow one argument is passed fixnum coerces power and calls #**" # NoMethodError: undefined method `pow' for 13
fails "Integer#pow one argument is passed fixnum coerces power and calls #**" # NoMethodError: undefined method `pow' for 13
fails "Integer#pow one argument is passed fixnum overflows the answer to a bignum transparently" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum overflows the answer to a bignum transparently" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum raises a TypeError when given a non-numeric power" # NoMethodError: undefined method `pow' for 13
fails "Integer#pow one argument is passed fixnum raises a TypeError when given a non-numeric power" # NoMethodError: undefined method `pow' for 13
fails "Integer#pow one argument is passed fixnum raises a ZeroDivisionError for 0 ** -1" # NoMethodError: undefined method `pow' for 0
fails "Integer#pow one argument is passed fixnum raises a ZeroDivisionError for 0 ** -1" # NoMethodError: undefined method `pow' for 0
fails "Integer#pow one argument is passed fixnum raises negative numbers to the given power" # NoMethodError: undefined method `pow' for -2
fails "Integer#pow one argument is passed fixnum raises negative numbers to the given power" # NoMethodError: undefined method `pow' for -2
fails "Integer#pow one argument is passed fixnum returns Float when power is Float" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns Float when power is Float" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns Float::INFINITY for 0 ** -1.0" # NoMethodError: undefined method `pow' for 0
fails "Integer#pow one argument is passed fixnum returns Float::INFINITY for 0 ** -1.0" # NoMethodError: undefined method `pow' for 0
fails "Integer#pow one argument is passed fixnum returns Float::INFINITY when the number is too big" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns Float::INFINITY when the number is too big" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns Rational when power is Rational" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns Rational when power is Rational" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns a complex number when negative and raised to a fractional power" # NoMethodError: undefined method `pow' for -8
fails "Integer#pow one argument is passed fixnum returns a complex number when negative and raised to a fractional power" # NoMethodError: undefined method `pow' for -8
fails "Integer#pow one argument is passed fixnum returns self raised to the given power" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow one argument is passed fixnum returns self raised to the given power" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed ensures all arguments are integers" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed ensures all arguments are integers" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed handles sign like #divmod does" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed handles sign like #divmod does" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed raises TypeError for non-numeric value" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed raises TypeError for non-numeric value" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed raises a ZeroDivisionError when the given argument is 0" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed raises a ZeroDivisionError when the given argument is 0" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed returns modulo of self raised to the given power" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed returns modulo of self raised to the given power" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed works well with bignums" # NoMethodError: undefined method `pow' for 2
fails "Integer#pow two arguments are passed works well with bignums" # NoMethodError: undefined method `pow' for 2
fails "Integer#remainder bignum does raises ZeroDivisionError if other is zero and a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder bignum does raises ZeroDivisionError if other is zero and a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder bignum raises a ZeroDivisionError if other is zero and not a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder bignum raises a ZeroDivisionError if other is zero and not a Float" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder bignum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder bignum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 9223372036854776000
fails "Integer#remainder fixnum keeps sign of self" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum keeps sign of self" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum means x-y*(x/y).truncate" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum means x-y*(x/y).truncate" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum raises TypeError if passed non-numeric argument" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum raises TypeError if passed non-numeric argument" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 5
fails "Integer#round returns different rounded values depending on the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#round returns different rounded values depending on the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#round returns itself if passed a positive precision and the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#round returns itself if passed a positive precision and the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#size bignum returns the number of bytes required to hold the unsigned bignum data" # Expected 4 to equal 8
fails "Integer#size bignum returns the number of bytes required to hold the unsigned bignum data" # Expected 4 to equal 8
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given a base returns self converted to a String using the given base" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given a base returns self converted to a String using the given base" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given a base returns self converted to a String using the given base" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given a base returns self converted to a String using the given base" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given no base returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given no base returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s bignum when given no base returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s bignum when given no base returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when given a base raises an ArgumentError if the base is less than 2 or higher than 36" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when given a base returns self converted to a String in the given base" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when given a base returns self converted to a String in the given base" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when given a base returns self converted to a String in the given base" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when given a base returns self converted to a String in the given base" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when no base given returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when no base given returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal' for Encoding
fails "Integer#to_s fixnum when no base given returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#to_s fixnum when no base given returns self converted to a String using base 10" # NoMethodError: undefined method `default_internal=' for Encoding
fails "Integer#truncate precision argument specified as part of the truncate method is negative returns an integer with at least precision.abs trailing zeros" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#truncate precision argument specified as part of the truncate method is negative returns an integer with at least precision.abs trailing zeros" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#truncate returns itself if passed a positive precision" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#truncate returns itself if passed a positive precision" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#truncate returns self if not passed a precision" # Expected 1 to have same value and type as 1.0000000000000002e+70
fails "Integer#truncate returns self if not passed a precision" # Expected 1 to have same value and type as 1.0000000000000002e+70
fails "Integer#truncate returns self if passed a precision of zero" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#truncate returns self if passed a precision of zero" # ArgumentError: [Number#to_i] wrong number of arguments(1 for 0)
fails "Integer#| bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (9 was returned)
fails "Integer#| bignum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (9 was returned)
fails "Integer#| bignum returns self bitwise OR other" # Expected 2 to equal 9223372036854776000
fails "Integer#| bignum returns self bitwise OR other" # Expected 2 to equal 9223372036854776000
fails "Integer#| bignum returns self bitwise OR other when both operands are negative" # Expected 0 to equal -1
fails "Integer#| bignum returns self bitwise OR other when both operands are negative" # Expected 0 to equal -1
fails "Integer#| bignum returns self bitwise OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
fails "Integer#| bignum returns self bitwise OR other when one operand is negative" # Expected 0 to equal -64563604257983430000
fails "Integer#| fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#| fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#| fixnum returns self bitwise OR other" # Expected 65535 to equal 9223372036854841000
fails "Integer#| fixnum returns self bitwise OR other" # Expected 65535 to equal 9223372036854841000
fails "Integer#~ bignum returns self with each bit flipped" # Expected -1 to equal -9223372036854776000
fails "Integer#~ bignum returns self with each bit flipped" # Expected -1 to equal -9223372036854776000
fails "Integer.sqrt accepts any argument that can be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt accepts any argument that can be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `arguments' for main
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `arguments' for main
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a Math::DomainError if the argument is negative" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a Math::DomainError if the argument is negative" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a TypeError if the argument cannot be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a TypeError if the argument cannot be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt returns an integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt returns an integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt returns the integer square root of the argument" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt returns the integer square root of the argument" # NoMethodError: undefined method `sqrt' for Integer
fails "Invoking a method expands the Array elements from the splat after executing the arguments and block if no other arguments follow the splat" # Expected [[1, nil], nil] to equal [[1], nil]
fails "Kernel#inspect returns a String with the object class and object_id encoded" # Expected "main" to match /^#<Object:0x[0-9a-f]+>$/
fails "Kernel#sprintf faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Kernel#sprintf faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Kernel#sprintf flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
fails "Kernel#sprintf flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
fails "Kernel#sprintf flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel#sprintf flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel#sprintf flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
fails "Kernel#sprintf flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Kernel#sprintf flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Kernel#sprintf flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel#sprintf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "Kernel#sprintf float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "Kernel#sprintf float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "Kernel#sprintf float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
fails "Kernel#sprintf float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "Kernel#sprintf float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "Kernel#sprintf float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "Kernel#sprintf float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
fails "Kernel#sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel#sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel#sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel#sprintf other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
fails "Kernel#sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel#sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
fails "Kernel#sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
fails "Kernel#sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
fails "Kernel#sprintf returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
fails "Kernel#sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Kernel#to_s returns a String containing the name of self's class" # Expected "main" to match /Object/
fails "Kernel#yield_self returns a sized Enumerator when no block given" # NoMethodError: undefined method `yield_self' for main
fails "Kernel#yield_self returns the block return value" # NoMethodError: undefined method `yield_self' for main
fails "Kernel#yield_self yields self" # NoMethodError: undefined method `yield_self' for main
fails "Kernel.printf formatting io is not specified faulty key raises a KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified faulty key raises a KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to format o does nothing for negative argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to format o does nothing for negative argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats bBxX does nothing for zero argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats bBxX does nothing for zero argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags # applies to gG does not remove trailing zeros" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags # applies to gG does not remove trailing zeros" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ ignores '-' sign" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ ignores '-' sign" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ raises exception if argument number is bigger than actual arguments list" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ raises exception if argument number is bigger than actual arguments list" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ specifies the absolute argument number for this field" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags (digit)$ specifies the absolute argument number for this field" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags * left-justifies the result if specified with $ argument is negative" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags * left-justifies the result if specified with $ argument is negative" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags * left-justifies the result if width is negative" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags * left-justifies the result if width is negative" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags * raises ArgumentError when is mixed with width" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags * raises ArgumentError when is mixed with width" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags * uses the previous argument as the field width" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags * uses the previous argument as the field width" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags * uses the specified argument as the width if * is followed by a number and $" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags * uses the specified argument as the width if * is followed by a number and $" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags - left-justifies the result of conversion if width is specified" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags - left-justifies the result of conversion if width is specified" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats A displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats A displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats A displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats A displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats E cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats E cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats E displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats E displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats E displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats E displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats E rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats E rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats G the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats G the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats a displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats a displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats a displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats a displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats converts argument into Float" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats converts argument into Float" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats e cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats e cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats e displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats e displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats e displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats e displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats e rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats e rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats f converts floating point argument as [-]ddd.dddddd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats f converts floating point argument as [-]ddd.dddddd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats f cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats f cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats f displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats f displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats f displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats f displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats f rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats f rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats g the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats g the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified float formats raises TypeError exception if cannot convert to Float" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified float formats raises TypeError exception if cannot convert to Float" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats B collapse negative number representation if it equals 1" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats B collapse negative number representation if it equals 1" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats B converts argument as a binary number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats B converts argument as a binary number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats B displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats B displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats X collapse negative number representation if it equals F" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats X collapse negative number representation if it equals F" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats X converts argument as a hexadecimal number with uppercase letters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats X converts argument as a hexadecimal number with uppercase letters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats X displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats X displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats b collapse negative number representation if it equals 1" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats b collapse negative number representation if it equals 1" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats b converts argument as a binary number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats b converts argument as a binary number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats b displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats b displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats converts String argument with Kernel#Integer" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats converts String argument with Kernel#Integer" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats converts argument into Integer with to_i if to_int isn't available" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats converts argument into Integer with to_i if to_int isn't available" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats converts argument into Integer with to_int" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats converts argument into Integer with to_int" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats d converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats d converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats d works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats d works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats i converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats i converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats i works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats i works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats o collapse negative number representation if it equals 7" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats o collapse negative number representation if it equals 7" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats o converts argument as an octal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats o converts argument as an octal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats o displays negative number as a two's complement prefixed with '..7'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats o displays negative number as a two's complement prefixed with '..7'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats raises TypeError exception if cannot convert to Integer" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats raises TypeError exception if cannot convert to Integer" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats u converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats u converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats u works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats u works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats x collapse negative number representation if it equals f" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats x collapse negative number representation if it equals f" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats x converts argument as a hexadecimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats x converts argument as a hexadecimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified integer formats x displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified integer formats x displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats % alone raises an ArgumentError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats % alone raises an ArgumentError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats % is escaped by %" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats % is escaped by %" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats c displays character if argument is a numeric code of character" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats c displays character if argument is a numeric code of character" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats c displays character if argument is a single character string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats c displays character if argument is a single character string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats c raises ArgumentError if argument is a string of several characters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats c raises ArgumentError if argument is a string of several characters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats c raises ArgumentError if argument is an empty string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats c raises ArgumentError if argument is an empty string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats c supports Unicode characters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats c supports Unicode characters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats p displays argument.inspect value" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats p displays argument.inspect value" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats s converts argument to string with to_s" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats s converts argument to string with to_s" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats s does not try to convert with to_str" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats s does not try to convert with to_str" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified other formats s substitute argument passes as a string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified other formats s substitute argument passes as a string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified precision float types controls the number of decimal places displayed in fraction part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified precision float types controls the number of decimal places displayed in fraction part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified precision float types does not affect G format" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified precision float types does not affect G format" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified precision integer types controls the number of decimal places displayed" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified precision integer types controls the number of decimal places displayed" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified precision string formats determines the maximum number of characters to be copied from the string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified precision string formats determines the maximum number of characters to be copied from the string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style allows to place name in any position" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style allows to place name in any position" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style cannot be mixed with unnamed style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style cannot be mixed with unnamed style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style supports flags, width, precision and type" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style supports flags, width, precision and type" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style uses value passed in a hash argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %<name>s style uses value passed in a hash argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style cannot be mixed with unnamed style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style cannot be mixed with unnamed style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style converts value to String with to_s" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style converts value to String with to_s" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style does not support type style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style does not support type style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style raises KeyError when there is no matching key" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style raises KeyError when there is no matching key" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style supports flags, width and precision" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style supports flags, width and precision" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style uses value passed in a hash argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified reference by name %{name} style uses value passed in a hash argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified width is ignored if argument's actual length is greater" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified width is ignored if argument's actual length is greater" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is not specified width specifies the minimum number of characters that will be written to the result" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is not specified width specifies the minimum number of characters that will be written to the result" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified faulty key raises a KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified faulty key raises a KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to format o does nothing for negative argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to format o does nothing for negative argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to format o increases the precision until the first digit will be `0' if it is not formatted as complements" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to formats bBxX does nothing for zero argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to formats bBxX does nothing for zero argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to formats bBxX prefixes the result with 0x, 0X, 0b and 0B respectively for non-zero argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags # applies to gG does not remove trailing zeros" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags # applies to gG does not remove trailing zeros" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags (digit)$ ignores '-' sign" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags (digit)$ ignores '-' sign" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags (digit)$ raises ArgumentError exception when absolute and relative argument numbers are mixed" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags (digit)$ raises exception if argument number is bigger than actual arguments list" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags (digit)$ raises exception if argument number is bigger than actual arguments list" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags (digit)$ specifies the absolute argument number for this field" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags (digit)$ specifies the absolute argument number for this field" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags * left-justifies the result if specified with $ argument is negative" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags * left-justifies the result if specified with $ argument is negative" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags * left-justifies the result if width is negative" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags * left-justifies the result if width is negative" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags * raises ArgumentError when is mixed with width" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags * raises ArgumentError when is mixed with width" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags * uses the previous argument as the field width" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags * uses the previous argument as the field width" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags * uses the specified argument as the width if * is followed by a number and $" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags * uses the specified argument as the width if * is followed by a number and $" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags + applies to numeric formats bBdiouxXaAeEfgG does not use two's complement form for negative numbers for formats bBoxX" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags - left-justifies the result of conversion if width is specified" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags - left-justifies the result of conversion if width is specified" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified uses radix-1 when displays negative argument as a two's complement" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA prevents converting negative argument to two's complement form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats A displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats A displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats A displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats A displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats E converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats E cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats E cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats E displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats E displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats E displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats E displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats E rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats E rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats G the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats G the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats a displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats a displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats a displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats a displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats converts argument into Float" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats converts argument into Float" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats e converts argument into exponential notation [-]d.dddddde[+-]dd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats e cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats e cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats e displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats e displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats e displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats e displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats e rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats e rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats f converts floating point argument as [-]ddd.dddddd" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats f converts floating point argument as [-]ddd.dddddd" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats f cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats f cuts excessive digits and keeps only 6 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats f displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats f displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats f displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats f displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats f rounds the last significant digit to the closest one" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats f rounds the last significant digit to the closest one" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g displays Float::INFINITY as Inf" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g displays Float::INFINITY as Inf" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g displays Float::NAN as NaN" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g displays Float::NAN as NaN" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g otherwise converts a floating point number in dd.dddd form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g otherwise cuts fraction part to have only 6 digits at all" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g otherwise rounds the last significant digit to the closest one in fractional part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats g the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats g the exponent is less than -4 converts a floating point number using exponential form" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified float formats raises TypeError exception if cannot convert to Float" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified float formats raises TypeError exception if cannot convert to Float" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats B collapse negative number representation if it equals 1" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats B collapse negative number representation if it equals 1" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats B converts argument as a binary number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats B converts argument as a binary number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats B displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats B displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats X collapse negative number representation if it equals F" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats X collapse negative number representation if it equals F" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats X converts argument as a hexadecimal number with uppercase letters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats X converts argument as a hexadecimal number with uppercase letters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats X displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats X displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats b collapse negative number representation if it equals 1" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats b collapse negative number representation if it equals 1" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats b converts argument as a binary number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats b converts argument as a binary number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats b displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats b displays negative number as a two's complement prefixed with '..1'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats converts String argument with Kernel#Integer" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats converts String argument with Kernel#Integer" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_i if to_int isn't available" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_i if to_int isn't available" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_int" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats converts argument into Integer with to_int" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats d converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats d converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats d works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats d works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats i converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats i converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats i works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats i works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats o collapse negative number representation if it equals 7" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats o collapse negative number representation if it equals 7" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats o converts argument as an octal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats o converts argument as an octal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats o displays negative number as a two's complement prefixed with '..7'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats o displays negative number as a two's complement prefixed with '..7'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats raises TypeError exception if cannot convert to Integer" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats raises TypeError exception if cannot convert to Integer" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats u converts argument as a decimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats u converts argument as a decimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats u works well with large numbers" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats u works well with large numbers" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats x collapse negative number representation if it equals f" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats x collapse negative number representation if it equals f" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats x converts argument as a hexadecimal number" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats x converts argument as a hexadecimal number" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified integer formats x displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified integer formats x displays negative number as a two's complement prefixed with '..f'" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats % alone raises an ArgumentError" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats % alone raises an ArgumentError" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats % is escaped by %" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats % is escaped by %" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats c displays character if argument is a numeric code of character" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats c displays character if argument is a numeric code of character" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats c displays character if argument is a single character string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats c displays character if argument is a single character string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is a string of several characters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is a string of several characters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is an empty string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats c raises ArgumentError if argument is an empty string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats c supports Unicode characters" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats c supports Unicode characters" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats p displays argument.inspect value" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats p displays argument.inspect value" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats s converts argument to string with to_s" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats s converts argument to string with to_s" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats s does not try to convert with to_str" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats s does not try to convert with to_str" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified other formats s substitute argument passes as a string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified other formats s substitute argument passes as a string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified precision float types controls the number of decimal places displayed in fraction part" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified precision float types controls the number of decimal places displayed in fraction part" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified precision float types does not affect G format" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified precision float types does not affect G format" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified precision integer types controls the number of decimal places displayed" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified precision integer types controls the number of decimal places displayed" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified precision string formats determines the maximum number of characters to be copied from the string" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified precision string formats determines the maximum number of characters to be copied from the string" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style allows to place name in any position" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style allows to place name in any position" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style cannot be mixed with unnamed style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style cannot be mixed with unnamed style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style supports flags, width, precision and type" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style supports flags, width, precision and type" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style uses value passed in a hash argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %<name>s style uses value passed in a hash argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style cannot be mixed with unnamed style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style cannot be mixed with unnamed style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style converts value to String with to_s" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style converts value to String with to_s" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style does not support type style" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style does not support type style" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style raises KeyError when there is no matching key" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style raises KeyError when there is no matching key" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style supports flags, width and precision" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style supports flags, width and precision" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style uses value passed in a hash argument" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified reference by name %{name} style uses value passed in a hash argument" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified width is ignored if argument's actual length is greater" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified width is ignored if argument's actual length is greater" # NoMethodError: undefined method `tmp' for main
fails "Kernel.printf formatting io is specified width specifies the minimum number of characters that will be written to the result" # NoMethodError: undefined method `close' for main
fails "Kernel.printf formatting io is specified width specifies the minimum number of characters that will be written to the result" # NoMethodError: undefined method `tmp' for main
fails "Kernel.sprintf faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "Kernel.sprintf faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "Kernel.sprintf flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
fails "Kernel.sprintf flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
fails "Kernel.sprintf flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel.sprintf flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel.sprintf flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
fails "Kernel.sprintf flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Kernel.sprintf flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Kernel.sprintf flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "Kernel.sprintf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "Kernel.sprintf float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "Kernel.sprintf float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "Kernel.sprintf float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
fails "Kernel.sprintf float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "Kernel.sprintf float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "Kernel.sprintf float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "Kernel.sprintf float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
fails "Kernel.sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel.sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel.sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "Kernel.sprintf other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
fails "Kernel.sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "Kernel.sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
fails "Kernel.sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
fails "Kernel.sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
fails "Kernel.sprintf returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
fails "Kernel.sprintf returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
fails "Kernel.sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "Method#=== for a Method generated by respond_to_missing? does not call the original method name even if it now exists" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
fails "Method#=== for a Method generated by respond_to_missing? invokes method_missing dynamically" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
fails "Method#=== for a Method generated by respond_to_missing? invokes method_missing with the method name and the specified arguments" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
fails "Method#=== for a Method generated by respond_to_missing? invokes method_missing with the specified arguments and returns the result" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
fails "Method#=== invokes the method with the specified arguments, returning the method's return value" # Expected false to equal 15
fails "Method#=== raises an ArgumentError when given incorrect number of arguments" # Expected ArgumentError but no exception was raised (false was returned)
fails "Method#to_s returns a String containing 'Method'" # Expected "main" to match /\bMethod\b/
fails "Module#autoload (concurrently) raises a LoadError in each thread if the file does not exist" # NotImplementedError: Thread creation not available
fails "Module#autoload (concurrently) raises a NameError in each thread if the constant is not set" # NotImplementedError: Thread creation not available
fails "Module#prepend called on a module does not obscure the module's methods from reflective access" # NoMethodError: undefined method `prepend' for #<Module:0x4ba4a>
fails "Module#refine adds methods defined in its block to the anonymous module's public instance methods" # NoMethodError: undefined method `refine' for #<Module:0x3ae64>
fails "Module#refine applies refinements to calls in the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae7a>
fails "Module#refine does not apply refinements to external scopes not using the module" # NoMethodError: undefined method `refine' for #<Module:0x3ae60>
fails "Module#refine does not make available methods from another refinement module" # NoMethodError: undefined method `refine' for #<Module:0x3ae8c>
fails "Module#refine does not override methods in subclasses" # NoMethodError: undefined method `refine' for #<Module:0x3ae56>
fails "Module#refine doesn't apply refinements outside the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae72>
fails "Module#refine for methods accessed indirectly is honored by BasicObject#__send__" # NoMethodError: undefined method `refine' for #<Module:0x3aeb2>
fails "Module#refine for methods accessed indirectly is honored by Kernel#binding" # NoMethodError: undefined method `refine' for #<Module:0x3aeaa>
fails "Module#refine for methods accessed indirectly is honored by Kernel#send" # NoMethodError: undefined method `refine' for #<Module:0x3aeae>
fails "Module#refine for methods accessed indirectly is honored by Symbol#to_proc" # NoMethodError: undefined method `refine' for #<Module:0x3aeba>
fails "Module#refine for methods accessed indirectly is honored by string interpolation" # NoMethodError: undefined method `refine' for #<Module:0x3aeb6>
fails "Module#refine for methods accessed indirectly is not honored by Kernel#method" # NoMethodError: undefined method `refine' for #<Module:0x3aec0>
fails "Module#refine for methods accessed indirectly is not honored by Kernel#respond_to?" # NoMethodError: undefined method `refine' for #<Module:0x3aea6>
fails "Module#refine makes available all refinements from the same module" # NoMethodError: undefined method `refine' for #<Module:0x3ae88>
fails "Module#refine method lookup looks in included modules from the refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3aea0>
fails "Module#refine method lookup looks in prepended modules from the refinement first" # NoMethodError: undefined method `refine' for #<Module:0x3ae98>
fails "Module#refine method lookup looks in refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3ae94>
fails "Module#refine method lookup looks in the class then" # NoMethodError: undefined method `refine' for #<Module:0x3ae90>
fails "Module#refine method lookup looks in the object singleton class first" # NoMethodError: undefined method `refine' for #<Module:0x3ae9c>
fails "Module#refine module inclusion activates all refinements from all ancestors" # NoMethodError: undefined method `refine' for #<Module:0x3aed4>
fails "Module#refine module inclusion overrides methods of ancestors by methods in descendants" # NoMethodError: undefined method `refine' for #<Module:0x3aed0>
fails "Module#refine raises ArgumentError if not given a block" # NoMethodError: undefined method `refine' for #<Module:0x3ae5c>
fails "Module#refine raises ArgumentError if not passed an argument" # NoMethodError: undefined method `refine' for #<Module:0x3ae80>
fails "Module#refine raises TypeError if not passed a class" # NoMethodError: undefined method `refine' for #<Module:0x3ae6e>
fails "Module#refine returns created anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae68>
fails "Module#refine runs its block in an anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae76>
fails "Module#refine uses the same anonymous module for future refines of the same class" # NoMethodError: undefined method `refine' for #<Module:0x3ae84>
fails "Module#refine when super is called in a refinement looks in the included to refinery module" # NoMethodError: undefined method `refine' for #<Module:0x3aec8>
fails "Module#refine when super is called in a refinement looks in the refined class" # NoMethodError: undefined method `refine' for #<Module:0x3aecc>
fails "Module#refine when super is called in a refinement looks in the refined class even if there is another active refinement" # NoMethodError: undefined method `refine' for #<Module:0x3aec4>
fails "Module#using accepts module as argument" # NoMethodError: undefined method `refine' for #<Module:0x2a040>
fails "Module#using accepts module without refinements" # Expected to not get Exception but got NoMethodError (undefined method `using' for #<Module:0x2a02a>)
fails "Module#using activates refinement even for existed objects" # NoMethodError: undefined method `refine' for #<Module:0x2a052>
fails "Module#using activates updates when refinement reopens later" # NoMethodError: undefined method `refine' for #<Module:0x2a018>
fails "Module#using does not accept class" # NoMethodError: undefined method `using' for #<Module:0x2a03c>
fails "Module#using imports class refinements from module into the current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a02e>
fails "Module#using raises TypeError if passed something other than module" # NoMethodError: undefined method `using' for #<Module:0x2a034>
fails "Module#using raises error in method scope" # NoMethodError: undefined method `using' for #<Module:0x2a044>
fails "Module#using returns self" # NoMethodError: undefined method `using' for #<Module:0x2a022>
fails "Module#using scope of refinement is active for method defined in a scope wherever it's called" # NoMethodError: undefined method `refine' for #<Module:0x2a06a>
fails "Module#using scope of refinement is active until the end of current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a07a>
fails "Module#using scope of refinement is not active before the `using` call" # NoMethodError: undefined method `refine' for #<Module:0x2a05e>
fails "Module#using scope of refinement is not active for code defined outside the current scope" # NoMethodError: undefined method `refine' for #<Module:0x2a072>
fails "Module#using scope of refinement is not active when class/module reopens" # NoMethodError: undefined method `refine' for #<Module:0x2a056>
fails "Module#using works in classes too" # NoMethodError: undefined method `refine' for #<Module:0x2a01c>
fails "Numeric#finite? returns true by default" # NoMethodError: undefined method `finite?' for main
fails "Numeric#infinite? returns nil by default" # NoMethodError: undefined method `infinite?' for main
fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with keyword arguments when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with mixed arguments when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when step is a String with self and stop as Fixnums raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when step is a String with self and stop as Fixnums raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when step is a String with self and stop as Floats raises an ArgumentError when step is a numeric representation" # TypeError: 0 can't be coerced into String
fails "Numeric#step with positional args when step is a String with self and stop as Floats raises an ArgumentError with step as an alphanumeric string" # TypeError: 0 can't be coerced into String
fails "Predefined global $. can be assigned a Float" # Expected 123.5 to equal 123
fails "Predefined global $. raises TypeError if object can't be converted to an Integer" # Expected TypeError but no exception was raised (main was returned)
fails "Predefined global $. raises TypeError if object can't be converted to an Integer" # Mock 'bad-value' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Predefined global $. should call #to_int to convert the object to an Integer" # Expected main to equal 321
fails "Predefined global $. should call #to_int to convert the object to an Integer" # Mock 'good-value' expected to receive to_int("any_args") exactly 1 times but received it 0 times
fails "Proc#inspect for a proc created with Proc.new returns a description optionally including file and line number" # Expected "main" to match /^#<Proc:([^ ]*?)(@([^ ]*)\/to_s\.rb:4)?>$/
fails "Proc#inspect for a proc created with proc returns a description optionally including file and line number" # Expected "main" to match /^#<Proc:([^ ]*?)(@([^ ]*)\/to_s\.rb:16)?>$/
fails "Proc#to_s for a proc created with Proc.new returns a description optionally including file and line number" # Expected "main" to match /^#<Proc:([^ ]*?)(@([^ ]*)\/to_s\.rb:4)?>$/
fails "Proc#to_s for a proc created with proc returns a description optionally including file and line number" # Expected "main" to match /^#<Proc:([^ ]*?)(@([^ ]*)\/to_s\.rb:16)?>$/
fails "Random#bytes returns the same numeric output for a given huge seed across all implementations and platforms" # Expected "z­" to equal "_\u0091"
fails "Random#bytes returns the same numeric output for a given seed across all implementations and platforms" # Expected "ÚG" to equal "\u0014\\"
fails "Random.urandom raises an ArgumentError on a negative size" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns a String" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns a String of the length given as argument" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns a random binary String" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns an ASCII-8BIT String" # NoMethodError: undefined method `urandom' for Random
fails "Rational#* does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Rational#+ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Rational#- does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Rational#/ does not rescue exception raised in other#coerce" # TypeError: MockObject can't be coerce into Numeric
fails "Rational#<=> when passed an Object that responds to #coerce does not rescue exception raised in other#coerce" # ArgumentError: comparison of Rational with MockObject failed
fails "Rational#round with half option returns a Rational when the precision is greater than 0" # ArgumentError: [Rational#round] wrong number of arguments(2 for -1)
fails "Rational#round with half option returns an Integer when precision is not passed" # TypeError: not an Integer
fails "Rational#to_r fails when a BasicObject's to_r does not return a Rational" # NoMethodError: undefined method `nil?' for BasicObject
fails "Rational#to_r works when a BasicObject has to_r" # NoMethodError: undefined method `nil?' for BasicObject
fails "Set#=== is an alias for include?" # Expected #<Method: Set#=== (defined in Kernel in corelib/kernel.rb:14)> to equal #<Method: Set#include? (defined in Set in set.rb:125)>
fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false to equal true
fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false to equal true
fails "Set#=== returns true when self contains the passed Object" # Expected false to be true
fails "Set#=== returns true when self contains the passed Object" # Expected false to be true
fails "Set#compare_by_identity causes future comparisons on the receiver to be made by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1}>
fails "Set#compare_by_identity compares its members by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity does not call #hash on members" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity is idempotent and has no effect on an already compare_by_identity set" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity is not equal to set what does not compare by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1,2}>
fails "Set#compare_by_identity persists over #clones" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity persists over #dups" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity regards #clone'd objects as having different identities" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity regards #dup'd objects as having different identities" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity rehashes internally so that old members can be looked up" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1,2,3,4,5,6,7,8,9,10,main}>
fails "Set#compare_by_identity returns self" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity uses #equal? semantics, but doesn't actually call #equal? to determine identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity uses the semantics of BasicObject#equal? to determine members identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity? returns false by default" # NoMethodError: undefined method `compare_by_identity?' for #<Set: {}>
fails "Set#compare_by_identity? returns true once #compare_by_identity has been invoked on self" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#compare_by_identity? returns true when called multiple times on the same set" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
fails "Set#to_s correctly handles self-references" # Expected "main" to include "#<Set: {...}>"
fails "Set#to_s is an alias of inspect" # Expected #<Method: Set#to_s (defined in Object in corelib/main.rb:1)> to equal #<Method: Set#inspect (defined in Set in set.rb:36)>
fails "String#% faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "String#% faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "String#% flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
fails "String#% flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
fails "String#% flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "String#% flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "String#% flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
fails "String#% flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "String#% flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "String#% flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
fails "String#% flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "String#% float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "String#% float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "String#% float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
fails "String#% float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
fails "String#% float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
fails "String#% float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
fails "String#% float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
fails "String#% integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "String#% integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "String#% integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
fails "String#% other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
fails "String#% precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
fails "String#% precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
fails "String#% precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
fails "String#% raises an error if single % appears at the end" # Expected ArgumentError but no exception was raised ("%" was returned)
fails "String#% returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
fails "String#% returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
fails "String#% when key is missing from passed-in hash sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `receiver' for #<KeyError: key not found: "foo">:KeyError
fails "String#% when key is missing from passed-in hash sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `key' for #<KeyError: key not found: "foo">:KeyError
fails "String#% width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
fails "String#capitalize! capitalizes self in place for all of Unicode" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
fails "String#casecmp independent of case returns nil if other can't be converted to a string" # TypeError: no implicit conversion of MockObject into String
fails "String#casecmp? independent of case for UNICODE characters returns true when downcase(:fold) on unicode" # NoMethodError: undefined method `casecmp?' for "äöü":String
fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns false when they are unrelated" # NoMethodError: undefined method `casecmp?' for "Ã":String
fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns true when they are the same with normalized case" # NoMethodError: undefined method `casecmp?' for "Ã":String
fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns true when they have the same bytes" # NoMethodError: undefined method `casecmp?' for "Ã":String
fails "String#casecmp? independent of case returns false when not equal to other" # NoMethodError: undefined method `casecmp?' for "abc":String
fails "String#casecmp? independent of case returns nil if other can't be converted to a string" # NoMethodError: undefined method `casecmp?' for "abc":String
fails "String#casecmp? independent of case returns true when equal to other" # NoMethodError: undefined method `casecmp?' for "abc":String
fails "String#casecmp? independent of case tries to convert other to string using to_str" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
fails "String#casecmp? independent of case tries to convert other to string using to_str" # NoMethodError: undefined method `casecmp?' for "abc":String
fails "String#casecmp? independent of case when comparing a subclass instance returns false when not equal to other" # NoMethodError: undefined method `casecmp?' for "b":String
fails "String#casecmp? independent of case when comparing a subclass instance returns true when equal to other" # NoMethodError: undefined method `casecmp?' for "a":String
fails "String#codepoints is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
fails "String#delete_prefix calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
fails "String#delete_prefix calls to_str on its argument" # NoMethodError: undefined method `delete_prefix' for "hello":String
fails "String#delete_prefix doesn't set $~" # NoMethodError: undefined method `delete_prefix' for "hello":String
fails "String#delete_prefix returns a copy of the string, when the prefix isn't found" # NoMethodError: undefined method `delete_prefix' for "hello":String
fails "String#delete_prefix returns a copy of the string, with the given prefix removed" # NoMethodError: undefined method `delete_prefix' for "hello":String
fails "String#delete_prefix returns a subclass instance when called on a subclass instance" # NoMethodError: undefined method `delete_prefix' for "hello":String
fails "String#delete_prefix! calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
fails "String#delete_prefix! calls to_str on its argument" # NoMethodError: undefined method `delete_prefix!' for "hello":String
fails "String#delete_prefix! doesn't set $~" # NoMethodError: undefined method `delete_prefix!' for "hello":String
fails "String#delete_prefix! removes the found prefix" # NoMethodError: undefined method `delete_prefix!' for "hello":String
fails "String#delete_prefix! returns nil if no change is made" # NoMethodError: undefined method `delete_prefix!' for "hello":String
fails "String#delete_suffix calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
fails "String#delete_suffix calls to_str on its argument" # NoMethodError: undefined method `delete_suffix' for "hello":String
fails "String#delete_suffix doesn't set $~" # NoMethodError: undefined method `delete_suffix' for "hello":String
fails "String#delete_suffix returns a copy of the string, when the suffix isn't found" # NoMethodError: undefined method `delete_suffix' for "hello":String
fails "String#delete_suffix returns a copy of the string, with the given suffix removed" # NoMethodError: undefined method `delete_suffix' for "hello":String
fails "String#delete_suffix returns a subclass instance when called on a subclass instance" # NoMethodError: undefined method `delete_suffix' for "hello":String
fails "String#delete_suffix! calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
fails "String#delete_suffix! calls to_str on its argument" # NoMethodError: undefined method `delete_suffix!' for "hello":String
fails "String#delete_suffix! doesn't set $~" # NoMethodError: undefined method `delete_suffix!' for "hello":String
fails "String#delete_suffix! removes the found prefix" # NoMethodError: undefined method `delete_suffix!' for "hello":String
fails "String#delete_suffix! returns nil if no change is made" # NoMethodError: undefined method `delete_suffix!' for "hello":String
fails "String#downcase! modifies self in place for all of Unicode" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
fails "String#each_codepoint is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
fails "String#each_line when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
fails "String#include? with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
fails "String#intern raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
fails "String#intern returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
fails "String#intern returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # NoMethodError: undefined method `b' for "foobar":String
fails "String#intern returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
fails "String#intern returns a binary Symbol for a binary String containing non US-ASCII characters" # NoMethodError: undefined method `b' for "binarí":String
fails "String#lines when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
fails "String#lines when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
fails "String#start_with? sets Regexp.last_match if it returns true" # TypeError: no implicit conversion of Regexp into String
fails "String#start_with? supports regexps" # TypeError: no implicit conversion of Regexp into String
fails "String#start_with? supports regexps with ^ and $ modifiers" # TypeError: no implicit conversion of Regexp into String
fails "String#swapcase! modifies self in place for all of Unicode" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
fails "String#to_sym raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
fails "String#to_sym returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
fails "String#to_sym returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # NoMethodError: undefined method `b' for "foobar":String
fails "String#to_sym returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
fails "String#to_sym returns a binary Symbol for a binary String containing non US-ASCII characters" # NoMethodError: undefined method `b' for "binarí":String
fails "String#unpack1 returns the first value of #unpack" # NoMethodError: undefined method `unpack1' for "ABCD":String
fails "String#upcase! modifies self in place for all of Unicode" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
fails "String.new accepts a capacity argument" # ArgumentError: [String.new] wrong number of arguments(2 for -1)
fails "Struct.new keyword_init: false option behaves like it does without :keyword_init option" # NoMethodError: undefined method `new' for nil
fails "Struct.new raises a ArgumentError if passed a Hash with an unknown key" # TypeError: no implicit conversion of Hash into String
fails "The 'case'-construct tests with a string interpolated in a regexp" # Failed: This example is a failure
fails "The BEGIN keyword returns the top-level script's filename for __FILE__" # NoMethodError: undefined method `tmp' for main
fails "The if expression accepts multiple assignments in conditional expression with nil values" # NoMethodError: undefined method `ary' for main
fails "The if expression accepts multiple assignments in conditional expression with non-nil values" # NoMethodError: undefined method `ary' for main
fails "The rescue keyword inline form can be inlined" # Expected Infinity to equal 1
fails "The rescue keyword will execute an else block even without rescue and ensure" # Expected warning to match: /else without rescue is useless/ but got: ""
fails "The rescue keyword without rescue expression will not rescue exceptions except StandardError" # NameError: uninitialized constant SystemStackError
fails "The return keyword at top level file loading stops file loading and execution" # Exception: path.substr is not a function
fails "The return keyword at top level file loading stops file loading and execution" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level file requiring stops file loading and execution" # Exception: path.substr is not a function
fails "The return keyword at top level file requiring stops file loading and execution" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level return with argument does not affect exit status" # Exception: path.substr is not a function
fails "The return keyword at top level return with argument does not affect exit status" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level stops file execution" # Exception: path.substr is not a function
fails "The return keyword at top level stops file execution" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin fires ensure block before returning" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin fires ensure block before returning" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin fires ensure block before returning while loads file" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin fires ensure block before returning while loads file" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin is allowed in begin block" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin is allowed in begin block" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin is allowed in ensure block" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin is allowed in ensure block" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin is allowed in rescue block" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin is allowed in rescue block" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a begin swallows exception if returns in ensure block" # Exception: path.substr is not a function
fails "The return keyword at top level within a begin swallows exception if returns in ensure block" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a block is allowed" # Exception: path.substr is not a function
fails "The return keyword at top level within a block is allowed" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within a class raises a SyntaxError" # Exception: path.substr is not a function
fails "The return keyword at top level within a class raises a SyntaxError" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within if is allowed" # Exception: path.substr is not a function
fails "The return keyword at top level within if is allowed" # NoMethodError: undefined method `tmp' for main
fails "The return keyword at top level within while loop is allowed" # Exception: path.substr is not a function
fails "The return keyword at top level within while loop is allowed" # NoMethodError: undefined method `tmp' for main
fails "The super keyword when using keyword arguments passes default argument values to the parent" # Expected {} to equal {"b"=>"b"}
fails "The super keyword when using regular and keyword arguments passes default argument values to the parent" # Expected ["a", {}] to equal ["a", {"c"=>"c"}]
fails "The throw keyword raises an UncaughtThrowError if used to exit a thread" # NotImplementedError: Thread creation not available
fails "Time.at passed [Time, Numeric, format] :microsecond format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.at passed [Time, Numeric, format] :millisecond format traits second argument as milliseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.at passed [Time, Numeric, format] :nanosecond format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.at passed [Time, Numeric, format] :nsec format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.at passed [Time, Numeric, format] :usec format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.at passed [Time, Numeric, format] supports Float second argument" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
fails "Time.gm handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
fails "Time.new uses the local timezone" # Expected 10800 to equal -28800
fails "Time.now uses the local timezone" # Expected 10800 to equal -28800
fails "Time.utc handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
fails "UnboundMethod#to_s the String reflects that this is an UnboundMethod object" # Expected "main" to match /\bUnboundMethod\b/
fails "rescuing Interrupt raises an Interrupt when sent a signal SIGINT" # NoMethodError: undefined method `kill' for Process
fails "rescuing SignalException raises a SignalException when sent a signal" # NoMethodError: undefined method `kill' for Process
fails "top-level constant lookup on a class does not search Object after searching other scopes" # Expected NameError but no exception was raised (Hash was returned)

# Found manually, the errors comes from the `before(:all)` hook.
fails "Struct.new keyword_init: true option creates a class that accepts keyword arguments to initialize"
fails "Struct.new keyword_init: true option new class instantiation accepts arguments as hash as well"
fails "Struct.new keyword_init: true option new class instantiation raises ArgumentError when passed not declared keyword argument"
fails "Struct.new keyword_init: true option new class instantiation raises ArgumentError when passed a list of arguments"
fails "Struct.new keyword_init: false option behaves like it does without :keyword_init option"

# Found manually, these specs depend on some shared behavior
# env RUBYSPECS=true RANDOM_SEED=23905 PATTERN=spec/ruby/core/**/*_spec.rb bundle exec rake mspec_ruby_nodejs
fails "Kernel#sprintf faulty key raises a KeyError"
fails "Kernel.sprintf faulty key raises a KeyError"
fails "String#% faulty key raises a KeyError"
end
