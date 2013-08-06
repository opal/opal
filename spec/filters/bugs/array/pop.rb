opal_filter "Array#pop" do
  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
  fails "Array#pop passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Array#pop passed a number n as an argument raises an ArgumentError if n is negative"
end
