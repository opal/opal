opal_filter "Bignum" do
  fails "Bignum#<= returns false if compares with near float"
  fails "Bignum#| raises a TypeError when passed a Float"
  fails "Bignum#^ raises a TypeError when passed a Float"
end

