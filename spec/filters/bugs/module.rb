opal_filter "Module" do
  fails "A class definition has no class variables"
  fails "A class definition allows the declaration of class variables in the body"
  fails "A class definition allows the declaration of class variables in a class method"
  fails "A class definition allows the declaration of class variables in an instance method"

  fails "Module#method_defined? converts the given name to a string using to_str"
  fails "Module#method_defined? raises a TypeError when the given object is not a string/symbol/fixnum"
  fails "Module#method_defined? does not search Object or Kernel when called on a module"
  fails "Module#method_defined? returns true if a public or private method with the given name is defined in self, self's ancestors or one of self's included modules"

  fails "Module#const_defined? should not search parent scopes of classes and modules if inherit is false"
  fails "Module#const_get should not search parent scopes of classes and modules if inherit is false"

  fails "Module#class_variable_set sets the value of a class variable with the given name defined in an included module"
  fails "Module#class_variable_get returns the value of a class variable with the given name defined in an included module"

  fails "Module#module_function as a toggle (no arguments) in a Module body functions normally if both toggle and definitions inside a eval"
  fails "Module#module_function as a toggle (no arguments) in a Module body does not affect definitions when inside an eval even if the definitions are outside of it"

  fails "Module#module_function is a private method"
  fails "Module#module_function on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#module_function with specific method names makes the instance methods private"
  fails "Module#module_function with specific method names makes the new Module methods public"
  fails "Module#module_function with specific method names tries to convert the given names to strings using to_str"
  fails "Module#module_function with specific method names raises a TypeError when the given names can't be converted to string using to_str"
  fails "Module#module_function with specific method names can make accessible private methods"
  fails "Module#module_function as a toggle (no arguments) in a Module body does not affect module_evaled method definitions also if outside the eval itself"
  fails "Module#module_function as a toggle (no arguments) in a Module body has no effect if inside a module_eval if the definitions are outside of it"
  fails "Module#module_function with specific method names creates an independent copy of the method, not a redirect"
end
