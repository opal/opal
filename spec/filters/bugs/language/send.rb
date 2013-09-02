opal_filter "send" do
  fails "Invoking a private getter method does not permit self as a receiver"
  fails "Invoking a method with manditory and optional arguments raises an ArgumentError if too many values are passed"
  fails "Invoking a method with optional arguments raises ArgumentError if extra arguments are passed"
  fails "Invoking a method passes a literal hash without curly braces or parens"
  fails "Invoking a method passes literal hashes without curly braces as the last parameter"
  fails "Invoking a method raises a SyntaxError with both a literal block and an object as block"
  fails "Invoking a method with an object as a block uses 'to_proc' for coercion"
end
