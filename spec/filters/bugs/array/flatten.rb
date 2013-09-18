opal_filter "Array#flatten" do
  fails "Array#flatten does not call flatten on elements"
  fails "Array#flatten raises an ArgumentError on recursive arrays"
  fails "Array#flatten flattens any element which responds to #to_ary, using the return value of said method"
  fails "Array#flatten returns subclass instance for Array subclasses"
  fails "Array#flatten with a non-Array object in the Array ignores the return value of #to_ary if it is nil"
  fails "Array#flatten with a non-Array object in the Array raises a TypeError if the return value of #to_ary is not an Array"
  fails "Array#flatten raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten tries to convert passed Objects to Integers using #to_int"
end

opal_filter "Array#flatten!" do
  fails "Array#flatten! does not call flatten! on elements"
  fails "Array#flatten! raises an ArgumentError on recursive arrays"
  fails "Array#flatten! flattens any elements which responds to #to_ary, using the return value of said method"
  fails "Array#flatten! raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten! tries to convert passed Objects to Integers using #to_int"
end
