# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Array" do
  fails "Array#[] raises a RangeError when the length is out of range of Fixnum" # Expected RangeError but no exception was raised ([2, 3, 4, 5, 6] was returned)
  fails "Array#[] raises a RangeError when the start index is out of range of Fixnum" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#eql? returns false if any corresponding elements are not #eql?" # Expected [1, 2, 3, 4] not to have same value or type as [1, 2, 3, 4]
  fails "Array#fill does not replicate the filler" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "Array#first raises a RangeError when count is a Bignum" # Expected RangeError but no exception was raised ([] was returned)
  fails "Array#hash calls to_int on result of calling hash on each element" # Expected "A,#<MockObject:0x876aa>" == "A,3" to be truthy but was false
  fails "Array#hash returns the same fixnum for arrays with the same content" # Expected "A" (String) to be an instance of Integer
  fails "Array#initialize is private" # Expected Array to have private instance method 'initialize' but it does not
  fails "Array#inspect represents a recursive element with '[...]'" # Expected "[1, \"two\", 3, [...], [...], [...], [...], [...]]" == "[1, \"two\", 3.0, [...], [...], [...], [...], [...]]" to be truthy but was false
  fails "Array#inspect with encoding does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive inspect("any_args") exactly 1 times but received it 0 times
  fails "Array#inspect with encoding returns a US-ASCII string for an empty Array" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Array#inspect with encoding use US-ASCII encoding if the default external encoding is not ascii compatible" # ArgumentError: unknown encoding name - UTF-32
  fails "Array#join fails for arrays with incompatibly-encoded strings" # Expected EncodingError but no exception was raised ("barbázÿ" was returned)
  fails "Array#join returns a US-ASCII string for an empty Array" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Array#join uses the first encoding when other strings are compatible" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Array#slice raises a RangeError when the length is out of range of Fixnum" # Expected RangeError but no exception was raised ([2, 3, 4, 5, 6] was returned)
  fails "Array#slice raises a RangeError when the start index is out of range of Fixnum" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#to_s represents a recursive element with '[...]'" # Expected "[1, \"two\", 3, [...], [...], [...], [...], [...]]" == "[1, \"two\", 3.0, [...], [...], [...], [...], [...]]" to be truthy but was false
  fails "Array#to_s with encoding does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive inspect("any_args") exactly 1 times but received it 0 times
  fails "Array#to_s with encoding returns a US-ASCII string for an empty Array" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Array#to_s with encoding use US-ASCII encoding if the default external encoding is not ascii compatible" # ArgumentError: unknown encoding name - UTF-32
  fails "Array#uniq uses eql? semantics" # Expected [1] == [1, 1] to be truthy but was false
end
