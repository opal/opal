opal_filter "Enumerable" do
  fails "Enumerable#cycle passed a number n as an argument raises an ArgumentError if more arguments are passed"

  fails "Enumerable#grep can use $~ in the block when used with a Regexp"

  fails "Enumerable#inject returns nil when fails(legacy rubycon)"
  fails "Enumerable#inject without inject arguments(legacy rubycon)"

  fails "Enumerable#reduce returns nil when fails(legacy rubycon)"
  fails "Enumerable#reduce without inject arguments(legacy rubycon)"
end
