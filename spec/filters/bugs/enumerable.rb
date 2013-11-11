opal_filter "Enumerable" do
  fails "Enumerable#cycle passed a number n as an argument raises an ArgumentError if more arguments are passed"

  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#group_by returns a hash without default_proc"
  fails "Enumerable#group_by gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#include? returns true if any element == argument for numbers"
  fails "Enumerable#include? gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#inject returns nil when fails(legacy rubycon)"
  fails "Enumerable#inject without inject arguments(legacy rubycon)"

  fails "Enumerable#member? returns true if any element == argument for numbers"
  fails "Enumerable#member? gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#min raises an ArgumentError for incomparable elements"
  fails "Enumerable#min gathers whole arrays as elements when each yields multiple"

  fails "Enumerable#reduce returns nil when fails(legacy rubycon)"
  fails "Enumerable#reduce without inject arguments(legacy rubycon)"

  fails "Enumerable#select passes through the values yielded by #each_with_index"
  fails "Enumerable#select returns an enumerator when no block given"
end
