# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerable" do
  fails "Enumerable#chain returns a chain of self and provided enumerables" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x8c490>
  fails "Enumerable#chain returns an Enumerator::Chain if given a block" # NoMethodError: undefined method `chain' for #<EnumerableSpecs::Numerous:0x6b0b4>
  fails "Enumerable#chunk_while on a single-element array ignores the block and returns an enumerator that yields [element]" # Expected [] to equal [[1]]
  fails "Enumerable#collect reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#collect yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#filter Enumerable with no size when no block is given returned Enumerator size returns nil" # NoMethodError: undefined method `filter' for #<EnumerableSpecs::Numerous:0x6ae7c>
  fails "Enumerable#filter Enumerable with size when no block is given returned Enumerator size returns the enumerable size" # NoMethodError: undefined method `filter' for #<EnumerableSpecs::NumerousWithSize:0x6ae76>
  fails "Enumerable#filter gathers whole arrays as elements when each yields multiple" # NoMethodError: undefined method `filter' for #<EnumerableSpecs::YieldsMulti:0x6ae62>
  fails "Enumerable#filter passes through the values yielded by #each_with_index" # NoMethodError: undefined method `filter' for #<Enumerator: ["a", "b"]:each_with_index>
  fails "Enumerable#filter returns all elements for which the block is not false" # NoMethodError: undefined method `filter' for #<EnumerableSpecs::Numerous:0x6ae72>
  fails "Enumerable#filter returns an enumerator when no block given" # NoMethodError: undefined method `filter' for #<EnumerableSpecs::Numerous:0x6ae66>
  fails "Enumerable#filter_map returns an array with truthy results of passing each element to block" # NoMethodError: undefined method `filter_map' for #<EnumerableSpecs::Numerous:0x6c896>
  fails "Enumerable#filter_map returns an empty array if there are no elements" # NoMethodError: undefined method `filter_map' for #<EnumerableSpecs::Empty:0x6c89c>
  fails "Enumerable#filter_map returns an enumerator when no block given" # NoMethodError: undefined method `filter_map' for #<EnumerableSpecs::Numerous:0x6c892>
  fails "Enumerable#first returns a gathered array from yield parameters"
  fails "Enumerable#grep does not set $~ when given no block" # Expected nil == "z" to be truthy but was false
  fails "Enumerable#grep_v does not set $~ when given no block" # Expected "e" == "z" to be truthy but was false
  fails "Enumerable#map reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#map yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#none? given a pattern argument returns true iff none match that pattern" # Works, but depends on the difference between Integer and Float
  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#slice_when when an iterator method yields more than one value processes all yielded values"
  fails "Enumerable#slice_when when given a block doesn't yield an empty array on a small enumerable" # Expected [] to equal [[42]]
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # Mock '#<EnumerableSpecs::Numerous:0x64116>' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerable#sort_by returns an array of elements when a block is supplied and #map returns an enumerable"
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments"
  fails "Enumerable#tally counts values as gathered array when yielded with multiple arguments" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::YieldsMixed2:0x8e6b4>
  fails "Enumerable#tally does not call given block" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::Numerous:0x8e6a4>
  fails "Enumerable#tally returns a hash with counts according to the value" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::Numerous:0x8e6a8>
  fails "Enumerable#tally returns a hash without default" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::Numerous:0x8e6ac>
  fails "Enumerable#tally returns an empty hash for empty enumerables" # NoMethodError: undefined method `tally' for #<EnumerableSpecs::Empty:0x8e6b0>
  fails "Enumerable#to_h with block coerces returned pair to Array with #to_ary" # TypeError: wrong element type NilClass (expected array)
  fails "Enumerable#to_h with block converts [key, value] pairs returned by the block to a hash" # TypeError: wrong element type NilClass (expected array)
  fails "Enumerable#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but got: TypeError (wrong element type NilClass (expected array))
  fails "Enumerable#uniq compares elements with matching hash codes with #eql?" # Depends on tainting
  fails "Enumerable#uniq uses eql? semantics" # Depends on the difference between Integer and Float
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given"
end
