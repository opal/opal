opal_filter "RNGs" do
  fails "Array#shuffle uses given random generator"
  fails "Array#shuffle uses default random generator"
end
