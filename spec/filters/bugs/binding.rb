# NOTE: run bin/format-filters after changing this file
opal_filter "Binding" do
  fails "Binding#clone is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x1c7b0>
  fails "Binding#clone returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x1c958>
  fails "Binding#dup is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x67b30>
  fails "Binding#dup returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x67cd8>
  fails "Binding#eval behaves like Kernel.eval(..., self)" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x8e1d4>
  fails "Binding#eval does not leak variables to cloned bindings" # Expected [] == ["x"] to be truthy but was false
  fails "Binding#eval reflects refinements activated in the binding scope" # NameError: uninitialized constant BindingSpecs::Refined
  fails "Binding#eval starts with a __LINE__ from the third argument if passed" # Expected 1 == 88 to be truthy but was false
  fails "Binding#eval starts with line 1 if the Binding is created with #send" # RuntimeError: Opal doesn't support dynamic calls to binding
  fails "Binding#eval with __method__ returns the method where the Binding was created" # Expected nil == "get_binding_and_method" to be truthy but was false
  fails "Binding#eval with __method__ returns the method where the Binding was created, ignoring #send" # Expected nil == "get_binding_with_send_and_method" to be truthy but was false
  fails "Binding#irb creates an IRB session with the binding in scope" # NoMethodError: undefined method `popen' for IO
  fails "Binding#local_variable_defined? allows usage of an object responding to #to_str as the variable name" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using Binding#local_variable_set" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using eval()" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_get gets a local variable defined using eval()" # Exception: number is not defined
  fails "Binding#local_variable_set adds nonexistent variables to the binding's eval scope" # NoMethodError: undefined method `local_variables' for #<BindingSpecs::Demo:0x77602>
  fails "Binding#local_variable_set raises a NameError on global access" # Expected NameError but no exception was raised ("" was returned)
  fails "Binding#local_variable_set raises a NameError on special variable access" # Expected NameError but got: Exception (Unexpected token '~')
  fails "Binding#local_variable_set sets a local variable using an object responding to #to_str as the variable name" # Exception: Invalid or unexpected token
  fails "Binding#local_variables includes local variables defined after calling binding.local_variables" # Expected [] == ["a", "b"] to be truthy but was false
  fails "Binding#local_variables includes local variables of inherited scopes and eval'ed context" # Expected ["c"] == ["c", "a", "b", "p"] to be truthy but was false
  fails "Binding#local_variables includes new variables defined in the binding" # Expected ["b"] == ["a", "b"] to be truthy but was false
end
