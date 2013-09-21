opal_filter "String" do
  fails "String#center with length, padding pads with whitespace if no padstr is given"
  fails "String#center with length, padding returns a new string of specified length with self centered and padded with padstr"

  fails "String#lines should split on the default record separator and return enumerator if not block is given"
end
