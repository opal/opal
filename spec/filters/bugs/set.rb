# NOTE: run bin/format-filters after changing this file
opal_filter "Set" do
  fails "Set#& raises an ArgumentError when passed a non-Enumerable" # Expected ArgumentError but got: NoMethodError (undefined method `&' for #<Set: {a,b,c}>)
  fails "Set#& returns a new Set containing only elements shared by self and the passed Enumerable" # NoMethodError: undefined method `&' for #<Set: {a,b,c}>
  fails "Set#<=> returns +1 if the set is a proper superset of other set" # Expected nil == 1 to be truthy but was false
  fails "Set#<=> returns -1 if the set is a proper subset of the other set" # Expected nil == -1 to be truthy but was false
  fails "Set#== does not depend on the order of nested Sets" # Expected #<Set: {#<Set:0xb8280>,#<Set:0xb8282>,#<Set:0xb8284>}> == #<Set: {#<Set:0xb828a>,#<Set:0xb828c>,#<Set:0xb828e>}> to be truthy but was false
  fails "Set#== returns true when the passed Object is a Set and self and the Object contain the same elements" # Expected #<Set: {1,2,3}> == #<Set: {1,2,3}> to be falsy but was true
  fails "Set#=== is an alias for include?" # Expected #<Method: Set#=== (defined in Kernel in <internal:corelib/kernel.rb>:13)> == #<Method: Set#include? (defined in Set in ./set.rb:161)> to be truthy but was false
  fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false == true to be truthy but was false
  fails "Set#=== returns true when self contains the passed Object" # Expected false to be true
  fails "Set#^ raises an ArgumentError when passed a non-Enumerable" # Expected ArgumentError but got: NoMethodError (undefined method `^' for #<Set: {1,2,3,4}>)
  fails "Set#^ returns a new Set containing elements that are not in both self and the passed Enumerable" # NoMethodError: undefined method `^' for #<Set: {1,2,3,4}>
  fails "Set#compare_by_identity compares its members by identity" # Expected ["a", "b"] == ["a", "b", "b"] to be truthy but was false
  fails "Set#compare_by_identity is not equal to set what does not compare by identity" # Expected #<Set: {1,2}> == #<Set: {1,2}> to be falsy but was true
  fails "Set#compare_by_identity regards #clone'd objects as having different identities" # Expected ["a"] == ["a", "a"] to be truthy but was false
  fails "Set#compare_by_identity regards #dup'd objects as having different identities" # Expected ["a"] == ["a", "a"] to be truthy but was false
  fails "Set#divide divides self into a set of subsets based on the blocks return values" # NoMethodError: undefined method `divide' for #<Set: {one,two,three,four,five}>
  fails "Set#divide returns an enumerator when not passed a block" # NoMethodError: undefined method `divide' for #<Set: {1,2,3,4}>
  fails "Set#divide when passed a block with an arity of 2 divides self into a set of subsets based on the blocks return values" # NoMethodError: undefined method `divide' for #<Set: {1,3,4,6,9,10,11}>
  fails "Set#divide when passed a block with an arity of 2 returns an enumerator when not passed a block" # NoMethodError: undefined method `divide' for #<Set: {1,2,3,4}>
  fails "Set#divide when passed a block with an arity of 2 yields each two Object to the block" # NoMethodError: undefined method `divide' for #<Set: {1,2}>
  fails "Set#divide when passed a block with an arity of > 2 only uses the first element if the arity = -1" # NoMethodError: undefined method `divide' for #<Set: {one,two,three,four,five}>
  fails "Set#divide when passed a block with an arity of > 2 only uses the first element if the arity > 2" # NoMethodError: undefined method `divide' for #<Set: {one,two,three,four,five}>
  fails "Set#divide yields each Object to the block" # NoMethodError: undefined method `divide' for #<Set: {one,two,three,four,five}>
  fails "Set#flatten raises an ArgumentError when self is recursive" # Expected ArgumentError but got: NoMethodError (undefined method `flatten' for #<Set: {#<Set:0xb7b90>}>)
  fails "Set#flatten returns a copy of self with each included Set flattened" # NoMethodError: undefined method `flatten' for #<Set: {1,2,#<Set:0xb7b9c>,9,10}>
  fails "Set#flatten when Set contains a Set-like object returns a copy of self with each included Set-like object flattened" # NoMethodError: undefined method `flatten' for #<Set: {#<SetSpecs::SetLike:0xb7ba2>}>
  fails "Set#flatten! flattens self" # NoMethodError: undefined method `flatten!' for #<Set: {1,2,#<Set:0xb7bc8>,9,10}>
  fails "Set#flatten! raises an ArgumentError when self is recursive" # Expected ArgumentError but got: NoMethodError (undefined method `flatten!' for #<Set: {#<Set:0xb7bb6>}>)
  fails "Set#flatten! returns nil when self was not modified" # NoMethodError: undefined method `flatten!' for #<Set: {1,2,3,4}>
  fails "Set#flatten! returns self when self was modified" # NoMethodError: undefined method `flatten!' for #<Set: {1,2,#<Set:0xb7bbe>}>
  fails "Set#flatten! when Set contains a Set-like object flattens self, including Set-like objects" # NoMethodError: undefined method `flatten!' for #<Set: {#<SetSpecs::SetLike:0xb7bd2>}>
  fails "Set#flatten_merge flattens the passed Set and merges it into self" # NoMethodError: undefined method `flatten_merge' for #<Set: {1,2}>
  fails "Set#flatten_merge raises an ArgumentError when trying to flatten a recursive Set" # Expected ArgumentError but got: NoMethodError (undefined method `flatten_merge' for #<Set: {1,2,3}>)
  fails "Set#hash is static" # Expected 752958 == 752962 to be truthy but was false
  fails "Set#initialize uses #each on the provided Enumerable if it does not respond to #each_entry" # ArgumentError: value must be enumerable
  fails "Set#initialize uses #each_entry on the provided Enumerable" # ArgumentError: value must be enumerable
  fails "Set#initialize_clone does not freeze the new Set when called from clone(freeze: false)" # FrozenError: can't modify frozen Hash: {1=>true, 2=>true}
  fails "Set#inspect correctly handles cyclic-references" # Expected "#<Set: {#<Set:0x2e8c>}>" to include "#<Set: {...}>"
  fails "Set#inspect does include the elements of the set" # Expected "#<Set: {1}>" == "#<Set: {\"1\"}>" to be truthy but was false
  fails "Set#inspect puts spaces between the elements" # Expected "#<Set: {1,2}>" to include "\", \""
  fails "Set#intersection raises an ArgumentError when passed a non-Enumerable" # Expected ArgumentError but got: NoMethodError (undefined method `intersection' for #<Set: {a,b,c}>)
  fails "Set#intersection returns a new Set containing only elements shared by self and the passed Enumerable" # NoMethodError: undefined method `intersection' for #<Set: {a,b,c}>
  fails "Set#join calls #to_a to convert the Set in to an Array" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join does not separate elements when the passed separator is nil" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns a new string formed by joining elements after conversion" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns a string formed by concatenating each element separated by the separator" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns an empty string if the Set is empty" # NoMethodError: undefined method `join' for #<Set: {}>
  fails "Set#merge raises an ArgumentError when passed a non-Enumerable" # Expected ArgumentError but got: NoMethodError (undefined method `each' for 1)
  fails "Set#pretty_print_cycle passes the 'pretty print' representation of a self-referencing Set to the pretty print writer" # Mock 'PrettyPrint' expected to receive text("#<Set: {...}>") exactly 1 times but received it 0 times
  fails "Set#to_s correctly handles cyclic-references" # Expected "#<Set:0xb920e>" to include "#<Set: {...}>"
  fails "Set#to_s does include the elements of the set" # Expected "#<Set:0xb9246>" == "#<Set: {\"1\"}>" to be truthy but was false
  fails "Set#to_s is an alias of inspect" # Expected #<Method: Set#to_s (defined in Kernel in <internal:corelib/kernel.rb>:768)> == #<Method: Set#inspect (defined in Set in ./set.rb:36)> to be truthy but was false
  fails "Set#to_s puts spaces between the elements" # Expected "#<Set:0xb9274>" to include "\", \""
end
