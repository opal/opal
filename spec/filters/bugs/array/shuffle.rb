opal_filter "Array#shuffle" do
  fails "Array#shuffle uses given random generator"
  fails "Array#shuffle uses default random generator"
  fails "Array#shuffle attempts coercion via #to_hash"
  fails "Array#shuffle is not destructive"
  fails "Array#shuffle returns the same values, in a usually different order"
end

opal_filter "Array#shuffle!" do
  fails "Array#shuffle! returns the same values, in a usually different order"
end
