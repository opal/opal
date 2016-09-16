opal_unsupported_filter "BasicObject" do
  fails "BasicObject#method_missing for a Class raises a NoMethodError when a private method is called"
  fails "BasicObject#method_missing for a Class raises a NoMethodError when a protected method is called"
  fails "BasicObject#method_missing for a Class with #method_missing defined is called when an private method is called"
  fails "BasicObject#method_missing for a Class with #method_missing defined is called when an protected method is called"
  fails "BasicObject#method_missing for a Module raises a NoMethodError when a private method is called"
  fails "BasicObject#method_missing for a Module raises a NoMethodError when a protected method is called"
  fails "BasicObject#method_missing for a Module with #method_missing defined is called when a private method is called"
  fails "BasicObject#method_missing for a Module with #method_missing defined is called when a protected method is called"
  fails "BasicObject#method_missing for an instance raises a NoMethodError when a private method is called"
  fails "BasicObject#method_missing for an instance raises a NoMethodError when a protected method is called"
  fails "BasicObject#method_missing for an instance with #method_missing defined is called when an private method is called"
  fails "BasicObject#method_missing for an instance with #method_missing defined is called when an protected method is called"
end
