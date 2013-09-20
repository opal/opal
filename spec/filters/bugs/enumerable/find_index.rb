opal_filter "Enumerable#find_index" do
  fails "Enumerable#find_index returns an Enumerator if no block given"
  fails "Enumerable#find_index gathers initial args as elements when each yields multiple"
end
