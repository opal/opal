# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel#__dir__ returns the real name of the directory containing the currently-executing file" # Expected "/Users/jan/workspace/opal/corelib" == "/Users/jan/workspace/opal/ruby/core/kernel" to be truthy but was false
  fails "Kernel#__dir__ when used in eval with a given filename returns File.dirname(filename)" # Expected "/Users/jan/workspace/opal/corelib" == "." to be truthy but was false
  fails "Kernel#caller includes core library methods defined in Ruby"
  fails "Kernel#clone with freeze: anything else raises ArgumentError when passed not true/false/nil" # Expected ArgumentError (unexpected value for freeze: Integer) but got: ArgumentError (unexpected value for freeze: Number)
  fails "Kernel#clone with freeze: false calls #initialize_clone with kwargs freeze: false even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#clone with freeze: true calls #initialize_clone with kwargs freeze: true even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#object_id returns a different value for two Bignum literals" # Expected 161122 == 161122 to be falsy but was true
  fails "Kernel#object_id returns a different value for two String literals" # Expected 120850 == 120850 to be falsy but was true
end
