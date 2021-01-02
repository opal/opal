# NOTE: run bin/format-filters after changing this file
opal_filter "Struct" do
  fails "Struct#hash returns different hashes for structs with different values when using keyword_init: true" # NameError: wrong constant name 1 non symbol member
  fails "Struct#hash returns different hashes for structs with different values" # Expected "Hash" == "Hash" to be falsy but was true
  fails "Struct#hash returns the same fixnum for structs with the same content"
  fails "Struct#hash returns the same integer for structs with the same content" # Expected "Hash" (String) to be kind of Integer
  fails "Struct-based class#dup retains an included module in the ancestor chain for the struct's singleton class"
  fails "Struct.new keyword_init: true option raises when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x294> was returned)
  fails "Struct.new raises ArgumentError when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x256> was returned)
  fails "Struct.new raises a ArgumentError if passed a Hash with an unknown key" # Just like "def m(a: nil); end; m(b: nil)" doesn't raise an error. That's a bug in the handling of kwargs
end
