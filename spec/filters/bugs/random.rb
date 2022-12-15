# NOTE: run bin/format-filters after changing this file
opal_filter "Random" do
  fails "Random#bytes returns the same numeric output for a given huge seed across all implementations and platforms" # Expected "àË" == "_\x91" to be truthy but was false
  fails "Random#bytes returns the same numeric output for a given seed across all implementations and platforms" # Expected "ç\x16" == "\x14\\" to be truthy but was false
  fails "Random#rand with Range returns a float within a given float range" # Expected 51 == 37.454011884736246 to be truthy but was false
  fails "Random#rand with Range supports custom object types" # Expected "NaN#<struct RandomSpecs::CustomRangeInteger value=1>" (String) to be an instance of RandomSpecs::CustomRangeInteger
  fails "Random::DEFAULT changes seed on reboot" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x24f62>
  fails "Random::DEFAULT is deprecated" # Expected #<Random:0x158 @seed=32102, @state=3547213637002595>.equal? Random to be truthy but was false
  fails "Random::DEFAULT refers to the Random class" # Expected #<Random:0x158 @seed=32102, @state=3547213637002595>.equal? Random to be truthy but was false
  fails "SecureRandom.random_number generates a random float number between 0.0 and 1.0 if argument is negative float" # ArgumentError: invalid argument - -11.1
  fails "SecureRandom.random_number generates a random float number between 0.0 and 1.0 if argument is negative" # ArgumentError: invalid argument - -10
  fails "SecureRandom.random_number raises ArgumentError if the argument is non-numeric" # Expected ArgumentError but got: TypeError (no implicit conversion of Object into Integer)  
end
