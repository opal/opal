# NOTE: run bin/format-filters after changing this file
opal_filter "Array" do
  fails "Array#== compares with an equivalent Array-like object using #to_ary" # Expected false to be true
  fails "Array#== returns true for [NaN] == [NaN] because Array#== first checks with #equal? and NaN.equal?(NaN) is true" # Expected [NaN] == [NaN] to be truthy but was false
  fails "Array#[] can be sliced with Enumerator::ArithmeticSequence has endless range with start outside of array's bounds" # Expected [] == nil to be truthy but was false
  fails "Array#[] can be sliced with Enumerator::ArithmeticSequence has range with bounds outside of array" # Expected RangeError but no exception was raised ([0, 2, 4] was returned)
  fails "Array#[] raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#[] raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#[] raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#all? ignores the block if there is an argument" # Expected warning to match: /given block not used/ but got: ""
  fails "Array#any? when given a pattern argument ignores the block if there is an argument" # Expected warning to match: /given block not used/ but got: ""
  fails "Array#drop raises a TypeError when the passed argument isn't an integer and #to_int returns non-Integer" # Expected TypeError but no exception was raised ([1, 2] was returned)
  fails "Array#fill with (filler, index, length) raises a TypeError when the length is not numeric" # Expected TypeError (/no implicit conversion of Symbol into Integer/) but got: TypeError (no implicit conversion of String into Integer)
  fails "Array#fill with (filler, range) works with endless ranges" # Expected [1, 2, 3, 4] == [1, 2, 3, "x"] to be truthy but was false
  fails "Array#filter returns a new array of elements for which block is true" # Expected [1] == [1, 4, 6] to be truthy but was false
  fails "Array#flatten does not call #to_ary on elements beyond the given level" # Mock '1' expected to receive to_ary("any_args") exactly 0 times but received it 1 times
  fails "Array#flatten performs respond_to? and method_missing-aware checks when coercing elements to array" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x2698>
  fails "Array#flatten with a non-Array object in the Array calls #method_missing if defined" # Expected [#<MockObject:0x2730 @name="Array#flatten", @null=nil>] == [1, 2, 3] to be truthy but was false
  fails "Array#initialize with no arguments does not use the given block" # Expected warning to match: /ruby\/core\/array\/initialize_spec.rb:57: warning: given block not used/ but got: ""
  fails "Array#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#intersect? tries to convert the passed argument to an Array using #to_ary" # Expected false == true to be truthy but was false
  fails "Array#none? ignores the block if there is an argument" # Expected warning to match: /given block not used/ but got: ""
  fails "Array#one? ignores the block if there is an argument" # Expected warning to match: /given block not used/ but got: ""
  fails "Array#pack with format 'A' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'A' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'C' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'C' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'L' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'L' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'U' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'U' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'a' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'a' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'c' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'c' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'l' ignores comments in the format string" # RuntimeError: Unsupported pack directive "m" (no chunk reader defined)
  fails "Array#pack with format 'l' warns that a directive is unknown" # Expected warning to match: /unknown pack directive 'R'/ but got: ""
  fails "Array#pack with format 'u' calls #to_str to convert an Object to a String" # Mock 'pack u string' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'u' ignores comments in the format string" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' warns that a directive is unknown" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' will not implicitly convert a number to a string" # Expected TypeError but got: RuntimeError (Unsupported pack directive "u" (no chunk reader defined))
  fails "Array#partition returns in the left array values for which the block evaluates to true" # Expected [[0], [1, 2, 3, 4, 5]] == [[0, 1, 2], [3, 4, 5]] to be truthy but was false
  fails "Array#product returns converted arguments using :method_missing" # TypeError: no implicit conversion of ArraySpecs::ArrayMethodMissing into Array
  fails "Array#rassoc calls elem == obj on the second element of each contained array" # Expected [1, "foobar"] == [2, #<MockObject:0x4a6b4 @name="foobar", @null=nil>] to be truthy but was false
  fails "Array#rassoc does not check the last element in each contained but specifically the second" # Expected [1, "foobar", #<MockObject:0x4a37e @name="foobar", @null=nil>] == [2, #<MockObject:0x4a37e @name="foobar", @null=nil>, 1] to be truthy but was false
  fails "Array#sample returns nil for an empty array when called without n and a Random is given" # ArgumentError: invalid argument - 0
  fails "Array#select returns a new array of elements for which block is true" # Expected [1] == [1, 4, 6] to be truthy but was false
  fails "Array#shuffle! matches CRuby with random:" # Expected [7, 4, 5, 0, 3, 9, 2, 8, 10, 1, 6] == [2, 6, 8, 5, 7, 10, 3, 1, 0, 4, 9] to be truthy but was false
  fails "Array#shuffle! matches CRuby with srand" # Expected ["d", "j", "g", "f", "i", "e", "c", "k", "b", "h", "a"] == ["a", "e", "f", "h", "i", "j", "d", "b", "g", "k", "c"] to be truthy but was false
  fails "Array#slice can be sliced with Enumerator::ArithmeticSequence has endless range with start outside of array's bounds" # Expected [] == nil to be truthy but was false
  fails "Array#slice can be sliced with Enumerator::ArithmeticSequence has range with bounds outside of array" # Expected RangeError but no exception was raised ([0, 2, 4] was returned)
  fails "Array#slice raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#slice raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#slice raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#sum calls + on the init value" # NoMethodError: undefined method `-' for #<MockObject:0x7f7c2 @name="b" @null=nil>
  fails "Array#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#zip raises TypeError when some argument isn't Array and doesn't respond to #to_ary and #to_enum" # Expected TypeError (wrong argument type Object (must respond to :each)) but got: NoMethodError (undefined method `each' for #<Object:0x6273e>)
  fails "Array.new with no arguments does not use the given block" # Expected warning to match: /warning: given block not used/ but got: ""
  fails "Array.try_convert sends #to_ary to the argument and raises TypeError if it's not a kind of Array" # Expected TypeError (can't convert MockObject to Array (MockObject#to_ary gives Object)) but got: TypeError (can't convert MockObject into Array (MockObject#to_ary gives Object))
end
