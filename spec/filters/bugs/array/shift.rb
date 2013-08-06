opal_filter "Array#shift" do
  fails "Array#shift passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#shift passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
  fails "Array#shift passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Array#shift passed a number n as an argument raises an ArgumentError if n is negative"
  fails "Array#shift passed a number n as an argument returns a new empty array if there are no more elements"
end
