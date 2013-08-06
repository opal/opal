opal_filter "Array#combination" do
  fails "Array#combination generates from a defensive copy, ignoring mutations"
  fails "Array#combination yields a partition consisting of only singletons"
  fails "Array#combination yields [] when length is 0"
  fails "Array#combination yields a copy of self if the argument is the size of the receiver"
  fails "Array#combination yields nothing if the argument is out of bounds"
  fails "Array#combination yields the expected combinations"
  fails "Array#combination yields nothing for out of bounds length and return self"
  fails "Array#combination returns self when a block is given"
  fails "Array#combination returns an enumerator when no block is provided"
end
