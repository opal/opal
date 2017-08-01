opal_filter "2.4" do
  fails "Constant resolution within methods with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "Literal (A::X) constant resolution with dynamically assigned constants returns the updated value when a constant is reassigned" # Expected warning to match: /already initialized constant/
  fails "The break statement in a captured block from another thread raises a LocalJumpError when getting the value from another thread" # NameError: uninitialized constant Thread
  fails "The defined? keyword for a variable scoped constant returns 'constant' if the constant is defined in the scope of the class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for a variable scoped constant returns nil if the class scoped constant is not defined" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with '!' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The defined? keyword for an expression with logical connectives returns nil for an expression with 'not' and an unset class variable" # Expected warning to match: /class variable access from toplevel/
  fails "The for expression allows a constant as an iterator name" # Expected warning to match: /already initialized constant/
  fails "Literal Regexps matches against $_ (last input) in a conditional if no explicit matchee provided" # Expected warning to match: /regex literal in condition/
  fails "Literal Regexps supports conditional regular expressions with named capture groups" # Exception: named captures are not supported in javascript: "^(?<word>foo)?(?(<word>)(T)|(F))$"
  fails "Optional variable assignments using compunded constants with &&= assignments" # Expected warning to match: /already initialized constant/
  fails "Optional variable assignments using compunded constants with operator assignments" # Expected warning to match: /already initialized constant/
  fails "The predefined global constants includes FALSE" # Expected warning to match: /constant ::FALSE is deprecated/
  fails "The predefined global constants includes NIL" # Expected warning to match: /constant ::NIL is deprecated/
  fails "The predefined global constants includes TRUE" # Expected warning to match: /constant ::TRUE is deprecated/
  fails_badly "The while expression stops running body if interrupted by break with unless in a parenthesized attribute op-assign-or value"
  fails_badly "The while expression stops running body if interrupted by break with unless in a begin ... end attribute op-assign-or value"
  fails "Array#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "BasicObject#instance_eval evaluates string with given filename and negative linenumber" # Expected ["RuntimeError"] to equal ["b_file", "-98"]
  fails "Exception#backtrace returns an Array that can be updated" # Expected "RuntimeError" to equal "backtrace first"
  fails "FalseClass .allocate raises a TypeError" # Expected TypeError but no exception was raised (false was returned)
  fails "FalseClass .new is undefined" # Expected NoMethodError but no exception was raised (false was returned)
  fails "Fixnum .allocate raises a TypeError" # Exception: Maximum call stack size exceeded
  fails "Fixnum .new is undefined" # Exception: Maximum call stack size exceeded
  fails "Float .allocate raises a TypeError" # Expected TypeError but no exception was raised (#<Float:0x38f36> was returned)
  fails "Float .new is undefined" # Expected NoMethodError but no exception was raised (#<Float:0x38f2e> was returned)
  fails "Hash#compact keeps own pairs" # NoMethodError: undefined method `compact' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compact returns new object that rejects pair has nil value" # NoMethodError: undefined method `compact' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compact! on frozen instance keeps pairs and raises a RuntimeError" # NoMethodError: undefined method `compact!' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compact! rejects own pair has nil value" # NoMethodError: undefined method `compact!' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compact! returns self" # NoMethodError: undefined method `compact!' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compact! when each pair does not have nil value returns nil" # NoMethodError: undefined method `compact!' for {"truthy"=>true, "false"=>false, "nil"=>nil, nil=>true}
  fails "Hash#compare_by_identity gives different identity for string literals" # Expected [2] to equal [1, 2]
  fails "Hash#fetch gives precedence to the default block over the default argument when passed both" # Expected warning to match: /block supersedes default value argument/
  fails "Hash#inspect calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#inspect does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#inspect does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x30638>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#to_s calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#to_s does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#to_s does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x1b948>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#transform_values returns new hash" # NoMethodError: undefined method `transform_values' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values sets the result as transformed values with the given block" # NoMethodError: undefined method `transform_values' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values when no block is given returns a sized Enumerator" # NoMethodError: undefined method `transform_values' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values! on frozen instance keeps pairs and raises a RuntimeError" # NoMethodError: undefined method `transform_values!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values! on frozen instance when no block is given does not raise an exception" # NoMethodError: undefined method `transform_values!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values! returns self" # NoMethodError: undefined method `transform_values!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values! updates self as transformed values with the given block" # NoMethodError: undefined method `transform_values!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#transform_values! when no block is given returns a sized Enumerator" # NoMethodError: undefined method `transform_values!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash.[] ignores elements that are not arrays" # Expected warning to match: /ignoring wrong elements/
  fails "Kernel#=== does not call #object_id nor #equal? but still returns true for #== or #=== on the same object" # Mock '#<Object:0x37dd4>' expected to receive 'object_id' exactly 0 times but received it 2 times
  fails "Kernel#clone returns false for FalseClass" # TypeError: can't clone Boolean
  fails "Kernel#clone returns nil for NilClass" # TypeError: can't clone NilClass
  fails "Kernel#clone returns the same Integer for Integer" # TypeError: can't clone Number
  fails "Kernel#clone returns true for TrueClass" # TypeError: can't clone Boolean
  fails "Kernel#clone takes an option to copy freeze state or not" # ArgumentError: [Duplicate#clone] wrong number of arguments(1 for 0)
  fails "Kernel#dup returns false for FalseClass" # TypeError: can't dup Boolean
  fails "Kernel#dup returns nil for NilClass" # TypeError: can't dup NilClass
  fails "Kernel#dup returns the same Integer for Integer" # TypeError: can't dup Number
  fails "Kernel#dup returns true for TrueClass" # TypeError: can't dup Boolean
  fails "Kernel#eval evaluates string with given filename and negative linenumber" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Kernel#singleton_method find a method defined on the singleton class" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d20>
  fails "Kernel#singleton_method only looks at singleton methods and not at methods in the class" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method raises a NameError if there is no such method" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method returns a Method which can be called" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d1a>
  fails "Kernel.String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Marshal.dump with a Range dumps a Range with extra instance variables" # Expected nil to equal 42
  fails "MatchData#named_captures prefers later captures" # Exception: named captures are not supported in javascript: "^(?<a>.)(?<b>.)(?<b>.)(?<a>.)$"
  fails "MatchData#named_captures returns a Hash that has captured name and the matched string pairs" # Exception: named captures are not supported in javascript: "(?<a>.)(?<b>.)?"
  fails "MatchData#values_at slices captures with the given names" # Exception: named captures are not supported in javascript: "(?<a>.)(?<b>.)(?<c>.)"
  fails "MatchData#values_at takes names and indices" # Exception: named captures are not supported in javascript: "^(?<a>.)(?<b>.)$"
  fails "Math.log2 returns the natural logarithm of the argument" # Expected Infinity to equal 10001
  fails "Module#alias_method creates methods that are == to eachother" # Expected #<Method: #<Class:0x3ee54>#uno (defined in #<Class:0x3ee54> in ruby/core/module/fixtures/classes.rb:203)> to equal #<Method: #<Class:0x3ee54>#public_one (defined in ModuleSpecs::Aliasing in ruby/core/module/fixtures/classes.rb:203)>
  fails "Module#attr with a boolean argument emits a warning when $VERBOSE is true" # Expected warning to match: /boolean argument is obsoleted/
  fails "Module#const_get with dynamically assigned constants returns the updated value of a constant" # Expected warning to match: /already initialized constant/
  fails "Module#include doesn't accept no-arguments" # Expected ArgumentError but no exception was raised (#<Module:0x4fbac> was returned)
  fails "Module#prepend doesn't accept no-arguments" # NoMethodError: undefined method `prepend' for #<Module:0x4eda0>
  fails "NilClass .allocate raises a TypeError" # Expected TypeError but no exception was raised (nil was returned)
  fails "NilClass .new is undefined" # Expected NoMethodError but no exception was raised (nil was returned)
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size should return infinity_value when limit is nil" # ArgumentError: limit must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when stop is nil returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with keyword arguments when no block is given returned Enumerator size when stop is not passed returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with keyword arguments when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with keyword arguments when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when stop is nil returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with mixed arguments when no block is given returned Enumerator size when stop is not passed returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with mixed arguments when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with mixed arguments when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when stop is nil returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with positional args when no block is given returned Enumerator size when stop is not passed returns infinity_value" # ArgumentError: limit must be a number
  fails "Numeric#step with positional args when step is a String with self and stop as Fixnums raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when step is a String with self and stop as Fixnums raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when step is a String with self and stop as Floats raises an TypeError when step is a numeric representation" # ArgumentError: step must be a number
  fails "Numeric#step with positional args when step is a String with self and stop as Floats raises an TypeError with step as an alphanumeric string" # ArgumentError: step must be a number
  fails "Regexp#match? returns false when does not match the given value" # NoMethodError: undefined method `match?' for /STRING/:Regexp
  fails "Regexp#match? returns false when given nil" # NoMethodError: undefined method `match?' for /./:Regexp
  fails "Regexp#match? takes matching position as the 2nd argument" # NoMethodError: undefined method `match?' for /str/i:Regexp
  fails "Regexp#match? when matches the given value returns true but does not set Regexp.last_match" # NoMethodError: undefined method `match?' for /string/i:Regexp
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/
  fails "Regexp.new given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/
  fails "String#concat concatenates the initial value when given arguments contain 2 self" # NoMethodError: undefined method `concat' for "hello":String
  fails "String#concat returns self when given no arguments" # NoMethodError: undefined method `concat' for "hello":String
  fails "String#concat takes multiple arguments" # NoMethodError: undefined method `concat' for "hello ":String
  fails "String#match? returns false when does not match the given regex" # NoMethodError: undefined method `match?' for "string":String
  fails "String#match? takes matching position as the 2nd argument" # NoMethodError: undefined method `match?' for "string":String
  fails "String#match? when matches the given regex returns true but does not set Regexp.last_match" # NoMethodError: undefined method `match?' for "string":String
  fails "String#prepend prepends the initial value when given arguments contain 2 self" # NoMethodError: undefined method `prepend' for "hello":String
  fails "String#prepend returns self when given no arguments" # NoMethodError: undefined method `prepend' for "hello":String
  fails "String#prepend takes multiple arguments" # NoMethodError: undefined method `prepend' for " world":String
  fails "String#slice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#split with Regexp applies the limit to the number of split substrings, without counting captures" # Expected ["a", "aBa"] to equal ["a", "B", "", "", "aBa"]
  fails "String#swapcase works for all of Unicode" # Expected "äÖü" to equal "ÄöÜ"
  fails "Struct.new overwrites previously defined constants with string as first argument" # Expected warning to match: /redefining constant/
  fails "Time#- tracks microseconds from a Rational" # Expected 0 to equal 123456
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#gmtime on a frozen time raises a RuntimeError if the time is not UTC" # Expected RuntimeError but no exception was raised (2017-07-28 12:27:07 UTC was returned)
  fails "Time#localtime on a frozen time does not raise an error if already in the right time zone" # NoMethodError: undefined method `localtime' for 2017-07-28 15:26:55 +0300:Time
  fails "Time#localtime on a frozen time raises a RuntimeError if the time has a different time zone" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC:Time
  fails "Time#succ returns a new instance" # Expected warning to match: /Time#succ is obsolete/
  fails "Time#succ returns a new time one second later than time" # Expected warning to match: /Time#succ is obsolete/
  fails "TrueClass .allocate raises a TypeError" # Expected TypeError but no exception was raised (false was returned)
  fails "TrueClass .new is undefined" # Expected NoMethodError but no exception was raised (false was returned)
  fails "UncaughtThrowError#tag returns the object thrown" # NoMethodError: undefined method `tag' for #<UncaughtThrowError: uncaught throw "abc">:UncaughtThrowError
  fails "BigDecimal#to_r returns a Rational" # NoMethodError: undefined method `to_r' for 3.14159
  fails "BigDecimal#to_r returns a Rational with bignum values" # NoMethodError: undefined method `to_r' for 3.141592653589793238462643
  fails "BigDecimal.new raises ArgumentError for invalid strings" # Exception: new BigNumber() not a number: ruby
  fails "Date#strftime should be able to show the number of seconds since the unix epoch for a date" # Expected "954964800" to equal "954979200"
  fails "String#byteslice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "StringScanner#peek returns at most the specified number of bytes from the current position" # Expected "ét" to equal "é"
  fails "StringScanner#peep returns at most the specified number of bytes from the current position" # NoMethodError: undefined method `peep' for #<StringScanner:0x590>
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#utc on a frozen time raises a RuntimeError if the time is not UTC" # Expected RuntimeError but no exception was raised (2017-07-28 12:28:25 UTC was returned)
  fails "String#[] raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
end
