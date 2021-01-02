# NOTE: run bin/format-filters after changing this file
opal_filter "OpenStruct" do
  fails "OpenStruct#to_h with block coerces returned pair to Array with #to_ary" # Expected {"name"=>"John Smith", "age"=>70, "pension"=>300} == {"b"=>"b"} to be truthy but was false
  fails "OpenStruct#to_h with block converts [key, value] pairs returned by the block to a hash" # Expected {"name"=>"John Smith", "age"=>70, "pension"=>300} == {"name"=>"John SmithJohn Smith", "age"=>140, "pension"=>600} to be truthy but was false
  fails "OpenStruct#to_h with block does not coerce returned pair to Array with #to_a" # Expected TypeError (/wrong element type MockObject/) but no exception was raised ({"name"=>"John Smith", "age"=>70, "pension"=>300} was returned)
  fails "OpenStruct#to_h with block raises ArgumentError if block returns longer or shorter array" # Expected ArgumentError (/element has wrong array length/) but no exception was raised ({"name"=>"John Smith", "age"=>70, "pension"=>300} was returned)
  fails "OpenStruct#to_h with block raises TypeError if block returns something other than Array" # Expected TypeError (/wrong element type String/) but no exception was raised ({"name"=>"John Smith", "age"=>70, "pension"=>300} was returned)
end
