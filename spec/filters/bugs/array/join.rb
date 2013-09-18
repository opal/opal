opal_filter "Array#join" do
  fails "Array#join calls #to_str to convert the separator to a String"
  fails "Array#join does not call #to_str on the separator if the array is empty"
  fails "Array#join raises a TypeError if the separator cannot be coerced to a String by calling #to_str"
  fails "Array#join raises a TypeError if passed false as the separator"
end
