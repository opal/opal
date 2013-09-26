opal_filter "Class" do
  fails "Class.new raises a TypeError if passed a metaclass"
  fails "Class.new creates a class that can be given a name by assigning it to a constant"
  fails "Class.new raises a TypeError when given a non-Class"
  fails "Class#new passes the block to #initialize"
end
