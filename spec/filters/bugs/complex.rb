opal_filter "Complex" do
  fails "Rational#** when passed Rational returns a complex number when self is negative and the passed argument is not 0"
  fails "Rational#** when passed Float returns a complex number if self is negative and the passed argument is not 0"
end
