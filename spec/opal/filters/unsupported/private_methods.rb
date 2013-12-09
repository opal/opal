opal_filter "Private methods" do
  fails "Array#initialize is private"
  fails "The defined? keyword when called with a method name having a module as a receiver returns nil if the method is private"
  fails "Array#initialize_copy is private"

  fails "BasicObject#initialize is a private instance method"
  fails "BasicObject#method_missing is a private method"
  fails "BasicObject#!= is a public instance method"
  fails "BasicObject#! is a public instance method"

  fails "Hash#initialize_copy is private"
  fails "Hash#initialize is private"

  fails "Struct#initialize is private"

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

  fails "The private keyword changes the visibility of the existing method in the subclass"
  fails "The private keyword changes visiblity of previously called methods with same send/call site"
  fails "The private keyword changes visibility of previously called method"
  fails "The private keyword is overridden when a new class is opened"
  fails "The private keyword marks following methods as being private"

  fails "Class.inherited is called when marked as a public class method"
  fails "Class#initialize is private"
end
