# NOTE: run bin/format-filters after changing this file
opal_filter "Rational" do
  fails "Rational does not respond to new" # Expected NoMethodError but got: ArgumentError ([Rational#initialize] wrong number of arguments (given 1, expected 2))
  fails "Rational#coerce coerces to Rational, when given a Complex" # Expected nil == [(5/1), (3/4)] to be truthy but was false
  fails "Rational#coerce raises an error when passed a BigDecimal" # Expected TypeError (/BigDecimal can't be coerced into Rational/) but no exception was raised (nil was returned)
  fails "Rational#marshal_dump dumps numerator and denominator" # NoMethodError: undefined method `marshal_dump' for (1/2)
  fails "Rational#round with half option raise for a non-existent round mode" # Expected ArgumentError (invalid rounding mode: nonsense) but got: TypeError (not an Integer)
  fails "Rational#round with half option returns a Rational when the precision is greater than 0" # ArgumentError: [Rational#round] wrong number of arguments (given 2, expected -1)
  fails "Rational#round with half option returns an Integer when precision is not passed" # TypeError: not an Integer
  fails "Rational#to_f converts to a Float for large numerator and denominator" # Exception: Maximum call stack size exceeded
  fails "Rational#to_r fails when a BasicObject's to_r does not return a Rational" # Expected TypeError but got: NoMethodError (undefined method `nil?' for #<BasicObject:0x182c8>)
  fails "Rational#to_r raises TypeError trying to convert BasicObject" # Expected TypeError but got: NoMethodError (undefined method `nil?' for #<BasicObject:0x182d0>)
  fails "Rational#to_r works when a BasicObject has to_r" # NoMethodError: undefined method `nil?' for #<BasicObject:0x182d8>
  fails "Rational#truncate with an invalid value for precision does not call to_int on the argument" # Expected TypeError (not an integer) but got: TypeError (not an Integer)
  fails "Rational#truncate with an invalid value for precision raises a TypeError" # Expected TypeError (not an integer) but got: TypeError (not an Integer)
end
