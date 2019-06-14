opal_filter "Range" do
  fails "Range#=== requires #succ method to be implemented" # Expected TypeError (/can't iterate from/) but no exception was raised (true was returned)
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers accepts (+/-)Float::INFINITY from the block"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns an element at an index for which block returns 0"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block never returns zero"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns greater than zero for every element"
  fails "Range#bsearch with Float values with a block returning negative, zero, positive numbers returns nil if the block returns less than zero for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns minimum element if the block returns true for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns false for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns nil if the block returns nil for every element"
  fails "Range#bsearch with Float values with a block returning true or false returns the smallest element for which block returns true"
  fails "Range#each raises a TypeError if the first element is a Time object"
  fails "Range#each when no block is given returned Enumerator size returns the enumerable size"
  fails "Range#eql? returns false if the endpoints are not eql?"
  fails "Range#first raises a TypeError if #to_int does not return an Integer"
  fails "Range#hash generates a Fixnum for the hash value"
  fails "Range#include? on string elements returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when excluded end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ" # Expected true to be false
  fails "Range#include? with weird succ when included end value returns false if other is not matched by element.succ" # Expected true to be false
  fails "Range#last raises a TypeError if #to_int does not return an Integer"
  fails "Range#max given a block calls #> and #< on the return value of the block"
  fails "Range#max raises TypeError when called on a Time...Time(excluded end point)"
  fails "Range#max raises TypeError when called on an exclusive range and a non Integer value"
  fails "Range#max returns the maximum value in the range when called with no arguments"
  fails "Range#member? on string elements returns false if other is not matched by element.succ"
  fails "Range#member? with weird succ when excluded end value returns false if other is not matched by element.succ"
  fails "Range#member? with weird succ when included end value returns false if other is equal as last element but not matched by element.succ"
  fails "Range#member? with weird succ when included end value returns false if other is not matched by element.succ"
  fails "Range#min given a block calls #> and #< on the return value of the block"
  fails "Range#step with exclusive end and Float values returns Float values of 'step * n + begin < end'" # precision errors
  fails "Range#step with exclusive end and String values raises a TypeError when passed a Float step" # requires Fixnum != Float
  fails "Range#step with inclusive end and Float values returns Float values of 'step * n + begin <= end'" # precision errors
  fails "Range#step with inclusive end and String values raises a TypeError when passed a Float step" # requires Fixnum != Float
end
