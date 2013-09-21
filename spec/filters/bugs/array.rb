opal_filter "Array" do
  fails "Array includes Enumerable"
  fails "Array#at raises a TypeError when the passed argument can't be coerced to Integer"

  fails "Array#combination generates from a defensive copy, ignoring mutations"
  fails "Array#combination yields a partition consisting of only singletons"
  fails "Array#combination yields [] when length is 0"
  fails "Array#combination yields a copy of self if the argument is the size of the receiver"
  fails "Array#combination yields nothing if the argument is out of bounds"
  fails "Array#combination yields the expected combinations"
  fails "Array#combination yields nothing for out of bounds length and return self"
  fails "Array#combination returns self when a block is given"
  fails "Array#combination returns an enumerator when no block is provided"

  fails "Array#count returns the number of element for which the block evaluates to true"

  fails "Array#delete_at tries to convert the passed argument to an Integer using #to_int"

  fails "Array#delete_if returns an Enumerator if no block given, and the enumerator can modify the original array"
  fails "Array#delete_if returns an Enumerator if no block given, and the array is frozen"

  fails "Array#delete may be given a block that is executed if no element matches object"
  fails "Array#delete returns the last element in the array for which object is equal under #=="

  fails "Array#drop_while removes elements from the start of the array until the block returns false"
  fails "Array#drop_while removes elements from the start of the array until the block returns nil"
  fails "Array#drop_while removes elements from the start of the array while the block evaluates to true"

  fails "Array#drop raises an ArgumentError if the number of elements specified is negative"

  fails "Array#[]= does not call to_ary on rhs array subclasses for multi-element sets"
  fails "Array#[]= calls to_ary on its rhs argument for multi-element sets"
  fails "Array#[]= raises an IndexError when passed indexes out of bounds"
  fails "Array#[]= tries to convert Range elements to Integers using #to_int with [m..n] and [m...n]"

  fails "Array#[]= with [m..n] accepts Range subclasses"
  fails "Array#[]= with [m..n] inserts the other section at m if m > n"
  fails "Array#[]= with [m..n] replaces the section if m < 0 and n > 0"
  fails "Array#[]= with [m..n] replaces the section if m and n < 0"
  fails "Array#[]= with [m..n] just sets the section defined by range to nil if m and n < 0 and the rhs is nil"

  fails "Array#[]= sets elements in the range arguments when passed ranges"
  fails "Array#[]= checks frozen before attempting to coerce arguments"
  fails "Array#[]= calls to_int on its start and length arguments"
  fails "Array#[]= does nothing if the section defined by range has negative width and the rhs is an empty array"

  fails "Array#eql? returns false if any corresponding elements are not #eql?"

  fails "Array#fetch tries to convert the passed argument to an Integer using #to_int"
  fails "Array#fetch raises a TypeError when the passed argument can't be coerced to Integer"

  fails "Array#first tries to convert the passed argument to an Integer using #to_int"
  fails "Array#first raises a TypeError if the passed argument is not numeric"

  fails "Array#flatten does not call flatten on elements"
  fails "Array#flatten raises an ArgumentError on recursive arrays"
  fails "Array#flatten flattens any element which responds to #to_ary, using the return value of said method"
  fails "Array#flatten returns subclass instance for Array subclasses"
  fails "Array#flatten with a non-Array object in the Array ignores the return value of #to_ary if it is nil"
  fails "Array#flatten with a non-Array object in the Array raises a TypeError if the return value of #to_ary is not an Array"
  fails "Array#flatten raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten tries to convert passed Objects to Integers using #to_int"

  fails "Array#flatten! does not call flatten! on elements"
  fails "Array#flatten! raises an ArgumentError on recursive arrays"
  fails "Array#flatten! flattens any elements which responds to #to_ary, using the return value of said method"
  fails "Array#flatten! raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten! tries to convert passed Objects to Integers using #to_int"
  fails "Array#flatten! should not check modification by size"

  fails "Array#insert tries to convert the passed position argument to an Integer using #to_int"

  fails "Array#& properly handles recursive arrays"
  fails "Array#& tries to convert the passed argument to an Array using #to_ary"
  fails "Array#& determines equivalence between elements in the sense of eql?"

  fails "Array#join calls #to_str to convert the separator to a String"
  fails "Array#join does not call #to_str on the separator if the array is empty"
  fails "Array#join raises a TypeError if the separator cannot be coerced to a String by calling #to_str"
  fails "Array#join raises a TypeError if passed false as the separator"

  fails "Array#last tries to convert the passed argument to an Integer usinig #to_int"

  fails "Array#- removes an identical item even when its #eql? isn't reflexive"
  fails "Array#- doesn't remove an item with the same hash but not #eql?"
  fails "Array#- removes an item identified as equivalent via #hash and #eql?"
  fails "Array#- tries to convert the passed arguments to Arrays using #to_ary"

  fails "Array#* with an integer with a subclass of Array returns a subclass instance"
  fails "Array#* with an integer raises an ArgumentError when passed a negative integer"
  fails "Array#* raises a TypeError is the passed argument is nil"
  fails "Array#* converts the passed argument to a String rather than an Integer"
  fails "Array#* raises a TypeError if the argument can neither be converted to a string nor an integer"
  fails "Array#* tires to convert the passed argument to an Integer using #to_int"
  fails "Array#* tries to convert the passed argument to a String using #to_str"

  fails "Array.new with (size, object=nil) raises an ArgumentError if size is too large"

  fails "Array#+ tries to convert the passed argument to an Array using #to_ary"

  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
  fails "Array#pop passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Array#pop passed a number n as an argument raises an ArgumentError if n is negative"

  fails "Array#rassoc does not check the last element in each contained but speficically the second"
  fails "Array#rassoc calls elem == obj on the second element of each contained array"

  fails "Array#reject! returns an Enumerator if no block given, and the array is frozen"

  fails "Array#rindex rechecks the array size during iteration"
  fails "Array#rindex returns the first index backwards from the end where element == to object"

  fails "Array#select returns a new array of elements for which block is true"

  fails "Array#shift passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#shift passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
  fails "Array#shift passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Array#shift passed a number n as an argument raises an ArgumentError if n is negative"
  fails "Array#shift passed a number n as an argument returns a new empty array if there are no more elements"

  fails "Array#shuffle uses given random generator"
  fails "Array#shuffle uses default random generator"
  fails "Array#shuffle attempts coercion via #to_hash"
  fails "Array#shuffle is not destructive"
  fails "Array#shuffle returns the same values, in a usually different order"

  fails "Array#shuffle! returns the same values, in a usually different order"

  fails "Array#slice! does not expand array with negative indices out of bounds"
  fails "Array#slice! does not expand array with indices out of bounds"
  fails "Array#slice! calls to_int on range arguments"
  fails "Array#slice! removes and return elements in range"
  fails "Array#slice! calls to_int on start and length arguments"

  fails "Array#take raises an ArgumentError when the argument is negative"

  fails "Array#to_a does not return subclass instance on Array subclasses"

  fails "Array.try_convert does not rescue exceptions raised by #to_ary"
  fails "Array.try_convert sends #to_ary to the argument and raises TypeError if it's not a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's an Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's nil"

  fails "Array#uniq compares elements based on the value returned from the block"
  fails "Array#uniq compares elements with matching hash codes with #eql?"
  fails "Array#uniq uses eql? semantics"
  fails "Array#uniq returns subclass instance on Array subclasses"

  fails "Array#uniq! compares elements based on the value returned from the block"
  fails "Array#uniq! properly handles recursive arrays"

  fails "Array#zip calls #to_ary to convert the argument to an Array"
  fails "Array#zip uses #each to extract arguments' elements when #to_ary fails"
end
