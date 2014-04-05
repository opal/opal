opal_filter "Numeric" do
  fails "Integer#downto [stop] when self and stop are Fixnums raises an ArgumentError for invalid endpoints"
end
