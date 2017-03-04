opal_filter "Rational" do
  fails "Rational#marshal_dump dumps numerator and denominator"
  fails "Rational#to_r raises TypeError trying to convert BasicObject" # NoMethodError: undefined method `nil?' for BasicObject
end
