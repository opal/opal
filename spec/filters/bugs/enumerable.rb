# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerable" do
  fails "Enumerable#chain returns a chain of self and provided enumerables" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x2eb8 @list=[1]>
  fails "Enumerable#chain returns an Enumerator::Chain if given a block" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x2eb2 @list=[2, 5, 3, 6, 1, 4]>
  fails "Enumerable#chunk_while on a single-element array ignores the block and returns an enumerator that yields [element]" # Expected [] == [[1]] to be truthy but was false
  fails "Enumerable#collect reports the same arity as the given block" # Exception: Cannot read properties of undefined (reading '$$is_array')
  fails "Enumerable#collect yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments (given 1, expected 2)
  fails "Enumerable#first returns a gathered array from yield parameters" # Expected 1 == [1, 2] to be truthy but was false
  fails "Enumerable#grep correctly handles non-string elements" # Expected nil == "match" to be truthy but was false
  fails "Enumerable#grep does not modify Regexp.last_match without block" # NoMethodError: undefined method `[]' for nil
  fails "Enumerable#grep does not set $~ when given no block" # Expected nil == "z" to be truthy but was false
  fails "Enumerable#grep_v correctly handles non-string elements" # Expected nil == "match" to be truthy but was false
  fails "Enumerable#grep_v does not modify Regexp.last_match without block" # Expected "e" == "z" to be truthy but was false
  fails "Enumerable#grep_v does not set $~ when given no block" # Expected "e" == "z" to be truthy but was false
  fails "Enumerable#inject raises an ArgumentError when no parameters or block is given" # Expected ArgumentError but got: Exception (Cannot read properties of undefined (reading '$inspect'))
  fails "Enumerable#map reports the same arity as the given block" # Exception: Cannot read properties of undefined (reading '$$is_array')
  fails "Enumerable#map yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments (given 1, expected 2)
  fails "Enumerable#reduce raises an ArgumentError when no parameters or block is given" # Expected ArgumentError but got: Exception (Cannot read properties of undefined (reading '$inspect'))
  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple" # Expected [6, 3, 1] == [[6, 7, 8, 9], [3, 4, 5], [1, 2]] to be truthy but was false
  fails "Enumerable#slice_when when an iterator method yields more than one value processes all yielded values" # Expected [] == [[[1, 2]]] to be truthy but was false
  fails "Enumerable#slice_when when given a block doesn't yield an empty array on a small enumerable" # Expected [] == [[42]] to be truthy but was false
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # Mock '#<EnumerableSpecs::Numerous:0x42a10 @list=[1, 2, 3]>' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # NoMethodError: undefined method `sort!' for nil
  fails "Enumerable#sort_by returns an array of elements when a block is supplied and #map returns an enumerable" # NoMethodError: undefined method `sort!' for #<EnumerableSpecs::MapReturnsEnumerable::EnumerableMapping:0x42a48 @items=#<EnumerableSpecs::MapReturnsEnumerable:0x42a46> @block=#<Proc:0x42a4a>>
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments" # Expected [1, [2], [3, 4], [5, 6, 7], [8, 9], nil, []] == [1, [2], 3, 5, [8, 9], nil, []] to be truthy but was false
  fails "Enumerable#tally counts values as gathered array when yielded with multiple arguments" # Expected {[]=>3, 0=>1, [0, 1]=>2, [0, 1, 2]=>3, nil=>1, "default_arg"=>1, [0]=>1} == {nil=>2, 0=>1, [0, 1]=>2, [0, 1, 2]=>3, "default_arg"=>1, []=>2, [0]=>1} to be truthy but was false
  fails "Enumerable#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Enumerable#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but got: ArgumentError (wrong array length at 0 (expected 2, was 3))
  fails "Enumerable#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but got: TypeError (wrong element type NilClass at 0 (expected array))
  fails "Enumerable#uniq uses eql? semantics" # Expected [1] == [1, 1] to be truthy but was false
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given" # Expected [[1, 4, 7], [2, 5, 8], [3, 6, 9]] == nil to be truthy but was false  
end
