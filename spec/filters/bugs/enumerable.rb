opal_filter "Enumerable" do
  fails "Enumerable#chunk_while on a single-element array ignores the block and returns an enumerator that yields [element]" # Expected [] to equal [[1]]
  fails "Enumerable#first returns a gathered array from yield parameters"
  fails "Enumerable#max_by when called with an argument n when n is nil returns the maximum element"
  fails "Enumerable#max_by when called with an argument n with a block on a enumerable of length x where x < n returns an array containing the maximum n elements of length n"
  fails "Enumerable#max_by when called with an argument n with a block returns an array containing the maximum n elements based on the block's value"
  fails "Enumerable#max_by when called with an argument n without a block returns an enumerator"
  fails "Enumerable#min_by when called with an argument n when n is nil returns the minimum element"
  fails "Enumerable#min_by when called with an argument n with a block on a enumerable of length x where x < n returns an array containing the minimum n elements of length n"
  fails "Enumerable#min_by when called with an argument n with a block returns an array containing the minimum n elements based on the block's value"
  fails "Enumerable#min_by when called with an argument n without a block returns an enumerator"
  fails "Enumerable#minmax_by Enumerable with no size when no block is given returned Enumerator size returns nil"
  fails "Enumerable#minmax_by Enumerable with size when no block is given returned Enumerator size returns the enumerable size"
  fails "Enumerable#minmax_by gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#minmax_by is able to return the maximum for enums that contain nils"
  fails "Enumerable#minmax_by returns an enumerator if no block"
  fails "Enumerable#minmax_by returns nil if #each yields no objects"
  fails "Enumerable#minmax_by returns the object for whom the value returned by block is the largest"
  fails "Enumerable#minmax_by returns the object that appears first in #each in case of a tie"
  fails "Enumerable#minmax_by uses min/max.<=>(current) to determine order"
  fails "Enumerable#none? given a pattern argument returns true iff none match that pattern" # Works, but depends on the difference between Integer and Float
  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#slice_when when an iterator method yields more than one value processes all yielded values"
  fails "Enumerable#slice_when when given a block doesn't yield an empty array on a small enumerable" # Expected [] to equal [[42]]
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # Mock '#<EnumerableSpecs::Numerous:0x64116>' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerable#sort_by calls #each to iterate over the elements to be sorted" # NoMethodError: undefined method `sort!' for nil
  fails "Enumerable#sort_by returns an array of elements when a block is supplied and #map returns an enumerable"
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments"
  fails "Enumerable#to_h calls #to_ary on contents"
  fails "Enumerable#to_h converts empty enumerable to empty hash"
  fails "Enumerable#to_h converts yielded [key, value] pairs to a hash"
  fails "Enumerable#to_h forwards arguments to #each"
  fails "Enumerable#to_h raises ArgumentError if an element is not a [key, value] pair"
  fails "Enumerable#to_h raises TypeError if an element is not an array"
  fails "Enumerable#to_h uses the last value of a duplicated key"
  fails "Enumerable#uniq compares elements with matching hash codes with #eql?" # Depends on tainting
  fails "Enumerable#uniq uses eql? semantics" # Depends on the difference between Integer and Float
  fails "Enumerable#zip converts arguments to enums using #to_enum"
  fails "Enumerable#zip gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given"
end
