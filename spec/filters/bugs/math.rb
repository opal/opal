# NOTE: run bin/format-filters after changing this file
opal_filter "Math" do
  fails "Math.ldexp returns correct value that closes to the max value of double type" # Expected Infinity == 9.207889385574391e+307 to be truthy but was false
  fails "Math.log2 returns the natural logarithm of the argument" # Expected Infinity == 10001 to be truthy but was false  
end
