# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerator" do
  fails "Enumerator#feed can be called for each iteration" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#feed causes yield to return the value if called during iteration" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#feed raises a TypeError if called more than once without advancing the enumerator" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#feed returns nil" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#feed sets the future return value of yield if called before advancing the iterator" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#feed sets the return value of Yielder#yield" # NotImplementedError: Opal doesn't support Enumerator#feed
  fails "Enumerator#initialize returns self when given a block" # Expected nil to be identical to #<Enumerator: #<Enumerator::Generator:0x4ef82 @block=#<Proc:0x4efa6>>:each>
  fails "Enumerator#initialize sets size to nil if size is not given" # NoMethodError: undefined method `size' for nil
  fails "Enumerator#initialize sets size to nil if the given size is nil" # NoMethodError: undefined method `size' for nil
  fails "Enumerator#initialize sets size to the given size if the given size is Float::INFINITY" # Expected 4 to be identical to Infinity
  fails "Enumerator#initialize sets size to the given size if the given size is a Proc" # NoMethodError: undefined method `size' for nil
  fails "Enumerator#initialize sets size to the given size if the given size is an Integer" # Expected 4 == 100 to be truthy but was false
  fails "Enumerator#inspect returns a not initialized representation if #initialized is not called yet" # NoMethodError: undefined method `any?' for nil
  fails "Enumerator.new no block given raises" # Expected ArgumentError but no exception was raised (#<Enumerator: 1:upto(3)> was returned)
  fails "Enumerator.new when passed a block yielded values handles yield arguments properly" # Expected 1 == [1, 2] to be truthy but was false
  fails "Enumerator.produce creates an infinite enumerator" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce terminates iteration when block raises StopIteration exception" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped starts enumerable from result of first block call" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped uses nil instead" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.product accepts a block" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product accepts a list of enumerators of any length" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product accepts infinite enumerators and returns infinite enumerator" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product calls #each_entry lazily" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product calls only #each_entry method on arguments" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product iterates through consuming enumerator elements only once" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product raises NoMethodError when argument doesn't respond to #each_entry" # Expected NoMethodError (/undefined method `each_entry' for/) but got: NoMethodError (undefined method `product' for Enumerator)
  fails "Enumerator.product reject keyword arguments" # Expected ArgumentError (unknown keywords: :foo, :bar) but got: NoMethodError (undefined method `product' for Enumerator)
  fails "Enumerator.product returns a Cartesian product of enumerators" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product returns an enumerator with an empty array when no arguments passed" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product returns an instance of Enumerator::Product" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator.product returns nil when a block passed" # NoMethodError: undefined method `product' for Enumerator
  fails "Enumerator::ArithmeticSequence.allocate is not defined" # Expected TypeError (allocator undefined for Enumerator::ArithmeticSequence) but no exception was raised (#<Enumerator::ArithmeticSequence>(#pretty_inspect raised #<NoMethodError: undefined method `begin' for nil>) was returned)
  fails "Enumerator::ArithmeticSequence.new is not defined" # Expected NoMethodError but got: ArgumentError ([ArithmeticSequence#initialize] wrong number of arguments (given 0, expected -2))
  fails "Enumerator::Chain#inspect returns a not initialized representation if #initialized is not called yet" # Expected "#<Enumerator::Chain: nil>" == "#<Enumerator::Chain: uninitialized>" to be truthy but was false
  fails "Enumerator::Generator#each returns the block returned value" # Expected #<Enumerator::Generator:0x3f346 @block=#<Proc:0x3f40c>> to be identical to "block_returned"
  fails "Enumerator::Generator#initialize returns self when given a block" # Expected #<Proc:0x3ff5e> to be identical to #<Enumerator::Generator:0x3ff52 @block=#<Proc:0x3ff5e>>
  fails "Enumerator::Lazy defines lazy versions of a whitelist of Enumerator methods" # Expected ["initialize",  "lazy",  "collect",  "collect_concat",  "drop",  "drop_while",  "enum_for",  "find_all",  "grep",  "reject",  "take",  "take_while",  "inspect",  "force",  "filter",  "flat_map",  "map",  "select",  "to_enum"] to include "chunk"
  fails "Enumerator::Lazy#chunk calls the block with gathered values when yield with multiple arguments" # NoMethodError: undefined method `force' for #<Enumerator: #<Enumerator::Generator:0x43cdc @block=#<Proc:0x43cde>>:each>
  fails "Enumerator::Lazy#chunk on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#chunk returns a new instance of Enumerator::Lazy" # Expected #<Enumerator: #<Enumerator::Generator:0x43cc2 @block=#<Proc:0x43cc6>>:each> (Enumerator) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#chunk returns an Enumerator if called without a block" # NoMethodError: undefined method `force' for #<Enumerator: #<Enumerator::Generator:0x43caa @block=#<Proc:0x43cac>>:each>
  fails "Enumerator::Lazy#chunk when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#chunk works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#chunk_while should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x4e058 @block=#<Proc:0x4e05c>>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#chunk_while works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#collect_concat works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#compact returns array without nil elements" # Expected [1, 3, false, 5] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#compact sets #size to nil" # NoMethodError: undefined method `each' for #<Object:0x9caea>
  fails "Enumerator::Lazy#drop on a nested Lazy sets difference of given count with old size to new size" # Expected 20 == 30 to be truthy but was false
  fails "Enumerator::Lazy#drop on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop sets difference of given count with old size to new size" # Expected 20 == 80 to be truthy but was false
  fails "Enumerator::Lazy#drop when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop_while on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop_while when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#drop_while works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#eager does not enumerate an enumerator" # NoMethodError: undefined method `eager' for #<Enumerator::Lazy: [1, 2, 3]>
  fails "Enumerator::Lazy#eager returns a non-lazy Enumerator converted from the lazy enumerator" # NoMethodError: undefined method `eager' for #<Enumerator::Lazy: [1, 2, 3]>
  fails "Enumerator::Lazy#enum_for generates a lazy enumerator from the given name" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#enum_for passes given arguments to wrapped method" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#enum_for works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#filter on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter_map does not map false results" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#filter_map maps only truthy results" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#find_all calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#find_all on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#find_all when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#find_all works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map when the returned lazy enumerator is evaluated by Enumerable#first flattens elements when the given block returned an array or responding to .each and .force" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#flat_map works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#force on a nested Lazy calls all block and returns an Array" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#force passes given arguments to receiver.each" # Expected [[],  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "arg1",  ["arg2", "arg3"],  [],  [0],  [0, 1],  [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "arg1",  ["arg2", "arg3"],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#force works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep calls the block with a gathered array when yield with multiple arguments" # Expected [[],  [],  0,  0,  [0, 1],  [...],  [0, 1, 2],  [...],  [0, 1, 2],  [...],  nil,  nil,  "default_arg",  "default_arg",  [],  [],  [],  [],  [0],  [...],  [0, 1],  [...],  [0, 1, 2],  [...]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#grep on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v calls the block with a gathered array when yield with multiple arguments" # NoMethodError: undefined method `force' for [[nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"], [nil, 0, nil, "default_arg"]]
  fails "Enumerator::Lazy#grep_v on a nested Lazy sets #size to nil" # NoMethodError: undefined method `each' for #<Object:0x7b884>
  fails "Enumerator::Lazy#grep_v on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v returns a new instance of Enumerator::Lazy" # Expected [] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#grep_v sets #size to nil" # NoMethodError: undefined method `each' for #<Object:0x7b738>
  fails "Enumerator::Lazy#grep_v sets $~ in the block" # NoMethodError: undefined method `force' for [nil]
  fails "Enumerator::Lazy#grep_v sets $~ in the next block with each" # Expected #<MatchData "e"> == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v sets $~ in the next block with map" # Expected #<MatchData "e"> == nil to be truthy but was false
  fails "Enumerator::Lazy#grep_v when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times when not given a block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#grep_v works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#initialize returns self" # Expected nil to be identical to #<Enumerator::Lazy: #<Object:0xa73bc>>
  fails "Enumerator::Lazy#initialize sets #size to nil if given size is nil" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets #size to nil if not given a size" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is Float::INFINITY" # Expected 4 to be identical to Infinity
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is a Proc" # NoMethodError: undefined method `size' for nil
  fails "Enumerator::Lazy#initialize sets given size to own size if the given size is an Integer" # Expected 4 == 100 to be truthy but was false
  fails "Enumerator::Lazy#initialize when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # NoMethodError: undefined method `first' for nil
  fails "Enumerator::Lazy#map on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#map when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#map works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#reject calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#reject on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#reject when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#reject works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#select calls the block with a gathered array when yield with multiple arguments" # Expected [nil, 0, 0, 0, 0, nil, "default_arg", [], [], [0], [0, 1], [0, 1, 2]] == [nil,  0,  [0, 1],  [0, 1, 2],  [0, 1, 2],  nil,  "default_arg",  [],  [],  [0],  [0, 1],  [0, 1, 2]] to be truthy but was false
  fails "Enumerator::Lazy#select doesn't over-evaluate when peeked" # NoMethodError: undefined method `length' for #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>>
  fails "Enumerator::Lazy#select doesn't pre-evaluate the next element" # NoMethodError: undefined method `length' for #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>>
  fails "Enumerator::Lazy#select doesn't re-evaluate after peek" # NoMethodError: undefined method `length' for #<Enumerator::Lazy: #<Enumerator::Lazy: #<Enumerator::Lazy: ["Text1", "Text2", "Text3"]>>>
  fails "Enumerator::Lazy#select on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#select when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#select works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_after should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x3305c @block=#<Proc:0x33060>>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_after works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_before should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x66168 @block=#<Proc:0x6616c>>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_before works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#slice_when should return a lazy enumerator" # Expected #<Enumerator: #<Enumerator::Generator:0x86660 @block=#<Proc:0x86664>>:each> (Enumerator) to be kind of Enumerator::Lazy
  fails "Enumerator::Lazy#slice_when works with an infinite enumerable" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#take on a nested Lazy when the returned lazy enumerator is evaluated by .force stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#take on a nested Lazy when the returned lazy enumerator is evaluated by .force stops without iterations if the given argument is 0" # Expected ["before_yield"] == [] to be truthy but was false
  fails "Enumerator::Lazy#take sets given count to size if the old size is Infinity" # Expected Infinity == 20 to be truthy but was false
  fails "Enumerator::Lazy#take when the returned lazy enumerator is evaluated by .force stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#take when the returned lazy enumerator is evaluated by .force stops without iterations if the given argument is 0" # Expected ["before_yield"] == [] to be truthy but was false
  fails "Enumerator::Lazy#take_while on a nested Lazy when the returned lazy enumerator is evaluated by .force stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#take_while when the returned lazy enumerator is evaluated by .force stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#to_enum generates a lazy enumerator from the given name" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#to_enum passes given arguments to wrapped method" # TypeError: can't iterate from Float
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
  fails "Enumerator::Lazy#with_index enumerates with a given block" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#with_index enumerates with an index starting at 0 when offset is nil" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#with_index enumerates with an index starting at a given offset" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#with_index enumerates with an index" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#zip calls the block with a gathered array when yield with multiple arguments" # NoMethodError: undefined method `force' for [[[], []], [0, 0], [[0, 1], [0, 1]], [[0, 1, 2], [0, 1, 2]], [[0, 1, 2], [0, 1, 2]], [nil, nil], ["default_arg", "default_arg"], [[], []], [[], []], [[0], [0]], [[0, 1], [0, 1]], [[0, 1, 2], [0, 1, 2]]]
  fails "Enumerator::Lazy#zip keeps size" # NoMethodError: undefined method `each' for #<Object:0xb6158>
  fails "Enumerator::Lazy#zip on a nested Lazy keeps size" # NoMethodError: undefined method `each' for #<Object:0xb62fe>
  fails "Enumerator::Lazy#zip on a nested Lazy when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#zip raises a TypeError if arguments contain non-list object" # Expected TypeError but got: NoMethodError (undefined method `each' for #<Object:0xb624e>)
  fails "Enumerator::Lazy#zip returns a Lazy when no arguments given" # Expected [[[]], [0], [[0, 1]], [[0, 1, 2]], [[0, 1, 2]], [nil], ["default_arg"], [[]], [[]], [[0]], [[0, 1]], [[0, 1, 2]]] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#zip returns a new instance of Enumerator::Lazy" # Expected [[[], nil], [0, nil], [[0, 1], nil], [[0, 1, 2], nil], [[0, 1, 2], nil], [nil, nil], ["default_arg", nil], [[], nil], [[], nil], [[0], nil], [[0, 1], nil], [[0, 1, 2], nil]] (Array) to be an instance of Enumerator::Lazy
  fails "Enumerator::Lazy#zip when the returned lazy enumerator is evaluated by Enumerable#first stops after specified times" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#zip works with an infinite enumerable and an array" # TypeError: can't iterate from Float
  fails "Enumerator::Lazy#zip works with two infinite enumerables" # TypeError: can't iterate from Float
  fails "SimpleDelegator can be marshalled" # Expected String == SimpleDelegator to be truthy but was false
end
