opal_filter "MatchData" do
  fails "MatchData#regexp returns the pattern used in the match"
  fails "MatchData#values_at when passed a Range returns an array of the matching value"

  fails "MatchData#[Symbol] returns the corresponding named match when given a Symbol"
  fails "MatchData#[Symbol] returns the corresponding named match when given a String"
  fails "MatchData#[Symbol] returns the matching version of multiple corresponding named match"
  fails "MatchData#[Symbol] returns the last match when multiple named matches exist with the same name"
  fails "MatchData#[Symbol] returns nil on non-matching named matches"
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the Symbol"
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the String"
  fails "MatchData#[Symbol] returns matches in the String's encoding"
end
