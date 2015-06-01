opal_filter "Bignum" do
  # Bug or Feature? MRI ruby returns -1 if result is -0.999. JSBN returns 0 for -0.999
  fails "Bignum#div returns self divided by other"
  fails "Bignum#div returns a result of integer division of self by a float argument"
  fails "Bignum#/ returns self divided by other"
  fails "Bignum#/ returns self divided by float"
end
