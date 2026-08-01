# NOTE: run bin/format-filters after changing this file
opal_filter "Complex" do
  fails "Complex#<=> returns 0, 1, or -1 if self and argument do not have imaginary part" # Expected nil == 1 to be truthy but was false
  fails "Complex#coerce returns an array containing other as Complex and self when other is a Numeric which responds to #real? with true" # Expected (#<NumericMockObject:0x1574c @name="other" @null=nil>+0i) to have same value and type as (#<NumericMockObject:0x1574c @name="other" @null=nil>+0i)
  fails "Complex#inspect adds an `*' before the `i' if the last character of the imaginary part is not numeric" # ArgumentError: comparison of NumericSpecs::Subclass with 0 failed
  fails "Complex#inspect calls #inspect on real and imaginary" # ArgumentError: comparison of NumericSpecs::Subclass with 0 failed
  fails "Complex#to_c returns self" # Expected ((1+5i)+0i) to be identical to (1+5i)
  fails "Complex#to_c returns the same value" # Expected ((1+5i)+0i) == (1+5i) to be truthy but was false
  fails "Complex#to_s treats real and imaginary parts as strings" # ArgumentError: comparison of NumericSpecs::Subclass with 0 failed
  fails "Complex.polar computes the real values of the real & imaginary parts from the polar form" # TypeError: not a real
end
