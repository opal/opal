# NOTE: run bin/format-filters after changing this file
opal_filter "Hash" do
  fails "Hash#== compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#== computes equality for complex recursive hashes"
  fails "Hash#== computes equality for recursive hashes & arrays"
  fails "Hash#[] compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#[] does not create copies of the immediate default value" # spec uses mutable string
  fails "Hash#[]= keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
  fails "Hash#compare_by_identity gives different identity for string literals" # Expected [2] to equal [1, 2]
  fails "Hash#delete allows removing a key while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#each yields 2 values and not an Array of 2 elements when given a callable of arity 2" # ArgumentError: [Object#foo] wrong number of arguments(1 for 2)
  fails "Hash#each_pair yields 2 values and not an Array of 2 elements when given a callable of arity 2" # ArgumentError: [Object#foo] wrong number of arguments(1 for 2)
  fails "Hash#eql? compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#eql? computes equality for complex recursive hashes"
  fails "Hash#eql? computes equality for recursive hashes & arrays"
  fails "Hash#inspect calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#inspect does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#inspect does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x30638>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#invert compares new keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#rehash removes duplicate keys" # Expected 2 to equal 1
  fails "Hash#shift allows shifting entries while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#store keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
  fails "Hash#to_s calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#to_s does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#to_s does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x1b948>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#transform_keys! prevents conflicts between new keys and old ones" # Expected {"e"=>1} to equal {"b"=>1, "c"=>2, "d"=>3, "e"=>4}
  fails "Hash#transform_keys! returns the processed keys if we broke from the block" # Expected {"c"=>1, "d"=>4} to equal {"b"=>1, "c"=>2}
end
