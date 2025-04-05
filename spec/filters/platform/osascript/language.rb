# NOTE: run bin/format-filters after changing this file
opal_filter "language" do
  fails "The defined? keyword for a simple constant returns 'constant' when the constant is defined" # Expected false == true to be truthy but was false
  fails "The defined? keyword for an expression returns 'assignment' for assigning a local variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals for a literal Array returns 'expression' if each element is defined" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'false' for false" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'nil' for nil" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'self' for self" # Expected false == true to be truthy but was false
  fails "The defined? keyword for literals returns 'true' for true" # Expected false == true to be truthy but was false
  fails "The defined? keyword for super for a method taking no arguments returns 'super' when a superclass method exists" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'class variable' when called with the name of a class variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'global-variable' for a global variable that has been assigned nil" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'instance-variable' for an instance variable that has been assigned" # Expected false == true to be truthy but was false
  fails "The defined? keyword for variables returns 'local-variable' when called with the name of a local variable" # Expected false == true to be truthy but was false
  fails "The defined? keyword for yield returns 'yield' if a block is passed to a method not taking a block parameter" # Expected false == true to be truthy but was false
  fails "The defined? keyword when called with a method name without a receiver returns 'method' if the method is defined" # Expected false == true to be truthy but was false
end
