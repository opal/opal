# NOTE: run bin/format-filters after changing this file
opal_filter "Hash" do
  fails "Hash#== compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#== computes equality for complex recursive hashes"
  fails "Hash#== computes equality for recursive hashes & arrays"
  fails "Hash#[] compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#[] does not create copies of the immediate default value" # spec uses mutable string
  fails "Hash#[] does not dispatch to hash for Boolean, Integer, Float, String, or Symbol" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Hash#[]= does not dispatch to hash for Boolean, Integer, Float, String, or Symbol" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Hash#[]= keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
  fails "Hash#compare_by_identity gives different identity for string literals" # Expected [2] to equal [1, 2]
  fails "Hash#deconstruct_keys ignores argument" # NoMethodError: undefined method `deconstruct_keys' for {"a"=>1, "b"=>2}
  fails "Hash#deconstruct_keys requires one argument" # Expected ArgumentError (/wrong number of arguments \(given 0, expected 1\)/) but got: NoMethodError (undefined method `deconstruct_keys' for {"a"=>1})
  fails "Hash#deconstruct_keys returns self" # NoMethodError: undefined method `deconstruct_keys' for {"a"=>1, "b"=>2}
  fails "Hash#delete allows removing a key while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#each always yields an Array of 2 elements, even when given a callable of arity 2" # Expected ArgumentError but no exception was raised ({"a"=>1} was returned)
  fails "Hash#each yields 2 values and not an Array of 2 elements when given a callable of arity 2" # ArgumentError: [Object#foo] wrong number of arguments(1 for 2)
  fails "Hash#each_pair always yields an Array of 2 elements, even when given a callable of arity 2" # Expected ArgumentError but no exception was raised ({"a"=>1} was returned)
  fails "Hash#each_pair yields 2 values and not an Array of 2 elements when given a callable of arity 2" # ArgumentError: [Object#foo] wrong number of arguments(1 for 2)
  fails "Hash#eql? compares keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#eql? computes equality for complex recursive hashes"
  fails "Hash#eql? computes equality for recursive hashes & arrays"
  fails "Hash#except always returns a Hash without a default" # NoMethodError: undefined method `except' for {"bar"=>12, "foo"=>42}
  fails "Hash#except ignores keys not present in the original hash" # NoMethodError: undefined method `except' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#except returns a hash without the requested subset" # NoMethodError: undefined method `except' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#except returns a new duplicate hash without arguments" # NoMethodError: undefined method `except' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#filter processes entries with the same order as reject" # NoMethodError: undefined method `filter' for {"a"=>9, "c"=>4, "b"=>5, "d"=>2}
  fails "Hash#filter returns a Hash of entries for which block is true" # NoMethodError: undefined method `filter' for {"a"=>9, "c"=>4, "b"=>5, "d"=>2}
  fails "Hash#filter returns an Enumerator if called on a non-empty hash without a block" # NoMethodError: undefined method `filter' for {1=>2, 3=>4, 5=>6}
  fails "Hash#filter returns an Enumerator if called on an empty hash without a block" # NoMethodError: undefined method `filter' for {}
  fails "Hash#filter returns an Enumerator when called on a non-empty hash without a block" # NoMethodError: undefined method `filter' for {1=>2, 3=>4, 5=>6}
  fails "Hash#filter returns an Enumerator when called on an empty hash without a block" # NoMethodError: undefined method `filter' for {}
  fails "Hash#filter when no block is given returned Enumerator size returns the enumerable size" # NoMethodError: undefined method `filter' for {1=>2, 3=>4, 5=>6}
  fails "Hash#filter yields two arguments: key and value" # NoMethodError: undefined method `filter' for {1=>2, 3=>4}
  fails "Hash#filter! is equivalent to keep_if if changes are made" # NoMethodError: undefined method `filter!' for {"a"=>2}
  fails "Hash#filter! removes all entries if the block is false" # NoMethodError: undefined method `filter!' for {"a"=>1, "b"=>2, "c"=>3}
  fails "Hash#filter! returns an Enumerator if called on a non-empty hash without a block" # NoMethodError: undefined method `filter!' for {1=>2, 3=>4, 5=>6}
  fails "Hash#filter! returns an Enumerator if called on an empty hash without a block" # NoMethodError: undefined method `filter!' for {}
  fails "Hash#filter! returns nil if no changes were made" # NoMethodError: undefined method `filter!' for {"a"=>1}
  fails "Hash#filter! when no block is given returned Enumerator size returns the enumerable size" # NoMethodError: undefined method `filter!' for {1=>2, 3=>4, 5=>6}
  fails "Hash#inspect calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#inspect does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#inspect does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x30638>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#inspect does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#invert compares new keys with eql? semantics" # spec relies on integer and float being different
  fails "Hash#merge accepts multiple hashes" # ArgumentError: [Hash#merge] wrong number of arguments(3 for 1)
  fails "Hash#merge accepts zero arguments and returns a copy of self" # ArgumentError: [Hash#merge] wrong number of arguments(0 for 1)
  fails "Hash#merge! accepts multiple hashes" # ArgumentError: [Hash#merge!] wrong number of arguments(3 for 1)
  fails "Hash#merge! accepts zero arguments" # ArgumentError: [Hash#merge!] wrong number of arguments(0 for 1)
  fails "Hash#rehash removes duplicate keys" # Expected 2 to equal 1
  fails "Hash#shift allows shifting entries while iterating" # Exception: Cannot read property '$$is_string' of undefined
  fails "Hash#store does not dispatch to hash for Boolean, Integer, Float, String, or Symbol" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Hash#store keeps the existing String key in the hash if there is a matching one" # Expected "foo" not to be identical to "foo"
  fails "Hash#to_h with block coerces returned pair to Array with #to_ary" # Expected {"a"=>1} == {"b"=>"b"} to be truthy but was false
  fails "Hash#to_h with block converts [key, value] pairs returned by the block to a hash" # Expected {"a"=>1, "b"=>2} == {"a"=>1, "b"=>4} to be truthy but was false
  fails "Hash#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but no exception was raised ({"a"=>1} was returned)
  fails "Hash#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but no exception was raised ({"a"=>1, "b"=>2} was returned)
  fails "Hash#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but no exception was raised ({"a"=>1, "b"=>2} was returned)
  fails "Hash#to_proc the returned proc has an arity of 1" # Expected -1 == 1 to be truthy but was false
  fails "Hash#to_proc the returned proc is a lambda" # Expected #<Proc:0x231fa>.lambda? to be truthy but was false
  fails "Hash#to_s calls #to_s on the object returned from #inspect if the Object isn't a String" # Expected "{\"a\"=>abc}" to equal "{:a=>abc}"
  fails "Hash#to_s does not call #to_s on a String returned from #inspect" # Expected "{\"a\"=>\"abc\"}" to equal "{:a=>\"abc\"}"
  fails "Hash#to_s does not call #to_str on the object returned from #inspect when it is not a String" # Expected "{\"a\"=>#<MockObject:0x1b948>}" to match /^\{:a=>#<MockObject:0x[0-9a-f]+>\}$/
  fails "Hash#to_s does not call #to_str on the object returned from #to_s when it is not a String" # Exception: Cannot convert object to primitive value
  fails "Hash#transform_keys! prevents conflicts between new keys and old ones" # Expected {"e"=>1} to equal {"b"=>1, "c"=>2, "d"=>3, "e"=>4}
  fails "Hash#transform_keys! returns the processed keys if we broke from the block" # Expected {"c"=>1, "d"=>4} to equal {"b"=>1, "c"=>2}
  fails "Hash#update accepts multiple hashes" # ArgumentError: [Hash#merge!] wrong number of arguments(3 for 1)
  fails "Hash#update accepts zero arguments" # ArgumentError: [Hash#merge!] wrong number of arguments(0 for 1)
  fails "Hash.[] raises for elements that are not arrays" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "Hash.ruby2_keywords_hash raises TypeError for non-Hash" # Expected TypeError but got: NoMethodError (undefined method `ruby2_keywords_hash' for Hash)
  fails "Hash.ruby2_keywords_hash returns a copy of a Hash and marks the copy as a keywords Hash" # NoMethodError: undefined method `ruby2_keywords_hash' for Hash
  fails "Hash.ruby2_keywords_hash returns an instance of the subclass if called on an instance of a subclass of Hash" # NoMethodError: undefined method `ruby2_keywords_hash' for Hash
  fails "Hash.ruby2_keywords_hash? raises TypeError for non-Hash" # Expected TypeError but got: NoMethodError (undefined method `ruby2_keywords_hash?' for Hash)
  fails "Hash.ruby2_keywords_hash? returns false if the Hash is not a keywords Hash" # NoMethodError: undefined method `ruby2_keywords_hash?' for Hash
  fails "Hash.ruby2_keywords_hash? returns true if the Hash is a keywords Hash marked by Module#ruby2_keywords" # NoMethodError: undefined method `ruby2_keywords' for #<Class:0x57648>
end
