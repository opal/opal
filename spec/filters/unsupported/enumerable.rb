# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Enumerable" do
  fails "Enumerable#chunk does not return elements for which the block returns :_separator" # Expected [[1, [1]], ["_separator", [2]], [1, [3, 3]], ["_separator", [2]], [1, [1]]] == [[1, [1]], [1, [3, 3]], [1, [1]]] to be truthy but was false
  fails "Enumerable#chunk raises a RuntimeError if the block returns a Symbol starting with an underscore other than :_alone or :_separator" # Expected RuntimeError but no exception was raised ([["_arbitrary", [1, 2, 3, 2, 1]]] was returned)  
end
