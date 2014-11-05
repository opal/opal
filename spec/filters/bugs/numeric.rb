opal_filter "Fixnum bugs" do
  fails "Integer#downto [stop] when self and stop are Fixnums raises an ArgumentError for invalid endpoints"
  fails "Integer#upto [stop] when self and stop are Fixnums raises an ArgumentError for non-numeric endpoints"
  fails "Integer#even? returns true when self is an even number"

  fails "Fixnum#to_s when no base given returns self converted to a String using base 10"

  fails "Fixnum#zero? returns true if self is 0"
end

opal_filter "Fixnum#<< doesn't handle Bignum and large number checks" do
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_min() * 2 when fixnum_min() << 1 and n < 0"
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_max() * 2 when fixnum_max() << 1 and n > 0"
  fails "Fixnum#<< with n << m returns 0 when m < 0 and m is a Bignum"
  fails "Fixnum#<< with n << m returns 0 when m < 0 and m == p where 2**p > n >= 2**(p-1)"
end

opal_filter "Fixnum#>> doesn't handle Bignum" do
  fails "Fixnum#>> with n >> m returns a Bignum == fixnum_max() * 2 when fixnum_max() >> -1 and n > 0"
  fails "Fixnum#>> with n >> m returns a Bignum == fixnum_min() * 2 when fixnum_min() >> -1 and n < 0"
  fails "Fixnum#>> with n >> m returns 0 when m is a Bignum"
end
