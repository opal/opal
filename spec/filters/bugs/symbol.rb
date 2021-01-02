# NOTE: run bin/format-filters after changing this file
opal_filter "Symbol" do
  fails "Symbol#to_proc produces a Proc that always returns [[:rest]] for #parameters" # Expected [["rest", "args"], ["block", "block"]] == [["rest"]] to be truthy but was false
end
