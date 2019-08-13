# NOTE: run bin/format-filters after changing this file
opal_filter "Class" do
  fails "Class#allocate raises TypeError for #superclass"
  fails "Class#dup duplicates both the class and the singleton class"
  fails "Class#dup retains an included module in the ancestor chain for the singleton class"
  fails "Class#dup retains the correct ancestor chain for the singleton class"
  fails "Class#initialize raises a TypeError when called on BasicObject"
  fails "Class#initialize raises a TypeError when called on already initialized classes"
  fails "Class#initialize when given the Class raises a TypeError"
  fails "Class#new uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Class.new raises a TypeError if passed a metaclass"
end
