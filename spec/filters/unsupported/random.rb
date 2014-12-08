opal_filter "RNGs" do
  fails "Array#shuffle uses given random generator"
  fails "Array#shuffle uses default random generator"
  fails "Random#bytes returns the same numeric output for a given seed accross all implementations and platforms" 
  fails "Random#bytes returns an ASCII-8BIT String" 
  fails "Random#rand with Bignum typically returns a Bignum"
  fails "Random.new accepts (and converts to Integer) a Rational seed value as an argument" 
  fails "Random.new accepts (and converts to Integer) a Complex (without imaginary part) seed value as an argument" 
  fails "Random.new raises a RangeError if passed a Complex (with imaginary part) seed value as an argument" 
  fails "Random.new uses a random seed value if none is supplied" 
  fails "Random#bytes returns the same numeric output for a given huge seed accross all implementations and platforms" 
  fails "Random.new_seed returns a Bignum" 
  # fails "Random.rand coerces arguments to Integers with #to_int" # much attempt. so tries. very not pass 
end
