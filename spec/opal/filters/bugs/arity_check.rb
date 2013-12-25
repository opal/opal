opal_filter "Wrong arity check" do
  fails "Array#shift passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"
end
