opal_filter "Bignum" do
  # Bug: http://de.wikipedia.org/wiki/Division_mit_Rest#Beispiel
  # jsbn implements the naiv way which is executing the division without 
  # signs and adding them afterwards
  # Ruby is implementing the Math way which calculates the signs 
  # in the divison
  fails "Bignum#div returns self divided by other"
  fails "Bignum#div returns a result of integer division of self by a float argument"
  fails "Bignum#/ returns self divided by other"
  fails "Bignum#/ returns self divided by float"
  fails "Bignum#modulo returns the modulus obtained from dividing self by the given argument"
  fails "Bignum#% returns the modulus obtained from dividing self by the given argument"
  fails "Bignum#divmod returns an Array containing quotient and modulus obtained from dividing self by the given argument"
  fails "Bignum#divmod with q = floor(x/y), a = q*b + r, returns [q,r] when a < 0, b > 0 and |a| < b"
  fails "Bignum#divmod with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a > |b|"
  fails "Bignum#divmod with q = floor(x/y), a = q*b + r, returns [q,r] when a > 0, b < 0 and a < |b|"
end
