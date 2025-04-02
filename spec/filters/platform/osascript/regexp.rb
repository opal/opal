# NOTE: run bin/format-filters after changing this file
opal_filter "regular_expressions" do
  fails "Literal Regexps is frozen" # Expected /Hello/.frozen? to be truthy but was false
  fails "Regexp#initialize raises a FrozenError on a Regexp literal" # Expected FrozenError but no exception was raised (nil was returned)
end
