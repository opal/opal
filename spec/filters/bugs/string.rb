opal_filter "String" do
  fails "String#center with length, padding pads with whitespace if no padstr is given"
  fails "String#center with length, padding returns a new string of specified length with self centered and padded with padstr"

  fails "String#lines should split on the default record separator and return enumerator if not block is given"

  fails "String#upcase is locale insensitive (only replaces a-z)"
  fails "String#size returns the length of self"
  fails "String#length returns the length of self"

  fails "String#index with Regexp converts start_offset to an integer via to_int"
  fails "String#index with Regexp supports \\G which matches at the given start offset"
  fails "String#index with Regexp starts the search at the given offset"
  fails "String#index with Regexp returns the index of the first match of regexp"
  fails "String#index calls #to_int to convert the second argument"
  fails "String#index calls #to_str to convert the first argument"
  fails "String#index raises a TypeError if passed a Symbol"
end
