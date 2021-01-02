# NOTE: run bin/format-filters after changing this file
opal_filter "Range" do
  fails "Range#% produces an arithmetic sequence with a percent sign in #inspect" # NoMethodError: undefined method `%' for 1..10
  fails "Range#% works as a Range#step" # NoMethodError: undefined method `%' for 1..10
  fails "Range#== returns true if the endpoints are == for beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#== returns true if the endpoints are == for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#== works for endless Ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#=== requires #succ method to be implemented" # Expected TypeError (/can't iterate from/) but no exception was raised (true was returned)
  fails "Range#=== returns true if other is an element of self for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns a boundary element if appropriate" # NoMethodError: undefined method `prev_float' for 3
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0 (small numbers)" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers works with infinity bounds" # TypeError: can't iterate from Float
  fails "Range#bsearch with Float values with a block returning true or false returns a boundary element if appropriate" # NoMethodError: undefined method `prev_float' for 3
  fails "Range#bsearch with Float values with a block returning true or false returns minimum element if the block returns true for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns false for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns nil for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns the smallest element for which block returns true"
  fails "Range#bsearch with Float values with a block returning true or false works with infinity bounds" # TypeError: can't iterate from Float
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning negative, zero, positive numbers works with infinity bounds" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns nil if the block returns nil for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns nil if the block returns true for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false returns the smallest element for which block returns true" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Float values with a block returning true or false works with infinity bounds" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers accepts Float::INFINITY from the block" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with beginless ranges and Integer values with a block returning true or false returns the smallest element for which block returns true" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning negative, zero, positive numbers works with infinity bounds" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns minimum element if the block returns true for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns nil if the block returns false for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns nil if the block returns nil for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false returns the smallest element for which block returns true" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Float values with a block returning true or false works with infinity bounds" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers accepts -Float::INFINITY from the block" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0.0" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block never returns zero" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning true or false returns minimum element if the block returns true for every element" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#bsearch with endless ranges and Integer values with a block returning true or false returns the smallest element for which block returns true" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#count returns Infinity for beginless ranges without arguments or blocks" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#cover? range argument accepts range argument" # Expected false to be true
  fails "Range#cover? range argument honors exclusion of right boundary (:exclude_end option)" # Expected false to be true
  fails "Range#cover? range argument supports boundaries of different comparable types" # Expected false to be true
  fails "Range#cover? returns true if other is an element of self for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#each raises a TypeError beginless ranges" # Expected TypeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#each raises a TypeError if the first element is a Time object"
  fails "Range#each works with String endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#each works with endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#eql? returns false if the endpoints are not eql?"
  fails "Range#eql? works for endless Ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#first raises a RangeError when called on an beginless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#first raises a TypeError if #to_int does not return an Integer"
  fails "Range#hash generates a Fixnum for the hash value"
  fails "Range#hash generates an Integer for the hash value" # Expected "A,1,1,0" (String) to be an instance of Integer
  fails "Range#include? on string elements returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? returns true if other is an element of self for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#include? with weird succ when excluded end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#initialize raises a FrozenError if called on an already initialized Range" # Expected FrozenError but got: NameError ('initialize' called twice)
  fails "Range#inspect works for beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#inspect works for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#inspect works for nil ... nil ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#last raises a RangeError when called on an endless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#last raises a TypeError if #to_int does not return an Integer"
  fails "Range#max given a block calls #> and #< on the return value of the block"
  fails "Range#max given a block raises RangeError when called with custom comparison method on an beginless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#max raises RangeError when called on an endless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#max raises TypeError when called on a Time...Time(excluded end point)"
  fails "Range#max raises TypeError when called on an exclusive range and a non Integer value"
  fails "Range#max raises for an exclusive beginless range" # Expected TypeError (cannot exclude end value with non Integer begin value) but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#max returns the end point for beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#max returns the maximum value in the range when called with no arguments"
  fails "Range#member? on string elements returns false if other is not matched by element.succ"
  fails "Range#member? returns true if other is an element of self for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#member? with weird succ when excluded end value returns false if other is not matched by element.succ"
  fails "Range#member? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ"
  fails "Range#member? with weird succ when included end value returns false if other is not matched by element.succ"
  fails "Range#min given a block calls #> and #< on the return value of the block"
  fails "Range#min given a block raises RangeError when called with custom comparison method on an endless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#min raises RangeError when called on an beginless range" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#min returns the start point for endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#minmax on an exclusive range raises TypeError if the end value is not an integer" # Expected TypeError (cannot exclude non Integer end value) but got: TypeError (can't iterate from Float)
  fails "Range#minmax on an exclusive range should raise RangeError on a beginless range" # ArgumentError: bad value for range
  fails "Range#minmax on an exclusive range should raise RangeError on an endless range" # Mock 'x': method <=>  called with unexpected arguments (nil)
  fails "Range#minmax on an inclusive range raises RangeError or ArgumentError on a beginless range" # ArgumentError: bad value for range
  fails "Range#minmax on an inclusive range should raise RangeError on an endless range without iterating the range" # Mock 'x': method <=>  called with unexpected arguments (nil)
  fails "Range#minmax on an inclusive range should return the minimum and maximum values for a non-numeric range without iterating the range" # Mock 'x' expected to receive succ("any_args") exactly 0 times but received it 1 times
  fails "Range#minmax on an inclusive range should return the minimum and maximum values for a numeric range without iterating the range" # TypeError: can't iterate from Float
  fails "Range#size returns Float::INFINITY for all beginless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#size returns Float::INFINITY for endless ranges if the start is numeric" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#size returns nil for endless ranges if the start is not numeric" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step when no block is given raises an ArgumentError if step is 0" # Expected ArgumentError but no exception was raised (#<Enumerator: -1..1:step(0)> was returned)
  fails "Range#step when no block is given returned Enumerator size raises a TypeError if #to_int does not return an Integer" # Expected TypeError but no exception was raised (#<Enumerator: 1..2:step(#<MockObject:0x13494>)> was returned)
  fails "Range#step when no block is given returned Enumerator size raises a TypeError if step does not respond to #to_int" # Expected TypeError but no exception was raised (#<Enumerator: 1..2:step(#<MockObject:0x13478>)> was returned)
  fails "Range#step when no block is given returned Enumerator size returns the ceil of range size divided by the number of steps even if step is negative" # ArgumentError: step can't be negative
  fails "Range#step when no block is given returned Enumerator type when both begin and end are numerics returns an instance of Enumerator::ArithmeticSequence" # Expected Enumerator == Enumerator::ArithmeticSequence to be truthy but was false
  fails "Range#step with an endless range and Float values handles infinite values at the start" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Float values yields Float values incremented by 1 and less than end when not passed a step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Float values yields Float values incremented by a Float step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Float values yields Float values incremented by an Integer step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Integer values yield Integer values incremented by 1 when not passed a step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Integer values yields Float values incremented by a Float step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and Integer values yields Integer values incremented by an Integer step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and String values raises a TypeError when passed a Float step" # Expected TypeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#step with an endless range and String values yields String values incremented by #succ and less than or equal to end when not passed a step" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with an endless range and String values yields String values incremented by #succ called Integer step times" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range#step with exclusive end and Float values returns Float values of 'step * n + begin < end'" # precision errors
  fails "Range#step with exclusive end and String values raises a TypeError when passed a Float step" # requires Fixnum != Float
  fails "Range#step with inclusive end and Float values returns Float values of 'step * n + begin <= end'" # precision errors
  fails "Range#step with inclusive end and String values raises a TypeError when passed a Float step" # requires Fixnum != Float
  fails "Range#to_a throws an exception for beginless ranges" # Expected TypeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#to_a throws an exception for endless ranges" # Expected RangeError but got: Opal::SyntaxError (undefined method `type' for nil)
  fails "Range#to_s can show endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Range.new beginless/endless range allows beginless left boundary" # ArgumentError: bad value for range
  fails "Range.new beginless/endless range allows endless right boundary" # ArgumentError: bad value for range
  fails "Range.new beginless/endless range distinguishes ranges with included and excluded right boundary" # ArgumentError: bad value for range
  fails_badly "Range#minmax on an exclusive range should return the minimum and maximum values for a numeric range without iterating the range"
end
