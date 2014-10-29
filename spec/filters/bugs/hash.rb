opal_filter "Hash" do
  fails "Hash.[] coerces a single argument which responds to #to_ary"
  fails "Hash.[] ignores elements that are not arrays"
  fails "Hash.[] calls to_hash"
  fails "Hash.[] returns an instance of a subclass when passed an Array"
  fails "Hash.[] returns instances of subclasses"
  fails "Hash.[] returns an instance of the class it's called on"
  fails "Hash.[] does not call #initialize on the subclass instance"
  fails "Hash.[] passed an array treats elements that are 1 element arrays as keys with value nil"
  fails "Hash.[] passed a single argument which responds to #to_hash coerces it and returns a copy"
  fails "Hash.[] removes the default_proc"

  fails "Hash#assoc only returns the first matching key-value pair for identity hashes"

  fails "Hash#default_proc= uses :to_proc on its argument"

  fails "Hash#each properly expands (or not) child class's 'each'-yielded args"
  fails "Hash#each yields the key only to a block expecting |key,|"

  fails "Hash#each_pair properly expands (or not) child class's 'each'-yielded args"
  fails "Hash#each_pair yields the key only to a block expecting |key,|"

  fails "Hash#== compares the values in self to values in other hash"
  fails "Hash#== returns true iff other Hash has the same number of keys and each key-value pair matches"
  fails "Hash#== compares keys with matching hash codes via eql?"
  fails "Hash#== compares keys with eql? semantics"
  fails "Hash#== computes equality for recursive hashes & arrays"
  fails "Hash#== computes equality for complex recursive hashes"
  fails "Hash#== does not compare keys with different hash codes via eql?"
  fails "Hash#== first compares keys via hash"

  fails "Hash#eql? compares the values in self to values in other hash"
  fails "Hash#eql? returns true iff other Hash has the same number of keys and each key-value pair matches"
  fails "Hash#eql? compares keys with matching hash codes via eql?"
  fails "Hash#eql? compares keys with eql? semantics"
  fails "Hash#eql? computes equality for recursive hashes & arrays"
  fails "Hash#eql? computes equality for complex recursive hashes"
  fails "Hash#eql? does not compare keys with different hash codes via eql?"
  fails "Hash#eql? first compares keys via hash"
  fails "Hash#eql? does not compare values when keys don't match"

  fails "Hash#[] calls subclass implementations of default"
  fails "Hash#[] does not create copies of the immediate default value"
  fails "Hash#[] compares keys with eql? semantics"
  fails "Hash#[] compares key via hash"
  fails "Hash#[] does not compare keys with different #hash values via #eql?"
  fails "Hash#[] compares keys with the same #hash value via #eql?"
  fails "Hash#[] finds a value via an identical key even when its #eql? isn't reflexive"

  fails "Hash#[]= stores unequal keys that hash to the same value"
  fails "Hash#[]= associates the key with the value and return the value"

  fails "Hash#fetch raises an ArgumentError when not passed one or two arguments"

  fails "Hash#flatten recursively flattens Array values to the given depth"
  fails "Hash#flatten raises a TypeError if given a non-Integer argument"

  fails "Hash#hash returns the same hash for recursive hashes through arrays"
  fails "Hash#hash returns the same hash for recursive hashes"
  fails "Hash#hash generates a hash for recursive hash structures"
  fails "Hash#hash returns a value which doesn't depend on the hash order"

  fails "Hash#invert compares new keys with eql? semantics"

  fails "Hash#initialize_copy does not transfer default values"
  fails "Hash#initialize_copy calls to_hash on hash subclasses"
  fails "Hash#initialize_copy tries to convert the passed argument to a hash using #to_hash"
  fails "Hash#initialize_copy replaces the contents of self with other"

  fails "Hash#merge returns subclass instance for subclasses"

  fails "Hash.new raises an ArgumentError if more than one argument is passed"
  fails "Hash.new raises an ArgumentError if passed both default argument and default block"

  fails "Hash#rassoc uses #== to compare the argument to the values"

  fails "Hash#rehash reorganizes the hash by recomputing all key hash codes"

  fails "Hash#reject returns subclass instance for subclasses"
  fails "Hash#reject processes entries with the same order as reject!"
  fails "Hash#reject! removes keys from self for which the block yields true"
  fails "Hash#reject! is equivalent to delete_if if changes are made"
  fails "Hash#reject! returns nil if no changes were made"
  fails "Hash#reject! processes entries with the same order as delete_if"
  fails "Hash#reject! returns an Enumerator if called on a non-empty hash without a block"
  fails "Hash#reject! returns an Enumerator if called on an empty hash without a block"

  fails "Hash#replace tries to convert the passed argument to a hash using #to_hash"
  fails "Hash#replace does not transfer default values"

  fails "Hash#select returns a Hash of entries for which block is true"

  fails "Hash#shift returns (computed) default for empty hashes"

  fails "Hash#store stores unequal keys that hash to the same value"
  fails "Hash#store associates the key with the value and return the value"

  fails "Hash#sort converts self to a nested array of [key, value] arrays and sort with Array#sort"
  fails "Hash#sort works when some of the keys are themselves arrays"
  fails "Hash#sort uses block to sort array if passed a block"

  fails "Hash.try_convert does not rescue exceptions raised by #to_hash"
  fails "Hash.try_convert sends #to_hash to the argument and raises TypeError if it's not a kind of Hash"
  fails "Hash.try_convert sends #to_hash to the argument and returns the result if it's a kind of Hash"
  fails "Hash.try_convert sends #to_hash to the argument and returns the result if it's a Hash"
  fails "Hash.try_convert sends #to_hash to the argument and returns the result if it's nil"
  fails "Hash.try_convert returns nil when the argument does not respond to #to_hash"
  fails "Hash.try_convert returns the argument if it's a kind of Hash"
  fails "Hash.try_convert returns the argument if it's a Hash"
end
