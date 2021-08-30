# NOTE: run bin/format-filters after changing this file
opal_filter "Array" do
  fails "Array#== compares with an equivalent Array-like object using #to_ary" # Expected false to be true
  fails "Array#== returns true for [NaN] == [NaN] because Array#== first checks with #equal? and NaN.equal?(NaN) is true" # Expected [NaN] to equal [NaN]
  fails "Array#[] can accept beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[] can accept endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[] can accept nil...nil ranges" # TypeError: no implicit conversion of NilClass into Integer
  fails "Array#[] raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#[] raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#[] raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#[]= with [..n] and [...n] inserts at the beginning if n < negative the array size" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [..n] and [...n] just sets the section defined by range to nil even if the rhs is nil" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [..n] and [...n] just sets the section defined by range to nil if n < 0 and the rhs is nil" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [..n] and [...n] replaces everything if n > the array size" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [..n] and [...n] replaces the section defined by range" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [..n] and [...n] replaces the section if n < 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [m..] inserts at the end if m > the array size" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [m..] just sets the section defined by range to nil even if the rhs is nil" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [m..] just sets the section defined by range to nil if m and n < 0 and the rhs is nil" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [m..] replaces the section defined by range" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#[]= with [m..] replaces the section if m and n < 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#drop raises a TypeError when the passed argument can't be coerced to Integer" # Expected TypeError but no exception was raised ([1, 2] was returned)
  fails "Array#drop raises a TypeError when the passed argument isn't an integer and #to_int returns non-Integer" # Expected TypeError but no exception was raised ([1, 2] was returned)
  fails "Array#drop tries to convert the passed argument to an Integer using #to_int" # Expected [1, 2, 3] == [3] to be truthy but was false
  fails "Array#each does not yield elements deleted from the end of the array" # Expected [2, 3, nil] to equal [2, 3]
  fails "Array#each yields elements added to the end of the array by the block" # Expected [2] to equal [2, 0, 0]
  fails "Array#fill with (filler, range) works with beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#fill with (filler, range) works with endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#filter returns a new array of elements for which block is true" # NoMethodError: undefined method `filter' for [1, 3, 4, 5, 6, 9]
  fails "Array#flatten does not call #to_ary on elements beyond the given level"
  fails "Array#flatten performs respond_to? and method_missing-aware checks when coercing elements to array"
  fails "Array#flatten with a non-Array object in the Array calls #method_missing if defined"
  fails "Array#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#partition returns in the left array values for which the block evaluates to true"
  fails "Array#rassoc calls elem == obj on the second element of each contained array"
  fails "Array#rassoc does not check the last element in each contained but specifically the second" # Expected [1, "foobar", #<MockObject:0x4ef6e>] to equal [2, #<MockObject:0x4ef6e>, 1]
  fails "Array#select returns a new array of elements for which block is true"
  fails "Array#slice can accept beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#slice can accept endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#slice can accept nil...nil ranges" # TypeError: no implicit conversion of NilClass into Integer
  fails "Array#slice raises TypeError if to_int returns non-integer" # Expected TypeError but no exception was raised ([1, 2, 3, 4] was returned)
  fails "Array#slice raises a RangeError if passed a range with a bound that is too large" # Expected RangeError but no exception was raised (nil was returned)
  fails "Array#slice raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ([2, 3] was returned)
  fails "Array#slice! works with beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#slice! works with endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject at 0/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Array#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String at 0/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Array#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Array#uniq! properly handles recursive arrays"
  fails "Array#values_at works when given beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Array#values_at works when given endless ranges" # Opal::SyntaxError: undefined method `type' for nil
end
