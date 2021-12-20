# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerator" do
  fails "Enumerator#feed can be called for each iteration"
  fails "Enumerator#feed causes yield to return the value if called during iteration"
  fails "Enumerator#feed raises a TypeError if called more than once without advancing the enumerator"
  fails "Enumerator#feed returns nil"
  fails "Enumerator#feed sets the future return value of yield if called before advancing the iterator"
  fails "Enumerator#feed sets the return value of Yielder#yield"
  fails "Enumerator#initialize returns self when given a block"
  fails "Enumerator#initialize sets size to nil if size is not given"
  fails "Enumerator#initialize sets size to nil if the given size is nil"
  fails "Enumerator#initialize sets size to the given size if the given size is Float::INFINITY"
  fails "Enumerator#initialize sets size to the given size if the given size is a Proc"
  fails "Enumerator#initialize sets size to the given size if the given size is an Integer" # Expected 4 == 100 to be truthy but was false
  fails "Enumerator.new no block given raises" # Expected ArgumentError but no exception was raised (#<Enumerator: 1:upto(3)> was returned)
  fails "Enumerator.new when passed a block yielded values handles yield arguments properly" # Expected 1 == [1, 2] to be truthy but was false
  fails "Enumerator.produce creates an infinite enumerator" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce terminates iteration when block raises StopIteration exception" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped starts enumerable from result of first block call" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped uses nil instead" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator::ArithmeticSequence#hash is based on begin, end, step and exclude_end?" # Expected "A,3,21,3,0" (String) to be an instance of Integer
  fails "Enumerator::ArithmeticSequence.allocate is not defined" # Expected TypeError (allocator undefined for Enumerator::ArithmeticSequence) but no exception was raised (#<Enumerator::ArithmeticSequence>(#pretty_inspect raised #<NoMethodError: undefined method `begin' for nil>) was returned)
  fails "Enumerator::ArithmeticSequence.new is not defined" # Expected NoMethodError but got: ArgumentError ([ArithmeticSequence#initialize] wrong number of arguments (given 0, expected -2))  
  fails "Enumerator::Generator#each returns the block returned value" # Expected #<Enumerator::Generator:0x74c7e> to be identical to "block_returned"
  fails "Enumerator::Generator#initialize returns self when given a block" # Expected #<Proc:0x1b2ee> to be identical to #<Enumerator::Generator:0x1b2e2>
  fails "Enumerator::Lazy defines lazy versions of a whitelist of Enumerator methods" # Expected ["initialize",  "force",  "lazy",  "collect",  "collect_concat",  "drop",  "drop_while",  "enum_for",  "filter",  "find_all",  "flat_map",  "grep",  "map",  "select",  "reject",  "take",  "take_while",  "to_enum",  "inspect"] to include "chunk"
  fails "Enumerator::Lazy#chunk calls the block with gathered values when yield with multiple arguments" # NoMethodError: undefined method `force' for #<Enumerator: #<Enumerator::Generator:0x5dcd4>:each>
  fails "Enumerator::Lazy#chunk on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected 0 == 2 to be truthy but was false
  fails "Enumerator::Lazy#chunk returns a new instance of Enumerator::Lazy" # Expected #<Enumerator: #<Enumerator::Generator:0x5dcbc>:each> (Enumerator) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#chunk returns an Enumerator if called without a block" # NoMethodError: undefined method `force' for #<Enumerator: #<Enumerator::Generator:0x5dc8a>:each>
  fails "Enumerator::Lazy#chunk when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Exception: Object.defineProperty called on non-object
  fails "Enumerator::Lazy#chunk works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#chunk_while should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x5174c>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#chunk_while works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [2, 3, 4] to be truthy but was false
  fails "Enumerator::Lazy#collect when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [1, 2, 3] to be truthy but was false
  fails "Enumerator::Lazy#collect works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # Expected [] == ["0", "1", "0", "2", "0", "3"] to be truthy but was false
  fails "Enumerator::Lazy#collect_concat on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == ["0", "10", "20", "30", "40", "50"] to be truthy but was false
  fails "Enumerator::Lazy#collect_concat when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # Expected [] == ["0", "1", "0", "2", "0", "3"] to be truthy but was false
  fails "Enumerator::Lazy#collect_concat when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == ["0", "10", "20", "30", "40", "50"] to be truthy but was false
  fails "Enumerator::Lazy#collect_concat works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop on a nested Lazy sets difference of given count with old size to new size" # Expected 20 == 30 to be truthy but was false
  fails "Enumerator::Lazy#drop on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [4, 5] to be truthy but was false
  fails "Enumerator::Lazy#drop sets difference of given count with old size to new size" # Expected 20 == 80 to be truthy but was false
  fails "Enumerator::Lazy#drop when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [2, 3] to be truthy but was false
  fails "Enumerator::Lazy#drop works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop_while on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [6, 7] to be truthy but was false
  fails "Enumerator::Lazy#drop_while when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [5, 6] to be truthy but was false
  fails "Enumerator::Lazy#drop_while works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#eager does not enumerate an enumerator" # NoMethodError: undefined method `eager' for #<Enumerator::Lazy: [1, 2, 3]>
  fails "Enumerator::Lazy#eager returns a non-lazy Enumerator converted from the lazy enumerator" # NoMethodError: undefined method `eager' for #<Enumerator::Lazy: [1, 2, 3]>
  fails "Enumerator::Lazy#enum_for generates a lazy enumerator from the given name" # Expected [] == [[0, 10], [1, 11], [2, 12]] to be truthy but was false
  fails "Enumerator::Lazy#enum_for passes given arguments to wrapped method" # Expected [] == [0, 6, 20, 42] to be truthy but was false
  fails "Enumerator::Lazy#enum_for works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter calls the block with a gathered array when yield with multiple arguments" # NoMethodError: undefined method `force' for [[], 0, [0, 1], [0, 1, 2], [0, 1, 2], nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]]
  fails "Enumerator::Lazy#filter on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [6, 8, 10] to be truthy but was false
  fails "Enumerator::Lazy#filter when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [0, 2, 4] to be truthy but was false
  fails "Enumerator::Lazy#filter works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter_map does not map false results" # Expected [] == [1, 3, 5, 7] to be truthy but was false
  fails "Enumerator::Lazy#filter_map maps only truthy results" # Expected [] == [1, 3, 5, 7] to be truthy but was false
  fails "Enumerator::Lazy#find_all calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#find_all on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [6, 8, 10] to be truthy but was false
  fails "Enumerator::Lazy#find_all when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [0, 2, 4] to be truthy but was false
  fails "Enumerator::Lazy#find_all works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # Expected [] == ["0", "1", "0", "2", "0", "3"] to be truthy but was false
  fails "Enumerator::Lazy#flat_map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == ["0", "10", "20", "30", "40", "50"] to be truthy but was false
  fails "Enumerator::Lazy#flat_map when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # Expected [] == ["0", "1", "0", "2", "0", "3"] to be truthy but was false
  fails "Enumerator::Lazy#flat_map when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == ["0", "10", "20", "30", "40", "50"] to be truthy but was false
  fails "Enumerator::Lazy#flat_map works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#force on a nested Lazy calls all block and returns an Array" # Expected [] == [1, 2] to be truthy but was false
  fails "Enumerator::Lazy#force passes given arguments to receiver.each" # Expected [[],  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "arg1",  ["arg2", "arg3"],  [],  [0],  [0, 1],  [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "arg1",  ["arg2", "arg3"],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#force works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep calls the block with a gathered array when yield with multiple arguments" # Expected [[],  [],  0,  0,  [0, 1],  [...],  [0, 1, 2],  [...],  [0, 1, 2],  [...],  nil,  nil,  "default_arg",  "default_arg",  [],  [],  [],  [],  [0],  [...],  [0, 1],  [...],  [0, 1, 2],  [...]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#grep on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # Exception: Object.defineProperty called on non-object
  fails "Enumerator::Lazy#grep on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # Expected [] == [0, 1, 2] to be truthy but was false
  fails "Enumerator::Lazy#grep when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # Expected [] == [1, 2, 3] to be truthy but was false
  fails "Enumerator::Lazy#grep when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # Expected [] == [0, 1, 2] to be truthy but was false
  fails "Enumerator::Lazy#grep works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v calls the block with a gathered array when yield with multiple arguments" # NoMethodError: undefined method `force' for [[nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"]]
  fails "Enumerator::Lazy#grep_v on a nested Lazy sets #size to nil" # Expected 0 == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # Exception: Object.defineProperty called on non-object
  fails "Enumerator::Lazy#grep_v on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # Expected [] == [0, 1, 2] to be truthy but was false
  fails "Enumerator::Lazy#grep_v returns a new instance of Enumerator::Lazy" # Expected [] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#grep_v sets #size to nil" # Expected 0 == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v sets $~ in the block" # NoMethodError: undefined method `force' for [nil]
  fails "Enumerator::Lazy#grep_v sets $~ in the next block with each" # Expected #<MatchData>(#pretty_inspect raised #<NoMethodError: undefined method `named_captures' for /e/>) == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v sets $~ in the next block with map" # Expected #<MatchData>(#pretty_inspect raised #<NoMethodError: undefined method `named_captures' for /e/>) == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # Expected [] == [1, 2, 3] to be truthy but was false
  fails "Enumerator::Lazy#grep_v when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # Expected [] == [0, 1, 2] to be truthy but was false
  fails "Enumerator::Lazy#grep_v works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#initialize returns self" # Expected nil to be identical to #<Enumerator::Lazy: #<Object:0x4d524>>
  fails "Enumerator::Lazy#initialize sets #size to nil if given size is nil" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets #size to nil if not given a size" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is Float::INFINITY" # Expected 4 to be identical to Infinity
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is a Proc" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is an Integer" # Expected 4 == 100 to be truthy but was false
  fails "Enumerator::Lazy#initialize when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # NoMethodError: undefined method `first' for nil
  fails "Enumerator::Lazy#map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [2, 3, 4] to be truthy but was false
  fails "Enumerator::Lazy#map when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [1, 2, 3] to be truthy but was false
  fails "Enumerator::Lazy#map works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#reject calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#reject on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [5, 7, 9] to be truthy but was false
  fails "Enumerator::Lazy#reject when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [1, 3, 5] to be truthy but was false
  fails "Enumerator::Lazy#reject works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#select calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#select doesn't over-evaluate when peeked" # NoMethodError: undefined method `peek' for #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>
  fails "Enumerator::Lazy#select doesn't pre-evaluate the next element" # NoMethodError: undefined method `next' for #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>
  fails "Enumerator::Lazy#select doesn't re-evaluate after peek" # NoMethodError: undefined method `peek' for #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>
  fails "Enumerator::Lazy#select on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [6, 8, 10] to be truthy but was false
  fails "Enumerator::Lazy#select when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [0, 2, 4] to be truthy but was false
  fails "Enumerator::Lazy#select works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_after should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x53eae>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_after works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_before should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x72c3a>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_before works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_when should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x50bb6>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_when works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#take on a nested Lazy when the returned lazy enumerator is evaluated by .force stops after specified times" # Expected [] == [1, 2] to be truthy but was false
  fails "Enumerator::Lazy#take on a nested Lazy when the returned lazy enumerator is evaluated by .force stops without iterations if the given argument is 0" # Expected ["before_yield"] == [] to be truthy but was false
  fails "Enumerator::Lazy#take sets given count to size if the old size is Infinity" # Expected Infinity == 20 to be truthy but was false
  fails "Enumerator::Lazy#take when the returned lazy enumerator is evaluated by .force stops after specified times" # Expected [] == [0, 1] to be truthy but was false
  fails "Enumerator::Lazy#take when the returned lazy enumerator is evaluated by .force stops without iterations if the given argument is 0" # Expected ["before_yield"] == [] to be truthy but was false
  fails "Enumerator::Lazy#take_while on a nested Lazy when the returned lazy enumerator is evaluated by .force stops after specified times" # Expected [] == [0] to be truthy but was false
  fails "Enumerator::Lazy#take_while when the returned lazy enumerator is evaluated by .force stops after specified times" # Expected [] == [0, 1, 2] to be truthy but was false
  fails "Enumerator::Lazy#to_enum generates a lazy enumerator from the given name" # Expected [] == [[0, 10], [1, 11], [2, 12]] to be truthy but was false
  fails "Enumerator::Lazy#to_enum passes given arguments to wrapped method" # Expected [] == [0, 6, 20, 42] to be truthy but was false
  fails "Enumerator::Lazy#to_enum works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#uniq when yielded with an argument return same value after rewind" # NoMethodError: undefined method `force' for [0, 1]
  fails "Enumerator::Lazy#uniq when yielded with an argument returns a lazy enumerator" # Expected [0, 1] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#uniq when yielded with an argument sets the size to nil" # Expected 2 == nil to be truthy but was false
  fails "Enumerator::Lazy#uniq when yielded with multiple arguments return same value after rewind" # NoMethodError: undefined method `force' for [[0, "foo"], [2, "bar"]]
  fails "Enumerator::Lazy#uniq when yielded with multiple arguments returns all yield arguments as an array" # NoMethodError: undefined method `force' for [[0, "foo"], [2, "bar"]]
  fails "Enumerator::Lazy#uniq without block return same value after rewind" # NoMethodError: undefined method `force' for [0, 1]
  fails "Enumerator::Lazy#uniq without block returns a lazy enumerator" # Expected [0, 1] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#uniq without block sets the size to nil" # Expected 2 == nil to be truthy but was false
  fails "Enumerator::Lazy#uniq works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#with_index enumerates with a given block" # Expected [] == [[0, 0], [2, 1], [4, 2]] to be truthy but was false
  fails "Enumerator::Lazy#with_index enumerates with an index starting at 0 when offset is nil" # Expected [] == [[0, 0], [1, 1], [2, 2]] to be truthy but was false
  fails "Enumerator::Lazy#with_index enumerates with an index starting at a given offset" # Expected [] == [[0, 3], [1, 4], [2, 5]] to be truthy but was false
  fails "Enumerator::Lazy#with_index enumerates with an index" # Expected [] == [[0, 0], [1, 1], [2, 2]] to be truthy but was false
  fails "Enumerator::Lazy#zip calls the block with a gathered array when yield with multiple arguments" # NoMethodError: undefined method `force' for [[[], []], [0, 0], [[0, 1], [0, 1]], [[0, 1, 2], [0, 1, 2]], [[0, 1, 2], [0, 1, 2]], [nil, nil], ["default_arg", "default_arg"], [[], []], [[], []], [[0], [0]], [[0, 1], [0, 1]], [[0, 1, 2], [0, 1, 2]]]
  fails "Enumerator::Lazy#zip keeps size" # Expected 0 == 100 to be truthy but was false
  fails "Enumerator::Lazy#zip on a nested Lazy keeps size" # Expected 0 == 100 to be truthy but was false
  fails "Enumerator::Lazy#zip on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [[1, 4, 8], [2, 5, nil]] to be truthy but was false
  fails "Enumerator::Lazy#zip raises a TypeError if arguments contain non-list object" # Expected TypeError but got: NoMethodError (undefined method `each' for #<Object:0x5898c>)
  fails "Enumerator::Lazy#zip returns a Lazy when no arguments given" # Expected [[[]], [0], [[0, 1]], [[0, 1, 2]], [[0, 1, 2]], [nil], ["default_arg"], [[]], [[]], [[0]], [[0, 1]], [[0, 1, 2]]] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#zip returns a new instance of Enumerator::Lazy" # Expected [[[], nil], [0, nil], [[0, 1], nil], [[0, 1, 2], nil], [[0, 1, 2], nil], [nil, nil], ["default_arg", nil], [[], nil], [[], nil], [[0], nil], [[0, 1], nil], [[0, 1, 2], nil]] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#zip when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # Expected [] == [[0, 4, 8], [1, 5, nil]] to be truthy but was false
  fails "Enumerator::Lazy#zip works with an infinite enumerable and an array" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#zip works with two infinite enumerables" # TypeError: can't iterate from Float
end
