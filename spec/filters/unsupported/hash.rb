# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Hash" do
  fails "Hash#[]= duplicates and freezes string keys"
  fails "Hash#[]= duplicates string keys using dup semantics" # TypeError: can't define singleton
  fails "Hash#assoc only returns the first matching key-value pair for identity hashes"
  fails "Hash#initialize is private"
  fails "Hash#inspect does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive 'inspect' exactly 1 times but received it 0 times
  fails "Hash#inspect returns a tainted string if self is tainted and not empty"
  fails "Hash#inspect returns an untrusted string if self is untrusted and not empty"
  fails "Hash#store duplicates and freezes string keys"
  fails "Hash#store duplicates string keys using dup semantics" # TypeError: can't define singleton
  fails "Hash#to_a returns a tainted array if self is tainted"
  fails "Hash#to_a returns an untrusted array if self is untrusted"
  fails "Hash#to_proc the returned proc passed as a block to instance_exec always retrieves the original hash's values"
  fails "Hash#to_proc the returned proc raises ArgumentError if not passed exactly one argument"
  fails "Hash#to_s does not raise if inspected result is not default external encoding" # Mock 'utf_16be' expected to receive 'inspect' exactly 1 times but received it 0 times
  fails "Hash#to_s returns a tainted string if self is tainted and not empty"
  fails "Hash#to_s returns an untrusted string if self is untrusted and not empty"
end
