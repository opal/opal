opal_filter "Module#class_variables" do
  fails "A class definition has no class variables"
  fails "A class definition allows the declaration of class variables in the body"
  fails "A class definition allows the declaration of class variables in a class method"
  fails "A class definition allows the declaration of class variables in an instance method"
end
