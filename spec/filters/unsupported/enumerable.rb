# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Enumerable" do
  fails "Enumerable#chunk does not return elements for which the block returns :_separator"
  fails "Enumerable#chunk raises a RuntimeError if the block returns a Symbol starting with an underscore other than :_alone or :_separator"
  fails "Enumerable#chunk with [initial_state] yields an element and an object value-equal but not identical to the object passed to #chunk"
  fails "Enumerable#entries returns a tainted array if self is tainted"
  fails "Enumerable#entries returns an untrusted array if self is untrusted"
  fails "Enumerable#group_by returns a tainted hash if self is tainted"
  fails "Enumerable#group_by returns an untrusted hash if self is untrusted"
  fails "Enumerable#to_a returns a tainted array if self is tainted"
  fails "Enumerable#to_a returns an untrusted array if self is untrusted"
end
