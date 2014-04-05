opal_filter "Math" do
  fails "Math.erfc returns the complementary error function of the argument"
  fails "Math.ldexp raises a TypeError if the second argument cannot be coerced with Integer()"
end
