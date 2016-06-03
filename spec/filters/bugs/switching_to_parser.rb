opal_filter "To fix in spec/language:" do
  # next_spec
  fails "The next statement from within the block returns to the invoking method, with the specified value"

  # for_spec
  fails "The for expression executes code in containing variable scope with 'do'"
  fails "The for expression executes code in containing variable scope"
end

opal_filter 'To fix in corelib/**:' do
  # hash
  fails "Hash#default_proc= uses :to_proc on its argument" # looks like it didn't work before, returning value must be a passed argument

  # string
  fails "String#rindex with Regexp returns nil if the substring isn't found"
end
