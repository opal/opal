opal_filter "Array#drop" do
  fails "Array#drop raises an ArgumentError if the number of elements specified is negative"
end
