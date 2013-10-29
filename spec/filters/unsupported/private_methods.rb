opal_filter "Private methods" do
  fails "Array#initialize is private"
  fails "The defined? keyword when called with a method name having a module as a receiver returns nil if the method is private"

  fails "Defining an 'initialize' method sets the method's visibility to private"
  fails "Defining an 'initialize_copy' method sets the method's visibility to private"

  fails "Invoking a private getter method does not permit self as a receiver"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is private"
  fails "The defined? keyword when called with a method name having a module as receiver returns nil if the method is protected"

  fails "SimpleDelegator.new doesn't forward private method calls"
  fails "SimpleDelegator.new doesn't forward private method calls even via send or __send__"
  fails "SimpleDelegator.new forwards protected method calls"

  fails "Set#initialize is private"

  fails "Singleton.allocate is a private method"
  fails "Singleton.new is a private method"
end
