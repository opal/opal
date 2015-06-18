opal_filter "rational_numbers" do
  fails "Kernel.Integer calls to_i on Rationals"
  fails "Kernel#Integer calls to_i on Rationals"
  fails "Kernel#sleep accepts a Rational"
end
