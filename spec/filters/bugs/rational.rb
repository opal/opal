opal_filter "Rational" do
  fails "Rational#marshal_dump is a private method"
  fails "Rational#marshal_dump dumps numerator and denominator"
end
