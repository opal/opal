opal_filter "arrays" do
  fails "The unpacking splat operator (*) returns a new array containing the same values when applied to an array inside an empty array"
  fails "The unpacking splat operator (*) unpacks the start and count arguments in an array slice assignment"
  fails "The unpacking splat operator (*) unpacks arguments as if they were listed statically"
end
