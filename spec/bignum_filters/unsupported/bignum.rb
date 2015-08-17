opal_filter "Bignum" do
  fails "Bignum#** returns a complex number when negative and raised to a fractional power"
  fails "Bignum#coerce raises a TypeError when passed a Float or String"
end
