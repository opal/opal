opal_filter "RegExp" do
  fails "Regexp#~ matches against the contents of $_"
  fails "Regexp#match uses the start as a character offset"
  fails "Regexp#match matches the input at a given position"
  fails "Regexp#match with [string, position] when given a positive position matches the input at a given position"
  fails "Regexp#match with [string, position] when given a negative position matches the input at a given position"
end
