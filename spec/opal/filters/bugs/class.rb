opal_filter "Class" do
  fails "Class.new raises a TypeError if passed a metaclass"
  fails "Class#new passes the block to #initialize"
end
