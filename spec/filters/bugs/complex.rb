# NOTE: run bin/format-filters after changing this file
opal_filter "Complex" do
  fails "Complex#coerce returns an array containing other as Complex and self when other is a Numeric which responds to #real? with true"
  fails "Complex#to_c returns self" # Expected ((1+5i)+0i) to be identical to (1+5i)
  fails "Complex#to_c returns the same value" # Expected ((1+5i)+0i) == (1+5i) to be truthy but was false
end
