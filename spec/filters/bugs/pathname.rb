# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname.glob raises an ArgumentError when supplied a keyword argument other than :base" # Expected ArgumentError (unknown keyword: :?foo) but no exception was raised ([] was returned)
end
