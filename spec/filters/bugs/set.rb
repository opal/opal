# NOTE: run bin/format-filters after changing this file
opal_filter "Set" do
  fails "Set#& raises an ArgumentError when passed a non-Enumerable"
  fails "Set#& returns a new Set containing only elements shared by self and the passed Enumerable"
  fails "Set#<=> returns +1 if the set is a proper superset of other set" # Expected nil == 1 to be truthy but was false
  fails "Set#<=> returns -1 if the set is a proper subset of the other set" # Expected nil == -1 to be truthy but was false
  fails "Set#== does not depend on the order of nested Sets"
  fails "Set#== returns true when the passed Object is a Set and self and the Object contain the same elements"
  fails "Set#=== is an alias for include?" # Expected #<Method: Set#=== (defined in Kernel in corelib/kernel.rb:14)> to equal #<Method: Set#include? (defined in Set in set.rb:125)>
  fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false to equal true
  fails "Set#=== returns true when self contains the passed Object" # Expected false to be true
  fails "Set#^ raises an ArgumentError when passed a non-Enumerable"
  fails "Set#^ returns a new Set containing elements that are not in both self and the passed Enumerable" # NoMethodError: undefined method `^' for #<Set: {1,2,3,4}>
  fails "Set#compare_by_identity compares its members by identity" # Expected ["a", "b"] == ["a", "b", "b"] to be truthy but was false
  fails "Set#compare_by_identity is not equal to set what does not compare by identity" # Expected #<Set: {1,2}> == #<Set: {1,2}> to be falsy but was true
  fails "Set#compare_by_identity regards #clone'd objects as having different identities" # Expected ["a"] == ["a", "a"] to be truthy but was false
  fails "Set#compare_by_identity regards #dup'd objects as having different identities" # Expected ["a"] == ["a", "a"] to be truthy but was false
  fails "Set#divide divides self into a set of subsets based on the blocks return values"
  fails "Set#divide when passed a block with an arity of 2 divides self into a set of subsets based on the blocks return values"
  fails "Set#divide when passed a block with an arity of 2 yields each two Object to the block"
  fails "Set#divide yields each Object to the block"
  fails "Set#flatten raises an ArgumentError when self is recursive"
  fails "Set#flatten returns a copy of self with each included Set flattened"
  fails "Set#flatten when Set contains a Set-like object returns a copy of self with each included Set-like object flattened" # NoMethodError: undefined method `flatten' for #<Set: {#<SetSpecs::SetLike:0x8b30c>}>
  fails "Set#flatten! flattens self"
  fails "Set#flatten! raises an ArgumentError when self is recursive"
  fails "Set#flatten! returns nil when self was not modified"
  fails "Set#flatten! returns self when self was modified"
  fails "Set#flatten! when Set contains a Set-like object flattens self, including Set-like objects" # NoMethodError: undefined method `flatten!' for #<Set: {#<SetSpecs::SetLike:0x8b318>}>
  fails "Set#flatten_merge flattens the passed Set and merges it into self"
  fails "Set#flatten_merge raises an ArgumentError when trying to flatten a recursive Set"
  fails "Set#hash is static"
  fails "Set#initialize uses #each on the provided Enumerable if it does not respond to #each_entry" # ArgumentError: value must be enumerable
  fails "Set#initialize uses #each_entry on the provided Enumerable" # ArgumentError: value must be enumerable
  fails "Set#initialize_clone does not freeze the new Set when called from clone(freeze: false)" # Expected false == true to be truthy but was false
  fails "Set#inspect correctly handles self-references"
  fails "Set#intersection raises an ArgumentError when passed a non-Enumerable"
  fails "Set#intersection returns a new Set containing only elements shared by self and the passed Enumerable"
  fails "Set#join calls #to_a to convert the Set in to an Array" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join does not separate elements when the passed separator is nil" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns a new string formed by joining elements after conversion" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns a string formed by concatenating each element separated by the separator" # NoMethodError: undefined method `join' for #<Set: {a,b,c}>
  fails "Set#join returns an empty string if the Set is empty" # NoMethodError: undefined method `join' for #<Set: {}>
  fails "Set#merge raises an ArgumentError when passed a non-Enumerable"
  fails "Set#pretty_print_cycle passes the 'pretty print' representation of a self-referencing Set to the pretty print writer"
  fails "Set#to_s correctly handles self-references" # Expected "#<Set:0x865de>" to include "#<Set: {...}>"
  fails "Set#to_s is an alias of inspect" # Expected #<Method: Set#to_s (defined in Kernel in corelib/kernel.rb:1201)> to equal #<Method: Set#inspect (defined in Set in set.rb:36)>
end
