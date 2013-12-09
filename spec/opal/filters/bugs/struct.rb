opal_filter "Struct" do
  fails "Struct#[] fails when it does not know about the requested attribute"
  fails "Struct#[] fails if not passed a string, symbol, or integer"

  fails "Struct#[]= fails when trying to assign attributes which don't exist"

  fails "Struct#== returns true if the other has all the same fields"
  fails "Struct#== handles recursive structures by returning false if a difference can be found "

  fails "Struct#eql? returns false if any corresponding elements are not #eql?"
  fails "Struct#eql? handles recursive structures by returning false if a difference can be found "

  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct#hash returns the same value if structs are #eql?"
  fails "Struct#hash returns the same hash for recursive structs"

  fails "Struct#to_h returns a Hash with members as keys"
  fails "Struct#to_h returns a Hash that is independent from the struct"

  fails "Struct#initialize can be overriden"

  fails "Struct#inspect returns a string representation of some kind"

  fails "Struct#instance_variables returns an array with one name if an instance variable is added"
  fails "Struct#instance_variables returns an empty array if only attributes are defined"

  fails "Struct.new fails with too many arguments"
  fails "Struct.new creates a constant in subclass' namespace"
  fails "Struct.new raises a TypeError if object is not a Symbol"
  fails "Struct.new raises a TypeError if object doesn't respond to to_sym"
  fails "Struct.new fails with invalid constant name as first argument"
  fails "Struct.new does not create a constant with symbol as first argument"
  fails "Struct.new creates a new anonymous class with nil first argument"
  fails "Struct.new calls to_str on its first argument (constant name)"

  fails "Struct#values_at fails when passed unsupported types"
  fails "Struct#values_at returns an array of values"

  fails "Struct anonymous class instance methods Enumerable methods should work"
end
