opal_filter "Fixnum" do
  fails "Fixnum#/ returns self divided by the given argument"
  fails "Fixnum#/ supports dividing negative numbers"
  fails "Fixnum#/ raises a ZeroDivisionError if the given argument is zero and not a Float"
  fails "Fixnum#/ coerces fixnum and return self divided by other"
  fails "Fixnum#^ returns self bitwise EXCLUSIVE OR other"
  fails "Fixnum#| returns self bitwise OR other"
  fails "Fixnum#& returns self bitwise AND other"
end
