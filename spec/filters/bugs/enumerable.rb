opal_filter "Enumerable" do
  fails "Enumerable#cycle passed a number n as an argument raises an ArgumentError if more arguments are passed"

  fails "Enumerable#drop passed a number n as an argument tries to convert n to an Integer using #to_int"

  fails "Enumerable#drop_while passes elements to the block until the first false"

  fails "Enumerable#each_slice raises an Argument Error if there is not a single parameter > 0"

  fails "Enumerable#each_with_index provides each element to the block"
  fails "Enumerable#each_with_index provides each element to the block and its index"
  fails "Enumerable#each_with_index binds splat arguments properly"
  fails "Enumerable#each_with_index passes extra parameters to each"

  fails "Enumerable#entries passes arguments to each"

  fails "Enumerable#first when passed an argument consumes only what is needed"
  fails "Enumerable#first when passed an argument raises a TypeError if the passed argument is not numeric"
  fails "Enumerable#first when passed an argument tries to convert the passed argument to an Integer using #to_int"
  fails "Enumerable#first when passed an argument raises an ArgumentError when count is negative"

  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#group_by returns a hash without default_proc"
  fails "Enumerable#group_by gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#include? returns true if any element == argument for numbers"
  fails "Enumerable#include? gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#inject returns nil when fails(legacy rubycon)"
  fails "Enumerable#inject without inject arguments(legacy rubycon)"
  fails "Enumerable#inject can take a symbol argument"
  fails "Enumerable#inject ignores the block if two arguments"
  fails "Enumerable#inject can take two argument"

  fails "Enumerable#max raises an ArgumentError for incomparable elements"
  fails "Enumerable#max gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#member? returns true if any element == argument for numbers"
  fails "Enumerable#member? gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#min raises an ArgumentError for incomparable elements"
  fails "Enumerable#min gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#reduce returns nil when fails(legacy rubycon)"
  fails "Enumerable#reduce without inject arguments(legacy rubycon)"
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
