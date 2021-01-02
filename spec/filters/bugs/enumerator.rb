# NOTE: run bin/format-filters after changing this file
opal_filter "Enumerator" do
  fails "Enumerator#+ calls #each on each argument" # Mock 'obj1' expected to receive each("any_args") exactly 1 times but received it 0 times
  fails "Enumerator#+ returns a chain of self and provided enumerators" # NoMethodError: undefined method `+' for #<Enumerator: #<Enumerator::Generator:0x55192>:each>
  fails "Enumerator#enum_for exposes multi-arg yields as an array"
  fails "Enumerator#feed can be called for each iteration"
  fails "Enumerator#feed causes yield to return the value if called during iteration"
  fails "Enumerator#feed raises a TypeError if called more than once without advancing the enumerator"
  fails "Enumerator#feed returns nil"
  fails "Enumerator#feed sets the future return value of yield if called before advancing the iterator"
  fails "Enumerator#feed sets the return value of Yielder#yield"
  fails "Enumerator#initialize returns self when given a block"
  fails "Enumerator#initialize returns self when given an object"
  fails "Enumerator#initialize sets size to nil if size is not given"
  fails "Enumerator#initialize sets size to nil if the given size is nil"
  fails "Enumerator#initialize sets size to the given size if the given size is Float::INFINITY"
  fails "Enumerator#initialize sets size to the given size if the given size is a Fixnum"
  fails "Enumerator#initialize sets size to the given size if the given size is a Proc"
  fails "Enumerator#initialize sets size to the given size if the given size is an Integer" # Expected 4 == 100 to be truthy but was false
  fails "Enumerator#next restarts the enumerator if an exception terminated a previous iteration" # Expected [#<NoMethodError: undefined method `next' for #<Enumerator: #<Enumerator::Generator:0x4f2>:each>>,  #<NoMethodError: undefined method `next' for #<Enumerator: #<Enumerator::Generator:0x4f2>:each>>] == [#<StandardError: StandardError>, #<StandardError: StandardError>] to be truthy but was false
  fails "Enumerator#next_values advances the position of the current element"
  fails "Enumerator#next_values advances the position of the enumerator each time when called multiple times"
  fails "Enumerator#next_values raises StopIteration if called on a finished enumerator"
  fails "Enumerator#next_values returns an array with only nil if yield is called with nil"
  fails "Enumerator#next_values returns an empty array if yield is called without arguments"
  fails "Enumerator#next_values returns the next element in self"
  fails "Enumerator#next_values works in concert with #rewind"
  fails "Enumerator#peek can be called repeatedly without advancing the position of the current element"
  fails "Enumerator#peek does not advance the position of the current element"
  fails "Enumerator#peek raises StopIteration if called on a finished enumerator"
  fails "Enumerator#peek returns the next element in self"
  fails "Enumerator#peek works in concert with #rewind"
  fails "Enumerator#peek_values can be called repeatedly without advancing the position of the current element"
  fails "Enumerator#peek_values does not advance the position of the current element"
  fails "Enumerator#peek_values raises StopIteration if called on a finished enumerator"
  fails "Enumerator#peek_values returns an array with only nil if yield is called with nil"
  fails "Enumerator#peek_values returns an empty array if yield is called without arguments"
  fails "Enumerator#peek_values returns the next element in self"
  fails "Enumerator#peek_values works in concert with #rewind"
  fails "Enumerator#to_enum exposes multi-arg yields as an array" # NoMethodError: undefined method `next' for #<Enumerator: #<Object:0x53e80>:each>
  fails "Enumerator.new no block given raises" # Expected ArgumentError but no exception was raised (#<Enumerator: 1:upto(3)> was returned)
  fails "Enumerator.new when passed a block defines iteration with block, yielder argument and treating it as a proc" # Expected [] == ["a\n", "b\n", "c"] to be truthy but was false
  fails "Enumerator.new when passed a block yielded values handles yield arguments properly" # Expected 1 == [1, 2] to be truthy but was false
  fails "Enumerator.produce creates an infinite enumerator" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce terminates iteration when block raises StopIteration exception" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped starts enumerable from result of first block call" # NoMethodError: undefined method `produce' for Enumerator
  fails "Enumerator.produce when initial value skipped uses nil instead" # NoMethodError: undefined method `produce' for Enumerator
end
