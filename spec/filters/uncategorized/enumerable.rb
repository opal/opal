opal_filter "Enumerable" do
  fails "Enumerable#chunk with [initial_state] yields an element and an object value-equal but not identical to the object passed to #chunk"
  fails "Enumerable#chunk with [initial_state] does not yield the object passed to #chunk if it is nil"
  fails "Enumerable#entries returns a tainted array if self is tainted"
  fails "Enumerable#entries returns an untrusted array if self is untrusted"
  fails "Enumerable#group_by returns a tainted hash if self is tainted"
  fails "Enumerable#group_by returns an untrusted hash if self is untrusted"
  fails "Enumerable#minmax returns the minimum when using a block rule"
  fails "Enumerable#sort sorts by the natural order as defined by <=>"
  fails "Enumerable#take_while calls the block with initial args when yielded with multiple arguments"
  fails "Enumerable#to_a returns a tainted array if self is tainted"
  fails "Enumerable#to_a returns an untrusted array if self is untrusted"
end
