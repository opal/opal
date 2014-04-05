opal_filter "Fixnum bugs" do
  fails "Integer#downto [stop] when self and stop are Fixnums raises a ArgumentError for invalid endpoints"

  fails "Fixnum#to_s when no base given returns self converted to a String using base 10"

  fails "Fixnum#zero? returns true if self is 0"
end

opal_filter "Fixnum#<< doesn't handle non-integers" do
  fails "Fixnum#<< with n << m raises a TypeError when passed a String"
  fails "Fixnum#<< with n << m raises a TypeError when passed nil"
  fails "Fixnum#<< with n << m raises a TypeError when #to_int does not return an Integer"
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_min() * 2 when fixnum_min() << 1 and n < 0"
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_max() * 2 when fixnum_max() << 1 and n > 0"
  fails "Fixnum#<< with n << m returns 0 when m < 0 and m is a Bignum"
  fails "Fixnum#<< with n << m returns 0 when m < 0 and m == p where 2**p > n >= 2**(p-1)"
  fails "Fixnum#<< with n << m returns n shifted right m bits when n < 0, m < 0"
  fails "Fixnum#<< with n << m returns n shifted right m bits when n > 0, m < 0"
end
