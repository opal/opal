opal_filter "Struct" do
  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct-based class#dup retains an included module in the ancestor chain for the struct's singleton class"
end
