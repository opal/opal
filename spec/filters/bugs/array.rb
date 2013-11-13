opal_filter "Array" do
  fails "Array#clone copies singleton methods"
  fails "Array#clone creates a new array containing all elements or the original"

  fails "Array#collect! returns an Enumerator when no block given, and the enumerator can modify the original array"

  fails "Array#combination generates from a defensive copy, ignoring mutations"
  fails "Array#combination yields a partition consisting of only singletons"
  fails "Array#combination yields [] when length is 0"
  fails "Array#combination yields a copy of self if the argument is the size of the receiver"
  fails "Array#combination yields nothing if the argument is out of bounds"
  fails "Array#combination yields the expected combinations"
  fails "Array#combination yields nothing for out of bounds length and return self"
  fails "Array#combination returns self when a block is given"
  fails "Array#combination returns an enumerator when no block is provided"

  fails "Array#<=> calls <=> left to right and return first non-0 result"
  fails "Array#<=> returns -1 if the arrays have same length and a pair of corresponding elements returns -1 for <=>"
  fails "Array#<=> returns +1 if the arrays have same length and a pair of corresponding elements returns +1 for <=>"
  fails "Array#<=> properly handles recursive arrays"
  fails "Array#<=> tries to convert the passed argument to an Array using #to_ary"
  fails "Array#<=> returns nil when the argument is not array-like"

  fails "Array#concat tries to convert the passed argument to an Array using #to_ary"
  fails "Array#concat is not infected by the other"

  fails "Array#delete_at tries to convert the passed argument to an Integer using #to_int"

  fails "Array#delete_if returns an Enumerator if no block given, and the enumerator can modify the original array"

  fails "Array#delete may be given a block that is executed if no element matches object"
  fails "Array#delete returns the last element in the array for which object is equal under #=="

  fails "Array#dup creates a new array containing all elements or the original"

  fails "Array.[] can unpack 2 or more nested referenced array"

  fails "Array#[]= sets elements in the range arguments when passed ranges"

  fails "Array#eql? ignores array class differences"
  fails "Array#eql? handles well recursive arrays"
  fails "Array#eql? returns true if corresponding elements are #eql?"

  fails "Array#== compares with an equivalent Array-like object using #to_ary"
  fails "Array#== handles well recursive arrays"

  fails "Array#fetch tries to convert the passed argument to an Integer using #to_int"
  fails "Array#fetch raises a TypeError when the passed argument can't be coerced to Integer"

  fails "Array#first tries to convert the passed argument to an Integer using #to_int"
  fails "Array#first raises a TypeError if the passed argument is not numeric"

  fails "Array#flatten does not call flatten on elements"
  fails "Array#flatten raises an ArgumentError on recursive arrays"
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

  fails "Array#initialize with (size, object=nil) sets the array to the values returned by the block before break is executed"
  fails "Array#initialize with (size, object=nil) returns the value passed to break"
  fails "Array#initialize with (size, object=nil) uses the block value instead of using the default value"
  fails "Array#initialize with (size, object=nil) yields the index of the element and sets the element to the value of the block"
  fails "Array#initialize with (size, object=nil) raises a TypeError if the size argument is not an Integer type"
  fails "Array#initialize with (size, object=nil) calls #to_int to convert the size argument to an Integer when object is not given"
  fails "Array#initialize with (size, object=nil) calls #to_int to convert the size argument to an Integer when object is given"
  fails "Array#initialize with (size, object=nil) raises an ArgumentError if size is too large"
  fails "Array#initialize with (size, object=nil) sets the array to size and fills with the object"
  fails "Array#initialize with (array) calls #to_ary to convert the value to an array"
  fails "Array#initialize preserves the object's identity even when changing its value"

  fails "Array#insert tries to convert the passed position argument to an Integer using #to_int"

  fails "Array#join raises an ArgumentError when the Array is recursive"
  fails "Array#join raises a NoMethodError if an element does not respond to #to_str, #to_ary, or #to_s"
  fails "Array#join attempts coercion via #to_str first"
  fails "Array#join attempts coercion via #to_ary second"
  fails "Array#join attempts coercion via #to_s third"
  fails "Array#join separates elements with default separator when the passed separator is nil"
  fails "Array#join returns a string formed by concatenating each String element separated by $,"
  fails "Array#join uses the same separator with nested arrays"
  fails "Array#join returns a string formed by concatenating each element.to_str separated by separator"

  fails "Array#& properly handles recursive arrays"
  fails "Array#& tries to convert the passed argument to an Array using #to_ary"
  fails "Array#& determines equivalence between elements in the sense of eql?"

  fails "Array#join calls #to_str to convert the separator to a String"
  fails "Array#join does not call #to_str on the separator if the array is empty"
  fails "Array#join raises a TypeError if the separator cannot be coerced to a String by calling #to_str"
  fails "Array#join raises a TypeError if passed false as the separator"

  fails "Array#last tries to convert the passed argument to an Integer usinig #to_int"

  fails "Array#map! returns an Enumerator when no block given, and the enumerator can modify the original array"

  fails "Array#- removes an identical item even when its #eql? isn't reflexive"
  fails "Array#- doesn't remove an item with the same hash but not #eql?"
  fails "Array#- removes an item identified as equivalent via #hash and #eql?"
  fails "Array#- tries to convert the passed arguments to Arrays using #to_ary"

  fails "Array#* raises a TypeError is the passed argument is nil"
  fails "Array#* converts the passed argument to a String rather than an Integer"
  fails "Array#* raises a TypeError if the argument can neither be converted to a string nor an integer"
  fails "Array#* tires to convert the passed argument to an Integer using #to_int"
  fails "Array#* tries to convert the passed argument to a String using #to_str"
  fails "Array#* with a string uses the same separator with nested arrays"
  fails "Array#* with a string returns a string formed by concatenating each element.to_str separated by separator"

  fails "Array.new with (size, object=nil) raises an ArgumentError if size is too large"
  fails "Array.new with (array) calls #to_ary to convert the value to an array"
  fails "Array.new with (size, object=nil) calls #to_int to convert the size argument to an Integer when object is given"
  fails "Array.new with (size, object=nil) calls #to_int to convert the size argument to an Integer when object is not given"
  fails "Array.new with (size, object=nil) raises a TypeError if the size argument is not an Integer type"

  fails "Array#+ tries to convert the passed argument to an Array using #to_ary"

  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
  fails "Array#pop passed a number n as an argument tries to convert n to an Integer using #to_int"

  fails "Array#rassoc does not check the last element in each contained but speficically the second"
  fails "Array#rassoc calls elem == obj on the second element of each contained array"

  fails "Array#replace tries to convert the passed argument to an Array using #to_ary"

  fails "Array#rindex rechecks the array size during iteration"

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
  fails "Array#shuffle calls #rand on the Object passed by the :random key in the arguments Hash"
  fails "Array#shuffle ignores an Object passed for the RNG if it does not define #rand"
  fails "Array#shuffle accepts a Float for the value returned by #rand"
  fails "Array#shuffle calls #to_int on the Object returned by #rand"
  fails "Array#shuffle raises a RangeError if the value is less than zero"
  fails "Array#shuffle raises a RangeError if the value is equal to one"

  fails "Array#shuffle! returns the same values, in a usually different order"

  fails "Array#slice raises a RangeError when the length is out of range of Fixnum"
  fails "Array#slice raises a RangeError when the start index is out of range of Fixnum"
  fails "Array#slice returns nil if range start is not in the array with [m..n]"
  fails "Array#slice tries to convert Range elements to Integers using #to_int with [m..n] and [m...n]"
  fails "Array#slice accepts Range instances having a negative m and both signs for n with [m..n] and [m...n]"
  fails "Array#slice tries to convert the passed argument to an Integer using #to_int"

  fails "Array#slice! does not expand array with negative indices out of bounds"
  fails "Array#slice! does not expand array with indices out of bounds"
  fails "Array#slice! calls to_int on range arguments"
  fails "Array#slice! removes and return elements in range"
  fails "Array#slice! calls to_int on start and length arguments"

  fails "Array#transpose raises a TypeError if the passed Argument does not respond to #to_ary"
  fails "Array#transpose tries to convert the passed argument to an Array using #to_ary"

  fails "Array.try_convert does not rescue exceptions raised by #to_ary"
  fails "Array.try_convert sends #to_ary to the argument and raises TypeError if it's not a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's a kind of Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's an Array"
  fails "Array.try_convert sends #to_ary to the argument and returns the result if it's nil"

  fails "Array#uniq compares elements based on the value returned from the block"
  fails "Array#uniq compares elements with matching hash codes with #eql?"
  fails "Array#uniq uses eql? semantics"

  fails "Array#uniq! compares elements based on the value returned from the block"
  fails "Array#uniq! properly handles recursive arrays"

  fails "Array#values_at returns an array of elements at the indexes when passed indexes"
  fails "Array#values_at calls to_int on its indices"
  fails "Array#values_at returns an array of elements in the ranges when passes ranges"
  fails "Array#values_at properly handles recursive arrays"
  fails "Array#values_at calls to_int on arguments of ranges when passes ranges"
  fails "Array#values_at does not return subclass instance on Array subclasses"

  fails "Array#zip calls #to_ary to convert the argument to an Array"
  fails "Array#zip uses #each to extract arguments' elements when #to_ary fails"

  fails "Array#hash returns the same value if arrays are #eql?"
  fails "Array#hash returns same hash code for arrays with the same content"
  fails "Array#hash ignores array class differences"
  fails "Array#hash calls to_int on result of calling hash on each element"
  fails "Array#hash returns the same hash for equal recursive arrays through hashes"
  fails "Array#hash returns the same hash for equal recursive arrays"
  fails "Array#hash returns the same fixnum for arrays with the same content"

  fails "Array#initialize_copy tries to convert the passed argument to an Array using #to_ary"
  fails "Array#initialize_copy does not make self dependent to the original array"
  fails "Array#initialize_copy returns self"
  fails "Array#initialize_copy properly handles recursive arrays"
  fails "Array#initialize_copy replaces the elements with elements from other array"

  fails "Array#partition properly handles recursive arrays"
  fails "Array#partition returns in the left array values for which the block evaluates to true"
  fails "Array#partition returns two arrays"
  fails "Array#partition does not return subclass instances on Array subclasses"
end
