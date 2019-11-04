# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Struct" do
  fails "Struct#initialize is private"
  fails "Struct.new does not create a constant with symbol as first argument"
  fails "Struct.new fails with invalid constant name as first argument" # this invalid name gets interpreted as a struct member
  fails "Struct.new raises a TypeError if object is not a Symbol"
end
