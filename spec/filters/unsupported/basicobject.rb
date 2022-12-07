# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "BasicObject" do
  fails "BasicObject#method_missing for a Class raises a NoMethodError when a private method is called" # Expected NoMethodError but no exception was raised ("class_private_method" was returned)
  fails "BasicObject#method_missing for a Class raises a NoMethodError when a protected method is called" # Expected NoMethodError but no exception was raised ("class_private_method" was returned)
  fails "BasicObject#method_missing for a Class with #method_missing defined is called when an private method is called" # Expected "class_private_method" == "class_method_missing" to be truthy but was false
  fails "BasicObject#method_missing for a Class with #method_missing defined is called when an protected method is called" # Expected "class_private_method" == "class_method_missing" to be truthy but was false
  fails "BasicObject#method_missing for a Module raises a NoMethodError when a private method is called" # Expected NoMethodError but no exception was raised ("module_private_method" was returned)
  fails "BasicObject#method_missing for a Module raises a NoMethodError when a protected method is called" # Expected NoMethodError but no exception was raised ("module_private_method" was returned)
  fails "BasicObject#method_missing for a Module with #method_missing defined is called when a private method is called" # Expected "module_private_method" == "module_method_missing" to be truthy but was false
  fails "BasicObject#method_missing for a Module with #method_missing defined is called when a protected method is called" # Expected "module_private_method" == "module_method_missing" to be truthy but was false
  fails "BasicObject#method_missing for an instance raises a NoMethodError when a private method is called" # Expected NoMethodError but no exception was raised ("instance_private_method" was returned)
  fails "BasicObject#method_missing for an instance raises a NoMethodError when a protected method is called" # Expected NoMethodError but no exception was raised ("instance_private_method" was returned)
  fails "BasicObject#method_missing for an instance with #method_missing defined is called when an private method is called" # Expected "instance_private_method" == "instance_method_missing" to be truthy but was false
  fails "BasicObject#method_missing for an instance with #method_missing defined is called when an protected method is called" # Expected "instance_private_method" == "instance_method_missing" to be truthy but was false
end
