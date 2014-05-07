opal_filter "RegExp" do
  fails "Regexp#eql? is true if self and other have the same character set code"
  fails "Regexp#== is true if self and other have the same character set code"
  fails "Regexp#~ matches against the contents of $_"
  fails "Regexp#match uses the start as a character offset"
  fails "Regexp#match matches the input at a given position"
  fails "Regexp#match with [string, position] when given a positive position matches the input at a given position"
  fails "Regexp#match with [string, position] when given a negative position matches the input at a given position"
  fails "MatchData#regexp returns the pattern used in the match"
  fails "MatchData#values_at when passed a Range returns an array of the matching value"
end
