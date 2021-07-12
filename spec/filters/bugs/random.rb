# NOTE: run bin/format-filters after changing this file
opal_filter "Random" do
  fails "Random#bytes returns the same numeric output for a given huge seed across all implementations and platforms" # Expected "z­" to equal "_\u0091"
  fails "Random#bytes returns the same numeric output for a given seed across all implementations and platforms" # Expected "ÚG" to equal "\u0014\\"
  fails "Random#rand with Range supports custom object types" # Expected "NaN#<struct RandomSpecs::CustomRangeInteger value=1>" (String) to be an instance of RandomSpecs::CustomRangeInteger
  fails "Random.raw_seed raises an ArgumentError on a negative size" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a String of the length given as argument" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a String" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a random binary String" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns an ASCII-8BIT String" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random::DEFAULT changes seed on reboot" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Random::DEFAULT is deprecated" # Expected #<Random:0x3e>.equal? Random to be truthy but was false
  fails "Random::DEFAULT refers to the Random class" # Expected #<Random:0x3e>.equal? Random to be truthy but was false
  fails "SecureRandom.random_number generates a random float number between 0.0 and 1.0 if argument is negative float" # ArgumentError: invalid argument - -11.1
  fails "SecureRandom.random_number generates a random float number between 0.0 and 1.0 if argument is negative" # ArgumentError: invalid argument - -10
  fails "SecureRandom.random_number raises ArgumentError if the argument is non-numeric" # Expected ArgumentError but got: TypeError (no implicit conversion of Object into Integer)
end
