opal_filter "Enumerable" do
  fails "Enumerable#entries returns a tainted array if self is tainted"
  fails "Enumerable#entries returns an untrusted array if self is untrusted"
  fails "Enumerable#group_by returns a tainted hash if self is tainted"
  fails "Enumerable#group_by returns an untrusted hash if self is untrusted"
  fails "Enumerable#to_a returns a tainted array if self is tainted"
  fails "Enumerable#to_a returns an untrusted array if self is untrusted"
end
