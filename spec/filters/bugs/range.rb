# NOTE: run bin/format-filters after changing this file
opal_filter "Range" do
  fails "Range#% produces an arithmetic sequence with a percent sign in #inspect" # NoMethodError: undefined method `%' for 1..10
  fails "Range#% works as a Range#step" # NoMethodError: undefined method `%' for 1..10
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns a boundary element if appropriate" # NoMethodError: undefined method `prev_float' for 3
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0 (small numbers)" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers works with infinity bounds" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with Float values with a block returning true or false returns a boundary element if appropriate" # NoMethodError: undefined method `prev_float' for 3
  fails "Range#bsearch with Float values with a block returning true or false returns minimum element if the block returns true for every element" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns false for every element" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns nil for every element" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning true or false returns the smallest element for which block returns true" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning true or false works with infinity bounds" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers works with infinity bounds" # NoMethodError: undefined method `inf' for #<MSpecEnv:0x1b536>
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns nil if the block returns nil for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns nil if the block returns true for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns the smallest element for which block returns true" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false works with infinity bounds" # NoMethodError: undefined method `inf' for #<MSpecEnv:0x1b536>
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers accepts Float::INFINITY from the block" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with beginless ranges and Integer values with a block returning true or false returns the smallest element for which block returns true" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers works with infinity bounds" # NoMethodError: undefined method `inf' for #<MSpecEnv:0x1b536>
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns minimum element if the block returns true for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns nil if the block returns false for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns nil if the block returns nil for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns the smallest element for which block returns true" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false works with infinity bounds" # NoMethodError: undefined method `inf' for #<MSpecEnv:0x1b536>
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers accepts -Float::INFINITY from the block" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning true or false returns minimum element if the block returns true for every element" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#bsearch with endless ranges and Integer values with a block returning true or false returns the smallest element for which block returns true" # NotImplementedError: Can't #bsearch an infinite range
  fails "Range#cover? range argument accepts range argument" # Expected false to be true
  fails "Range#cover? range argument honors exclusion of right boundary (:exclude_end option)" # Expected false to be true
  fails "Range#cover? range argument supports boundaries of different comparable types" # Expected false to be true
  fails "Range#each raises a TypeError if the first element is a Time object" # Expected TypeError but no exception was raised (2021-01-02 22:49:45 +0100..2021-01-02 22:49:46 +0100 was returned)
  fails "Range#eql? returns false if the endpoints are not eql?" # Expected 0..1 not to have same value or type as 0..1
  fails "Range#first raises a TypeError if #to_int does not return an Integer" # Expected TypeError but no exception was raised ([2] was returned)
  fails "Range#hash generates an Integer for the hash value" # Expected "A,1,1,0" (String) to be an instance of Integer
  fails "Range#include? on string elements returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when excluded end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#initialize raises a FrozenError if called on an already initialized Range" # Expected FrozenError but got: NameError ('initialize' called twice)
  fails "Range#inspect works for nil ... nil ranges" # Expected ".." == "nil..nil" to be truthy but was false
  fails "Range#last raises a TypeError if #to_int does not return an Integer" # Expected TypeError but no exception was raised ([3] was returned)
  fails "Range#max given a block calls #> and #< on the return value of the block" # Mock 'obj' expected to receive >("any_args") exactly 2 times but received it 0 times
  fails "Range#max given a block raises RangeError when called with custom comparison method on an beginless range" # Expected RangeError but got: TypeError (can't iterate from NilClass)
  fails "Range#max raises TypeError when called on a Time...Time(excluded end point)" # Expected TypeError but no exception was raised (1609624185562 was returned)
  fails "Range#max raises TypeError when called on an exclusive range and a non Integer value" # Expected TypeError but no exception was raised (907.1111 was returned)
  fails "Range#max raises for an exclusive beginless range" # Expected TypeError (cannot exclude end value with non Integer begin value) but no exception was raised (0 was returned)
  fails "Range#max returns the maximum value in the range when called with no arguments" # Expected NaN == "e" to be truthy but was false
  fails "Range#member? on string elements returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#member? with weird succ when excluded end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#member? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ" # Expected true to be false
  fails "Range#member? with weird succ when included end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#min given a block calls #> and #< on the return value of the block" # Mock 'obj' expected to receive >("any_args") exactly 2 times but received it 0 times
  fails "Range#minmax on an exclusive range raises TypeError if the end value is not an integer" # Expected TypeError (cannot exclude non Integer end value) but got: TypeError (can't iterate from Float)
  fails "Range#minmax on an exclusive range should raise RangeError on a beginless range" # Expected RangeError (/cannot get the maximum of beginless range with custom comparison method|cannot get the minimum of beginless range/) but got: TypeError (can't iterate from NilClass)
  fails "Range#minmax on an exclusive range should raise RangeError on an endless range" # Mock 'x': method <=>  called with unexpected arguments (nil)
  fails "Range#minmax on an inclusive range raises RangeError or ArgumentError on a beginless range" # Expected ArgumentError (comparison of NilClass with MockObject failed) but got: TypeError (can't iterate from NilClass)
  fails "Range#minmax on an inclusive range should raise RangeError on an endless range without iterating the range" # Mock 'x': method <=>  called with unexpected arguments (nil)
  fails "Range#minmax on an inclusive range should return the minimum and maximum values for a non-numeric range without iterating the range" # Mock 'x' expected to receive succ("any_args") exactly 0 times but received it 1 times
  fails "Range#minmax on an inclusive range should return the minimum and maximum values for a numeric range without iterating the range" # TypeError: can't iterate from Float
  fails "Range#size returns nil for endless ranges if the start is not numeric" # Expected Infinity == nil to be truthy but was false
  fails "Range#step when no block is given raises an ArgumentError if step is 0" # Expected ArgumentError but no exception was raised (#<Enumerator: -1..1:step(0)> was returned)
  fails "Range#step when no block is given returned Enumerator size raises a TypeError if #to_int does not return an Integer" # Expected TypeError but no exception was raised (#<Enumerator: 1..2:step(#<MockObject:0x2d238>)> was returned)
  fails "Range#step when no block is given returned Enumerator size raises a TypeError if step does not respond to #to_int" # Expected TypeError but no exception was raised (#<Enumerator: 1..2:step(#<MockObject:0x2d214>)> was returned)
  fails "Range#step when no block is given returned Enumerator size returns the ceil of range size divided by the number of steps even if step is negative" # ArgumentError: step can't be negative
  fails "Range#step when no block is given returned Enumerator type when both begin and end are numerics returns an instance of Enumerator::ArithmeticSequence" # Expected Enumerator == Enumerator::ArithmeticSequence to be truthy but was false
  fails "Range#step with an endless range and Float values yields Float values incremented by a Float step" # Expected [-1, 0] to have same value and type as [-1, -0.5, 0, 0.5]
  fails "Range#step with an endless range and Integer values yields Float values incremented by a Float step" # Expected [-2, 1] to have same value and type as [-2, -0.5, 1]
  fails "Range#step with exclusive end and Float values returns Float values of 'step * n + begin < end'" # Expected [1, 2.8, 4.6, 1, 19.2, 37.4, 55.599999999999994] to have same value and type as [1, 2.8, 4.6, 1, 19.2, 37.4]
  fails "Range#step with exclusive end and String values raises a TypeError when passed a Float step" # Expected TypeError but no exception was raised ("A"..."G" was returned)
  fails "Range#step with inclusive end and Float values returns Float values of 'step * n + begin <= end'" # Expected [1, 2.8, 4.6, 6.4, 1, 2.3, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4] to have same value and type as [1, 2.8, 4.6, 6.4, 1, 2.3, 3.6, 4.9, 6.2, 7.5, 8.8, 10.1, 11.4, 12.7]
  fails "Range#step with inclusive end and String values raises a TypeError when passed a Float step" # Expected TypeError but no exception was raised ("A".."G" was returned)
  fails "Range#to_a throws an exception for endless ranges" # Expected RangeError but got: TypeError (cannot convert endless range to an array)
  fails "Range#to_s can show endless ranges" # Expected "1..." == "1.0..." to be truthy but was false
  fails_badly "Range#min given a block raises RangeError when called with custom comparison method on an endless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails_badly "Range#minmax on an exclusive range should return the minimum and maximum values for a numeric range without iterating the range"
  fails_badly "Range#step with an endless range and String values raises a TypeError when passed a Float step" # Expected TypeError but got: Opal::SyntaxError (undefined method `type' for nil)
end
