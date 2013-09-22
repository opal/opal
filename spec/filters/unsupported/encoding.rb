opal_filter "Encoding" do
  fails "Array#inspect raises if inspected result is not default external encoding"
  fails "Array#inspect use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect use the default external encoding if it is ascii compatible"
  fails "Array#inspect returns a US-ASCII string for an empty Array"
end
