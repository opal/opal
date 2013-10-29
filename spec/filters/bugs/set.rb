opal_filter "Set" do
  fails "Set#== returns true when the passed Object is a Set and self and the Object contain the same elements"
  fails "Set#== does not depend on the order of nested Sets"
  fails "Set#merge raises an ArgumentError when passed a non-Enumerable"

  fails "Emumerable#to_set allows passing an alternate class for Set"
end
