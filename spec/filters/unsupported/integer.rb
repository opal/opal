opal_filter "Integer" do
  fails "Integer#even? returns true for a Bignum when it is an even number"
end
