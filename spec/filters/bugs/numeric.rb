# NOTE: run bin/format-filters after changing this file
opal_filter "Numeric" do
  fails "Numeric#clone does not change frozen status" # Expected false == true to be truthy but was false
  fails "Numeric#clone raises ArgumentError if passed freeze: false" # Expected ArgumentError (/can't unfreeze/) but no exception was raised (1 was returned)
  fails "Numeric#dup does not change frozen status" # Expected false == true to be truthy but was false
  fails "Numeric#remainder returns the result of calling self#% with other - other if self is greater than 0 and other is less than 0"
  fails "Numeric#remainder returns the result of calling self#% with other - other if self is less than 0 and other is greater than 0"
  fails "Numeric#remainder returns the result of calling self#% with other if self and other are greater than 0"
  fails "Numeric#remainder returns the result of calling self#% with other if self and other are less than 0"
  fails "Numeric#remainder returns the result of calling self#% with other if self is 0"
  fails "Numeric#singleton_method_added raises a TypeError when trying to define a singleton method on a Numeric"
  fails "Numeric#step with keyword arguments defaults to an infinite limit with a step size of 1 for Integers" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with keyword arguments defaults to an infinite limit with a step size of 1.0 for Floats" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with keyword arguments when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self < stop" # Expected #<Enumerator: 1:step({"to"=>2, "by"=>3})> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
  fails "Numeric#step with keyword arguments when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self > stop" # Expected #<Enumerator: 1:step({"to"=>0, "by"=>2})> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
  fails "Numeric#step with mixed arguments  raises an ArgumentError when step is 0" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "Numeric#step with mixed arguments defaults to an infinite limit with a step size of 1 for Integers" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with mixed arguments defaults to an infinite limit with a step size of 1.0 for Floats" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with mixed arguments raises an ArgumentError when step is 0.0" # Expected ArgumentError but no exception was raised (nil was returned)
  fails "Numeric#step with mixed arguments when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self < stop" # Expected #<Enumerator: 1:step(2, {"by"=>3})> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
  fails "Numeric#step with mixed arguments when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self > stop" # Expected #<Enumerator: 1:step(0, {"by"=>2})> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
  fails "Numeric#step with positional args defaults to an infinite limit with a step size of 1 for Integers" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with positional args defaults to an infinite limit with a step size of 1.0 for Floats" # Expected [] to equal [1, 2, 3, 4, 5]
  fails "Numeric#step with positional args when no block is given returned Enumerator::ArithmeticSequence type returns an instance of Enumerator::ArithmeticSequence" # Expected Enumerator == Enumerator::ArithmeticSequence to be truthy but was false
  fails "Numeric#step with positional args when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self < stop" # Expected #<Enumerator: 1:step(2, 3)> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
  fails "Numeric#step with positional args when no block is given returns an Enumerator::ArithmeticSequence when not passed a block and self > stop" # Expected #<Enumerator: 1:step(0, 2)> (Enumerator) to be an instance of Enumerator::ArithmeticSequence
end
