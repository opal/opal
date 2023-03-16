# NOTE: run bin/format-filters after changing this file
opal_filter "Array" do
  fails "Array#== compares with an equivalent Array-like object using #to_ary" # Expected false to be true
  fails "Array#== returns true for [NaN] == [NaN] because Array#== first checks with #equal? and NaN.equal?(NaN) is true" # Expected [NaN] == [NaN] to be truthy but was false
  fails "Array#[] can be sliced with Enumerator::ArithmeticSequence has endless range with start outside of array's bounds" # Expected [] == nil to be truthy but was false
  fails "Array#[] can be sliced with Enumerator::ArithmeticSequence has range with bounds outside of array" # Expected RangeError but no exception was raised ([0, 2, 4] was returned)
  fails "Array#[] raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#[] raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#[] raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#drop raises a TypeError when the passed argument isn't an integer and #to_int returns non-Integer" # Expected TypeError but no exception was raised ([1, 2] was returned)
  fails "Array#each does not yield elements deleted from the end of the array" # Expected [2, 3, nil] == [2, 3] to be truthy but was false
  fails "Array#each yields each element to the block even if the array is changed during iteration" # Expected [1, 2, 3, 4, 5] == [1, 2, 3, 4, 5, 7, 9] to be truthy but was false
  fails "Array#each yields elements added to the end of the array by the block" # Expected [2] == [2, 0, 0] to be truthy but was false
  fails "Array#each yields elements based on an internal index" # NoMethodError: undefined method `even?' for nil
  fails "Array#each yields only elements that are still in the array" # NoMethodError: undefined method `even?' for nil
  fails "Array#each yields the same element multiple times if inserting while iterating" # Expected [1, 1] == [1, 1, 2] to be truthy but was false
  fails "Array#fill with (filler, index, length) raises a TypeError when the length is not numeric" # Expected TypeError (/no implicit conversion of Symbol into Integer/) but got: TypeError (no implicit conversion of String into Integer)
  fails "Array#fill with (filler, range) works with endless ranges" # Expected [1, 2, 3, 4] == [1, 2, 3, "x"] to be truthy but was false
  fails "Array#filter returns a new array of elements for which block is true" # Expected [1] == [1, 4, 6] to be truthy but was false
  fails "Array#flatten does not call #to_ary on elements beyond the given level" # Mock '1' expected to receive to_ary("any_args") exactly 0 times but received it 1 times
  fails "Array#flatten performs respond_to? and method_missing-aware checks when coercing elements to array" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x2698>
  fails "Array#flatten with a non-Array object in the Array calls #method_missing if defined" # Expected [#<MockObject:0x2730 @name="Array#flatten", @null=nil>] == [1, 2, 3] to be truthy but was false
  fails "Array#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#pack with format 'u' calls #to_str to convert an Object to a String" # Mock 'pack u string' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'u' will not implicitly convert a number to a string" # Expected TypeError but got: RuntimeError (Unsupported pack directive "u" (no chunk reader defined))
  fails "Array#partition returns in the left array values for which the block evaluates to true" # Expected [[0], [1, 2, 3, 4, 5]] == [[0, 1, 2], [3, 4, 5]] to be truthy but was false
  fails "Array#rassoc calls elem == obj on the second element of each contained array" # Expected [1, "foobar"] == [2, #<MockObject:0x4a6b4 @name="foobar", @null=nil>] to be truthy but was false
  fails "Array#rassoc does not check the last element in each contained but specifically the second" # Expected [1, "foobar", #<MockObject:0x4a37e @name="foobar", @null=nil>] == [2, #<MockObject:0x4a37e @name="foobar", @null=nil>, 1] to be truthy but was false
  fails "Array#sample returns nil for an empty array when called without n and a Random is given" # ArgumentError: invalid argument - 0
  fails "Array#select returns a new array of elements for which block is true" # Expected [1] == [1, 4, 6] to be truthy but was false
  fails "Array#slice can be sliced with Enumerator::ArithmeticSequence has endless range with start outside of array's bounds" # Expected [] == nil to be truthy but was false
  fails "Array#slice can be sliced with Enumerator::ArithmeticSequence has range with bounds outside of array" # Expected RangeError but no exception was raised ([0, 2, 4] was returned)
  fails "Array#slice raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#slice raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#slice raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject at 0/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Array#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String at 0/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Array#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#uniq! properly handles recursive arrays" # Expected [1, "two", 3, [...], [...], [...]] == [1, "two", 3, [1, "two", 3, [...], [...], [...]]] to be truthy but was false
end
