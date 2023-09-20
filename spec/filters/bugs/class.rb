# NOTE: run bin/format-filters after changing this file
opal_filter "Class" do
  fails "Class#allocate raises TypeError for #superclass" # Expected TypeError but no exception was raised (nil was returned)
  fails "Class#dup raises TypeError if called on BasicObject" # Expected TypeError (can't copy the root class) but got: Exception (Cannot read properties of null (reading '$$is_number'))
  fails "Class#initialize raises a TypeError when called on BasicObject" # Expected TypeError but no exception was raised (nil was returned)
  fails "Class#initialize raises a TypeError when called on already initialized classes" # Expected TypeError but no exception was raised (nil was returned)
  fails "Class#initialize when given the Class raises a TypeError" # Expected TypeError but got: ArgumentError ([.initialize] wrong number of arguments (given 1, expected 0))
  fails "Class#new uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Class#subclasses works when creating subclasses concurrently" # NotImplementedError: Thread creation not available
  fails "Class.new raises a TypeError if passed a metaclass" # Expected TypeError but no exception was raised (#<Class:0x34cae> was returned)
  fails_badly "Class#descendants returns a list of classes descended from self (excluding self)" # GC/Spec order issue. Expected [#<Class:0x2e77c>,  #<Class:0x2e79a>,  #<Class:0x37368>,  ModuleSpecs::Child,  ModuleSpecs::Child2,  ModuleSpecs::Grandchild] == [ModuleSpecs::Child, ModuleSpecs::Child2, ModuleSpecs::Grandchild] to be truthy but was false
  fails_badly "Class#subclasses returns a list of classes directly inheriting from self" # GC/Spec order issue. Expected [#<Class:0x2e77c>,  #<Class:0x2e79a>,  #<Class:0x37368>,  ModuleSpecs::Child,  ModuleSpecs::Child2] == [ModuleSpecs::Child, ModuleSpecs::Child2] to be truthy but was false
end
