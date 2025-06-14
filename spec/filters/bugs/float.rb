# NOTE: run bin/format-filters after changing this file
opal_filter "Float" do
  fails "Float constant MAX is 1.7976931348623157e+308" # Exception: Maximum call stack size exceeded
  fails "Float constant MIN is 2.2250738585072014e-308" # Expected 5e-324 == (1/4.49423283715579e+307) to be truthy but was false
  fails "Float#<=> raises TypeError when #coerce misbehaves" # Expected TypeError (coerce must return [x, y]) but no exception was raised (nil was returned)
  fails "Float#<=> returns 0 when self is Infinity and other other is infinite?=1" # Expected nil == 0 to be truthy but was false
  fails "Float#<=> returns 1 when self is Infinity and other is infinite?=-1" # Expected nil == 1 to be truthy but was false
  fails "Float#<=> returns 1 when self is Infinity and other is infinite?=nil (which means finite)" # Expected nil == 1 to be truthy but was false
  fails "Float#<=> returns the correct result when one side is infinite" # Expected 0 == 1 to be truthy but was false
  fails "Float#divmod returns an [quotient, modulus] from dividing self by other" # Expected 0 to be within 18446744073709552000 +/- 0.00004
  fails "Float#inspect emits a trailing '.0' for a whole number" # Expected "50" == "50.0" to be truthy but was false
  fails "Float#inspect emits a trailing '.0' for the mantissa in e format" # Expected "100000000000000000000" == "1.0e+20" to be truthy but was false
  fails "Float#inspect encoding returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Float#inspect encoding returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Float#inspect matches random examples in all ranges" # Expected "4.9247416523566613e-8" == "4.9247416523566613e-08" to be truthy but was false
  fails "Float#inspect matches random examples in human ranges" # Expected "174" == "174.0" to be truthy but was false
  fails "Float#inspect matches random values from divisions" # Expected "0" == "0.0" to be truthy but was false
  fails "Float#inspect returns '0.0' for 0.0" # Expected "0" == "0.0" to be truthy but was false
  fails "Float#inspect uses e format for a negative value with fractional part having 6 significant figures" # Expected "-0.00001" == "-1.0e-05" to be truthy but was false
  fails "Float#inspect uses e format for a negative value with whole part having 17 significant figures" # Expected "-1000000000000000" == "-1.0e+15" to be truthy but was false
  fails "Float#inspect uses e format for a negative value with whole part having 18 significant figures" # Expected "-10000000000000000" == "-1.0e+16" to be truthy but was false
  fails "Float#inspect uses e format for a positive value with fractional part having 6 significant figures" # Expected "0.00001" == "1.0e-05" to be truthy but was false
  fails "Float#inspect uses e format for a positive value with whole part having 17 significant figures" # Expected "1000000000000000" == "1.0e+15" to be truthy but was false
  fails "Float#inspect uses e format for a positive value with whole part having 18 significant figures" # Expected "10000000000000000" == "1.0e+16" to be truthy but was false
  fails "Float#inspect uses non-e format for a negative value with whole part having 15 significant figures" # Expected "-10000000000000" == "-10000000000000.0" to be truthy but was false
  fails "Float#inspect uses non-e format for a negative value with whole part having 16 significant figures" # Expected "-100000000000000" == "-100000000000000.0" to be truthy but was false
  fails "Float#inspect uses non-e format for a positive value with whole part having 15 significant figures" # Expected "10000000000000" == "10000000000000.0" to be truthy but was false
  fails "Float#inspect uses non-e format for a positive value with whole part having 16 significant figures" # Expected "100000000000000" == "100000000000000.0" to be truthy but was false
  fails "Float#negative? on negative zero returns false" # Expected true to be false
  fails "Float#rationalize returns self as a simplified Rational with no argument" # Expected (3547048656689661/1048576) == (4806858197361/1421) to be truthy but was false
  fails "Float#round does not lose precision during the rounding process" # ArgumentError: [Number#round] wrong number of arguments (given 2, expected -1)
  fails "Float#round preserves cases where neighbouring floating pointer number increase the decimal places" # ArgumentError: [Number#round] wrong number of arguments (given 2, expected -1)
  fails "Float#round raise for a non-existent round mode" # Expected ArgumentError (invalid rounding mode: nonsense) but got: TypeError (no implicit conversion of Hash into Integer)
  fails "Float#round raises FloatDomainError for exceptional values with a half option" # Expected FloatDomainError but got: TypeError (no implicit conversion of Hash into Integer)
  fails "Float#round returns big values rounded to nearest" # Expected 0 to have same value and type as 300000000000000000000
  fails "Float#round returns different rounded values depending on the half option" # TypeError: no implicit conversion of Hash into Integer
  fails "Float#round rounds self to an optionally given precision with a half option" # ArgumentError: [Number#round] wrong number of arguments (given 2, expected -1)
  fails "Float#round when 0.0 is given returns 0 for 0 or undefined ndigits" # TypeError: no implicit conversion of Hash into Integer
  fails "Float#round when 0.0 is given returns self for positive ndigits" # Expected "0" == "0.0" to be truthy but was false
  fails "Float#to_i raises a FloatDomainError for NaN" # Expected FloatDomainError but no exception was raised (NaN was returned)
  fails "Float#to_int raises a FloatDomainError for NaN" # Expected FloatDomainError but no exception was raised (NaN was returned)
  fails "Float#to_s encoding returns a String in US-ASCII encoding when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Float#to_s encoding returns a String in US-ASCII encoding when Encoding.default_internal is not nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Float#to_s matches random examples in all ranges" # Expected "4.9247416523566613e-8" == "4.9247416523566613e-08" to be truthy but was false
  fails "Float#to_s matches random examples in human ranges" # Expected "174" == "174.0" to be truthy but was false
  fails "Float#to_s matches random values from divisions" # Expected "0" == "0.0" to be truthy but was false
  fails "Float#to_s uses e format for a negative value with fractional part having 6 significant figures" # Expected "-0.00001" == "-1.0e-05" to be truthy but was false
  fails "Float#to_s uses e format for a negative value with whole part having 17 significant figures" # Expected "-1000000000000000" == "-1.0e+15" to be truthy but was false
  fails "Float#to_s uses e format for a negative value with whole part having 18 significant figures" # Expected "-10000000000000000" == "-1.0e+16" to be truthy but was false
  fails "Float#to_s uses e format for a positive value with fractional part having 6 significant figures" # Expected "0.00001" == "1.0e-05" to be truthy but was false
  fails "Float#to_s uses e format for a positive value with whole part having 17 significant figures" # Expected "1000000000000000" == "1.0e+15" to be truthy but was false
  fails "Float#to_s uses e format for a positive value with whole part having 18 significant figures" # Expected "10000000000000000" == "1.0e+16" to be truthy but was false
  fails "Float#to_s uses non-e format for a negative value with whole part having 15 significant figures" # Expected "-10000000000000" == "-10000000000000.0" to be truthy but was false
  fails "Float#to_s uses non-e format for a negative value with whole part having 16 significant figures" # Expected "-100000000000000" == "-100000000000000.0" to be truthy but was false
  fails "Float#to_s uses non-e format for a positive value with whole part having 15 significant figures" # Expected "10000000000000" == "10000000000000.0" to be truthy but was false
  fails "Float#to_s uses non-e format for a positive value with whole part having 16 significant figures" # Expected "100000000000000" == "100000000000000.0" to be truthy but was false
  fails "Float#truncate raises a FloatDomainError for NaN" # Expected FloatDomainError but no exception was raised (NaN was returned)
  fails "Float#truncate returns self truncated to an Integer" # Expected -1 to have same value and type as 0
end
