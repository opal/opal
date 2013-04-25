opal_filter "Kernel#instance_variables" do
  fails "A class definition allows the definition of class-level instance variables in a class method"
end
