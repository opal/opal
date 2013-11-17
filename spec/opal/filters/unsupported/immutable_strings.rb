opal_filter "immutable strings" do
  fails "Array#fill does not replicate the filler"

  fails "Hash literal freezes string keys on initialization"

  fails "Time#strftime formats time according to the directives in the given format string"
  fails "Time#strftime with %z formats a local time with positive UTC offset as '+HHMM'"
  fails "Time#strftime with %z formats a local time with negative UTC offset as '-HHMM'"

  fails "String#chomp when passed no argument returns a copy of the String when it is not modified"

  fails "String#chop returns a new string when applied to an empty string"

  fails "String#chop! removes the final character"
  fails "String#chop! removes the final carriage return"
  fails "String#chop! removes the final newline"
  fails "String#chop! removes the final carriage return, newline"
  fails "String#chop! removes the carrige return, newline if they are the only characters"
  fails "String#chop! does not remove more than the final carriage return, newline"
  fails "String#chop! returns self if modifications were made"
  fails "String#chop! returns nil when called on an empty string"
  fails "String#chop! raises a RuntimeError on a frozen instance that is modified"
  fails "String#chop! raises a RuntimeError on a frozen instance that would not be modified"
end
