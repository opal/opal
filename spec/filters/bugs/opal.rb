opal_filter "Opal bugs" do
  fails "Array#join raises a NoMethodError if an element does not respond to #to_str, #to_ary, or #to_s"

  # arity checking bugs
  fails "Array#shift passed a number n as an argument raises an ArgumentError if more arguments are passed"
  fails "Array#pop passed a number n as an argument raises an ArgumentError if more arguments are passed"

  # lacking regexp conversion
  fails "String#index with Regexp supports \\G which matches at the given start offset"
  fails "String#index with Regexp starts the search at the given offset"
  fails "String#index with Regexp returns the index of the first match of regexp"

  fails "Kernel#warn requires multiple arguments"
end
