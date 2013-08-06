opal_filter "Array#zip" do
  fails "Array#zip calls #to_ary to convert the argument to an Array"
  fails "Array#zip uses #each to extract arguments' elements when #to_ary fails"
end
