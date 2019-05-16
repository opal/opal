opal_filter "Float" do
  fails "Float constant MAX is 1.7976931348623157e+308"
  fails "Float constant MIN is 2.2250738585072014e-308"
  fails "Float#divmod returns an [quotient, modulus] from dividing self by other" # precision errors caused by Math.frexp and Math.ldexp
  fails "Float#next_float gives the same result for -0.0 as for +0.0" # NoMethodError: undefined method `next_float' for 0
  fails "Float#next_float returns Float::INFINITY for Float::INFINITY" # NoMethodError: undefined method `next_float' for Infinity
  fails "Float#next_float returns NAN if NAN was the receiver"
  fails "Float#next_float returns a float the smallest possible step greater than the receiver"
  fails "Float#next_float returns negative zero when stepping upward from just below zero"
  fails "Float#next_float reverses the effect of prev_float for all Floats except INFINITY and +0.0" # NoMethodError: undefined method `prev_float' for -0.739980680635199
  fails "Float#next_float steps directly between -1.0 and -1.0 + EPSILON/2"
  fails "Float#next_float steps directly between 1.0 and 1.0 + EPSILON"
  fails "Float#next_float steps directly between MAX and INFINITY"
  fails "Float#prev_float gives the same result for -0.0 as for +0.0" # NoMethodError: undefined method `prev_float' for 0
  fails "Float#prev_float returns -Float::INFINITY for -Float::INFINITY" # NoMethodError: undefined method `prev_float' for -Infinity
  fails "Float#prev_float returns NAN if NAN was the receiver"
  fails "Float#prev_float returns a float the smallest possible step smaller than the receiver"
  fails "Float#prev_float returns positive zero when stepping downward from just above zero"
  fails "Float#prev_float reverses the effect of next_float for all Floats except -INFINITY and -0.0" # NoMethodError: undefined method `next_float' for 0.7192216026596725
  fails "Float#prev_float reverses the effect of next_float"
  fails "Float#prev_float steps directly between -1.0 and -1.0 - EPSILON"
  fails "Float#prev_float steps directly between 1.0 and 1.0 - EPSILON/2"
  fails "Float#prev_float steps directly between MAX and INFINITY"
  fails "Float#rationalize returns self as a simplified Rational with no argument" # precision errors caused by Math.frexp and Math.ldexp
  fails "Float#round returns big values rounded to nearest" # Expected 0 to have same value and type as 300000000000000000000
  fails "Float#round raise for a non-existent round mode" # TypeError: no implicit conversion of Hash into Integer
  fails "Float#round raises FloatDomainError for exceptional values with a half option" # TypeError: no implicit conversion of Hash into Integer
  fails "Float#round rounds self to an optionally given precision with a half option" # ArgumentError: [Number#round] wrong number of arguments(2 for -1)
  fails "Float#to_i returns self truncated to an Integer"
  fails "Float#to_int returns self truncated to an Integer"
  fails "Float#to_s uses e format for a negative value with fractional part having 6 significant figures"
  fails "Float#to_s uses e format for a negative value with whole part having 18 significant figures"
  fails "Float#to_s uses e format for a positive value with fractional part having 6 significant figures"
  fails "Float#to_s uses e format for a positive value with whole part having 18 significant figures"
  fails "Float#to_s uses non-e format for a negative value with whole part having 15 significant figures"
  fails "Float#to_s uses non-e format for a negative value with whole part having 16 significant figures"
  fails "Float#to_s uses non-e format for a negative value with whole part having 17 significant figures"
  fails "Float#to_s uses non-e format for a positive value with whole part having 15 significant figures"
  fails "Float#to_s uses non-e format for a positive value with whole part having 16 significant figures"
  fails "Float#to_s uses non-e format for a positive value with whole part having 17 significant figures"
  fails "Float#to_s matches random examples in all ranges" # Expected "4.9247416523566613e-8" to equal "4.9247416523566613e-08"
  fails "Float#to_s matches random examples in human ranges" # Expected "174" to equal "174.0"
  fails "Float#to_s matches random values from divisions" # Expected "0" to equal "0.0"
  fails "Float#to_s uses e format for a negative value with whole part having 17 significant figures" # Expected "-1000000000000000" to equal "-1.0e+15"
  fails "Float#to_s uses e format for a positive value with whole part having 17 significant figures" # Expected "1000000000000000" to equal "1.0e+15"
  fails "Float#truncate returns self truncated to an Integer"
  fails "Float#round returns different rounded values depending on the half option" # TypeError: no implicit conversion of Hash into Integer
end
