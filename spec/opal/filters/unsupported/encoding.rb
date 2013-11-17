opal_filter "Encoding" do
  fails "Array#inspect raises if inspected result is not default external encoding"
  fails "Array#inspect use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect use the default external encoding if it is ascii compatible"
  fails "Array#inspect returns a US-ASCII string for an empty Array"
  fails "Array#to_s raises if inspected result is not default external encoding"
  fails "Array#to_s use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s use the default external encoding if it is ascii compatible"
  fails "Array#to_s returns a US-ASCII string for an empty Array"
  fails "Array#join fails for arrays with incompatibly-encoded strings"
  fails "Array#join uses the widest common encoding when other strings are incompatible"
  fails "Array#join uses the first encoding when other strings are compatible"
  fails "Array#join returns a US-ASCII string for an empty Array"
end
