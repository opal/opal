opal_filter "Array.new" do
  fails "Array.new with (size, object=nil) raises an ArgumentError if size is too large"
end
