opal_filter "Hash" do
  fails "Hash#== compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#== computes equality for complex recursive hashes"
  fails "Hash#== computes equality for recursive hashes & arrays"
  fails "Hash#[] compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#[] does not create copies of the immediate default value" # spec uses mutable string
  fails "Hash#each yields the key only to a block expecting |key,|" # procs in Opal do not have access to this info (yet)
  fails "Hash#each_pair yields the key only to a block expecting |key,|" # procs in Opal do not have access to this info (yet)
  fails "Hash#eql? compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#eql? computes equality for complex recursive hashes"
  fails "Hash#eql? computes equality for recursive hashes & arrays"
  fails "Hash#fetch raises an ArgumentError when not passed one or two arguments" # arity issue?
  fails "Hash#hash returns the same hash for recursive hashes through arrays"
  fails "Hash#hash returns the same hash for recursive hashes"
  fails "Hash#invert compares new keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash.new raises an ArgumentError if more than one argument is passed" # arity issue?
end
