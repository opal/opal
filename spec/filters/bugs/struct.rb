opal_filter "Struct" do
  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct-based class#dup retains an included module in the ancestor chain for the struct's singleton class"
  fails "Struct.new raises a ArgumentError if passed a Hash with an unknown key" # Just like "def m(a: nil); end; m(b: nil)" doesn't raise an error. That's a bug in the handling of kwargs
end
