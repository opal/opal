# NOTE: run bin/format-filters after changing this file
opal_filter "Struct" do
  fails "Struct#dig returns the value by the index" # Expected nil == "one" to be truthy but was false
  fails "Struct#hash returns different hashes for structs with different values when using keyword_init: true" # NameError: wrong constant name 1 non symbol member
  fails "Struct#initialize can be initialized with keyword arguments" # Expected "3.2" == {"version"=>"3.2", "platform"=>"OS"} to be truthy but was false
  fails "Struct#inspect does not call #name method when struct is anonymous" # Expected "#<struct #<Class:0x55d36> a=\"\">" == "#<struct a=\"\">" to be truthy but was false
  fails "Struct#to_h with block converts [key, value] pairs returned by the block to a hash" # Expected {"Ford"=>"", "Ranger"=>"", ""=>""} == {"make"=>"ford", "model"=>"ranger", "year"=>""} to be truthy but was false
  fails "Struct#to_s does not call #name method when struct is anonymous" # Expected "#<struct #<Class:0x29fd6> a=\"\">" == "#<struct a=\"\">" to be truthy but was false
  fails "Struct#values_at supports mixing of names and indices" # TypeError: no implicit conversion of String into Integer
  fails "Struct#values_at when passed a list of Integers returns nil value for any integer that is out of range" # Exception: Cannot read properties of undefined (reading '$$is_array')
  fails "Struct#values_at when passed an integer Range fills with nil values for range elements larger than the captured values number" # Exception: Cannot read properties of undefined (reading '$$is_array')
  fails "Struct#values_at when passed an integer Range fills with nil values for range elements larger than the structure" # IndexError: offset 3 too large for struct(size:3)
  fails "Struct#values_at when passed an integer Range raises RangeError if any element of the range is negative and out of range" # Expected RangeError (-4..3 out of range) but got: IndexError (offset -4 too small for struct(size:3))
  fails "Struct#values_at when passed an integer Range returns an empty Array when Range is empty" # Exception: Cannot read properties of undefined (reading '$$is_number')
  fails "Struct#values_at when passed an integer Range supports endless Range" # TypeError: cannot convert endless range to an array
  fails "Struct#values_at when passed names slices captures with the given String names" # TypeError: no implicit conversion of String into Integer
  fails "Struct#values_at when passed names slices captures with the given names" # TypeError: no implicit conversion of String into Integer
  fails "Struct.new keyword_init: true option raises when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x76a42> was returned)
  fails "Struct.new raises ArgumentError when there is a duplicate member" # Expected ArgumentError (duplicate member: foo) but no exception was raised (#<Class:0x769fa> was returned)
  fails "StructClass#keyword_init? returns nil for a struct that did not explicitly specify keyword_init" # Expected false to be nil
  fails "StructClass#keyword_init? returns true for any truthy value, not just for true" # Expected 1 to be true
  fails_badly "Struct#hash returns different hashes for different struct classes" # A failure in Chromium that once passes, other times it doesn't, most probably related to some kind of undeterminism.
  fails_badly "Struct#hash returns different hashes for structs with different values" # Ditto
  fails_badly "Struct#values_at when passed an integer Range supports beginningless Range" # TypeError: cannot convert endless range to an array
end
