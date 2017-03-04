opal_filter "Random" do
  fails "Random.raw_seed raises an ArgumentError on a negative size" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a String of the length given as argument" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a String" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns a random binary String" # NoMethodError: undefined method `raw_seed' for Random
  fails "Random.raw_seed returns an ASCII-8BIT String" # NoMethodError: undefined method `raw_seed' for Random
end
