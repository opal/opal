opal_filter "Struct" do
  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct#initialize can be overriden"
  fails "Struct#inspect returns a string representation of some kind"
  fails "Struct#members does not override the instance accessor method"
end
