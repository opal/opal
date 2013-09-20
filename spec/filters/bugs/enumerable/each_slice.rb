opal_filter "Enumerable#each_slice" do
  fails "Enumerable#each_slice tries to convert n to an Integer using #to_int"
  fails "Enumerable#each_slice raises an Argument Error if there is not a single parameter > 0"
  fails "Enumerable#each_slice yields only as much as needed"
  fails "Enumerable#each_slice gathers whole arrays as elements when each yields multiple"
  fails "Enumerable#each_slice returns an enumerator if no block"
end
