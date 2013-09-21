opal_filter "Enumerable" do
  fails "Enumerable#detect passes the ifnone proc to the enumerator"
  fails "Enumerable#detect returns an enumerator when no block given"
  fails "Enumerable#detect passes through the values yielded by #each_with_index"

  fails "Enumerable#drop passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Enumerable#drop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"

  fails "Enumerable#drop_while passes elements to the block until the first false"
  fails "Enumerable#drop_while will only go through what's needed"
  fails "Enumerable#drop_while gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#each_slice tries to convert n to an Integer using #to_int"
  fails "Enumerable#each_slice raises an Argument Error if there is not a single parameter > 0"
  fails "Enumerable#each_slice yields only as much as needed"
  fails "Enumerable#each_slice gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#each_with_index provides each element to the block"
  fails "Enumerable#each_with_index provides each element to the block and its index"
  fails "Enumerable#each_with_index binds splat arguments properly"
  fails "Enumerable#each_with_index passes extra parameters to each"

  fails "Enumerable#entries passes arguments to each"

  fails "Enumerable#find passes through the values yielded by #each_with_index"
  fails "Enumerable#find returns an enumerator when no block given"
  fails "Enumerable#find passes the ifnone proc to the enumerator"

  fails "Enumerable#find_all returns an enumerator when no block given"
  fails "Enumerable#find_all passes through the values yielded by #each_with_index"

  fails "Enumerable#find_index gathers initial args as elements when each yields multiple"

  fails "Enumerable#first when passed an argument consumes only what is needed"
  fails "Enumerable#first when passed an argument raises a TypeError if the passed argument is not numeric"
  fails "Enumerable#first when passed an argument tries to convert the passed argument to an Integer using #to_int"
  fails "Enumerable#first when passed an argument raises an ArgumentError when count is negative"

  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#group_by returns a hash without default_proc"
  fails "Enumerable#group_by gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#inject returns nil when fails(legacy rubycon)"
  fails "Enumerable#inject without inject arguments(legacy rubycon)"
  fails "Enumerable#inject gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#inject without argument takes a block with an accumulator (with first element as initial value) and the current element. Value of block becomes new accumulator"
  fails "Enumerable#inject can take a symbol argument"
  fails "Enumerable#inject ignores the block if two arguments"
  fails "Enumerable#inject can take two argument"

  fails "Enumerable#max raises an ArgumentError for incomparable elements"
  fails "Enumerable#max gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#min raises an ArgumentError for incomparable elements"
  fails "Enumerable#min gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#reduce returns nil when fails(legacy rubycon)"
  fails "Enumerable#reduce without inject arguments(legacy rubycon)"
  fails "Enumerable#reduce gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#reduce without argument takes a block with an accumulator (with first element as initial value) and the current element. Value of block becomes new accumulator"
  fails "Enumerable#reduce can take a symbol argument"
  fails "Enumerable#reduce ignores the block if two arguments"
  fails "Enumerable#reduce can take two argument"

  fails "Enumerable#select passes through the values yielded by #each_with_index"
  fails "Enumerable#select returns an enumerator when no block given"

  fails "Enumerable#take when passed an argument consumes only what is needed"
  fails "Enumerable#take when passed an argument raises a TypeError if the passed argument is not numeric"
  fails "Enumerable#take when passed an argument tries to convert the passed argument to an Integer using #to_int"
  fails "Enumerable#take when passed an argument raises an ArgumentError when count is negative"

  fails "Enumerable#to_a passes arguments to each"
end
