opal_filter "Enumerable" do
  fails "Enumerable#cycle passed a number n as an argument raises an ArgumentError if more arguments are passed"

  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#inject returns nil when fails(legacy rubycon)"
  fails "Enumerable#inject without inject arguments(legacy rubycon)"

  fails "Enumerable#reduce returns nil when fails(legacy rubycon)"
  fails "Enumerable#reduce without inject arguments(legacy rubycon)"

  fails "Enumerable#chunk does not yield the object passed to #chunk if it is nil"
  fails "Enumerable#chunk yields an element and an object value-equal but not identical to the object passed to #chunk"
  fails "Enumerable#chunk raises a RuntimeError if the block returns a Symbol starting with an underscore other than :_alone or :_separator"
  fails "Enumerable#chunk does not return elements for which the block returns nil"
  fails "Enumerable#chunk does not return elements for which the block returns :_separator"
  fails "Enumerable#chunk returns elements for which the block returns :_alone in separate Arrays"
  fails "Enumerable#chunk returns elements of the Enumerable in an Array of Arrays, [v, ary], where 'ary' contains the consecutive elements for which the block returned the value 'v'"
  fails "Enumerable#chunk yields the current element and the current chunk to the block"
  fails "Enumerable#chunk returns an Enumerator if given a block"
  fails "Enumerable#chunk raises an ArgumentError if called without a block"

  fails "Enumerable#each_cons gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#each_cons returns an enumerator if no block"
  fails "Enumerable#each_cons yields only as much as needed"
  fails "Enumerable#each_cons works when n is >= full length"
  fails "Enumerable#each_cons tries to convert n to an Integer using #to_int"
  fails "Enumerable#each_cons raises an Argument Error if there is not a single parameter > 0"
  fails "Enumerable#each_cons passes element groups to the block"

  fails "Enumerable#each_entry passes extra arguments to #each"
  fails "Enumerable#each_entry passes through the values yielded by #each_with_index"
  fails "Enumerable#each_entry returns an enumerator if no block"
  fails "Enumerable#each_entry yields multiple arguments as an array"

  fails "Enumerable#minmax_by gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#minmax_by is able to return the maximum for enums that contain nils"
  fails "Enumerable#minmax_by uses min/max.<=>(current) to determine order"
  fails "Enumerable#minmax_by returns the object that appears first in #each in case of a tie"
  fails "Enumerable#minmax_by returns the object for whom the value returned by block is the largest"
  fails "Enumerable#minmax_by returns nil if #each yields no objects"
  fails "Enumerable#minmax_by returns an enumerator if no block"

  fails "Enumerable#minmax gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#minmax return the minimun when using a block rule"
  fails "Enumerable#minmax raises a NoMethodError for elements without #<=>"
  fails "Enumerable#minmax raises an ArgumentError when elements are incomparable"
  fails "Enumerable#minmax returns [nil, nil] for an empty Enumerable"
  fails "Enumerable#minmax min should return the minimum element"

  fails "Enumerable#partition gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#partition returns an Enumerator if called without a block"
  fails "Enumerable#partition returns two arrays, the first containing elements for which the block is true, the second containing the rest"

  fails "Enumerable#reject gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#reject returns an Enumerator if called without a block"
  fails "Enumerable#reject returns an array of the elements for which block is false"

  fails "Enumerable#reverse_each gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#reverse_each returns an Enumerator if no block given"
  fails "Enumerable#reverse_each traverses enum in reverse order and pass each element to block"

  fails "Enumerable#sort gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#sort raises an error if objects can't be compared"
  fails "Enumerable#sort compare values returned by block with 0"
  fails "Enumerable#sort sorts enumerables that contain nils"
  fails "Enumerable#sort raises a NoMethodError if elements do not define <=>"
  fails "Enumerable#sort yields elements to the provided block"
  fails "Enumerable#sort sorts by the natural order as defined by <=> "

  fails "Enumerable#zip gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#zip converts arguments to enums using #to_enum"
  fails "Enumerable#zip converts arguments to arrays using #to_ary"
  fails "Enumerable#zip fills resulting array with nils if an argument array is too short"
  fails "Enumerable#zip passes each element of the result array to a block and return nil if a block is given"
  fails "Enumerable#zip combines each element of the receiver with the element of the same index in arrays given as arguments"
end
