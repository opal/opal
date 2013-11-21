opal_filter "Struct" do
  fails "Struct#initialize can be overriden"
  fails "Struct.new fails with too many arguments"
  fails "Struct.new creates a constant in subclass' namespace"
  fails "Struct.new raises a TypeError if object is not a Symbol"
  fails "Struct.new raises a TypeError if object doesn't respond to to_sym"
  fails "Struct.new fails with invalid constant name as first argument"
  fails "Struct.new does not create a constant with symbol as first argument"
  fails "Struct.new creates a new anonymous class with nil first argument"
  fails "Struct.new calls to_str on its first argument (constant name)"
end
