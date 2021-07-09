opal_filter "Binding" do
  fails " " # NoMethodError: undefined method `refine' for BindingSpecs::AddFooToString
  fails "Binding#clone is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x1c7b0>
  fails "Binding#clone returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x1c958>
  fails "Binding#dup is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x67b30>
  fails "Binding#dup returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x67cd8>
  fails "Binding#irb creates an IRB session with the binding in scope" # NoMethodError: undefined method `popen' for IO
  fails "Binding#local_variable_defined? allows usage of an object responding to #to_str as the variable name" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using Binding#local_variable_set" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using eval()" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_get gets a local variable defined using eval()" # Exception: number is not defined
  fails "Binding#local_variable_get raises a NameError on global access" # Expected NameError but got: Exception ($0 is not defined)
  fails "Binding#local_variable_get reads variables added later to the binding" # Expected NameError but no exception was raised (42 was returned)
  fails "Binding#local_variable_set adds nonexistent variables to the binding's eval scope" # NoMethodError: undefined method `local_variables' for #<BindingSpecs::Demo:0x77602>
  fails "Binding#local_variable_set raises a NameError on global access" # Expected NameError but no exception was raised ("" was returned)
  fails "Binding#local_variable_set raises a NameError on special variable access" # Expected NameError but got: Exception (Unexpected token '~')
  fails "Binding#local_variable_set sets a local variable using an object responding to #to_str as the variable name" # Exception: Invalid or unexpected token
  fails "Binding#local_variables includes local variables defined after calling binding.local_variables" # Expected [] == ["a", "b"] to be truthy but was false
  fails "Binding#local_variables includes local variables of inherited scopes and eval'ed context" # Expected ["c"] == ["c", "a", "b", "p"] to be truthy but was false
  fails "Binding#local_variables includes new variables defined in the binding" # Expected ["b"] == ["a", "b"] to be truthy but was false
  fails "Proc#curry produces Procs that raise ArgumentError for #binding" # Expected ArgumentError but no exception was raised (#<Binding:0x1ade4> was returned)
end
