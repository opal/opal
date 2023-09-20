# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Hash" do
  fails "Hash#[] compares key via hash" # Mock '0' expected to receive hash("any_args") exactly 1 times but received it 0 times (performance optimization)
  fails "Hash#[]= duplicates and freezes string keys" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "Hash#[]= duplicates string keys using dup semantics" # TypeError: can't define singleton
  fails "Hash#assoc only returns the first matching key-value pair for identity hashes" # Expected 1 == 2 to be truthy but was false
  fails "Hash#initialize is private" # Expected Hash to have private instance method 'initialize' but it does not
  fails "Hash#inspect does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive inspect("any_args") exactly 1 times but received it 0 times
  fails "Hash#store duplicates and freezes string keys" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "Hash#store duplicates string keys using dup semantics" # TypeError: can't define singleton
  fails "Hash#to_proc the returned proc passed as a block to instance_exec always retrieves the original hash's values" # Expected nil == 1 to be truthy but was false
  fails "Hash#to_proc the returned proc raises ArgumentError if not passed exactly one argument" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "Hash#to_s does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive inspect("any_args") exactly 1 times but received it 0 times
end
