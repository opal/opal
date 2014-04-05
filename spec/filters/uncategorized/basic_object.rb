opal_filter "BasicObject" do
  fails "BasicObject#singleton_method_added is called when a method is defined with alias_method in the singleton class"
  fails "BasicObject#singleton_method_added is called when a method is defined with syntax alias in the singleton class"
end
