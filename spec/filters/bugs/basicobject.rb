# NOTE: run bin/format-filters after changing this file
opal_filter "BasicObject" do
  fails "BasicObject raises NoMethodError for nonexistent methods after #method_missing is removed"
  fails "BasicObject#initialize does not accept arguments"
  fails "BasicObject#instance_eval converts filename argument with #to_str method" # Expected "<internal" == "file.rb" to be truthy but was false
  fails "BasicObject#instance_eval converts lineno argument with #to_int method" # Expected "corelib/kernel.rb>" == "15" to be truthy but was false
  fails "BasicObject#instance_eval converts string argument with #to_str method" # NoMethodError: undefined method `encoding' for #<Object:0x4b3c2>
  fails "BasicObject#instance_eval evaluates string with given filename and linenumber"
  fails "BasicObject#instance_eval evaluates string with given filename and negative linenumber" # Expected ["RuntimeError"] to equal ["b_file", "-98"]
  fails "BasicObject#instance_eval has access to the caller's local variables" # Expected nil to equal "value"
  fails "BasicObject#instance_eval raises ArgumentError if returned value is not Integer" # Expected TypeError (/can't convert Object to Integer/) but got: RuntimeError ()
  fails "BasicObject#instance_eval raises ArgumentError if returned value is not String" # Expected TypeError (/can't convert Object to String/) but got: NoMethodError (undefined method `encoding' for #<Object:0x4ab70>)
  fails "BasicObject#instance_eval raises an ArgumentError when a block and normal arguments are given" # Expected ArgumentError (wrong number of arguments (given 2, expected 0)) but got: ArgumentError (wrong number of arguments (2 for 0))
  fails "BasicObject#instance_eval raises an ArgumentError when more than 3 arguments are given" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but got: ArgumentError (wrong number of arguments (0 for 1..3))
  fails "BasicObject#instance_eval raises an ArgumentError when no arguments and no block are given" # Expected ArgumentError (wrong number of arguments (given 0, expected 1..3)) but got: ArgumentError (wrong number of arguments (0 for 1..3))
  fails "BasicObject#instance_exec raises a LocalJumpError unless given a block"
  fails "BasicObject#method_missing for an instance sets the receiver of the raised NoMethodError"
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined calls #method_missing" # Expected [] == [["singleton_method_added", "foo"],  ["singleton_method_added", "bar"],  ["singleton_method_added", "baz"]] to be truthy but was false
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined raises NoMethodError for a metaclass" # Expected NoMethodError (/undefined method `singleton_method_added' for/) but no exception was raised ("foo" was returned)
  fails "BasicObject#singleton_method_added when singleton_method_added is undefined raises NoMethodError for a singleton instance" # Expected NoMethodError (/undefined method `singleton_method_added' for #<Object:/) but no exception was raised ("foo" was returned)
end
