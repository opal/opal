opal_filter "Array" do

  fails "Array.[] can unpack 2 or more nested referenced array"

  fails "Array#initialize with (size, object=nil) sets the array to the values returned by the block before break is executed"
  fails "Array#initialize with (size, object=nil) returns the value passed to break"
  fails "Array#initialize with (size, object=nil) uses the block value instead of using the default value"
  fails "Array#initialize with (size, object=nil) yields the index of the element and sets the element to the value of the block"
  fails "Array#initialize with (size, object=nil) sets the array to size and fills with the object"
  fails "Array#initialize preserves the object's identity even when changing its value"

  fails "Array#& determines equivalence between elements in the sense of eql?"

  fails "Array#- doesn't remove an item with the same hash but not #eql?"
  fails "Array#- removes an item identified as equivalent via #hash and #eql?"

  fails "Array#* with a string uses the same separator with nested arrays"
  fails "Array#* with a string returns a string formed by concatenating each element.to_str separated by separator"

  fails "Array#flatten performs respond_to? and method_missing-aware checks when coercing elements to array"

  fails "Array#rassoc does not check the last element in each contained but speficically the second"
  fails "Array#rassoc calls elem == obj on the second element of each contained array"

  fails "Array#repeated_combination generates from a defensive copy, ignoring mutations"
  fails "Array#repeated_combination accepts sizes larger than the original array"
  fails "Array#repeated_combination yields a partition consisting of only singletons"
  fails "Array#repeated_combination yields nothing when the array is empty and num is non zero"
  fails "Array#repeated_combination yields [] when length is 0"
  fails "Array#repeated_combination yields the expected repeated_combinations"
  fails "Array#repeated_combination yields nothing for negative length and return self"
  fails "Array#repeated_combination returns self when a block is given"
  fails "Array#repeated_combination returns an enumerator when no block is provided"
  fails "Array#repeated_combination when no block is given returned Enumerator size returns 0 when the combination_size is < 0"
  fails "Array#repeated_combination when no block is given returned Enumerator size returns 1 when the combination_size is 0"
  fails "Array#repeated_combination when no block is given returned Enumerator size returns the binomial coeficient between combination_size and array size + combination_size -1"

  fails "Array#repeated_permutation generates from a defensive copy, ignoring mutations"
  fails "Array#repeated_permutation allows permutations larger than the number of elements"
  fails "Array#repeated_permutation returns an Enumerator which works as expected even when the array was modified"
  fails "Array#repeated_permutation truncates Float arguments"
  fails "Array#repeated_permutation handles duplicate elements correctly"
  fails "Array#repeated_permutation does not yield when called on an empty Array with a nonzero argument"
  fails "Array#repeated_permutation yields the empty repeated_permutation ([[]]) when the given length is 0"
  fails "Array#repeated_permutation yields all repeated_permutations to the block then returns self when called with block but no arguments"
  fails "Array#repeated_permutation returns an Enumerator of all repeated permutations of given length when called without a block"
  fails "Array#repeated_permutation when no block is given returned Enumerator size returns 0 when combination_size is < 0"
  fails "Array#repeated_permutation when no block is given returned Enumerator size returns array size ** combination_size"

  fails "Array#rindex rechecks the array size during iteration"

  fails "Array#select returns a new array of elements for which block is true"

  fails "Array#shuffle attempts coercion via #to_hash"
  fails "Array#shuffle calls #rand on the Object passed by the :random key in the arguments Hash"
  fails "Array#shuffle ignores an Object passed for the RNG if it does not define #rand"
  fails "Array#shuffle accepts a Float for the value returned by #rand"
  fails "Array#shuffle calls #to_int on the Object returned by #rand"
  fails "Array#shuffle raises a RangeError if the value is less than zero"
  fails "Array#shuffle raises a RangeError if the value is equal to one"

  fails "Array#slice! calls to_int on range arguments"
  fails "Array#slice! calls to_int on start and length arguments"
  fails "Array#slice! does not expand array with indices out of bounds"
  fails "Array#slice! does not expand array with negative indices out of bounds"
  fails "Array#slice! removes and return elements in range"
  fails "Array#slice! removes and returns elements in end-exclusive ranges"
  fails "Array#slice! returns nil if length is negative"

  fails "Array#sort_by! makes some modification even if finished sorting when it would break in the given block"
  fails "Array#sort_by! returns the specified value when it would break in the given block"
  fails "Array#sort_by! raises a RuntimeError on an empty frozen array"
  fails "Array#sort_by! raises a RuntimeError on a frozen array"
  fails "Array#sort_by! completes when supplied a block that always returns the same result"
  fails "Array#sort_by! returns an Enumerator if not given a block"
  fails "Array#sort_by! sorts array in place by passing each element to the given block"
  fails "Array#sort_by! when no block is given returned Enumerator size returns the enumerable size"

  fails "Array#uniq compares elements based on the value returned from the block"
  fails "Array#uniq compares elements with matching hash codes with #eql?"
  fails "Array#uniq handles nil and false like any other values"
  fails "Array#uniq uses eql? semantics"
  fails "Array#uniq yields items in order"
  fails "Array#uniq! compares elements based on the value returned from the block"

  fails "Array#hash returns the same fixnum for arrays with the same content"

  fails "Array#partition returns in the left array values for which the block evaluates to true"

  fails "Array#| acts as if using an intermediate hash to collect values"

  # recursive arrays
  fails "Array#uniq! properly handles recursive arrays"
  fails "Array#<=> properly handles recursive arrays"
  fails "Array#hash returns the same hash for equal recursive arrays through hashes"

  fails "Array#first raises a RangeError when count is a Bignum"

  fails "Array#combination when no block is given returned Enumerator size returns 0 when the number of combinations is < 0"
  fails "Array#combination when no block is given returned Enumerator size returns the binomial coeficient between the array size the number of combinations"
  fails "Array#permutation when no block is given returned Enumerator size with an array size greater than 0 returns the descending factorial of array size and given length"
  fails "Array#permutation when no block is given returned Enumerator size with an array size greater than 0 returns the descending factorial of array size with array size when there's no param"
  fails "Array#permutation when no block is given returned Enumerator size with an empty array returns 1 when the given length is 0"
  fails "Array#permutation when no block is given returned Enumerator size with an empty array returns 1 when there's param"
end
