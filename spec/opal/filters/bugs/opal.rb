opal_filter "Opal bugs" do
  fails "Array#join raises a NoMethodError if an element does not respond to #to_str, #to_ary, or #to_s"

  # arity checking bugs
  fails "Array#shift passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"
end
