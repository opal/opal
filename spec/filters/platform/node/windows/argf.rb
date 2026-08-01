# NOTE: run bin/format-filters after changing this file
opal_filter "ARGF" do
  fails "ARGF.binmode puts reading into binmode" # Expected  "test\r " ==  "test " to be truthy but was false
end
