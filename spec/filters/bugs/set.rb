# NOTE: run bin/format-filters after changing this file
opal_filter "Set" do
  fails "Set#& raises an ArgumentError when passed a non-Enumerable"
  fails "Set#& returns a new Set containing only elements shared by self and the passed Enumerable"
  fails "Set#== does not depend on the order of nested Sets"
  fails "Set#== returns true when the passed Object is a Set and self and the Object contain the same elements"
  fails "Set#=== is an alias for include?" # Expected #<Method: Set#=== (defined in Kernel in corelib/kernel.rb:14)> to equal #<Method: Set#include? (defined in Set in set.rb:125)>
  fails "Set#=== member equality is checked using both #hash and #eql?" # Expected false to equal true
  fails "Set#=== returns true when self contains the passed Object" # Expected false to be true
  fails "Set#^ raises an ArgumentError when passed a non-Enumerable"
  fails "Set#^ returns a new Set containing elements that are not in both self and the passed Enumerable" # NoMethodError: undefined method `^' for #<Set: {1,2,3,4}>
  fails "Set#compare_by_identity causes future comparisons on the receiver to be made by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1}>
  fails "Set#compare_by_identity compares its members by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity does not call #hash on members" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity is idempotent and has no effect on an already compare_by_identity set" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity is not equal to set what does not compare by identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1,2}>
  fails "Set#compare_by_identity persists over #clones" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity persists over #dups" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity regards #clone'd objects as having different identities" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity regards #dup'd objects as having different identities" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity rehashes internally so that old members can be looked up" # NoMethodError: undefined method `compare_by_identity' for #<Set: {1,2,3,4,5,6,7,8,9,10,#<Object:0x13a2>}>
  fails "Set#compare_by_identity returns self" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity uses #equal? semantics, but doesn't actually call #equal? to determine identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity uses the semantics of BasicObject#equal? to determine members identity" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity? returns false by default" # NoMethodError: undefined method `compare_by_identity?' for #<Set: {}>
  fails "Set#compare_by_identity? returns true once #compare_by_identity has been invoked on self" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#compare_by_identity? returns true when called multiple times on the same set" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "Set#divide divides self into a set of subsets based on the blocks return values"
  fails "Set#divide when passed a block with an arity of 2 divides self into a set of subsets based on the blocks return values"
  fails "Set#divide when passed a block with an arity of 2 yields each two Object to the block"
  fails "Set#divide yields each Object to the block"
  fails "Set#filter! keeps every element from self for which the passed block returns true" # NoMethodError: undefined method `filter!' for #<Set: {one,two,three}>
  fails "Set#filter! returns an Enumerator when passed no block" # NoMethodError: undefined method `filter!' for #<Set: {one,two,three}>
  fails "Set#filter! returns nil when self was not modified" # NoMethodError: undefined method `filter!' for #<Set: {one,two,three}>
  fails "Set#filter! returns self when self was modified" # NoMethodError: undefined method `filter!' for #<Set: {one,two,three}>
  fails "Set#filter! yields every element of self" # NoMethodError: undefined method `filter!' for #<Set: {one,two,three}>
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
  fails "Set#inspect correctly handles self-references"
  fails "Set#intersection raises an ArgumentError when passed a non-Enumerable"
  fails "Set#intersection returns a new Set containing only elements shared by self and the passed Enumerable"
  fails "Set#merge raises an ArgumentError when passed a non-Enumerable"
  fails "Set#pretty_print passes the 'pretty print' representation of self to the pretty print writer"
  fails "Set#pretty_print_cycle passes the 'pretty print' representation of a self-referencing Set to the pretty print writer"
  fails "Set#to_s correctly handles self-references" # Expected "#<Set:0x865de>" to include "#<Set: {...}>"
  fails "Set#to_s is an alias of inspect" # Expected #<Method: Set#to_s (defined in Kernel in corelib/kernel.rb:1201)> to equal #<Method: Set#inspect (defined in Set in set.rb:36)>
end
