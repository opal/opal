opal_filter "Enumerator" do
  fails "Enumerator#each requires multiple arguments" # arity issue

  fails "Enumerator#with_index returns the object being enumerated when given a block"
  fails "Enumerator#with_index numbers indices from the given index when given an offset but no block"
  fails "Enumerator#with_index numbers indices from the given index when given an offset and block"
  fails "Enumerator#with_index converts non-numeric arguments to Integer via #to_int"
  fails "Enumerator#with_index coerces the given numeric argument to an Integer"
  fails "Enumerator#with_index accepts negative argument"
end
