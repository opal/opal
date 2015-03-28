opal_filter "regular_expressions" do
  fails "MatchData#offset returns the offset for multi byte strings with unicode regexp"

  fails "String#sub with pattern, replacement supports \\G which matches at the beginning of the string"
end
