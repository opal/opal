opal_filter "immutable strings" do
  fails "Array#fill does not replicate the filler"

  fails "Hash literal freezes string keys on initialization"

  fails "Time#strftime formats time according to the directives in the given format string"
  fails "Time#strftime with %z formats a local time with positive UTC offset as '+HHMM'"
  fails "Time#strftime with %z formats a local time with negative UTC offset as '-HHMM'"
end
