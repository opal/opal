# NOTE: run bin/format-filters after changing this file
opal_filter "Numeric" do
  fails "Numeric#clone raises ArgumentError if passed freeze: false" # Expected ArgumentError (/can't unfreeze/) but no exception was raised (1 was returned)
  fails "Numeric#remainder returns the result of calling self#% with other - other if self is greater than 0 and other is less than 0" # Mock '#<NumericSpecs::Subclass:0x5c1ee>' expected to receive %(#<MockObject:0x5c1f2 @name="Passed Object" @null=nil>) exactly 1 times but received it 0 times
  fails "Numeric#remainder returns the result of calling self#% with other - other if self is less than 0 and other is greater than 0" # Mock '#<NumericSpecs::Subclass:0x5c182>' expected to receive %(#<MockObject:0x5c186 @name="Passed Object" @null=nil>) exactly 1 times but received it 0 times
  fails "Numeric#remainder returns the result of calling self#% with other if self and other are greater than 0" # Mock '#<NumericSpecs::Subclass:0x5c1d0>' expected to receive %(#<MockObject:0x5c1d4 @name="Passed Object" @null=nil>) exactly 1 times but received it 0 times
  fails "Numeric#remainder returns the result of calling self#% with other if self and other are less than 0" # Mock '#<NumericSpecs::Subclass:0x5c1a0>' expected to receive %(#<MockObject:0x5c1a4 @name="Passed Object" @null=nil>) exactly 1 times but received it 0 times
  fails "Numeric#remainder returns the result of calling self#% with other if self is 0" # Mock '#<NumericSpecs::Subclass:0x5c1be>' expected to receive %(#<MockObject:0x5c1c2 @name="Passed Object" @null=nil>) exactly 1 times but received it 0 times
  fails "Numeric#singleton_method_added raises a TypeError when trying to define a singleton method on a Numeric" # Expected TypeError but no exception was raised ("test" was returned)
end
