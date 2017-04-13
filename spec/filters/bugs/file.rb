opal_filter "File" do
  fails "File.join returns a duplicate string when given a single argument"
  fails "File.join raises a TypeError exception when args are nil"
  fails "File.join calls #to_str"
  fails "File.join calls #to_path"
  fails "File.join raises an ArgumentError if passed a recursive array"
  fails "File.join inserts the separator in between empty strings and arrays"
end
