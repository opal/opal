opal_filter "Symbol" do
  fails "Numeric#coerce raises a TypeError when passed a Symbol"
  fails "Fixnum#coerce raises a TypeError when given an Object that does not respond to #to_f"
end
