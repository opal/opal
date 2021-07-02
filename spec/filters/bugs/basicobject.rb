# NOTE: run bin/format-filters after changing this file
opal_filter "BasicObject" do
  fails "BasicObject raises NoMethodError for nonexistent methods after #method_missing is removed"
  fails "BasicObject#__send__ raises a TypeError if the method name is not a string or symbol" # NoMethodError: undefined method `' for SendSpecs
  fails "BasicObject#initialize does not accept arguments"
  fails "BasicObject#instance_eval evaluates string with given filename and linenumber"
  fails "BasicObject#instance_eval evaluates string with given filename and negative linenumber" # Expected ["RuntimeError"] to equal ["b_file", "-98"]
  fails "BasicObject#instance_eval has access to the caller's local variables" # Expected nil to equal "value"
  fails "BasicObject#instance_exec binds the block's binding self to the receiver"
  fails "BasicObject#instance_exec raises a LocalJumpError unless given a block"
  fails "BasicObject#method_missing for an instance sets the receiver of the raised NoMethodError"
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined calls #method_missing" # Expected [] == [["singleton_method_added", "foo"],  ["singleton_method_added", "bar"],  ["singleton_method_added", "baz"]] to be truthy but was false
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined raises NoMethodError for a metaclass" # Expected NoMethodError (/undefined method `singleton_method_added' for/) but no exception was raised ("foo" was returned)
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined raises NoMethodError for a singleton instance" # Expected NoMethodError (/undefined method `singleton_method_added' for #<Object:/) but no exception was raised ("foo" was returned)
end
