opal_filter "Hash" do
  fails "Hash#assoc only returns the first matching key-value pair for identity hashes"

  fails "Hash.[] creates a Hash; values can be provided as a list of value-pairs in an array"
  fails "Hash.[] coerces a single argument which responds to #to_ary"
  fails "Hash.[] ignores elements that are not arrays"
  fails "Hash.[] raises an ArgumentError for arrays of more than 2 elements"
  fails "Hash.[] raises an ArgumentError when passed a list of value-invalid-pairs in an array"
  fails "Hash.[] raises an ArgumentError when passed an odd number of arguments"
  fails "Hash.[] calls to_hash"
  fails "Hash.[] returns an instance of a subclass when passed an Array"
  fails "Hash.[] returns instances of subclasses"
  fails "Hash.[] returns an instance of the class it's called on"
  fails "Hash.[] does not call #initialize on the subclass instance"
  fails "Hash.[] passed an array treats elements that are 2 element arrays as key and value"
  fails "Hash.[] passed an array treats elements that are 1 element arrays as keys with value nil"
  fails "Hash.[] passed a single argument which responds to #to_hash coerces it and returns a copy"

  fails "Hash#default_proc= uses :to_proc on its argument"
  fails "Hash#default_proc= overrides the static default"
  fails "Hash#default_proc= raises an error if passed stuff not convertible to procs"
  fails "Hash#default_proc= raises a TypeError if passed a lambda with an arity other than 2"

  fails "Hash#default uses the default proc to compute a default value, passing given key"
  fails "Hash#default= unsets the default proc"
  fails "Hash#default= raises a RuntimeError if called on a frozen instance"

  fails "Hash#delete_if raises an RuntimeError if called on a frozen instance"

  fails "Hash#delete calls supplied block if the key is not found"
  fails "Hash#delete raises a RuntimeError if called on a frozen instance"

  fails "Hash#each properly expands (or not) child class's 'each'-yielded args"
  fails "Hash#each yields the key only to a block expecting |key,|"

  fails "Hash#each_pair properly expands (or not) child class's 'each'-yielded args"
  fails "Hash#each_pair yields the key only to a block expecting |key,|"

  fails "Hash#[] calls subclass implementations of default"
  fails "Hash#[] does not create copies of the immediate default value"
  fails "Hash#[] compares keys with eql? semantics"
  fails "Hash#[] compares key via hash"
  fails "Hash#[] does not compare keys with different #hash values via #eql?"
  fails "Hash#[] compares keys with the same #hash value via #eql?"
  fails "Hash#[] finds a value via an identical key even when its #eql? isn't reflexive"

  fails "Hash#[]= raises a RuntimeError if called on a frozen instance"
  fails "Hash#[]= duplicates and freezes string keys"
  fails "Hash#[]= stores unequal keys that hash to the same value"
  fails "Hash#[]= associates the key with the value and return the value"

  fails "Hash#fetch raises an ArgumentError when not passed one or two arguments"

  fails "Hash#flatten recursively flattens Array values to the given depth"
  fails "Hash#flatten raises an TypeError if given a non-Integer argument"

  fails "Hash#has_key? compares keys with the same #hash value via #eql?"
  fails "Hash#has_key? returns true if argument is a key"

  fails "Hash#include? compares keys with the same #hash value via #eql?"
  fails "Hash#include? returns true if argument is a key"

  fails "Hash#index compares values using =="

  fails "Hash#invert compares new keys with eql? semantics"

  fails "Hash#keep_if raises an RuntimeError if called on a frozen instance"

  fails "Hash#key? compares keys with the same #hash value via #eql?"
  fails "Hash#key? returns true if argument is a key"

  fails "Hash#key compares values using =="

  fails "Hash#member? compares keys with the same #hash value via #eql?"
  fails "Hash#member? returns true if argument is a key"

  fails "Hash#merge tries to convert the passed argument to a hash using #to_hash"
  fails "Hash#merge returns subclass instance for subclasses"

  fails "Hash#merge! tries to convert the passed argument to a hash using #to_hash"
  fails "Hash#merge! raises a RuntimeError on a frozen instance that is modified"
  fails "Hash#merge! checks frozen status before coercing an object with #to_hash"
  fails "Hash#merge! raises a RuntimeError on a frozen instance that would not be modified"

  fails "Hash.new raises an ArgumentError if more than one argument is passed"
  fails "Hash.new raises an ArgumentError if passed both default argument and default block"

  fails "Hash#rassoc uses #== to compare the argument to the values"

  fails "Hash#reject returns subclass instance for subclasses"
  fails "Hash#reject taints the resulting hash"
  fails "Hash#reject processes entries with the same order as reject!"
  fails "Hash#reject! removes keys from self for which the block yields true"
  fails "Hash#reject! is equivalent to delete_if if changes are made"
  fails "Hash#reject! returns nil if no changes were made"
  fails "Hash#reject! processes entries with the same order as delete_if"
  fails "Hash#reject! raises a RuntimeError if called on a frozen instance that is modified"
  fails "Hash#reject! raises a RuntimeError if called on a frozen instance that would not be modified"
  fails "Hash#reject! returns an Enumerator if called on a non-empty hash without a block"
  fails "Hash#reject! returns an Enumerator if called on an empty hash without a block"
  fails "Hash#reject! returns an Enumerator if called on a frozen instance"

  fails "Hash#replace tries to convert the passed argument to a hash using #to_hash"
  fails "Hash#replace does not transfer default values"
  fails "Hash#replace raises a RuntimeError if called on a frozen instance that is modified"
  fails "Hash#replace raises a RuntimeError if called on a frozen instance that would not be modified"

  fails "Hash#select returns a Hash of entries for which block is true"
  fails "Hash#select! raises a RuntimeError if called on an empty frozen instance"
  fails "Hash#select! raises a RuntimeError if called on a frozen instance that would not be modified"

  fails "Hash#shift returns (computed) default for empty hashes"
  fails "Hash#shift raises a RuntimeError if called on a frozen instance"

  fails "Hash#update raises a RuntimeError on a frozen instance that would not be modified"
  fails "Hash#update checks frozen status before coercing an object with #to_hash"
  fails "Hash#update raises a RuntimeError on a frozen instance that is modified"
  fails "Hash#update tries to convert the passed argument to a hash using #to_hash"
end
