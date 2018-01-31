opal_filter "2.5" do

fails "A Symbol literal with invalid bytes raises an EncodingError at parse time" # Actually passes, the error comes from the difference between MRI's opal and compiled opal-parser
fails "A method assigns local variables from method parameters for definition \n    def m(a, b = nil, c = nil, d, e: nil, **f)\n      [a, b, c, d, e, f]\n    end" # Exception: Cannot read property '$$is_array' of undefined
fails "An ensure block inside 'do end' block is executed even when a symbol is thrown in it's corresponding begin block" # Expected ["begin", "rescue", "ensure"] to equal ["begin", "ensure"]
fails "An ensure block inside a class is executed even when a symbol is thrown" # Expected ["class", "rescue", "ensure"] to equal ["class", "ensure"]
fails "Array#== compares with an equivalent Array-like object using #to_ary" # Expected false to be true
fails "Array#== compares with an equivalent Array-like object using #to_ary" # Mock 'array-like' expected to receive respond_to?("to_ary") at least 1 times but received it 0 times
fails "Array#inspect does not call #to_str on the object returned from #inspect when it is not a String" # Expected "[main]" to match /^\[#<MockObject:0x[0-9a-f]+>\]$/
fails "Array#to_s does not call #to_str on the object returned from #inspect when it is not a String" # Expected "[main]" to match /^\[#<MockObject:0x[0-9a-f]+>\]$/
fails "BigDecimal.limit picks the specified precision over global limit" # Expected 0.888 to equal 0.89
fails "BigDecimal.limit uses the global limit if no precision is specified" # Expected 0.888 to equal 0.9
fails "Constant resolution within methods with ||= assigns a global constant if previously undefined" # NameError: uninitialized constant OpAssignGlobalUndefined
fails "Constant resolution within methods with ||= assigns a scoped constant if previously undefined" # NameError: uninitialized constant ConstantSpecs::OpAssignUndefined
fails "Enumerable#none? given a pattern argument returns true iff none match that pattern" # Works, but depends on the difference between Integer and Float
fails "Enumerable#uniq compares elements with matching hash codes with #eql?" # Depends on tainting
fails "Enumerable#uniq uses eql? semantics" # Depends on the difference between Integer and Float
fails "Float#round returns different rounded values depending on the half option" # TypeError: no implicit conversion of Hash into Integer
fails "Global variable $VERBOSE converts truthy values to true" # Expected 1 to be true
fails "Integer is the class of both small and large integers" # Expected Number to be identical to Integer
fails "Integer#& fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#** fixnum raises a ZeroDivisionError for 0 ** -1" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ fixnum coerces fixnum and return self divided by other" # Expected 1.0842021724855044e-19 to equal 0
fails "Integer#/ fixnum raises a ZeroDivisionError if the given argument is zero and not a Float" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
fails "Integer#/ fixnum returns result the same class as the argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum returns self divided by the given argument" # Expected 1.5 to equal 1
fails "Integer#/ fixnum supports dividing negative numbers" # Expected -0.1 to equal -1
fails "Integer#<< (with n << m) fixnum returns -1 when n < 0, m < 0 and n > -(2**-m)" # Expected -7 to equal -1
fails "Integer#<< (with n << m) fixnum returns 0 when n > 0, m < 0 and n < 2**-m" # Expected 7 to equal 0
fails "Integer#>> (with n >> m) fixnum returns -1 when n < 0, m > 0 and n > -(2**m)" # Expected -7 to equal -1
fails "Integer#>> (with n >> m) fixnum returns 0 when n > 0, m > 0 and n < 2**m" # Expected 7 to equal 0
fails "Integer#^ fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (0 was returned)
fails "Integer#^ fixnum returns self bitwise EXCLUSIVE OR other" # Expected 5 to equal 9223372041149743000
fails "Integer#chr with an encoding argument raises a RangeError if self is too large" # Expected RangeError but no exception was raised ("膀" was returned)
fails "Integer#coerce fixnum raises a TypeError when given an Object that does not respond to #to_f" # depends on the difference between string/symbol
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # Mock 'x' expected to receive div(main) exactly 1 times but received it 0 times
fails "Integer#div fixnum calls #coerce and #div if argument responds to #coerce" # NoMethodError: undefined method `/' for main
fails "Integer#divmod fixnum raises a TypeError when given a non-Integer" # NoMethodError: undefined method `nan?' for main
fails "Integer#odd? fixnum returns true when self is an odd number" # Expected false to be true
fails "Integer#remainder fixnum keeps sign of self" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum means x-y*(x/y).truncate" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum raises TypeError if passed non-numeric argument" # NoMethodError: undefined method `remainder' for 5
fails "Integer#remainder fixnum returns the remainder of dividing self by other" # NoMethodError: undefined method `remainder' for 5
fails "Integer#round returns different rounded values depending on the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#round returns itself if passed a positive precision and the half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
fails "Integer#| fixnum raises a TypeError when passed a Float" # Expected TypeError but no exception was raised (3 was returned)
fails "Integer#| fixnum returns self bitwise OR other" # Expected 65535 to equal 9223372036854841000
fails "Integer.sqrt accepts any argument that can be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `arguments' for main
fails "Integer.sqrt converts the argument with #to_int" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a Math::DomainError if the argument is negative" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt raises a TypeError if the argument cannot be coerced to Integer" # NoMethodError: undefined method `sqrt' for Integer
fails "Integer.sqrt returns an integer" # NoMethodError: undefined method `sqrt' for Integer
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
fails "Random.urandom returns a String of the length given as argument" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns a String" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns a random binary String" # NoMethodError: undefined method `urandom' for Random
fails "Random.urandom returns an ASCII-8BIT String" # NoMethodError: undefined method `urandom' for Random
fails "Rational#round with half option returns a Rational when the precision is greater than 0" # ArgumentError: [Rational#round] wrong number of arguments(2 for -1)
fails "Rational#round with half option returns an Integer when precision is not passed" # TypeError: not an Integer
fails "Rational#to_r fails when a BasicObject's to_r does not return a Rational" # NoMethodError: undefined method `nil?' for BasicObject
fails "Rational#to_r works when a BasicObject has to_r" # NoMethodError: undefined method `nil?' for BasicObject
fails "Set#=== is an alias for include?" # Expected #<Method: Set#=== (defined in Kernel in corelib/kernel.rb:14)> to equal #<Method: Set#include? (defined in Set in set.rb:125)>
fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false to equal true
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
fails "String#start_with? sets Regexp.last_match if it returns true" # TypeError: no implicit conversion of Regexp into String
fails "String#start_with? supports regexps with ^ and $ modifiers" # TypeError: no implicit conversion of Regexp into String
fails "String#start_with? supports regexps" # TypeError: no implicit conversion of Regexp into String
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
fails "The if expression accepts multiple assignments in conditional expression with nil values" # NoMethodError: undefined method `ary' for main
fails "The if expression accepts multiple assignments in conditional expression with non-nil values" # NoMethodError: undefined method `ary' for main
fails "The rescue keyword inline form can be inlined" # Expected Infinity to equal 1
fails "The rescue keyword will execute an else block even without rescue and ensure" # Expected warning to match: /else without rescue is useless/ but got: ""
fails "The rescue keyword without rescue expression will not rescue exceptions except StandardError" # NameError: uninitialized constant SystemStackError
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
fails "top-level constant lookup on a class does not search Object after searching other scopes" # Expected NameError but no exception was raised (Hash was returned)


# The following specs depend on some shared behavior
fails "Kernel#sprintf faulty key raises a KeyError"
fails "Kernel.sprintf faulty key raises a KeyError"
fails "String#% faulty key raises a KeyError"

end
