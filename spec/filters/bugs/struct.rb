# NOTE: run bin/format-filters after changing this file
opal_filter "Struct" do
  fails "Struct#dig returns the value by the index" # Expected nil == "one" to be truthy but was false
  fails "Struct#hash returns different hashes for structs with different values when using keyword_init: true" # NameError: wrong constant name 1 non symbol member
  fails "Struct#hash returns the same integer for structs with the same content" # Expected "Hash" (String) to be kind of Integer
  fails "Struct#to_h with block coerces returned pair to Array with #to_ary" # Expected {"make"=>nil, "model"=>nil, "year"=>nil} == {"b"=>"b"} to be truthy but was false
  fails "Struct#to_h with block converts [key, value] pairs returned by the block to a hash" # Expected {"make"=>"Ford", "model"=>"Ranger", "year"=>nil} == {"make"=>"ford", "model"=>"ranger", "year"=>""} to be truthy but was false
  fails "Struct#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but no exception was raised ({"make"=>nil, "model"=>nil, "year"=>nil} was returned)
  fails "Struct#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but no exception was raised ({"make"=>nil, "model"=>nil, "year"=>nil} was returned)
  fails "Struct#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but no exception was raised ({"make"=>nil, "model"=>nil, "year"=>nil} was returned)
  fails "Struct-based class#dup retains an included module in the ancestor chain for the struct's singleton class"
  fails "Struct.new keyword_init: true option raises when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x294> was returned)
  fails "Struct.new raises ArgumentError when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x256> was returned)
  fails "Struct.new raises a ArgumentError if passed a Hash with an unknown key" # Just like "def m(a: nil); end; m(b: nil)" doesn't raise an error. That's a bug in the handling of kwargs
  fails_badly "Struct#hash returns different hashes for different struct classes" # A failure in Chromium that once passes, other times it doesn't, most probably related to some kind of undeterminism.
  fails_badly "Struct#hash returns different hashes for structs with different values" # Ditto
end
