opal_filter "Hash" do
  fails "Hash#== compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#== computes equality for complex recursive hashes"
  fails "Hash#== computes equality for recursive hashes & arrays"
  fails "Hash#[] compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#[] does not create copies of the immediate default value" # spec uses mutable string
  fails "Hash#[]= keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
  fails "Hash#delete allows removing a key while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#eql? compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#eql? computes equality for complex recursive hashes"
  fails "Hash#eql? computes equality for recursive hashes & arrays"
  fails "Hash#invert compares new keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#shift allows shifting entries while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#store keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
end
