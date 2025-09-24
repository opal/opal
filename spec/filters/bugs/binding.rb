# NOTE: run bin/format-filters after changing this file
opal_filter "Binding" do
  fails "Binding#clone is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x3aa86 @secret=99>
  fails "Binding#clone returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x3ac2e @secret=99>
  fails "Binding#dup is a shallow copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x336ac @secret=99>
  fails "Binding#dup returns a copy of the Binding object" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x33854 @secret=99>
  fails "Binding#eval behaves like Kernel.eval(..., self)" # NoMethodError: undefined method `a' for #<BindingSpecs::Demo:0x4e62 @secret=10>
  fails "Binding#eval does not leak variables to cloned bindings" # Expected [] == ["x"] to be truthy but was false
  fails "Binding#eval reflects refinements activated in the binding scope" # NoMethodError: undefined method `foo' for "bar"
  fails "Binding#eval starts with a __LINE__ from the third argument if passed" # Expected 1 == 88 to be truthy but was false
  fails "Binding#eval starts with line 1 if the Binding is created with #send" # RuntimeError: Opal doesn't support dynamic calls to binding
  fails "Binding#eval with __method__ returns the method where the Binding was created" # Expected nil == "get_binding_and_method" to be truthy but was false
  fails "Binding#eval with __method__ returns the method where the Binding was created, ignoring #send" # RuntimeError: Opal doesn't support dynamic calls to binding
  fails "Binding#irb creates an IRB session with the binding in scope" # NoMethodError: undefined method `popen' for IO
  fails "Binding#local_variable_defined? allows usage of an object responding to #to_str as the variable name" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using Binding#local_variable_set" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_defined? returns true when a local variable is defined using eval()" # Expected false == true to be truthy but was false
  fails "Binding#local_variable_get gets a local variable defined using eval()" # NameError: local variable `number' is not defined for #<Binding:0x47730 @jseval=#<Proc:0x47806> @scope_variables=["bind"] @receiver=#<MSpecEnv:0x4770a> @source_location=["ruby/core/binding/local_variable_get_spec.rb", 40]>
  fails "Binding#local_variable_set adds nonexistent variables to the binding's eval scope" # Expected [] == ["foo"] to be truthy but was false
  fails "Binding#local_variable_set raises a NameError on global access" # Expected NameError but no exception was raised ("" was returned)
  fails "Binding#local_variable_set raises a NameError on special variable access" # Expected NameError but got: Exception (Unexpected token '~')
  fails "Binding#local_variable_set sets a local variable using an object responding to #to_str as the variable name" # Exception: Invalid or unexpected token
  fails "Binding#local_variables includes local variables defined after calling binding.local_variables" # Expected [] == ["a", "b"] to be truthy but was false
  fails "Binding#local_variables includes local variables of inherited scopes and eval'ed context" # Expected ["c"] == ["c", "a", "b", "p"] to be truthy but was false
  fails "Binding#local_variables includes new variables defined in the binding" # Expected ["b"] == ["a", "b"] to be truthy but was false
  fails "Binding#source_location works for eval with a given line" # Expected ["foo", 1] == ["foo", 100] to be truthy but was false
  fails "Proc#binding returns a Binding instance" # RuntimeError: Evaluation on a Proc#binding is not supported
end
