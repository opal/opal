opal_filter "Regexp" do
  fails "Regexp#match with [string, position] when given a positive position matches the input at a given position"
  fails "Regexp#match with [string, position] when given a negative position matches the input at a given position"
end
