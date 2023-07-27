# NOTE: run bin/format-filters after changing this file
opal_filter "Struct" do
  fails "Struct#dig returns the value by the index" # Expected nil == "one" to be truthy but was false
  fails "Struct#hash returns different hashes for structs with different values when using keyword_init: true" # NameError: wrong constant name 1 non symbol member
  fails "Struct#hash returns the same integer for structs with the same content" # Expected "Hash" (String) to be kind of Integer
  fails "Struct#initialize warns about passing only keyword arguments" # Expected warning to match: /warning: Passing only keyword arguments/ but got: ""
  fails "Struct#to_h with block converts [key, value] pairs returned by the block to a hash" # Expected {"Ford"=>"", "Ranger"=>"", ""=>""} == {"make"=>"ford", "model"=>"ranger", "year"=>""} to be truthy but was false
  fails "Struct-based class#dup retains an included module in the ancestor chain for the struct's singleton class" # NoMethodError: undefined method `hello' for #<Module:0x776e4>
  fails "Struct.new keyword_init: true option raises when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x76a42> was returned)
  fails "Struct.new raises ArgumentError when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x769fa> was returned)
  fails "Struct.new raises a TypeError or ArgumentError if passed a Hash with an unknown key" # Expected StandardError but no exception was raised (#<Class:0x76a0a> was returned)
  fails "StructClass#keyword_init? returns nil for a struct that did not explicitly specify keyword_init" # Expected false to be nil  
  fails_badly "Struct#hash returns different hashes for different struct classes" # A failure in Chromium that once passes, other times it doesn't, most probably related to some kind of undeterminism.
  fails_badly "Struct#hash returns different hashes for structs with different values" # Ditto
end
