opal_filter "String#center" do
  fails "String#center with length, padding pads with whitespace if no padstr is given"
  fails "String#center with length, padding returns a new string of specified length with self centered and padded with padstr"
end
