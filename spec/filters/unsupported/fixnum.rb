opal_unsupported_filter "Fixnum" do
  fails "Fixnum#+ overflows to Bignum when the result does not fit in Fixnum"
  fails "Fixnum#- returns a Bignum only if the result is too large to be a Fixnum"
  fails "Fixnum#<< with n << m returns -1 when n < 0, m < 0 and n > -(2**-m)"
  fails "Fixnum#<< with n << m returns 0 when m < 0 and m is a Bignum"
  fails "Fixnum#<< with n << m returns 0 when n > 0, m < 0 and n < 2**-m"
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_max * 2 when fixnum_max << 1 and n > 0"
  fails "Fixnum#<< with n << m returns a Bignum == fixnum_min * 2 when fixnum_min << 1 and n < 0"
  fails "Fixnum#>> with n >> m returns -1 when n < 0, m > 0 and n > -(2**m)"
  fails "Fixnum#>> with n >> m returns 0 when m is a Bignum"
  fails "Fixnum#>> with n >> m returns 0 when n > 0, m > 0 and n < 2**m"
  fails "Fixnum#>> with n >> m returns a Bignum == fixnum_max * 2 when fixnum_max >> -1 and n > 0"
  fails "Fixnum#>> with n >> m returns a Bignum == fixnum_min * 2 when fixnum_min >> -1 and n < 0"
end
