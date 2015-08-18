opal_filter "Math" do
  fails "Math.erfc accepts any argument that can be coerced with Float()"
  fails "Math.erfc raises a TypeError if the argument cannot be coerced with Float()"
  fails "Math.erfc raises a TypeError if the argument is nil"
  fails "Math.erfc returns NaN given NaN"
  fails "Math.erfc returns a float"
  fails "Math.erfc returns the complementary error function of the argument"
end
