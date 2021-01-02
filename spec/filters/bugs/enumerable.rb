# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerable" do
  fails "Enumerable#chunk_while on a single-element array ignores the block and returns an enumerator that yields [element]" # Expected [] to equal [[1]]
  fails "Enumerable#collect reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#collect yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#first returns a gathered array from yield parameters"
  fails "Enumerable#map reports the same arity as the given block" # Exception: Cannot read property '$$is_array' of undefined
  fails "Enumerable#map yields 2 arguments for a Hash when block arity is 2" # ArgumentError: [#register] wrong number of arguments(1 for 2)
  fails "Enumerable#none? given a pattern argument returns true iff none match that pattern" # Works, but depends on the difference between Integer and Float
  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#slice_when when an iterator method yields more than one value processes all yielded values"
  fails "Enumerable#slice_when when given a block doesn't yield an empty array on a small enumerable" # Expected [] to equal [[42]]
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # Mock '#<EnumerableSpecs::Numerous:0x64116>' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerable#sort_by returns an array of elements when a block is supplied and #map returns an enumerable"
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments"
  fails "Enumerable#uniq compares elements with matching hash codes with #eql?" # Depends on tainting
  fails "Enumerable#uniq uses eql? semantics" # Depends on the difference between Integer and Float
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given"
end
