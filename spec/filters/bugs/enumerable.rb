# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerable" do
  fails "Enumerable#chain returns a chain of self and provided enumerables" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x8c490>
  fails "Enumerable#chain returns an Enumerator::Chain if given a block" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x6b0b4>
  fails "Enumerable#chunk_while on a single-element array ignores the block and returns an enumerator that yields [element]" # Expected [] to equal [[1]]
  fails "Enumerable#collect reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#collect yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#first returns a gathered array from yield parameters"
  fails "Enumerable#grep correctly handles non-string elements" # Expected nil == "match" to be truthy but was false
  fails "Enumerable#grep does not modify Regexp.last_match without block" # NoMethodError: undefined method `[]' for nil
  fails "Enumerable#grep does not set $~ when given no block" # Expected nil == "z" to be truthy but was false
  fails "Enumerable#grep_v correctly handles non-string elements" # Expected nil == "match" to be truthy but was false
  fails "Enumerable#grep_v does not modify Regexp.last_match without block" # Expected "e" == "z" to be truthy but was false
  fails "Enumerable#grep_v does not set $~ when given no block" # Expected "e" == "z" to be truthy but was false
  fails "Enumerable#map reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#map yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#slice_when when an iterator method yields more than one value processes all yielded values"
  fails "Enumerable#slice_when when given a block doesn't yield an empty array on a small enumerable" # Expected [] to equal [[42]]
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # Mock '#<EnumerableSpecs::Numerous:0x64116>' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerable#sort_by returns an array of elements when a block is supplied and #map returns an enumerable"
  fails "Enumerable#sum uses Kahan's compensated summation algorithm for precise sum of float numbers" # Expected 50.00000000000001 == 50 to be truthy but was false
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments"
  fails "Enumerable#tally counts values as gathered array when yielded with multiple arguments" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::YieldsMixed2:0x8e6b4>
  fails "Enumerable#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#uniq uses eql? semantics" # Depends on the difference between Integer and Float
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given"
end
