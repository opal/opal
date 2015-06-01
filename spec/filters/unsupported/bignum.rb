opal_filter "Bignum" do
  fails "Bignum#<= returns false if compares with near float"
  fails "Bignum#| raises a TypeError when passed a Float"
  fails "Bignum#^ raises a TypeError when passed a Float"
  fails "Bignum#<=> with a Float when other is negative returns 0 when other is equal"
  fails "Bignum#<=> with a Float when other is positive returns 0 when other is equal"
  fails "Bignum#/ does NOT raise ZeroDivisionError if other is zero and is a Float"
end

