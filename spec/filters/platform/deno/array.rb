# NOTE: run bin/format-filters after changing this file
opal_filter "Array" do
  fails "Array#inspect does not call #to_s on a String returned from #inspect" # Exception: Cannot create property '$$meta' on string 'abc'
  fails "Array#join uses the widest common encoding when other strings are incompatible" # FrozenError: can't modify frozen String
  fails "Array#to_s does not call #to_s on a String returned from #inspect" # Exception: Cannot create property '$$meta' on string 'abc'
end
