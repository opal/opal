opal_filter "Enumerable" do
  fails "Enumerable#drop passed a number n as an argument raise ArgumentError if n < 0"
  fails "Enumerable#drop passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Enumerable#drop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"

  fails "Enumerable#drop_while returns an Enumerator if no block given"
  fails "Enumerable#drop_while passes elements to the block until the first false"
  fails "Enumerable#drop_while will only go through what's needed"
  fails "Enumerable#drop_while gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#each_slice tries to convert n to an Integer using #to_int"
  fails "Enumerable#each_slice raises an Argument Error if there is not a single parameter > 0"
  fails "Enumerable#each_slice yields only as much as needed"
  fails "Enumerable#each_slice gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#each_slice returns an enumerator if no block"

  fails "Enumerable#each_with_index provides each element to the block"
  fails "Enumerable#each_with_index provides each element to the block and its index"
  fails "Enumerable#each_with_index binds splat arguments properly"
  fails "Enumerable#each_with_index passes extra parameters to each"

  fails "Enumerable#each_with_object returns an enumerator if no block"

  fails "Enumerable#find_index returns an Enumerator if no block given"
  fails "Enumerable#find_index gathers initial args as elements when each yields multiple"
  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#group_by returns a hash without default_proc"
  fails "Enumerable#group_by returns an Enumerator if called without a block"
  fails "Enumerable#group_by gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#sort_by returns an Enumerator when a block is not supplied"

  fails "Enumerable#take requires an argument"
end
