# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Struct" do
  fails "Struct#initialize is private" # Expected StructClasses::Car to have private instance method 'initialize' but it does not
  fails "Struct.new does not create a constant with symbol as first argument" # Expected true to be false
  fails "Struct.new fails with invalid constant name as first argument" # Expected NameError but no exception was raised (#<Class:0xa4f0> was returned)
end
