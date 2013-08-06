opal_filter "Enumerable#sort_by" do
  fails "Enumerable#sort_by returns an Enumerator when a block is not supplied"
end
