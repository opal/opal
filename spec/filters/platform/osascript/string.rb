# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
end
